require_relative 'models/env'
require 'sinatra'
require "sinatra/reloader" if development?
require 'slim'
require 'bcrypt'
require 'logger'

enable :sessions
logger = Logger.new('log/login_attempts.log')

before do
  if session[:id]
    @current_user = User.find_by_id(session[:id])
  end
end

helpers do
  def admin?
    @current_user && @current_user["rank"] == "admin"
  end

  def protected!
    halt 403, "Not authorized\n" unless admin?
  end
end

get('/') do
  slim(:index)
end

get('/login') do
  if session[:id]
    session.clear
    redirect('/login')
  else
    slim(:login)
  end
end

get('/register') do
  slim(:register)
end

get('/products') do
  @products = Product.all
  slim(:products)
end

get('/products/:id') do
  id = params[:id]
  @product = Product.find_by_id(id)
  slim(:products)
end 

get('/cart') do
  slim(:cart)
end

get('/admin') do
  protected!
  slim(:"admin/admin")
end

get('/admin/dashboard') do
  protected!
  @products = Product.all
  slim(:"admin/dashboard")
end 

get('/admin/users') do
  protected!
  @users = User.all
  slim(:"admin/users")
end

get('/admin/users/edit_user/:id') do
  protected!
  @user = User.find_by_id(params[:id].to_i)
  slim(:"admin/edit_user")
end

get('/admin/dashboard/edit_product/:id') do
  protected!
  @product = Product.find_by_id(params[:id].to_i)
  slim(:"admin/edit_product")
end

post('/login') do
  username = params[:username]
  password = params[:password]

  result = User.find_by_username(username)

  if result.nil?
    logger.info("Failed login attempt for username: #{username}")
    @error = "Användarnamn hittades inte"
    return slim(:login)
  end

  pwdigest = result["pwdigest"]
  id = result["id"]
  rank = result["rank"]

  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    session[:rank] = rank
    logger.info("Successful login for username: #{username}")
    redirect('/products')
  else
    logger.info("Failed login attempt for username: #{username}")
    @error = "FEL LÖSENORD"
    return slim(:login)
  end
end

post('/register') do
  username = params[:username]
  if params[:password] == params[:password_confirm]
    password = params[:password]
  else
    @error = "Lösenorden matchar inte"
    return slim(:register)
  end

  result = User.find_by_username(username)

  if result
    @error = "Användarnamnet är redan taget"
    return slim(:register)
  else
    User.create(username, password)
    redirect('/login')
  end
end

post('/admin/add_product') do
  protected!
  name = params[:name]
  price = params[:price]
  description = params[:description]
  image_url = "/img/placeholder.png"
  stock = params[:stock]
  Product.create(name, price, description, image_url, stock)
  redirect('/admin/dashboard')
end

post('/admin/delete_product') do
  protected!
  id = params[:id]
  Product.delete(id)
  redirect('/admin/dashboard')
end

post('/admin/update_product') do
  protected!
  id = params[:id]
  name = params[:name]
  price = params[:price]
  description = params[:description]
  image_url = params[:image_url]
  stock = params[:stock]
  Product.update(id, name, price, description, image_url, stock)
  redirect('/admin/dashboard')
end

post('/admin/delete_user') do
  protected!
  id = params[:id]
  User.delete(id)
  redirect('/admin/users')
end

post('/admin/update_user') do
  protected!
  id = params[:id]
  username = params[:username]
  if params[:rank].nil?
    rank = User.find_by_id(id)["rank"] 
  else
    rank = params[:rank]
  end
  password = params[:password]

  if password.empty?
    pwdigest = User.find_by_id(id)["pwdigest"]
  else
    pwdigest = BCrypt::Password.create(password)
  end

  User.update(id, username, pwdigest, rank)
  redirect('/admin/users')
end

post('/cart/add') do
  id = params[:product_id]
  product = Product.find_by_id(id)
  session[:cart] ||= []
  session[:cart] << product
  redirect('/products')
end

post('/cart/remove') do
  id = params[:product_id].to_i
  session[:cart] ||= [] 
  session[:cart].delete_if { |product| product["id"].to_i == id }
  redirect('/cart')
end
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
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  @products = db.execute('SELECT * FROM products')
  slim(:products)
end

get('/admin') do
  slim(:admin)
end

get('/admin/dashboard') do
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  @products = db.execute('SELECT * FROM products')
  slim(:dashboard)
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
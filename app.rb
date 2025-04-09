# Sinatra application for an e-commerce website with user authentication
# and product management capabilities
#
# @author Your Name
# @since 0.1.0
require_relative 'models/env'
require 'sinatra'
require "sinatra/reloader" if development?
require 'slim'
require 'bcrypt'
require 'logger'

# Enable session management for user authentication
enable :sessions
# Set up logging for login attempts
# @return [Logger] Logger for tracking login activity
logger = Logger.new('log/login_attempts.log')

# Check if user is logged in before each request
# @note Sets @current_user if a valid session exists
before do
  if session[:id]
    @current_user = User.find_by_id(session[:id])
  end
end

helpers do
  # Check if the current user has admin privileges
  # @return [Boolean] true if current user is an admin, false otherwise
  def admin?
    @current_user && @current_user["rank"] == "admin"
  end

  # Protect routes that require admin privileges
  # @raise [403] if the user isn't an admin
  def protected!
    halt 403, "Not authorized\n" unless admin?
  end
end

# Route for the home page
# @return [String] Rendered index template
get('/') do
  slim(:index)
end

# Route for the login page
# @note Clears the session if a user is already logged in
# @return [String] Rendered login template or redirect
get('/login') do
  if session[:id]
    session.clear
    redirect('/login')
  else
    slim(:login)
  end
end

# Route for the registration page
# @return [String] Rendered register template
get('/register') do
  slim(:register)
end

# Route for viewing all products
# @return [String] Rendered products template with all products
get('/products') do
  @products = Product.all
  slim(:products)
end

# Route for viewing a specific product
# @param id [Integer] The ID of the product to view
# @return [String] Rendered products template with the specified product
get('/products/:id') do
  id = params[:id]
  @product = Product.find_by_id(id)
  slim(:products)
end 

# Route for viewing the cart
# @return [String] Rendered cart template
get('/cart') do
  slim(:cart)
end

# Route for the admin panel home
# @note Requires admin privileges
# @return [String] Rendered admin template
get('/admin') do
  protected!
  slim(:"admin/admin")
end

# Route for the admin dashboard with product management
# @note Requires admin privileges
# @return [String] Rendered dashboard template with all products
get('/admin/dashboard') do
  protected!
  @products = Product.all
  slim(:"admin/dashboard")
end 

# Route for user management in admin panel
# @note Requires admin privileges
# @return [String] Rendered users management template with all users
get('/admin/users') do
  protected!
  @users = User.all
  slim(:"admin/users")
end

# Route for editing a user in admin panel
# @param id [Integer] The ID of the user to edit
# @note Requires admin privileges
# @return [String] Rendered edit user template with the specified user
get('/admin/users/edit_user/:id') do
  protected!
  @user = User.find_by_id(params[:id].to_i)
  slim(:"admin/edit_user")
end

# Route for editing a product in admin panel
# @param id [Integer] The ID of the product to edit
# @note Requires admin privileges
# @return [String] Rendered edit product template with the specified product
get('/admin/dashboard/edit_product/:id') do
  protected!
  @product = Product.find_by_id(params[:id].to_i)
  slim(:"admin/edit_product")
end

# Process login form submission
# @param username [String] The username entered
# @param password [String] The password entered
# @return [String, redirect] Redirect to products on success, error message on failure
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

# Process registration form submission
# @param username [String] The desired username
# @param password [String] The desired password
# @param password_confirm [String] Password confirmation
# @return [String, redirect] Redirect to login on success, error message on failure
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

# Add a new product to the database
# @param name [String] Product name
# @param price [Float] Product price
# @param description [String] Product description
# @param stock [Integer] Product stock quantity
# @note Requires admin privileges
# @return [redirect] Redirect to dashboard
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

# Delete a product from the database
# @param id [Integer] ID of the product to delete
# @note Requires admin privileges
# @return [redirect] Redirect to dashboard
post('/admin/delete_product') do
  protected!
  id = params[:id]
  Product.delete(id)
  redirect('/admin/dashboard')
end

# Update an existing product
# @param id [Integer] ID of the product to update
# @param name [String] Updated product name
# @param price [Float] Updated product price
# @param description [String] Updated product description
# @param image_url [String] Updated product image URL
# @param stock [Integer] Updated product stock quantity
# @note Requires admin privileges
# @return [redirect] Redirect to dashboard
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

# Delete a user from the database
# @param id [Integer] ID of the user to delete
# @note Requires admin privileges
# @return [redirect] Redirect to users management page
post('/admin/delete_user') do
  protected!
  id = params[:id]
  User.delete(id)
  redirect('/admin/users')
end

# Update an existing user
# @param id [Integer] ID of the user to update
# @param username [String] Updated username
# @param rank [String] Updated user rank (admin or user)
# @param password [String] Updated password (optional)
# @note Requires admin privileges
# @note If password is empty, the existing password is kept
# @return [redirect] Redirect to users management page
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

# Add a product to the cart
# @param product_id [Integer] ID of the product to add to cart
# @return [redirect] Redirect to products page
post('/cart/add') do
  id = params[:product_id]
  product = Product.find_by_id(id)
  session[:cart] ||= []
  session[:cart] << product
  redirect('/products')
end

# Remove a product from the cart
# @param product_id [Integer] ID of the product to remove from cart
# @return [redirect] Redirect to cart page
post('/cart/remove') do
  id = params[:product_id].to_i
  session[:cart] ||= [] 
  session[:cart].delete_if { |product| product["id"].to_i == id }
  redirect('/cart')
end
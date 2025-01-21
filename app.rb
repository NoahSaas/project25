require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions


before do
  if request.path_info != '/login' && session[:data].nil?
      redirect '/login'
  end
end


get('/') do
  slim(:index)
end

get('/login') do
  slim(:login)
end

get('/register') do
  slim(:register)
end

get('/clear_session') do
  session.clear
  redirect('/')
end

get('/products') do
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  @products = db.execute('SELECT * FROM products')
  slim(:products)
end

post('/login') do
  username = params[:username]
  password = params[:password]

  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username = ?", [username]).first

  if result.nil?
    @error = "Användarnamn hittades inte"
    return slim(:login)
  end

  pwdigest = result["pwdigest"]
  id = result["id"]

  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    redirect('/')
  else
    @error = "FEL LÖSENORD"
    return slim(:login)
  end
end

post('/register') do

end
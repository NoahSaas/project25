require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
  slim(:index)
end

get('/products') do
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  @products = db.execute('SELECT * FROM products')
  slim(:products)
end

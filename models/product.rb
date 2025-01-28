require 'sqlite3'

class Product
  def self.create(name, price, description, image_url)
    db = SQLite3::Database.new('db/database.db')
    db.execute("INSERT INTO products (name, price, description, image_url, stock) VALUES (?, ?, ?, ?, ?)", [name, price, description, image_url, 0])
  end

  def self.delete(id)
    db = SQLite3::Database.new('db/database.db')
    db.execute("DELETE FROM products WHERE id = ?", id)
  end

  def self.all
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    return db.execute('SELECT * FROM products')
  end

  def self.find_by_id(id)
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    return db.execute('SELECT * FROM products WHERE id = ?', id).first
  end

  def self.update(id, name, price, description, image_url, stock)
    db = SQLite3::Database.new('db/database.db')
    db.execute("UPDATE products SET name = ?, price = ?, description = ?, image_url = ?, stock = ? WHERE id = ?", [name, price, description, image_url, stock, id])
  end
end

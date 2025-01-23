class Product
  def self.create(name, price, description, image_url)
    db = SQLite3::Database.new('db/database.db')
    db.execute("INSERT INTO products (name, price, description, image_url, stock) VALUES (?, ?, ?, ?, ?)", [name, price, description, image_url, 0])
  end

  def self.delete(id)
    db = SQLite3::Database.new('db/database.db')
    db.execute("DELETE FROM products WHERE id = ?", id)
  end
end
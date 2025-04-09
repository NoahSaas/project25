require 'sqlite3'

# Product model for managing product data in the database
#
# @author Your Name
# @since 0.1.0
class Product
  # Creates a new product in the database
  #
  # @param name [String] The name of the product
  # @param price [Float] The price of the product
  # @param description [String] A description of the product
  # @param image_url [String] URL to the product image
  # @param stock [Integer] Available quantity in stock
  # @return [void]
  def self.create(name, price, description, image_url, stock)
    db = SQLite3::Database.new('db/database.db')
    db.execute("INSERT INTO products (name, price, description, image_url, stock) VALUES (?, ?, ?, ?, ?)", [name, price, description, image_url, stock])
  end

  # Deletes a product from the database
  #
  # @param id [Integer] The ID of the product to delete
  # @return [void]
  def self.delete(id)
    db = SQLite3::Database.new('db/database.db')
    db.execute("DELETE FROM products WHERE id = ?", id)
  end

  # Retrieves all products from the database
  #
  # @return [Array<Hash>] Array of product hashes with all product details
  def self.all
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    db.execute('SELECT * FROM products')
  end

  # Finds a product by its ID
  #
  # @param id [Integer] The ID of the product to find
  # @return [Hash, nil] Product details as a hash or nil if not found
  def self.find_by_id(id)
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    db.execute('SELECT * FROM products WHERE id = ?', id).first
  end

  # Updates an existing product in the database
  #
  # @param id [Integer] The ID of the product to update
  # @param name [String] Updated product name
  # @param price [Float] Updated product price
  # @param description [String] Updated product description
  # @param image_url [String] Updated product image URL
  # @param stock [Integer] Updated stock quantity
  # @return [void]
  def self.update(id, name, price, description, image_url, stock)
    db = SQLite3::Database.new('db/database.db')
    db.execute("UPDATE products SET name = ?, price = ?, description = ?, image_url = ?, stock = ? WHERE id = ?", [name, price, description, image_url, stock, id])
  end
end
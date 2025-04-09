require 'sqlite3'
require 'bcrypt'

# User model for managing user data in the database
#
# @author Your Name
# @since 0.1.0
class User
  # Finds a user by their username
  #
  # @param username [String] The username to search for
  # @return [Hash, nil] User details as a hash or nil if not found
  def self.find_by_username(username)
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    db.execute("SELECT * FROM users WHERE username = ?", [username]).first
  end

  # Finds a user by their ID
  #
  # @param id [Integer] The ID of the user to find
  # @return [Hash, nil] User details as a hash or nil if not found
  def self.find_by_id(id)
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    db.execute("SELECT * FROM users WHERE id = ?", [id]).first
  end

  # Creates a new user in the database
  #
  # @param username [String] The username for the new user
  # @param password [String] The password for the new user (will be hashed)
  # @return [void]
  # @note New users are created with the "user" rank by default
  def self.create(username, password)
    db = SQLite3::Database.new('db/database.db')
    pwdigest = BCrypt::Password.create(password)
    db.execute("INSERT INTO users (username, pwdigest, rank) VALUES (?, ?, ?)", [username, pwdigest, "user"])
  end

  # Retrieves all users from the database
  #
  # @return [Array<Hash>] Array of user hashes with all user details
  def self.all
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    db.execute("SELECT * FROM users")
  end

  # Updates an existing user in the database
  #
  # @param id [Integer] The ID of the user to update
  # @param username [String] Updated username
  # @param pwdigest [String] BCrypt password digest
  # @param rank [String] User rank (e.g., "user" or "admin")
  # @return [void]
  def self.update(id, username, pwdigest, rank)
    db = SQLite3::Database.new('db/database.db')
    db.execute("UPDATE users SET username = ?, pwdigest = ?, rank = ? WHERE id = ?", [username, pwdigest, rank, id])
  end

  # Deletes a user from the database
  #
  # @param id [Integer] The ID of the user to delete
  # @return [void]
  def self.delete(id)
    db = SQLite3::Database.new('db/database.db')
    db.execute("DELETE FROM users WHERE id = ?", [id])
  end
end
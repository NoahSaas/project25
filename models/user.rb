require 'sqlite3'
require 'bcrypt'

class User
  def self.find_by_username(username)
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    db.execute("SELECT * FROM users WHERE username = ?", [username]).first
  end

  def self.find_by_id(id)
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    db.execute("SELECT * FROM users WHERE id = ?", [id]).first
  end

  def self.create(username, password)
    db = SQLite3::Database.new('db/database.db')
    pwdigest = BCrypt::Password.create(password)
    db.execute("INSERT INTO users (username, pwdigest, rank) VALUES (?, ?, ?)", [username, pwdigest, "admin"])
  end

  def self.all
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    db.execute("SELECT * FROM users")
  end

  def self.update(id, username, pwdigest, rank)
    db = SQLite3::Database.new('db/database.db')
<<<<<<< Updated upstream
    pwdigest = password
=======
>>>>>>> Stashed changes
    db.execute("UPDATE users SET username = ?, pwdigest = ?, rank = ? WHERE id = ?", [username, pwdigest, rank, id])
  end

  def self.delete(id)
    db = SQLite3::Database.new('db/database.db')
    db.execute("DELETE FROM users WHERE id = ?", [id])
  end
end

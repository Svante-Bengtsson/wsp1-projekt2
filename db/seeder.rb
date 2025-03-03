require 'sqlite3'

class Seeder

  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS strats')
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('DROP TABLE IF EXISTS games')
  end

  def self.create_tables
    db.execute('
      CREATE TABLE strats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        rating_tot INTEGER NOT NULL DEFAULT 0,
        rating_amount INTEGER DEFAULT 1,
        user_id INTEGER NOT NULL,
        game_id INTEGER NOT NULL
      )
    ')
    db.execute('
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL
      )
    ')
    db.execute('
      CREATE TABLE games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ')
  end

  def self.populate_tables
    db.execute('INSERT INTO games (name, description) VALUES ("gloober", "fing feng huan shi")')
    db.execute('INSERT INTO strats (name, description, rating_tot, user_id, game_id) VALUES ("gloob", "ma schloob", 0, 1, 1)')
    db.execute('INSERT INTO strats (name, description, rating_tot, user_id, game_id) VALUES ("goop", "ma schoop", 0, 1, 1)')
  end
  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/stratroulette.sqlite')
    @db.results_as_hash = true
    @db
  end
end

Seeder.seed!
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
    db.execute('DROP TABLE IF EXISTS gametags')
    db.execute('DROP TABLE IF EXISTS tags')
    db.execute('DROP TABLE IF EXISTS logins')
  end

  def self.create_tables
    db.execute('
      CREATE TABLE strats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        rating_tot INTEGER NOT NULL DEFAULT 0,
        rating_amount INTEGER DEFAULT 0,
        user_id INTEGER NOT NULL,
        game_id INTEGER NOT NULL
      )
    ')
    db.execute('
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        admin INTEGER DEFAULT 0
      )
    ')
    db.execute('
      CREATE TABLE games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ')
    db.execute('
      CREATE TABLE gametags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL
      )
    ')
    db.execute('
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ')
    db.execute('
      CREATE TABLE logins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )')

  end

  def self.populate_tables
    db.execute('INSERT INTO games (name, description) VALUES ("gloober", "fing feng huan shi")')
    db.execute('INSERT INTO strats (name, description, rating_tot, user_id, game_id) VALUES ("gloob", "ma schloob", 0, 1, 1)')
    db.execute('INSERT INTO strats (name, description, rating_tot, user_id, game_id) VALUES ("goop", "ma schoop", 0, 1, 1)')
    db.execute('INSERT INTO users (name, password_hash, admin) VALUES ("admin", ?, TRUE)', "$2a$12$mqGpcE016gCJ19NYwFRaAelRJzgMBsdK7Aj8cS4SvOrOHoz5WxF/K")
    db.execute('INSERT INTO tags (name, description) VALUES ("fps", "shooty, shooty, bang bang")')
    db.execute('INSERT INTO gametags (game_id, tag_id) VALUES (1, 1)')
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
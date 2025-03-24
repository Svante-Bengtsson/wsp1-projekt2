class User
    def self.all(db)
        return db.execute('SELECT * FROM users')
    end

    def self.selectFromName(db, name)
        return db.execute('SELECT * FROM users WHERE name = ?', name)
    end

    def self.selectFromId(db, id)
        return db.execute('SELECT * FROM users WHERE id = ?', id)
    end

    def self.create(db, name, password_hashed)
        db.execute("INSERT INTO users (name, password_hash) VALUES (?, ?)",[name, password_hashed])
    end
    
    def self.update(db, name, description, id)
        db.execute("UPDATE users SET name = ?, password_hash = ? WHERE id = ?", [name, password_hashed, id])
    end

    def self.delete(db, id)
        db.execute("DELETE FROM users WHERE id = ?", id)
    end
end
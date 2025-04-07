class Login
    def self.all(db)
        return db.execute('SELECT * FROM logins')
    end

    def self.selectFromUserId(db, user_id)
        return db.execute('SELECT * FROM logins WHERE user_id = ?', user_id)
    end

    def self.create(db, user_id)
        db.execute("INSERT INTO logins (user_id) VALUES (?)", user_id)
    end

    def self.delete(db, id)
        db.execute("DELETE FROM logins WHERE id = ?", id)
    end
end
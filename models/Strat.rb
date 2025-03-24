class Strat
    def self.all(db)
        return db.execute('SELECT * FROM strats')
    end

    def self.selectFromName(db, name)
        return db.execute('SELECT * FROM strats WHERE name = ?', name)
    end

    def self.selectFromId(db, id)
        return db.execute('SELECT * FROM strats WHERE id = ?', id)
    end

    def self.selectFromGameId(db, game_id)
        return db.execute('SELECT * FROM strats WHERE game_id = ?', game_id)
    end

    def self.selectFromUserId(db, user_id)
        return db.execute('SELECT * FROM strats WHERE user_id = ?', user_id)
    end

    def self.create(db, name, description, session_id, game_id)
        db.execute("INSERT INTO strats (name, description, rating_tot, user_id, game_id) VALUES (?, ?, 0, ?, ?)", [name, description, session_id, game_id])
    end
    
    def self.update(db, name, description, id)
        db.execute("UPDATE strats SET name = ?, description = ? WHERE id = ?", [name, description, id])
    end

    def self.delete(db, id)
        db.execute("DELETE FROM strats WHERE id = ?", id)
    end
    
    def self.updateRatings(db, ratings_tot, id)
        db.execute("UPDATE strats SET rating_tot = rating_tot + ?, rating_amount = rating_amount + 1 WHERE id = ?", [ratings_tot, id])
    end
end
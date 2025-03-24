class Game
    def self.all(db)
        return db.execute('SELECT * FROM games')
    end

    def self.selectFromName(db, name)
        return db.execute('SELECT * FROM games WHERE name = ?', name)
    end

    def self.selectFromId(db, id)
        return db.execute('SELECT * FROM games WHERE id = ?', id)
    end

    def self.create(db, name, description)
        db.execute("INSERT INTO games (name, description) VALUES (?, ?)", [name, description])
    end
    
    def self.update(db, name, description)
        db.execute("UPDATE games SET name = ?, description = ? WHERE id = ?", [name, description, id])
    end

    def self.delete(db, id)
        #strats = Strat.selectFromGameId(db, id)  TBD
        #for i in 0...strats.length
        db.execute("DELETE FROM games WHERE id = ?", id)
    end
end
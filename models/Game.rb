require './models/Gametags.rb'
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

    def self.selectFromTagId(db, tag_id)
        gametags = Gametag.selectFromGameId(db, tag_id)
        if gametags != []
            games = []
            for i in 0...gametags.length
                games.append(selectFromId(db, gametags[i]['game_id']))
            end
            return games
        else
            return nil
        end    end

    def self.create(db, name, description)
        db.execute("INSERT INTO games (name, description) VALUES (?, ?)", [name, description])
    end
    
    def self.update(db, name, description)
        db.execute("UPDATE games SET name = ?, description = ? WHERE id = ?", [name, description, id])
    end

    def self.delete(db, id)
        strats = db.execute("SELECT * FROM strats WHERE game_id = ?", id).length
        for i in 0...strats.to_i
            db.execute("DELETE FROM strats WHERE game_id = ?", id)
        end
        tags = Gametag.selectFromGameId(db, id).first.length
        for i in 0...tags.to_i
            db.execute("DELETE FROM gametags WHERE game_id = ?", id)
        end
        db.execute("DELETE FROM games WHERE id = ?", id)
    end
end
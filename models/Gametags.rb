
class Gametag
    def self.all(db)
        return db.execute('SELECT * FROM gametags')
    end

    def self.selectFromId(db, id)
        return db.execute('SELECT * FROM gametags WHERE id = ?', id)
    end

    def self.selectFromGameId(db, game_id)
        return db.execute('SELECT * FROM gametags WHERE game_id = ?', game_id)
    end

    def self.selectFromTagId(db, tag_id)
        return db.execute('SELECT * FROM gametags WHERE tag_id = ?', tag_id)
    end

    def self.create(db, game_id, tag_id)
        db.execute("INSERT INTO gametags (game_id, tag_id) VALUES (?, ?)", [game_id, tag_id])
    end

    def self.delete(db, id)
        db.execute("DELETE FROM gametags WHERE id = ?", id)
    end
end
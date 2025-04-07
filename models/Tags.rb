require './models/Gametags.rb'
class Tag
    def self.all(db)
        return db.execute('SELECT * FROM tags')
    end

    def self.selectFromName(db, name)
        return db.execute('SELECT * FROM tags WHERE name = ?', name).first
    end

    def self.selectFromId(db, id)
        return db.execute('SELECT * FROM tags WHERE id = ?', id).first
    end

    def self.selectFromGameId(db, game_id)
        gametags = Gametag.selectFromGameId(db, game_id)
        if gametags != []
            tags = []
            for i in 0...gametags.length
                tags.append(selectFromId(db, gametags[i]['tag_id']))
            end
            return tags
        else
            return nil
        end
    end

    def self.create(db, name, description)
        db.execute("INSERT INTO tags (name, description) VALUES (?, ?)", [name, description])
    end

    def self.add(db, game_id, tag_id)
        Gametag.create(db, game_id, tag_id)
    end
    
    def self.update(db, name, description, id)
        db.execute("UPDATE tags SET name = ?, description = ? WHERE id = ?", [name, description, id])
    end

    def self.delete(db, id)
        tags = Gametag.selectFromTagId(db, id).first.length
        for i in 0...tags.to_i
            db.execute("DELETE FROM gametags WHERE tag_id = ?", id)
        end
        db.execute("DELETE FROM tags WHERE id = ?", id)
    end
end
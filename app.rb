class App < Sinatra::Base

    def db
        return @db if @db
        @db = SQLite3::Database.new('db/stratroulette.sqlite')
        @db.results_as_hash = true
        return @db
    end

    get '/' do
        @strats = db.execute('SELECT * FROM strats') 
        check = false
        numb = rand(0...@strats.length)
        @strat = @strats[numb]
        erb(:"stratroulette/index")
    end

    get '/strats' do
        @strats = db.execute('SELECT * FROM strats')
        erb(:"stratroulette/strats")
    end

    get '/strats/new' do
        erb(:"stratroulette/new")
    end

    get '/strats/:id' do | id |
        @strat = db.execute('SELECT * FROM strats WHERE id = ?', id).first
        erb(:"stratroulette/show")
    end

    post '/strats/:id/delete' do | id |
        db.execute("DELETE FROM strats WHERE id = ?", id)
        redirect("/strats")
    end

    get '/strats/:id/update' do | id |
        @strat = db.execute('SELECT * FROM strats WHERE id = ?', id).first
        erb(:"stratroulette/update")
    end

    post '/strats/:id/update' do | id |
        db.execute("UPDATE strats SET name = ?, description = ? WHERE id = ?", [params['strat_name'], params['strat_description'], id])
        redirect("/strats")
    end


    post '/strats' do
        db.execute("INSERT INTO strats (name, description, rating_tot) VALUES (?, ?, 0)", [params['strat_name'], params['strat_description']])
        redirect("/")
    end

    post '/ratings_update/:id' do | id |
        db.execute("UPDATE strats SET rating_tot = rating_tot + ?, rating_amount = rating_amount + 1 WHERE id = ?", [params['strat_rating_tot'], id])
        redirect("/")
    end
end

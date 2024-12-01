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
    get '/strats/:id' do | id |
        @strats = db.execute('SELECT * FROM strats WHERE id = ?', id)
        @strat = @strats[0]
        p @strat
        erb(:"stratroulette/show")
    end

        post '/ratings_update/:id' do | id |
            p "Form submitted with ID: #{id}, Params: #{params.inspect}"
            db.execute("UPDATE strats SET rating_tot = rating_tot + ?, rating_amount = rating_amount + 1 WHERE id = ?", [params['rating_tot'], id])
            redirect("/")
        end
end

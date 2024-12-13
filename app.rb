enable :sessions
class App < Sinatra::Base

    enable :sessions

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
 
    get '/logout' do
        session.clear
        redirect '/'
    end

    get '/register' do
        erb(:"stratroulette/register")
    end

    get '/login' do
        @login_failed = false
        erb(:"stratroulette/login")
    end

    get '/login_failed' do
        @login_failed = true
        erb(:"stratroulette/login")
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

    post '/register' do
        username = params[:name]
        password = params[:password]

        existing = db.execute("SELECT * FROM users WHERE name = ?", [username]).first

        if existing
            halt 400, "Username already taken."
        else
            password_hashed = BCrypt::Password.create(password)
            db.execute("INSERT INTO users (name, password_hash) VALUES (?, ?)",[username, password_hashed])
            redirect '/login'
        end
    end

    post '/login' do
        username = params[:name]
        password = params[:password]

        user = db.execute("SELECT * FROM users WHERE name = ?", [username]).first
        password_hashed = user["password_hash"].to_s
        db_id = user["id"].to_i
        if  BCrypt::Password.new(password_hashed) == password
            session[:user_id] = db_id
            p session[:user_id]
            redirect '/'
        else
            status 401
            redirect '/login_failed'
        end


    end
end

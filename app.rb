require './models/Game.rb'
require './models/Strat.rb'
require './models/User.rb'


enable :sessions
class App < Sinatra::Base

    enable :sessions

    def db
        return @db if @db
        @db = SQLite3::Database.new('db/stratroulette.sqlite')
        @db.results_as_hash = true
        return @db
    end

    before do
        admin = User.selectFromId(db, session[:user_id].to_i).first
        if !admin == nil 
            @admin = admin["admin"]
        else
            @admin = 0
        end
        @rut = request.fullpath
    end

    get '/' do
        @strats = Strat.all(db)
        @games = Game.all(db)
        check = false
        numb = rand(0...@strats.length)
        @strat = @strats[numb]
        erb(:"stratroulette/index")
    end 

    #strats#index
    get '/strats' do
        @strats = Strat.all(db)
        erb(:"stratroulette/strats/index")
    end

    #strats#new
    get '/strats/new' do
        erb(:"stratroulette/strats/new")
    end

    #strats#show
    get '/strats/:id' do | id |
        @strat = Strat.selectFromId(db, id).first
        erb(:"stratroulette/strats/show")
    end
 
    #user#logout
    get '/logout' do
        session.clear
        redirect '/'
    end

    #user#register
    get '/register' do
        erb(:"stratroulette/users/register")
    end

    #user#register
    get '/login' do
        @login_failed = false
        erb(:"stratroulette/users/login")
    end

    get '/login_failed' do
        @login_failed = true
        erb(:"stratroulette/users/login")
    end
    
    #user#show
    get '/user/:id' do | id |
        @strats = Strat.selectFromUserId(db, id)
        @id = id
        if session[:user_id].to_i != id.to_i
            redirect '/'
        end
        erb(:"stratroulette/users/show")
    end

    #strats#destroy
    post '/strats/:id/delete' do | id |
        Strat.delete(db, id)
        redirect("/strats")
    end

    #strats#edit
    get '/strats/:id/edit' do | id |
        @strat = Strat.selectFromId(db, id).first
        erb(:"stratroulette/strats/edit")
    end

    #strats#update
    post '/strats/:id/update' do | id |
        Strat.update(db, params['strat_name'], params['strat_description'], id)
        redirect("/strats")
    end

    #strats#new
    post '/strats' do
        #funkar inte rn
        Strat.create(db, params['strat_name'], params['strat_description'], session[:user_id], 1)
        redirect("/")
    end


    post '/ratings_update/:id' do | id |
        Strat.updateRatings(db, params['strat_rating_tot'], id)
        redirect("/")
    end

    #user#new
    post '/register' do
        username = params[:name]
        password = params[:password]

        existing = User.selectFromName(db, username).first

        if existing
            status 400
            redirect '/register'
        else
            password_hashed = BCrypt::Password.create(password)
            User.create(db, username, password_hashed)
            redirect '/login'
        end
    end

    post '/login' do
        username = params[:name]
        password = params[:password]

        user = User.selectFromName(db, username).first
        if user.nil?
            status 401
            redirect '/login_failed'
        end
        db_id = user["id"].to_i
        password_hashed = user["password_hash"].to_s
        if BCrypt::Password.new(password_hashed) == password
            session[:user_id] = db_id
            p session[:user_id]
            redirect '/'
        else
            status 401
            redirect '/login_failed'
        end


    end
    get '/games' do
        @games = Game.all(db)
        erb(:"stratroulette/games/index")
    end
    get '/games/:id' do | id |
        @game = Game.selectFromId(db, id).first
        @strats = db.execute('SELECT * FROM strats WHERE game_id = ?', id) 
        @strats = Strat.selectFromGameId(db, id)
        check = false
        numb = rand(0...@strats.length)
        @strat = @strats[numb]
        erb(:"stratroulette/games/show")
    end
end

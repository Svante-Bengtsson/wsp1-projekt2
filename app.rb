require './models/Game.rb'
require './models/Strat.rb'
require './models/User.rb'
require './models/Tags.rb'

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
        if admin != nil 
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
        redirect '/games'
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
        @empty = false
        if @strats == []
            @empty = true
        end
        if session[:user_id].to_i != id.to_i
            redirect '/'
        end
        erb(:"stratroulette/users/show")
    end

    #strats#destroy
    post '/strats/:id/delete' do | id |
        Strat.delete(db, id)
        
        redirect("/user/" + session[:user_id].to_s)
    end

    #strats#edit
    get '/strats/:id/edit' do | id |
        @strat = Strat.selectFromId(db, id).first
        erb(:"stratroulette/strats/edit")
    end

    #strats#update
    post '/strats/:id/update' do | id |
        Strat.update(db, params['strat_name'], params['strat_description'], id)
        redirect("/user/" + session[:user_id].to_s)
    end

    #strats#new
    post '/strats' do
        Strat.create(db, params['strat_name'], params['strat_description'], session[:user_id], params['game_id'])
        redirect("/games/"+params['game_id'].to_s)
    end


    post '/ratings_update/:id' do | id |
        Strat.updateRatings(db, params['strat_rating_tot'], id)
        p params['game_id']
        redirect("/games/" + params['game_id'].to_s)
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

    post '/users/:id/delete' do | id |
        User.delete(db, id)
        session.clear
        redirect '/'
    end 

    get '/games' do
        @games = Game.all(db)
        erb(:"stratroulette/games/index")
    end

    get '/games/:id' do | id |
        @empty = false
        @tags = Tag.selectFromGameId(db, id).first
        @game = Game.selectFromId(db, id).first
        @strats = Strat.selectFromGameId(db, id)
        check = false
        numb = rand(0...@strats.length)
        if @strats != []
            @strat = @strats[numb]
        else
            @empty = true
        end
        @id = id
        erb(:"stratroulette/games/show")
    end
    post '/games/new' do
        Game.create(db, params['game_name'], params['game_description'])
        @game = Game.selectFromName(db, params['game_name']).first
        id = @game['id'].to_i
        glop = "/games/" + id.to_s
        redirect glop
    end

    post '/games/:id/delete' do | id | 
        Game.delete(db, id)
        redirect '/'
    end

    get '/tags/:id' do | id |
        @tag = Tag.selectFromId(db, id).first
        @games = Game.selectFromTagId(db, id).first
        erb(:"stratroulette/tags/show")
    end

    get '/tags/add/:id' do | id |
        @tags = Tag.all(db).first
        @alreadytags = Tag.selectFromGameId(db, id).first
        removus = []
        for i in 0...@tags.length
            for k in 0...@alreadytags.length
                if @tags[i]['id'] == @alredytags[k]['id']
                    removus.append(@tags[i]['id'])
                end
            end
        end
        for i in 0...removus.length
            for k in 0...@tags.length
                if @tags[k]['id'] == removus[i]
                    @tags.delete_at(k)
                end
            end
        end
        @id = id
        erb(:"stratroulette/tags/add")
    end
    post '/tags/add/:id' do | id |
        Tag.add(db, id, params['tag_id'])
        redirect '/tags/add/' + id.to_s
    end
end

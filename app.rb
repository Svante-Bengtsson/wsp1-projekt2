require './models/Game.rb'
require './models/Strat.rb'
require './models/User.rb'
require './models/Tags.rb'
require './models/Login.rb'

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
        @role = 'guest'
        admin = User.selectFromId(db, session[:user_id].to_i)
        if admin != nil 
            @admin = admin["admin"]
        else
            @admin = 0
        end
        @rut = request.fullpath
        if session[:user_id] != nil
            if @admin == admin["admin"]
                @role = 'admin'
            else
                @role = 'standard'
            end
        end
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
        @strat = Strat.selectFromId(db, id)
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
        if @role == 'standard' or @role == 'admin'
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
        else
            redirect '/'
        end
    end

    #strats#destroy
    post '/strats/:id/delete' do | id |
        if @role == 'standard' or @role == 'admin'
            if Strat.selectFromId(db, id)['user_id'] == session[:user_id]
                Strat.delete(db, id)
            end
            redirect("/user/" + session[:user_id].to_s)
        else
            redirect '/'
        end
    end

    #strats#edit
    get '/strats/:id/edit' do | id |
        if @role == 'standard' or @role == 'admin'
            @strat = Strat.selectFromId(db, id)
            erb(:"stratroulette/strats/edit")
        else 
            redirct '/'
        end
    end

    #strats#update
    post '/strats/:id/update' do | id |
        if @role == 'standard' or @role == 'admin'
            Strat.update(db, params['strat_name'], params['strat_description'], id)
            redirect("/user/" + session[:user_id].to_s)
        else
            redirct '/'
        end
    end

    #strats#new
    post '/strats' do
        if @role == 'standard' or @role == 'admin'
            Strat.create(db, params['strat_name'], params['strat_description'], session[:user_id], params['game_id'])
            redirect("/games/"+params['game_id'].to_s)
        else
            redirect '/'
        end
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

        existing = User.selectFromName(db, username)

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
        user = User.selectFromName(db, username)
        loginlist = Login.selectFromUserId(db, user['id'])
        loginlist.each do | login |
            if Time.now.utc - Time.parse(login['created_at']) > (25 * 60)
                Login.delete(db, login['id'])
            end
        end
        if user.nil?
            status 401
            redirect '/login_failed'
        else
            if loginlist.length > 5
                status 401
                redirect '/login_failed'
            else
                db_id = user["id"].to_i
                password_hashed = user["password_hash"].to_s
                if BCrypt::Password.new(password_hashed) == password
                    session[:user_id] = db_id
                    redirect '/'
                else
                    Login.create(db, user['id'])
                    status 401
                    redirect '/login_failed'
                end
            end
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
        @tags = Tag.selectFromGameId(db, id)
        @game = Game.selectFromId(db, id)
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
    post '/games' do
        Game.create(db, params['game_name'], params['game_description'])
        @game = Game.selectFromName(db, params['game_name'])
        id = @game['id'].to_i
        glop = "/games/" + id.to_s
        redirect glop
    end

    post '/games/:id/delete' do | id | 
        if @role == 'admin'
            Game.delete(db, id)
        end
        redirect '/'
    end

    get '/tags/:id' do | id |
        @tag = Tag.selectFromId(db, id)
        @games = Game.selectFromTagId(db, id)
        erb(:"stratroulette/tags/show")
    end

    get '/tags/add/:id' do | id |

        @tags = Tag.all(db)
        @alreadytags = Tag.selectFromGameId(db, id)
        @alreadytags.each do |alreadytag|
            @tags = @tags - [alreadytag]
        end
        @id = id
        erb(:"stratroulette/tags/add")
    end

    post '/tags/add/:id' do | id |
        Tag.add(db, id, params['tag_id'])
        redirect '/tags/add/' + id.to_s
    end

    post '/tags' do
        Tag.create(db, params['tag_name'], params['tag_description'])
        redirect '/tags/add/' + params['game_id'].to_s
    end

    
end

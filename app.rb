require './models/Game.rb'
require './models/Strat.rb'
require './models/User.rb'
require './models/Tags.rb'
require './models/Login.rb'

enable :sessions

class App < Sinatra::Base

    enable :sessions

    # en funktion som returnar datatbasen så att man enklare kan pilla i databasem
    # @return [SQLite3::Database] databas
    # @example
    #  db.execute(...)
    #
    def db
        return @db if @db
        @db = SQLite3::Database.new('db/stratroulette.sqlite')
        @db.results_as_hash = true
        return @db
    end

    # @!method before
    # en funktion som körs före varenda route, håller koll på vilken behörighet användaren har, returnar inget men sätter några variabler
    #
    # @note sätter @role och @admin beroende på vilken behörighet
    #
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

    # @!method get'/'
    # redirectar till /games
    get '/' do
        @strats = Strat.all(db)
        @games = Game.all(db)
        check = false
        numb = rand(0...@strats.length)
        @strat = @strats[numb]
        redirect '/games'
        erb(:"stratroulette/index")
    end 

    # @!method get'/strats'
    # laddar in strats sidan - views/stratroulette/strats/index.erb
    get '/strats' do
        @strats = Strat.all(db)
        erb(:"stratroulette/strats/index")
    end

    # @!method get'/strats/new'
    # laddar in formuläret för att skapa en ny strat - views/stratroulette/strats/new.erb
    get '/strats/new' do
        erb(:"stratroulette/strats/new")
    end

    # @!method get'/strats/:id'
    # laddar in all infor för en viss strat - views/stratroulette/strats/show.erb
    # @param [numeric] id för straten som ska visas
    get '/strats/:id' do | id |
        @strat = Strat.selectFromId(db, id)
        erb(:"stratroulette/strats/show")
    end
    
    # @!method get'/logout'
    # loggar ut användaren om de är inloggader(clearar session) och sen dirigerar vidare till hemsidan
    get '/logout' do
        session.clear
        redirect '/'
    end

    # @!method get'/register'
    # laddar in formuläret för att registrera - views/stratroulette/users/register.erb
    get '/register' do
        erb(:"stratroulette/users/register")
    end

    # @!method get'/login'
    # sätter @login_failed till false och laddar in formuläret för att logga in - views/stratroulette/users/login.erb
    get '/login' do
        @login_failed = false
        erb(:"stratroulette/users/login")
    end
    # @!method get'/login_failed'
    # sätter @login_failed till true och laddar in formuläret för att logga in - views/stratroulette/users/login.erb
    get '/login_failed' do
        @login_failed = true
        erb(:"stratroulette/users/login")
    end
    
    # @!method get'/user/:id'
    # laddar in användarsidan för en viss användare beronde på id - views/stratroulette/users/show.erb
    # @param [numeric] id för användren
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

    # @!method post'/strats/:id/delete'
    # raderar en strat om man har behörigheten for det och dirigerar sedan en vidare beroende på behörighet
    # @params [numeric] id för straten
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

    # @!method get'/strats/:id/edit'
    # laddar in sidan för att redigera en viss strat beroende på id om man har behörighet och digigerar sedan vidare beroende på behörighet
    # @params [numeric] id för straten
    get '/strats/:id/edit' do | id |
        if @role == 'standard' or @role == 'admin'
            @strat = Strat.selectFromId(db, id)
            erb(:"stratroulette/strats/edit")
        else 
            redirct '/'
        end
    end

    # @!method post'/strats/:id/update'
    # updaterar straten beroende på id om man har behörighet och dirigerar sedan vidare beroende på behörighet
    # @params [numeric] id för straten
    post '/strats/:id/update' do | id |
        if @role == 'standard' or @role == 'admin'
            Strat.update(db, params['strat_name'], params['strat_description'], id)
            redirect("/user/" + session[:user_id].to_s)
        else
            redirct '/'
        end
    end

    # @!method post'/strats'
    # skapar en nu strat dirigerar sedan vidare beroende på behörighet
    post '/strats' do
        if @role == 'standard' or @role == 'admin'
            Strat.create(db, params['strat_name'], params['strat_description'], session[:user_id], params['game_id'])
            redirect("/games/"+params['game_id'].to_s)
        else
            redirect '/'
        end
    end

    # @!method post'/ratings_update/:id'
    # uppdaterar ratings för en viss strat beroende på id och medskickade params
    # @params [numeric] id för straten
    post '/ratings_update/:id' do | id |
        Strat.updateRatings(db, params['strat_rating_tot'], id)
        redirect("/games/" + params['game_id'].to_s)
    end

    # @!method post'/register'
    # skapar en ny användare baserat på medskickade params och redirectar sedan til /login
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

    # @!method post'/login'
    # loggar in en användare baserat på medskickade params och did´rigerar därefter vidare baserat på behörighet
    # @params [numeric] id för straten
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

    # @!method post'/users/:id/delete'
    # raderar en viss strat beroende på id och redirectar sedan till hemsidan
    # @params [numeric] id för straten
    post '/users/:id/delete' do | id |
        User.delete(db, id)
        session.clear
        redirect '/'
    end 

    # @!method get'//games'
    # laddar sidan som visar alla spel - views/stratroulette/games/index.erb
    get '/games' do
        @games = Game.all(db)
        erb(:"stratroulette/games/index")
    end

    # @!method get'/games/:id'
    # laddar sidan för ett vist spel beroende på id samt slumpar fram en strat att visa på sidan - views/stratroulette/games/show.erb
    # @params [numeric] id för spelet
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

    # @!method post'/games'
    # lägger till ett nytt spel baserat på medskickade params och sedan omdirigerar till det nya spelets sida
    post '/games' do
        Game.create(db, params['game_name'], params['game_description'])
        @game = Game.selectFromName(db, params['game_name'])
        id = @game['id'].to_i
        glop = "/games/" + id.to_s
        redirect glop
    end

    # @!method post'/games/:id/delete'
    # raderar ett visst spel beroende på id och omdirigerar sen till hemsidan
    # @params [numeric] id för spelet
    post '/games/:id/delete' do | id | 
        if @role == 'admin'
            Game.delete(db, id)
        end
        redirect '/'
    end

    # @!method get'/tags/:id'
    # laddar sidan för en viss tag beroende på id  - views/stratroulette/tags/show.erb
    # @params [numeric] id för tagen
    get '/tags/:id' do | id |
        @tag = Tag.selectFromId(db, id)
        @games = Game.selectFromTagId(db, id)
        erb(:"stratroulette/tags/show")
    end
    
    # @!method get'/tags/add/:id'
    # laddar sidan för att lägga till och ta bort tags på ett visst spel beroende på id  - views/stratroulette/tags/show.erb
    # @params [numeric] id för spelet
    get '/tags/add/:id' do | id |

        @tags = Tag.all(db)
        @alreadytags = Tag.selectFromGameId(db, id)
        if @alredytags != nil
            @alreadytags.each do |alreadytag|
                @tags = @tags - [alreadytag]
            end
        end
        
        @id = id
        erb(:"stratroulette/tags/add")
    end

    # @!method post'/tags/add/:id'
    # lägger till en viss tag beroende på medskickade params till ett visst spel beroende på id och redirectar sedan till sidan för att lägga till tags på spelet
    # @params [numeric] id för spelet
    post '/tags/add/:id' do | id |
        Tag.add(db, id, params['tag_id'])
        redirect '/tags/add/' + id.to_s
    end

    # @!method post'/tags'
    # lägger till en viss tag beroende på medckikade params och redirectar sedan till sidan för att lägga till tags på ett vist spel beroende på inskickande parametrar.
    post '/tags' do
        Tag.create(db, params['tag_name'], params['tag_description'])
        redirect '/tags/add/' + params['game_id'].to_s
    end

    
end

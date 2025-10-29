require "utils"
require "classes.world"
require "classes.tile"
require "classes.unit"
require "classes.player"
require "classes.buildMenu"
require "classes.building"
require "classes.nextPhase"
require "classes.button"

enet = require "enet"

function love.load()
    math.randomseed(os.clock())

    font = love.graphics.newFont("fonts/DePixelKlein.ttf", 20)
    font:setFilter("nearest")
    love.graphics.setFont(font)

    mouseX, mouseY = love.mouse.getPosition()
    windowWidth, windowHeight = love.graphics.getDimensions()

    menu = "main"
    onlineGame = false
    isHost = false

    playButton = button.new({color = {1,0,0}, font = love.graphics.newFont("fonts/DePixelKlein.ttf", 40), x = windowWidth/2, y = (windowHeight/2)-44, text = "play", code = 'menu = "game" World = world.new({tileRadius = 30, tileSpacing = 2, MapSize = 5})'})
    hostButton = button.new({color = {1,0,0}, font = love.graphics.newFont("fonts/DePixelKlein.ttf", 40), x = windowWidth/2, y = windowHeight/2, text = "host", code = 'menu = "host"'})
    joinButton = button.new({color = {1,0,0}, font = love.graphics.newFont("fonts/DePixelKlein.ttf", 40), x = windowWidth/2, y = hostButton.height+(windowHeight/2), text = "join", code = 'menu = "join"'})

    startGameButton = button.new({color = {1,0,0}, font = love.graphics.newFont("fonts/DePixelKlein.ttf", 40), x = windowWidth/2, y = 22, text = "Start Game", code = 'menu = "game" event = host:service(100) for i = 1, #players do players[i].event.peer:send("STARTING GAME:"..World.MapSize) end'})
end

function love.update(dt)
    mouseX, mouseY = love.mouse.getPosition()

    if (menu == "main") then
        playButton:update(dt)
        hostButton:update(dt)
        joinButton:update(dt)
    elseif (menu == "host") then
        if onlineGame == false then
            initGame(10)
            host = enet.host_create("localhost:6789")
            onlineGame = true
            isHost = true
            players = {}
        end

        World.tiles[5][5].data.building = building.new({type = "city", x = 5, y = 5, world = World})

        event = host:service(10)

        if event then
            if event.type == "receive" then
                print("Got message: ", event.data, event.peer)
            elseif event.type == "connect" then
                print(event.peer, "connected.")
                players[#players+1] = {event, done}
                players[#players].event = event
                players[#players].done = false
            elseif event.type == "disconnect" then
                print(event.peer, "disconnected.")
            end
        end
        
        startGameButton:update(dt)

    elseif (menu == "join") then
        if onlineGame == false then
            host = enet.host_create()
            server = host:connect("localhost:6789")
            onlineGame = true
        end

        event = host:service(10)

        if event then
            if event.type == "receive" then
                print("Got message: ", event.data, event.peer)
                if (event.data:sub(1, 13) == "STARTING GAME") then
                    menu = "game"
                    initGame(tonumber(event.data:sub(15)))
                end
                event.peer:send( "world?" )
            elseif event.type == "connect" then
                print(event.peer, "connected.")
            elseif event.type == "disconnect" then
                print(event.peer, "disconnected.")
            end
        end
    else
        World:update(dt)
        Player:update(dt)
        NextPhase:update(dt)

        if (Player.phases[Player.currentPhase] == "done") then
            if onlineGame == true then
                if (isHost == true) then
                    
                else
                    host:service(10)
                    server:send("done")
                end
            end
        end
        
        if onlineGame == true then
            event = host:service(10)

            if event then
                if event.type == "receive" then
                    if (isHost == true) then
                        if (event.data == "world?") then
                            sendWorld(event)
                        elseif (event.data:sub(1, 5) == "build") then
                            decryptBuild(event)
                        elseif (event.data == "done") then
                            for i = 1, #players do 
                                if (players[i].event.peer == event.peer) then
                                    players[i].done = true
                                    break
                                end
                            end

                            local allPlayersDone = true
                            for i = 1, #players do 
                                if (players[i].done == false) then
                                    allPlayersDone = false
                                    break
                                end
                            end
                            if ((allPlayersDone == true) and (Player.phases[Player.currentPhase] == "done"))then
                                for i = 1, #players do 
                                    players[i].event.peer:send("allPlayersDone")
                                    Player.currentPhase = NextPhase.nextPhase
                                end
                            end
                        end
                    else
                        if (event.data:sub(1, 3) == "MAP") then
                            decryptWorld(event)
                        elseif (event.data == "allPlayersDone") then
                            Player.currentPhase = NextPhase.nextPhase
                        else
                            print("Got message: ", event.data, event.peer)
                        end
                    end
                elseif event.type == "disconnect" then
                    print(event.peer, "disconnected.")
                end
            end
        end
    end
end

function love.draw()
    if (menu == "main") then
        playButton:draw()
        hostButton:draw()
        joinButton:draw()
    elseif (menu == "host") then
        startGameButton:draw()
    elseif (menu == "join") then
        
    else
        World:draw()
        BuildMenu:draw()
        NextPhase:draw()

        love.graphics.setColor(1,1,1)
        love.graphics.print(love.timer.getFPS(), 0, font:getHeight())
    end
end
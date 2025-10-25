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

    World = world.new({tileRadius = 30, tileSpacing = 2, MapSize = 10})

    Player = player.new({camSpeed = 50, world = World})

    BuildMenu = buildMenu.new({world = World})
    NextPhase = nextPhase.new()

    World.tiles[5][5].data.building = building.new({x = World.tiles[5][5].girdX, y = World.tiles[5][5].girdY, world = World, type = "city"})

    menu = "main"
    onlineGame = false
    isHost = false

    playButton = button.new({color = {1,0,0}, font = love.graphics.newFont("fonts/DePixelKlein.ttf", 40), x = windowWidth/2, y = (windowHeight/2)-44, text = "play", code = 'menu = "game"'})
    hostButton = button.new({color = {1,0,0}, font = love.graphics.newFont("fonts/DePixelKlein.ttf", 40), x = windowWidth/2, y = windowHeight/2, text = "host", code = 'menu = "host"'})
    joinButton = button.new({color = {1,0,0}, font = love.graphics.newFont("fonts/DePixelKlein.ttf", 40), x = windowWidth/2, y = hostButton.height+(windowHeight/2), text = "join", code = 'menu = "join"'})

    startGameButton = button.new({color = {1,0,0}, font = love.graphics.newFont("fonts/DePixelKlein.ttf", 40), x = windowWidth/2, y = 22, text = "Start Game", code = 'menu = "game" event = host:service(100) for i = 1, #players do players[i]:send("STARTING GAME") end'})
end

function love.update(dt)
    mouseX, mouseY = love.mouse.getPosition()

    if (menu == "main") then
        playButton:update(dt)
        hostButton:update(dt)
        joinButton:update(dt)
    elseif (menu == "host") then
        if onlineGame == false then
            host = enet.host_create("localhost:6789")
            onlineGame = true
            isHost = true
            players = {}
        end

        event = host:service(10)

        if event then
            if event.type == "receive" then
                print("Got message: ", event.data, event.peer)
            elseif event.type == "connect" then
                print(event.peer, "connected.")
                players[#players+1] = event.peer
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
                if (event.data == "STARTING GAME") then
                    menu = "game"
                end
                event.peer:send( "ping" )
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
            
        end

        if onlineGame == true then
            event = host:service(10)

            if event then
                if event.type == "receive" then
                    print("Got message: ", event.data, event.peer)
                    if (isHost == true) then
                        event.peer:send("pong")
                    else
                        event.peer:send("ping")
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
        if onlineGame == true then
            
        end
    end
end
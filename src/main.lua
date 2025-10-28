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

    Player = player.new({camSpeed = 50, world = World})

    BuildMenu = buildMenu.new({world = World})
    NextPhase = nextPhase.new()

    menu = "main"
    onlineGame = false
    isHost = false

    playButton = button.new({color = {1,0,0}, font = love.graphics.newFont("fonts/DePixelKlein.ttf", 40), x = windowWidth/2, y = (windowHeight/2)-44, text = "play", code = 'menu = "game" World = world.new({tileRadius = 30, tileSpacing = 2, MapSize = 5})'})
    hostButton = button.new({color = {1,0,0}, font = love.graphics.newFont("fonts/DePixelKlein.ttf", 40), x = windowWidth/2, y = windowHeight/2, text = "host", code = 'menu = "host"'})
    joinButton = button.new({color = {1,0,0}, font = love.graphics.newFont("fonts/DePixelKlein.ttf", 40), x = windowWidth/2, y = hostButton.height+(windowHeight/2), text = "join", code = 'menu = "join"'})

    startGameButton = button.new({color = {1,0,0}, font = love.graphics.newFont("fonts/DePixelKlein.ttf", 40), x = windowWidth/2, y = 22, text = "Start Game", code = 'menu = "game" event = host:service(100) for i = 1, #players do players[i]:send("STARTING GAME:"..World.MapSize) end'})
end

function love.update(dt)
    mouseX, mouseY = love.mouse.getPosition()

    if (menu == "main") then
        playButton:update(dt)
        hostButton:update(dt)
        joinButton:update(dt)
    elseif (menu == "host") then
        if onlineGame == false then
            World = world.new({tileRadius = 30, tileSpacing = 2, MapSize = 5})
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
                if (event.data:sub(1, 13) == "STARTING GAME") then
                    menu = "game"
                    World = world.new({tileRadius = 30, tileSpacing = 2, MapSize = tonumber(event.data:sub(15))})
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
            
        end
        
        if onlineGame == true then
            event = host:service(10)

            if event then
                if event.type == "receive" then
                    if (isHost == true) then
                        if (event.data == "world?") then
                            tileStringList = ""
                            for y = 1, World.MapSize do
                                for x = 1, World.MapSize do
                                    tileStringList = tileStringList..x..":"..y..":0:0;"
                                end
                            end
                            event.peer:send("MAP;"..tileStringList)
                        end
                    else
                        if (event.data:sub(1, 3) == "MAP") then
                            print(event.data:sub(5))

                            netTiles = {}
                            k = 1
                            netTiles[k] = ""
                            for i = 5, #event.data do
                                netTiles[k] = netTiles[k]..event.data:sub(i, i)
                                if (event.data:sub(i, i) == ";") then
                                    k = k + 1
                                    netTiles[k] = ""
                                end
                            end
                            for i = 1, #netTiles-1 do
                                local lookingForList = {"x", "y", "unit", "building"}
                                local lookingFor = 1
                                local x = ""
                                local y = ""
                                local unit = ""
                                local building = ""
                                for k = 1, #netTiles[i] do
                                    if (netTiles[i]:sub(k, k) == ":") then
                                        lookingFor = lookingFor + 1
                                    elseif (netTiles[i]:sub(k, k) == ";") then
                                        break
                                    else
                                        if (lookingForList[lookingFor] == "x") then
                                            x = x..netTiles[i]:sub(k, k)
                                        end
                                        if (lookingForList[lookingFor] == "y") then
                                            y = y..netTiles[i]:sub(k, k)
                                        end
                                        if (lookingForList[lookingFor] == "unit") then
                                            unit = unit..netTiles[i]:sub(k, k)
                                        end
                                        if (lookingForList[lookingFor] == "building") then
                                            building = building..netTiles[i]:sub(k, k)
                                        end
                                    end
                                end
                                print(x..":"..y..":"..unit..":"..building)
                                World.tiles[y][x] = tile.new({x = tonumber(x), y = tonumber(y), world = World})
                            end
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
        if onlineGame == true then
            
        end
    end
end
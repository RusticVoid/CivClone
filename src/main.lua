require "utils"
require "classes.world"
require "classes.tile"
require "classes.unit"
require "classes.player"
require "classes.buildMenu"
require "classes.building"
require "classes.nextPhase"

function love.load()
    math.randomseed(os.clock())
    font = love.graphics.getFont()
    mouseX, mouseY = love.mouse.getPosition()
    windowWidth, windowHeight = love.graphics.getDimensions()

    World = world.new({tileRadius = 30, tileSpacing = 2, MapSize = 10})

    Player = player.new({camSpeed = 50, world = World})

    BuildMenu = buildMenu.new({world = World})
    NextPhase = nextPhase.new()

    World.tiles[5][5].data.building = building.new({x = World.tiles[5][5].girdX, y = World.tiles[5][5].girdY, world = World, type = "city"})
end

function love.update(dt)
    mouseX, mouseY = love.mouse.getPosition()
    World:update(dt)
    Player:update(dt)
    NextPhase:update(dt)

    if (Player.phases[Player.currentPhase] == "done") then
        Player.currentPhase = NextPhase.nextPhase
    end
end

function love.draw()
    World:draw()

    BuildMenu:draw()
    NextPhase:draw()

    love.graphics.setColor(1,1,1)
    love.graphics.print(love.timer.getFPS(), 0, font:getHeight())
end
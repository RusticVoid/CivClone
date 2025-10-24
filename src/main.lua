require "classes.tile"
require "classes.unit"

function love.load()
    mouseX, mouseY = love.mouse.getPosition()

    tileRadius = 50
    tileInnerRadius = tileRadius/1.16
    tileSpacing = 2
    MapSize = 10

    selectedTile = 0

    love.window.setMode(tileRadius*(((MapSize*tileSpacing)/1.34)+1/2), MapSize*tileInnerRadius*tileSpacing+tileRadius/1.34)
    windowWidth, windowHeight = love.graphics.getDimensions()

    tiles = {}
    for y = 1, MapSize do
        tiles[y] = {}
        for x = 1, MapSize do
            tiles[y][x] = tile.new({x = x, y = y})
        end
    end

    tiles[1][1].data.unit = unit.new({x = tiles[1][1].girdX, y = tiles[1][1].girdY})

end

function love.update(dt)
    mouseX, mouseY = love.mouse.getPosition()
    for y = 1, MapSize do
        for x = 1, MapSize do
            tiles[y][x]:update(dt)
        end
    end
end

function love.draw()
    for y = 1, MapSize do
        for x = 1, MapSize do
            tiles[y][x]:draw()
        end
    end

    love.graphics.setColor(1,1,1)
    if (not (selectedTile == 0)) then
        love.graphics.print("X: "..selectedTile.girdX.." Y: "..selectedTile.girdY)
        love.graphics.print(selectedTile.data.unit, 0, 15)
    end
end
world = {}
world.__index = world

function world.new(settings)
    local self = setmetatable({}, world)

    self.tileRadius = settings.tileRadius
    self.tileInnerRadius = self.tileRadius/1.16
    self.tileSpacing = settings.tileSpacing
    self.MapSize = settings.MapSize

    self.x = 0
    self.y = 0

    self.tiles = {}
    for y = 1, self.MapSize do
        self.tiles[y] = {}
        for x = 1, self.MapSize do
            self.tiles[y][x] = tile.new({x = x, y = y, world = self})
        end
    end

    return self
end

function world:update(dt)
    for y = 1, self.MapSize do
        for x = 1, self.MapSize do
            self.tiles[y][x]:update(dt)
        end
    end
end

function world:draw()
    for y = 1, self.MapSize do
        for x = 1, self.MapSize do
            self.tiles[y][x]:draw()
        end
    end
end
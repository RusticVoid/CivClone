building = {}
building.__index = building

function building.new(settings)
    local self = setmetatable({}, building)

    self.girdX = settings.x
    self.girdY = settings.y

    self.type = settings.type

    self.world = settings.world

    self.color = {0,0,1,1}
    self.x = self.girdX*((self.world.tileRadius/1.34)*self.world.tileSpacing) - self.world.tileRadius/2
    self.y = self.girdY*((self.world.tileInnerRadius)*self.world.tileSpacing)
    if (self.girdX % 2 == 0) then
        self.y = self.y - self.world.tileInnerRadius
    end

    if (self.type == "barracks") then
        self.color = {1,0.5,0.5}
        self.produced = false
    end

    return self
end

function building:update(dt)
    self.x = self.world.x+(self.girdX*((self.world.tileRadius/1.34)*self.world.tileSpacing) - self.world.tileRadius/2)
    self.y = self.world.y+(self.girdY*((self.world.tileInnerRadius)*self.world.tileSpacing))
    if (self.girdX % 2 == 0) then
        self.y = self.y - self.world.tileInnerRadius
    end

    if (self.type == "barracks") then
        if self.produced == false then
            if (Player.phases[Player.currentPhase] == "move") then
                self.produced = true

                if (self.world.tiles[self.girdY][self.girdX].data.unit == 0) then
                    self.world.tiles[self.girdY][self.girdX].data.unit = unit.new({x = self.world.tiles[self.girdY][self.girdX].girdX, y = self.world.tiles[self.girdY][self.girdX].girdY, world = World})  
                end
            end
        else
            if (Player.phases[Player.currentPhase] == "done") then
                self.produced = false
            end
        end
    end
end

function building:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.x, self.y, self.world.tileInnerRadius/2)
end
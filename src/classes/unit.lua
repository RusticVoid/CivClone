unit = {}
unit.__index = unit

function unit.new(settings)
    local self = setmetatable({}, unit)

    self.girdX = settings.x
    self.girdY = settings.y

    self.world = settings.world

    self.color = {1,0,0,1}
    self.x = self.girdX*((self.world.tileRadius/1.34)*self.world.tileSpacing) - self.world.tileRadius/2
    self.y = self.girdY*((self.world.tileInnerRadius)*self.world.tileSpacing)
    if (self.girdX % 2 == 0) then
        self.y = self.y - self.world.tileInnerRadius
    end

    self.moveSpeed = 1
    self.moved = false

    return self
end

function unit:update(dt)
    self.x = self.world.x+(self.girdX*((self.world.tileRadius/1.34)*self.world.tileSpacing) - self.world.tileRadius/2)
    self.y = self.world.y+(self.girdY*((self.world.tileInnerRadius)*self.world.tileSpacing))
    if (self.girdX % 2 == 0) then
        self.y = self.y - self.world.tileInnerRadius
    end

    if self.moved == true then
        if (Player.phases[Player.currentPhase] == "done") then
            self.moved = false
        end
    end
end

function unit:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.x, self.y, self.world.tileInnerRadius/3)

    if (self.moved == false) then
        love.graphics.setColor(1,1,0)
        love.graphics.circle('line', self.x, self.y, self.world.tileInnerRadius/3)
    end
end
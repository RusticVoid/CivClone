unit = {}
unit.__index = unit

function unit.new(settings)
    local self = setmetatable({}, unit)

    self.girdX = settings.x
    self.girdY = settings.y

    self.moveSpeed = 1

    self.color = {1,0,0,1}

    return self
end

function unit:update(dt)
end

function unit:draw()
    self.color = {1,0,0,1}
    local x = self.girdX*((tileRadius/1.34)*tileSpacing) - tileRadius/2
    local y = self.girdY*((tileInnerRadius)*tileSpacing)

    if (self.girdX % 2 == 0) then
        y = y - tileInnerRadius
    end

    love.graphics.setColor(self.color)
    love.graphics.circle('fill', x, y, tileInnerRadius/2)
end
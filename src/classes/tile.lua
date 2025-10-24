tile = {}
tile.__index = tile

function tile.new(settings)
    local self = setmetatable({}, tile)

    self.girdX = settings.x
    self.girdY = settings.y

    self.x = self.girdX*((tileRadius/1.34)*tileSpacing) - tileRadius/2
    self.y = self.girdY*((tileInnerRadius)*tileSpacing)

    self.color = {1,1,1,1}
    if (self.girdX % 2 == 0) then
        self.y = self.y - tileInnerRadius
        self.color = {0.5,0.5,0.5,1}
    end

    self.selected = false
    self.highlight = false

    self.data = {
        unit = 0
    }

    return self
end

function tile:update(dt)
end

function tile:draw()
    self.x = self.girdX*((tileRadius/1.34)*tileSpacing) - tileRadius/2
    self.y = self.girdY*((tileInnerRadius)*tileSpacing)

    if (self.girdX % 2 == 0) then
        self.y = self.y - tileInnerRadius
    end

    if (self.highlight == true) then
        love.graphics.setColor(1,0,0)
    else
        love.graphics.setColor(self.color)
    end
    
    love.graphics.circle('fill', self.x, self.y, tileRadius, 6)

    if (self:getDistance(mouseX, mouseY, self.x, self.y) < tileInnerRadius) then
        self:drawBorder()
    end

    if love.mouse.isDown(1) then
        if (self:getDistance(mouseX, mouseY, self.x, self.y) < tileInnerRadius) then
            self.selected = true
            selectedTile = self
        else
            self.selected = false
            if (selectedTile == self) then
                selectedTile = 0
                self:highlightNear(false)
            end
        end
    end

    if love.mouse.isDown(2) then
        if (not (selectedTile == self)) then
            if (self:getDistance(mouseX, mouseY, self.x, self.y) < tileInnerRadius) then
                if (not (selectedTile.data.unit == 0)) then
                    if (self.highlight == true) then
                        self.data.unit = selectedTile.data.unit
                        self.data.unit.girdX = self.girdX
                        self.data.unit.girdY = self.girdY
                        selectedTile:highlightNear(false)
                        selectedTile.data.unit = 0
                    end
                end
            end
        end
    end

    if (self.selected == true) then
        self:drawBorder()

        if (not (self.data.unit == 0)) then
            self:highlightNear(true)
        end
    end

    love.graphics.setLineWidth(tileRadius/11)
    love.graphics.setColor(0,0,0)
    love.graphics.circle('line', self.x, self.y, tileRadius, 6)
    
    if (not (self.data.unit == 0)) then
        self.data.unit:draw()
    end
end

function tile:drawBorder()
    love.graphics.setColor(0,1,0)
    love.graphics.setLineWidth(tileRadius/10)
    love.graphics.circle('line', self.x, self.y, tileRadius-(tileRadius/10), 6)
end

function tile:highlightNear(highlight)
    for y = 1, MapSize do
        for x = 1, MapSize do
            local nearX = tiles[y][x].girdX*((tileRadius/1.34)*tileSpacing) - tileRadius/2
            local nearY = tiles[y][x].girdY*((tileInnerRadius)*tileSpacing)

            if (tiles[y][x].girdX % 2 == 0) then
                nearY = nearY - tileInnerRadius
            end
            
            if (not (self.data.unit == 0)) then
                if (self:getDistance(nearX, nearY, self.x, self.y) < self.data.unit.moveSpeed*(tileRadius*tileSpacing)) then
                    if (not (tiles[y][x] == self)) then
                        tiles[y][x].highlight = highlight
                    end
                end
            end
        end
    end
end

function tile:getDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end
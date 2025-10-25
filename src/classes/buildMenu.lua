buildMenu = {}
buildMenu.__index = buildMenu

function buildMenu.new(settings)
    local self = setmetatable({}, buildMenu)

    self.x = windowWidth-(windowWidth/3)
    self.y = 0
    self.width = windowWidth/3
    self.height = windowHeight

    self.world = settings.world
    self.canBuild = false

    self.buildables = {
        "barracks",
        "city"
    }
    self.buildablesCost = {
        50,
        100
    }

    return self
end

function buildMenu:update(dt)
end

function buildMenu:draw()
    love.graphics.setColor(0.8,0.8,0.8,0.7)
    if (Player.phases[Player.currentPhase] == "build") then
        if ((not (Player.selectedTile == 0)) and (Player.selectedTile.data.building == 0)) then

            self.canBuild = false
            for y = 1, self.world.MapSize do
                for x = 1, self.world.MapSize do
                    local nearX = self.world.tiles[y][x].x
                    local nearY = self.world.tiles[y][x].y
                    
                    if (getDistance(nearX, nearY, Player.selectedTile.x, Player.selectedTile.y) < 1*(self.world.tileRadius*self.world.tileSpacing)) then
                        if (not (self.world.tiles[y][x] == Player.selectedTile)) then
                            if (not (self.world.tiles[y][x].data.building == 0)) then
                                self.canBuild = self.world.tiles[y][x].data.building.type == "city"
                                if (self.canBuild == true) then
                                    break
                                end
                            end
                        end
                    end
                end
                if (self.canBuild == true) then
                    break
                end
            end

            if (self.canBuild == true) then
                love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
                for i = 1, #self.buildables do
                    love.graphics.setColor(1,0.8,0.8,0.7)
                    love.graphics.rectangle("fill", self.x+4, ((i-1)*(self.height/#self.buildables))+2, self.width-8, (self.height/#self.buildables)-4)
                    love.graphics.setColor(0,0,0)
                    love.graphics.print(self.buildables[i].." Cost: "..self.buildablesCost[i], self.x+4, ((i-1)*(self.height/#self.buildables))+2)
                    if (isMouseOver(self.x+4, ((i-1)*(self.height/#self.buildables))+2, self.width-8, (self.height/#self.buildables)-4)) then
                        if love.mouse.isDown(1) then
                            if (Player.selectedTile.data.building == 0) then
                                Player.selectedTile.data.building = building.new({x = Player.selectedTile.girdX, y = Player.selectedTile.girdY, world = self.world, type = self.buildables[i]})
                            end
                        end
                    end
                end
            end
        end
    end
end
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
        self.coolDown = 0
        self.maxCoolDown = 3
        self.coolDownDone = false
    end

    self.team = 0

    return self
end

function building:update(dt)
    self.x = self.world.x+(self.girdX*((self.world.tileRadius/1.34)*self.world.tileSpacing) - self.world.tileRadius/2)
    self.y = self.world.y+(self.girdY*((self.world.tileInnerRadius)*self.world.tileSpacing))
    if (self.girdX % 2 == 0) then
        self.y = self.y - self.world.tileInnerRadius
    end

    if (self.type == "barracks") then
        if (self.team == Player.team) then
            if self.produced == false then
                if (Player.phases[Player.currentPhase] == "move") then
                    self.produced = true
                    self.coolDown = self.maxCoolDown

                    if (self.world.tiles[self.girdY][self.girdX].data.unit == 0) then
                        if onlineGame == true then
                            self.world.tiles[self.girdY][self.girdX].data.unit = unit.new({type = "basic", moveSpeed = unitTypes["basic"].moveSpeed, x = self.world.tiles[self.girdY][self.girdX].girdX, y = self.world.tiles[self.girdY][self.girdX].girdY, world = World})  
                            if (isHost == true) then 
                                for i = 1, #players do
                                   sendWorld(players[i].event)
                                end
                            else
                                host:service(10)
                                server:send("makeUnit:"..self.world.tiles[self.girdY][self.girdX].girdX..":"..self.world.tiles[self.girdY][self.girdX].girdY..":".."basic"..":"..self.coolDown..":"..Player.team..";")
                            end
                        end
                    end
                end
            else
                if (Player.phases[Player.currentPhase] == "done") then
                    if (self.coolDownDone == false) then
                        self.coolDown = self.coolDown - 1
                        if (isHost == true) then 
                            for i = 1, #players do
                                sendWorld(players[i].event)
                            end
                        else
                            host:service(10)
                            server:send("updateCoolDown:"..self.world.tiles[self.girdY][self.girdX].girdX..":"..self.world.tiles[self.girdY][self.girdX].girdY..":"..self.coolDown..";")
                        end
                        if (self.coolDown == 0) then
                            self.produced = false
                        end
                        self.coolDownDone = true
                    end
                elseif (Player.phases[Player.currentPhase] == "move") then
                    self.coolDownDone = false
                end
            end
        end
    end
end

function building:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.x, self.y, self.world.tileInnerRadius/2)
    
    if (self.type == "barracks") then
        love.graphics.setColor(1,1,1)
        love.graphics.print(self.coolDown, self.x, self.y)
    end
end
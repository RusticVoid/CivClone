nextPhase = {}
nextPhase.__index = nextPhase

function nextPhase.new()
    local self = setmetatable({}, nextPhase)

    self.x = 0
    self.y = 0
    self.nextPhase = Player.currentPhase+1
    if (self.nextPhase > #Player.phases) then
        self.nextPhase = 1
    end
    self.width = font:getWidth(Player.phases[Player.currentPhase].."->"..Player.phases[self.nextPhase])
    self.height = font:getHeight()

    self.coolDown = 1

    return self
end

function nextPhase:update(dt)
    self.nextPhase = Player.currentPhase+1
    if (self.nextPhase > #Player.phases) then
        self.nextPhase = 1
    end
    self.width = font:getWidth(Player.phases[Player.currentPhase].."->"..Player.phases[self.nextPhase])
    self.height = font:getHeight()

    self.coolDown = self.coolDown - (1*dt)
end

function nextPhase:draw()
    if (Player.phases[Player.currentPhase] == "done") then
        self.width = font:getWidth("waiting")
        self.height = font:getHeight()

        love.graphics.setColor(0.5,0.5,1)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        
        love.graphics.setColor(0,0,0)
        love.graphics.print("waiting", self.x, self.y)
    else
        love.graphics.setColor(0.5,1,0.5)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        love.graphics.setColor(0,0,0)
        love.graphics.print(Player.phases[Player.currentPhase].."->"..Player.phases[self.nextPhase], self.x, self.y)
        if (isMouseOver(self.x, self.y, self.width, self.height)) then
            if ((love.mouse.isDown(1)) and (self.coolDown < 0)) then
                self.coolDown = 1
                Player.currentPhase = self.nextPhase
            end
        end
    end
end
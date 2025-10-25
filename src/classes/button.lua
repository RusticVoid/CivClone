button = {}
button.__index = button

function button.new(settings)
    local self = setmetatable({}, button)

    self.x = settings.x or 0
    self.y = settings.y or 0

    self.text = settings.text
    self.font = settings.font
    self.font:setFilter("nearest")

    self.width = self.font:getWidth(self.text)
    self.height = self.font:getHeight()

    self.color = settings.color

    self.code = settings.code

    self.defaultCoolDown = 0.5
    self.coolDown = 0

    self.hovered = false

    return self
end

function button:update(dt)
    self.coolDown = self.coolDown - (1*dt)
    if (isMouseOver(self.x-(self.width/2), self.y-(self.height/2), self.width, self.height)) then
        self.hovered = true
        if ((love.mouse.isDown(1)) and (self.coolDown < 0)) then
            self.coolDown = self.defaultCoolDown
            local func, err = load(self.code)
            if func then
                func()
            else
                print("Error loading code from string. "..err)
            end
        end
    else
        self.hovered = false
    end
end

function button:draw()
    love.graphics.setFont(self.font)

    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x-(self.width/2), self.y-(self.height/2), self.width, self.height)

    if (self.hovered == true) then
        love.graphics.setColor(1,1,1,0.5)
        love.graphics.rectangle("fill", self.x-(self.width/2), self.y-(self.height/2), self.width, self.height)
    end

    love.graphics.setColor(0,0,0)
    love.graphics.print(self.text, self.x-(self.width/2), self.y-(self.height/2))

end
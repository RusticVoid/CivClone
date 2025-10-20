
temp = {}
temp.__index = temp

function temp.new()
    local self = setmetatable({}, temp)
    return self
end

function temp:update(dt)
end

function temp:draw()
end






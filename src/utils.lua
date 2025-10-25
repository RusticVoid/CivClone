function isMouseOver(x, y, width, height)
    if mouseX > x and mouseX < x+width
    and mouseY > y and mouseY < y+height then
        return true
    end
end

function getDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end
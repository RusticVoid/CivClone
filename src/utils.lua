function isMouseOver(x, y, width, height)
    if mouseX > x and mouseX < x+width
    and mouseY > y and mouseY < y+height then
        return true
    end
end

function getDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function initGame(MapSize)
    World = world.new({tileRadius = 30, tileSpacing = 2, MapSize = MapSize})
    Player = player.new({camSpeed = 50, world = World})
    BuildMenu = buildMenu.new({world = World})
    NextPhase = nextPhase.new()
end

--NETWORKING

function sendWorld(event)
    tileStringList = ""
    for y = 1, World.MapSize do
        for x = 1, World.MapSize do
            local buildingType = 0
            if (not (World.tiles[y][x].data.building == 0)) then
                buildingType = World.tiles[y][x].data.building.type
            end

            tileStringList = tileStringList..x..":"..y..":".."0"..":"..buildingType..";"
        end
    end
    event.peer:send("MAP;"..tileStringList)
end

function decryptWorld(event)
    netTiles = {}
    k = 1
    netTiles[k] = ""
    for i = 5, #event.data do
        netTiles[k] = netTiles[k]..event.data:sub(i, i)
        if (event.data:sub(i, i) == ";") then
            k = k + 1
            netTiles[k] = ""
        end
    end
    for i = 1, #netTiles-1 do
        local lookingForList = {"x", "y", "unit", "buildingType"}
        local lookingFor = 1
        local x = ""
        local y = ""
        local unit = ""
        local buildingType = ""
        for k = 1, #netTiles[i] do
            if (netTiles[i]:sub(k, k) == ":") then
                lookingFor = lookingFor + 1
            elseif (netTiles[i]:sub(k, k) == ";") then
                break
            else
                if (lookingForList[lookingFor] == "x") then
                    x = x..netTiles[i]:sub(k, k)
                end
                if (lookingForList[lookingFor] == "y") then
                    y = y..netTiles[i]:sub(k, k)
                end
                if (lookingForList[lookingFor] == "unit") then
                    unit = unit..netTiles[i]:sub(k, k)
                end
                if (lookingForList[lookingFor] == "buildingType") then
                    buildingType = buildingType..netTiles[i]:sub(k, k)
                end
            end
        end
        World.tiles[tonumber(y)][tonumber(x)] = tile.new({x = tonumber(x), y = tonumber(y), world = World})
        if (not (buildingType == "0")) then
            World.tiles[tonumber(y)][tonumber(x)].data.building = building.new({type = buildingType, x = tonumber(x), y = tonumber(y), world = World})
        end
    end
end

function decryptBuild(event)
    local lookingForList = {"x", "y", "buildingType"}
    local lookingFor = 1
    local x = ""
    local y = ""
    local buildingType = ""
    for k = 7, #event.data do
        if (event.data:sub(k, k) == ":") then
            lookingFor = lookingFor + 1
        elseif (event.data:sub(k, k) == ";") then
            break
        else
            if (lookingForList[lookingFor] == "x") then
                x = x..event.data:sub(k, k)
            end
            if (lookingForList[lookingFor] == "y") then
                y = y..event.data:sub(k, k)
            end
            if (lookingForList[lookingFor] == "buildingType") then
                buildingType = buildingType..event.data:sub(k, k)
            end
        end
    end
    World.tiles[tonumber(y)][tonumber(x)].data.building = building.new({type = buildingType, x = tonumber(x), y = tonumber(y), world = World})
    for i = 1, #players do 
        sendWorld(players[i].event)
    end
end
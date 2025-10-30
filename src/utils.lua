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

function initUnits()
    unitTypes = {}
    unitTypes["basic"] = {moveSpeed = 1}
end

--NETWORKING

function sendWorld(event)
    tileStringList = ""
    for y = 1, World.MapSize do
        for x = 1, World.MapSize do
            local buildingType = 0
            local buildingProduced = 0
            if (not (World.tiles[y][x].data.building == 0)) then
                buildingType = World.tiles[y][x].data.building.type
                if (buildingType == "barracks") then
                    if (World.tiles[y][x].data.building.produced) then
                        buildingProduced = 1
                    end
                end
            end

            local unitType = 0
            local unitMoved = 0
            if (not (World.tiles[y][x].data.unit == 0)) then
                unitType = World.tiles[y][x].data.unit.type
                if (World.tiles[y][x].data.unit.moved) then
                    unitMoved = 1
                end
            end

            tileStringList = tileStringList..x..":"..y..":"..unitType..":"..unitMoved..":"..buildingType..":"..buildingProduced..";"
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
        local lookingForList = {"x", "y", "unitType", "unitMoved", "buildingType", "buildingProduced"}
        local lookingFor = 1
        local x = ""
        local y = ""
        local unitType = ""
        local unitMoved = ""
        local buildingType = ""
        local buildingProduced = ""
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
                if (lookingForList[lookingFor] == "unitMoved") then
                    unitMoved = unitMoved..netTiles[i]:sub(k, k)
                end
                if (lookingForList[lookingFor] == "unitType") then
                    unitType = unitType..netTiles[i]:sub(k, k)
                end
                if (lookingForList[lookingFor] == "buildingType") then
                    buildingType = buildingType..netTiles[i]:sub(k, k)
                end
                if (lookingForList[lookingFor] == "buildingProduced") then
                    buildingProduced = buildingProduced..netTiles[i]:sub(k, k)
                end
            end
        end
        World.tiles[tonumber(y)][tonumber(x)] = tile.new({x = tonumber(x), y = tonumber(y), world = World})
        if (not (buildingType == "0")) then
            World.tiles[tonumber(y)][tonumber(x)].data.building = building.new({type = buildingType, x = tonumber(x), y = tonumber(y), world = World})
            if (buildingType == "barracks") then
                if (buildingProduced == "1") then
                    World.tiles[tonumber(y)][tonumber(x)].data.building.produced = true
                else
                    World.tiles[tonumber(y)][tonumber(x)].data.building.produced = false
                end
            end
        end
        if (not (unitType == "0")) then
            World.tiles[tonumber(y)][tonumber(x)].data.unit = unit.new({type = unitType, moveSpeed = unitTypes[unitType].moveSpeed, x = tonumber(x), y = tonumber(y), world = World})
            if (unitMoved == "1") then
                World.tiles[tonumber(y)][tonumber(x)].data.unit.moved = true
            else
                World.tiles[tonumber(y)][tonumber(x)].data.unit.moved = false
            end
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

function decryptUnit(event)
    local lookingForList = {"x", "y", "unitType"}
    local lookingFor = 1
    local x = ""
    local y = ""
    local unitType = ""
    for k = 6, #event.data do
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
            if (lookingForList[lookingFor] == "unitType") then
                unitType = unitType..event.data:sub(k, k)
            end
        end
    end
    World.tiles[tonumber(y)][tonumber(x)].data.unit = unit.new({type = unitType, moveSpeed = unitTypes[unitType].moveSpeed, x = tonumber(x), y = tonumber(y), world = World})
    for i = 1, #players do 
        sendWorld(players[i].event)
    end
end

function decryptMovedUnit(event)
    local lookingForList = {"x", "y", "newx", "newy"}
    local lookingFor = 1
    local x = ""
    local y = ""
    local newx = ""
    local newy = ""
    for k = 11, #event.data do
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
            if (lookingForList[lookingFor] == "newx") then
                newx = newx..event.data:sub(k, k)
            end
            if (lookingForList[lookingFor] == "newy") then
                newy = newy..event.data:sub(k, k)
            end
        end
    end

    moveUnit(World.tiles[tonumber(newy)][tonumber(newx)], World.tiles[tonumber(y)][tonumber(x)])
    for i = 1, #players do 
        sendWorld(players[i].event)
    end
end

function moveUnit(newtile, tile)
    newtile.data.unit = tile.data.unit
    newtile.data.unit.moved = true
    newtile.data.unit.girdX = newtile.girdX
    newtile.data.unit.girdY = newtile.girdY
    tile:highlightNear(false)
    tile.data.unit = 0
end
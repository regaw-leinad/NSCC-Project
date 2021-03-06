--[[
    ent_terrain.lua
    Randomly generated terrain

    Authors:
        Dan Wager
        Daniel Rolandi
--]]

local terrain = EntityManager.derive("base")

-- Daniel Rolandi's random terrain generation
-- @param xStart The starting X value
-- @param yStart The starting Y value
-- @param wMin The minimum width between vertices
-- @param wBuff The maximum width between vertices
-- @param hBuff The maximum height change between vertices
-- @return The table of verticies in the polygon
local function generateTerrain(xStart, yStart, wMin, wBuff, hBuff)
    math.randomseed(os.time())

    local v = {
        0,
        math.random(yStart - hBuff, yStart + hBuff)
    }

    -- current vertex
    local current = {
        x = v[1],
        y = v[2]
    }

    -- we want to start appending at position 3 later
    local count = 2

    while current.x < SCREEN_WIDTH do

        -- compute the next vertex we want to generate
        -- uses math.min and math.max to prevent off-screen vertices
        local target = {
            x = math.random(math.min(SCREEN_WIDTH, current.x + wMin), math.min(SCREEN_WIDTH, current.x + wBuff)),
            y = math.random(math.max(0, current.y - hBuff), math.min(SCREEN_HEIGHT, current.y + hBuff))
        }

        current.x = target.x
        current.y = target.y

        count = count + 1
        v[count] = current.x
        count = count + 1
        v[count] = current.y
    end

    -- must add two extra vertices: bottom-right and bottom-left corner
    count = count + 1
    v[count] = SCREEN_WIDTH
    count = count + 1
    v[count] = SCREEN_HEIGHT

    count = count + 1
    v[count] = 0
    count = count + 1
    v[count] = SCREEN_HEIGHT

    return v
end

-- Initial set up of the entity
-- @param data Table of arguments
function terrain:load(data)
    -- Init data if not passed so we don't have errors
    if not data then data = {} end

    local widthMin = data.widthMin or 10
    local widthBuf = data.widthBuf or 50
    local heightBuf = data.heightBuf or 20
    local startX = data.startX or 0
    local startY = data.startY or 450

    self.coords = generateTerrain(startX, startY, widthMin, widthBuf, heightBuf)
    self.cutPoly = polygonCut(SCREEN_WIDTH / 2, SCREEN_HEIGHT, self.coords)
    self.terrain = TextureManager.makeTexturedPoly(self.coords, self.cutPoly, TextureManager.getImageData(data.texture))
end

-- Draws the entity on screen
function terrain:draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.terrain, 0, SCREEN_HEIGHT - self.terrain:getHeight() + 1)

    if DEBUG then
        love.graphics.setColor(255, 0, 0, 255)
        for _,pol in ipairs(self.cutPoly) do
            love.graphics.polygon("line", pol)
        end
    end
end

-- Gets the table of coordinates that make up the terrain
-- @return The coordinates of the terrain's polygon (table)
function terrain:getCoords()
    return self.coords
end

-- Gets a value indicating how many values are in the coordinate table not including the last 2 points
-- @return Number of values in the coordinates table not including the last 2 points (int)
function terrain:getPointCount()
    return #self.coords - 4
end

return terrain

--Modules
local graphics = require "graphics"

local marching_cubes = require "world/marching_cubes"
local chunk = require "world/chunk"
local generation = require "world/generation"

local world = {}

WorldWidth, WorldLength = 256, 256

Chunks = {}

local renderedChunks = {}
local storedChunks = {}

function world.load()
    Seed = love.math.random() * 1000000.0

    --Initialize chunk grid with the center at [0, 0], the one benefit of lua!
    Chunks = {}
    for x = -WorldWidth / 2, WorldWidth / 2 do 
        Chunks[x] = {}
        for z = -WorldLength / 2, WorldLength / 2 do 
            Chunks[x][z] = nil
        end
    end
end

local floor = math.floor
local pow = math.pow
function world.update()
    renderedChunks = {}
    storedChunks = {}

    local originX, originZ = CameraPosition.X / ChunkWidth - 0.5, CameraPosition.Z / ChunkLength - 0.5
    --Loop through area close to camera position
    for x = floor(originX - RenderDistance), floor(originX + RenderDistance) do

        for z = floor(originZ - RenderDistance), floor(originZ + RenderDistance) do
            --Only render Chunks with a distance less than render distance to camera position
            if math.sqrt(pow(x - originX, 2.0) + pow(z - originZ, 2.0)) < RenderDistance then
                --Make sure chunk is within world
                if (Chunks[x] ~= nil) then
                    --Create Chunks that do not exist but should
                    if Chunks[x][z] == nil then
                        Chunks[x][z] = chunk.newChunk(x, z)
                        table.insert(storedChunks, Chunks[x][z])
                    else
                        --Add them to a table for later drawing
                        table.insert(renderedChunks, Chunks[x][z])
                    end
                end
            end
        end
    end
    for i = 1, #storedChunks do
        storedChunks[i].willUnload = true
    end
    for i = 1, #renderedChunks do
        --This is to handle updates all at once rather than after every modification
        if renderedChunks[i].updateNeeded == true then
            marching_cubes.generateTriangles(renderedChunks[i])
            renderedChunks[i].updateNeeded = false
        end
        renderedChunks[i].willUnload = false
    end
    for i = 1, #storedChunks do
        if storedChunks[i].willUnload == true then 
            storedChunks[i].triangles = nil
            storedChunks[i].updateNeeded = true
        end
    end
end

function world.addPointValue(x, y, z, w)
    --Don't do anything if point is below or above chunk limits
    if y < 0 or y > Chunkheight then return end

    chunkX, chunkZ = floor(x / ChunkWidth), floor(z / ChunkLength)
    pointX, pointY, pointZ = floor(x % ChunkWidth), floor(y), floor(z % ChunkLength)
    if Chunks[chunkX] == nil then return end
    if Chunks[chunkX][chunkZ] == nil then return end
    local chunk = Chunks[chunkX][chunkZ]
    local point = chunk.points[pointX][pointY][pointZ]

    point.W = point.W + w

    chunk.updateNeeded = true
    updateNeighbors(chunkX, chunkZ)
end

function world.getPointValue(x, y, z)
    --Don't do anything if point is below or above chunk limits
    if y < 0 or y > Chunkheight then return 0.0 end

    chunkX, chunkZ = floor(x / ChunkWidth), floor(z / ChunkLength)
    pointX, pointY, pointZ = floor(x % ChunkWidth), floor(y), floor(z % ChunkLength)
    if Chunks[chunkX] == nil then return end
    if Chunks[chunkX][chunkZ] == nil then return end
    local chunk = Chunks[chunkX][chunkZ]
    local point = chunk.points[pointX][pointY][pointZ]
    
    return point.W
end

function updateNeighbors(x, z)
    --Make sure that neighbors are loaded before updating
    if Chunks[x + 1][z] ~= nil then Chunks[x + 1][z].updateNeeded = true end
    if Chunks[x - 1][z] ~= nil then Chunks[x - 1][z].updateNeeded = true end
    if Chunks[x][z + 1] ~= nil then Chunks[x][z + 1].updateNeeded = true end
    if Chunks[x][z - 1] ~= nil then Chunks[x][z - 1].updateNeeded = true end
end

function world.drawChunks()
    for i = 1, #renderedChunks do
        local c = renderedChunks[i]
        graphics.drawTriangles(c.triangles)
        if c.meshTriangles ~= nil then
            graphics.drawTriangles(c.meshTriangles)
        end
    end
end

return world
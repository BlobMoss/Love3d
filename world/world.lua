--Modules
local graphics = require "graphics"
local marching_cubes = require "world/marching_cubes"

local world = {}

WorldWidth, WorldLength = 256, 256

Chunks = {}

ChunkWidth, Chunkheight, ChunkLength = 8, 32, 8

local renderedChunks = {}

function world.load()
    Seed = love.math.random() * 1000000.0

    --Initialize chunk grid with the center at [0, 0], the one benefit of lua!
    for x = -WorldWidth / 2, WorldWidth / 2 do 
        Chunks[x] = {}
    end
end

local floor = math.floor
local pow = math.pow
function world.update()
    renderedChunks = {}

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
                        Chunks[x][z] = newChunk(x, z)
                    else
                        --Add them to a table for later drawing
                        table.insert(renderedChunks, Chunks[x][z])
                    end
                end
            end
        end
    end
    for i = 1, #renderedChunks do
        if renderedChunks[i].updateNeeded == true then
            marching_cubes.generateTriangles(renderedChunks[i])
            renderedChunks[i].updateNeeded = false
        end
    end
end

function newChunk(x, z)
    local chunk = {} 
    chunk.X = x
    chunk.Z = z
    marching_cubes.generatePoints(chunk)
    chunk.updateNeeded = true
    updateNeighbors(x, z)
    return chunk
end

function world.setPointValue(x, y, z, w)
    chunkX, chunkZ = floor(x / ChunkWidth), floor(z / ChunkLength)
    pointX, pointY, pointZ = floor(x % ChunkWidth), floor(y), floor(z % ChunkLength)
    local chunk = Chunks[chunkX][chunkZ]
    local point = chunk.points[pointX][pointY][pointZ]
    point.W = point.W + w

    chunk.updateNeeded = true
    updateNeighbors(chunkX, chunkZ)
end

function updateNeighbors(x, z)
    if Chunks[x + 1][z] ~= nil then Chunks[x + 1][z].updateNeeded = true end
    if Chunks[x - 1][z] ~= nil then Chunks[x - 1][z].updateNeeded = true end
    if Chunks[x][z + 1] ~= nil then Chunks[x][z + 1].updateNeeded = true end
    if Chunks[x][z - 1] ~= nil then Chunks[x][z - 1].updateNeeded = true end
end

function world.drawChunks()
    for i = 1, #renderedChunks do
        graphics.drawMesh(renderedChunks[i])
    end
end

return world
--Modules
local graphics = require "graphics"
local marching_cubes = require "world/marching_cubes"

local world = {}

WorldWidth, WorldLength = 256, 256

local chunks = {}

ChunkWidth, Chunkheight, ChunkLength = 8, 24, 8

--This is the value to decrease if you need more performance
local renderDistance = 2.5

local renderedChunks = {}

function world.load()
    --Initialize chunk grid with the center at [0, 0], the one benefit of lua!
    for x = -WorldWidth / 2, WorldWidth / 2 do 
        chunks[x] = {}
    end
end

local floor = math.floor
local pow = math.pow
function world.update()
    renderedChunks = {}

    local originX, originZ = CameraPosition.X / ChunkWidth, CameraPosition.Z / ChunkLength
    --Loop through area close to camera position
    for x = floor(originX - renderDistance), floor(originX + renderDistance) do

        for z = floor(originZ - renderDistance), floor(originZ + renderDistance) do
            --Only render chunks with a distance less than render distance to camera position
            if math.sqrt(pow(x - originX, 2) + pow(z - originZ, 2)) < renderDistance then
                --Make sure chunk is within world
                if (chunks[x] ~= nil) then
                    --Create chunks that do not exist but should
                    if chunks[x][z] == nil then
                        chunks[x][z] = newChunk(x, z)
                    else
                    --Add them to a table for later drawing
                    table.insert(renderedChunks, chunks[x][z])
                    end
                end
            end
        end
    end
end

function newChunk(x, z)
    local chunk = {} 
    chunk.triangles = marching_cubes.generate(x * ChunkWidth, z * ChunkLength)
    return chunk
end

function world.drawChunks()
    for i = 1, #renderedChunks do
        graphics.drawMesh(renderedChunks[i])
    end
end

return world
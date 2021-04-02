--Math
local vector = require "math/vector"
local matrix = require "math/matrix"
local triangle = require "math/triangle"

--Modules
local graphics = require "graphics"
local marching_cubes = require "world/marching_cubes"

ChunkWidth, Chunkheight, ChunkLength = 8, 24, 8

local world = {}

local chunks = {}

function world.load()
    local chunk = {} 
    chunk.triangles = marching_cubes.generate(0, 0)
    table.insert(chunks, chunk)

    local chunk = {} 
    chunk.triangles = marching_cubes.generate(8, 0)
    table.insert(chunks, chunk)

    local chunk = {} 
    chunk.triangles = marching_cubes.generate(0, 8)
    table.insert(chunks, chunk)

    local chunk = {} 
    chunk.triangles = marching_cubes.generate(8, 8)
    table.insert(chunks, chunk)
end

function world.update()

end

function world.drawChunks()
    for i = 1, #chunks do
        graphics.drawMesh(chunks[i])
    end
end

return world
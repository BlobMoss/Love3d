local generation = require("world/generation")

local chunk = {}

ChunkWidth, Chunkheight, ChunkLength = 8, 32, 8

function chunk.generatePoints(chunk)
    local points = {}

    for x = 0, ChunkWidth do 
        points[x] = {}
        for y = 0, Chunkheight do 
            points[x][y] = {}
            for z = 0, ChunkLength do 
                local point = vector3(x + ChunkWidth * chunk.X, y, z + ChunkLength * chunk.Z)

                point.W = generation.generatePointValue(x + ChunkWidth * chunk.X, y, z + ChunkLength * chunk.Z)

                points[x][y][z] = point
            end
        end
    end

    chunk.points = points
end

return chunk
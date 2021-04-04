--Math
local vector = require "math/vector"

local tri_table = require "tri_table"

local marching_cubes = {}

--Points with a value lesser than the surface value are considered to be inside the mesh
local surfaceLevel = 8.0

function marching_cubes.generatePoints(chunk)
    local points = {}

    for x = 0, ChunkWidth do 
        points[x] = {}
        for y = 0, Chunkheight do 
            points[x][y] = {}
            for z = 0, ChunkLength do 
                local point = vector3(x + ChunkWidth * chunk.X, y, z + ChunkLength * chunk.Z)

                point.W = generatePointValue(x + ChunkWidth * chunk.X, y, z + ChunkLength * chunk.Z)

                points[x][y][z] = point
            end
        end
    end

    chunk.points = points
end

function generatePointValue(x, y, z)
    --This is where the world generation happens!
    local value = 0.0
    value = value + noise(x, y, z, 0.01, 0.7) --General shape
    value = value + noise(x, y, z, 0.15, 0.7) --Details
    value = value * 16 - y * 0.5 --More mass further down
    return value
end

function noise(x, y, z, frequency, amplitude)
    return love.math.noise(
        x * frequency, 
        y * frequency, 
        z * frequency
    ) * amplitude
end

function marching_cubes.generateTriangles(chunk)
    triangles = {}

    points = chunk.points

    for x = 0, ChunkWidth do 
        for y = 0, Chunkheight - 1 do 
            for z = 0, ChunkLength do 
                if x == ChunkWidth and chunks[chunk.X + 1][chunk.Z] ~= nil then
                    points[x][y][z] = chunks[chunk.X + 1][chunk.Z].points[0][y][z]
                end
                if z == ChunkLength and chunks[chunk.X][chunk.Z + 1] ~= nil then
                    points[x][y][z] = chunks[chunk.X][chunk.Z + 1].points[x][y][0]
                end
                if x ~= ChunkWidth and z ~= ChunkLength then 
                    march(x, y, z)
                end
            end
        end
    end
    
    chunk.triangles = triangles
end

function march(x, y, z)
    --Create a table containing ever corner of a cube
    local cubeCorners = {
        points[x    ][y    ][z    ],
        points[x + 1][y    ][z    ],
        points[x + 1][y    ][z + 1],
        points[x    ][y    ][z + 1],
        points[x    ][y + 1][z    ],
        points[x + 1][y + 1][z    ],
        points[x + 1][y + 1][z + 1],
        points[x    ][y + 1][z + 1],
    }

    --Generate 8 bit number (cubeIndex) based on which nodes have a value below the surface level
    local cubeIndex = 1
    for i = 1, 8 do
        if cubeCorners[i].W < surfaceLevel then 
            cubeIndex = cubeIndex + math.pow(2, i - 1) 
        end
    end

    --Find which triangles correspond to that index
    local configuration = tri_table.triangulation[cubeIndex]
    --Vertices are stored in groups of 3 to form triangles
    for i = 0, #configuration - 1, 3 do 
        local a1 = tri_table.cornerIndexAFromEdge[tri_table.triangulation[cubeIndex][i + 1]]
        local b1 = tri_table.cornerIndexBFromEdge[tri_table.triangulation[cubeIndex][i + 1]]

        local a2 = tri_table.cornerIndexAFromEdge[tri_table.triangulation[cubeIndex][i + 2]]
        local b2 = tri_table.cornerIndexBFromEdge[tri_table.triangulation[cubeIndex][i + 2]]

        local a3 = tri_table.cornerIndexAFromEdge[tri_table.triangulation[cubeIndex][i + 3]]
        local b3 = tri_table.cornerIndexBFromEdge[tri_table.triangulation[cubeIndex][i + 3]]

        local triangle = {
            interpolateVerts(cubeCorners[a1], cubeCorners[b1]),
            interpolateVerts(cubeCorners[a2], cubeCorners[b2]),
            interpolateVerts(cubeCorners[a3], cubeCorners[b3]),
            color = vector3(y / Chunkheight, 0.3, 0.3)
        }
        table.insert(triangles, triangle)
    end
end

function interpolateVerts(v1, v2)
    --Bring vertex closer to points higher values
    local t = (surfaceLevel - v1.W) / (v2.W - v1.W)
    --t = 0.5 --(Enable for no interpolation)
    local o = vector.sub(v2, v1)
    o = vector.mul(o, t)
    o = vector.add(v1, o)
    return o
end

return marching_cubes
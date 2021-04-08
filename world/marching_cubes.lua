--Math
local vector = require "math/vector"

local tri_table = require "tri_table"

local marching_cubes = {}

--Points with a value lesser than the surface value are considered to be inside the mesh
SurfaceLevel = 8.0

function marching_cubes.generateTriangles(chunk)
    triangles = {}

    points = chunk.points

    for x = 0, ChunkWidth do 
        for y = 0, Chunkheight - 1 do 
            for z = 0, ChunkLength do 
                if x == ChunkWidth and Chunks[chunk.X + 1][chunk.Z] ~= nil then
                    points[x][y][z] = Chunks[chunk.X + 1][chunk.Z].points[0][y][z]
                end
                if z == ChunkLength and Chunks[chunk.X][chunk.Z + 1] ~= nil then
                    points[x][y][z] = Chunks[chunk.X][chunk.Z + 1].points[x][y][0]
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
        if cubeCorners[i].W < SurfaceLevel then 
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
    local t = (SurfaceLevel - v1.W) / (v2.W - v1.W)
    --t = 0.5 --(Enable for no interpolation)
    local o = vector.sub(v2, v1)
    o = vector.mul(o, t)
    o = vector.add(v1, o)
    return o
end

return marching_cubes
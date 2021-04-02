--Math
local vector = require "math/vector"

local tri_table = require "tri_table"

local marching_cubes = {}

local surfaceLevel = 8.0
--local pointsPerAxis = 16

local triangles = {}
local points = {}

--[[
function indexOfPoint(x, y, z)
    return z * pointsPerAxis * pointsPerAxis + y * pointsPerAxis + x
end
]]

function interpolateVerts(v1, v2)
    --Bring vertex closer to higher surface values
    local t = (surfaceLevel - v1.W) / (v2.W - v1.W)
    --t = 0.5 no interpolation
    local o = vector.sub(v2, v1)
    o = vector.mul(o, t)
    o = vector.add(v1, o)
    return o
end

function marching_cubes.generate(offsetX, offsetZ)
    triangles = {}
    points = {}

    for x = offsetX, ChunkWidth + offsetX do 
        points[x] = {}
        for y = 0, Chunkheight do 
            points[x][y] = {}
            for z = offsetZ, ChunkLength + offsetZ do 
                local point = vector3(x, y, z)

                point.W = generatePointValue(x, y, z)

                points[x][y][z] = point
            end
        end
    end

    --[[
    for x = 1, pointsPerAxis do 
        for y = 1, pointsPerAxis do 
            for z = 1, pointsPerAxis do 
                local point = vector3(x, y, z)

                point.W = generatePointValue(x + offsetX, y, z + offsetZ)

                points[indexOfPoint(x, y, z)] = point
            end
        end
    end
    ]]

    for x = offsetX, ChunkWidth + offsetX - 1 do 
        for y = 0, Chunkheight - 1 do 
            for z = offsetZ, ChunkLength + offsetZ - 1 do 
                march(points[x][y][z])
            end
        end
    end

    return triangles
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

function march(point)

    --Create a table containing ever corner of a cube
    local cubeCorners = {
        points[point.X]    [point.Y]    [point.Z],
        points[point.X + 1][point.Y]    [point.Z],
        points[point.X + 1][point.Y]    [point.Z + 1],
        points[point.X]    [point.Y]    [point.Z + 1],
        points[point.X]    [point.Y + 1][point.Z],
        points[point.X + 1][point.Y + 1][point.Z],
        points[point.X + 1][point.Y + 1][point.Z + 1],
        points[point.X]    [point.Y + 1][point.Z + 1],
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
            color = vector3(point.Y / Chunkheight, 0.3, 0.3)
        }
        table.insert(triangles, triangle)
    end
end

return marching_cubes
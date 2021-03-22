local marching_cubes = {}

local vector = require "vector"

local tri_table = require "tri_table"

local isoLevel = 8.0
local pointsPerAxis = 32
local points = {}

local triangles = {}

function indexOfPoint(x, y, z)
    return z * pointsPerAxis * pointsPerAxis + y * pointsPerAxis + x
end

function interpolateVerts(v1, v2)
    --Bring vertex closer to higher iso values
    local t = (isoLevel - v1.W) / (v2.W - v1.W)
    --t = 0.5
    local o = vector.sub(v2, v1)
    o = vector.mul(o, t)
    o = vector.add(v1, o)
    return o
end

function marching_cubes.generate()
    for x = 1, pointsPerAxis do 
        for y = 1, pointsPerAxis do 
            for z = 1, pointsPerAxis do 
                local v4 = vector3(x, y, z)
                --This will be some proper world generation at some point but noise looks fine for now
                v4.W = love.math.noise((x + love.math.random()) * 0.1, (y + love.math.random()) * 0.1, (z + love.math.random()) * 0.1) * 32 - y * 0.5
                points[indexOfPoint(x, y, z)] = v4
            end
        end
    end

    for i = 1, #points do 
        if (points[i] ~= nil) then 
            march(points[i])
        end
    end

    return triangles
end

function march(v)
    --The final rows are included when point is turned into cube
    if (v.X >= pointsPerAxis - 1 or v.Y >= pointsPerAxis - 1 or v.Z >= pointsPerAxis - 1) then 
        return
    end

    --Create a table containing ever corner of a cube
    local cubeCorners = {
        points[indexOfPoint(v.X,     v.Y,     v.Z    )],
        points[indexOfPoint(v.X + 1, v.Y,     v.Z    )],
        points[indexOfPoint(v.X + 1, v.Y,     v.Z + 1)],
        points[indexOfPoint(v.X,     v.Y,     v.Z + 1)],
        points[indexOfPoint(v.X,     v.Y + 1, v.Z    )],
        points[indexOfPoint(v.X + 1, v.Y + 1, v.Z    )],
        points[indexOfPoint(v.X + 1, v.Y + 1, v.Z + 1)],
        points[indexOfPoint(v.X,     v.Y + 1, v.Z + 1)]
    }

    local cubeIndex = 1

    --Generate 8 bit number based on which nodes have a value below the iso level
    for i = 1, 8 do
        if cubeCorners[i].W < isoLevel then cubeIndex = cubeIndex + math.pow(2, i - 1) end
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
            color = vector3(v.Y / pointsPerAxis, 0.3, 0.3)
        }
        table.insert(triangles, triangle)
    end
end

return marching_cubes
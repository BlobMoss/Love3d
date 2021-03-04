local marching_cubes = {}

local tri_table = require "tri_table"
local vector = require "vector"

local isoLevel = 14.0
local pointsPerAxis = 12

local points = {}

marching_cubes.triangles = {}

function indexOfPoint(x, y, z)
    return z * pointsPerAxis * pointsPerAxis + y * pointsPerAxis + x
end

function interpolateVerts(v1, v2)
    local t = (isoLevel - v1.W) / (v2.W - v1.W)
    local t = 0.5
    return vector.add(v1, vector.mul(vector.sub(v2, v1), t))
end

function marching_cubes.load()
    for x = 1, pointsPerAxis, 1 do 
        for y = 1, pointsPerAxis, 1 do 
            for z = 1, pointsPerAxis, 1 do 
                local v4 = vector3(x, y, z)
                v4.W = love.math.noise((x + love.math.random()) * 0.15, (y + love.math.random()) * 0.15, (z + love.math.random()) * 0.15) * 32
                points[indexOfPoint(x, y, z)] = v4
            end
        end
    end

    for i = 1, #points, 1 do 
        if (points[i] ~= nil) then 
            march(points[i])
        end
    end
end

function march(v)
    if (v.X >= pointsPerAxis - 1 or v.Y >= pointsPerAxis - 1 or v.Z >= pointsPerAxis - 1) then 
        return
    end

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

    if cubeCorners[1].W < isoLevel then cubeIndex = cubeIndex + 1 end
    if cubeCorners[2].W < isoLevel then cubeIndex = cubeIndex + 2 end
    if cubeCorners[3].W < isoLevel then cubeIndex = cubeIndex + 4 end
    if cubeCorners[4].W < isoLevel then cubeIndex = cubeIndex + 8 end
    if cubeCorners[5].W < isoLevel then cubeIndex = cubeIndex + 16 end
    if cubeCorners[6].W < isoLevel then cubeIndex = cubeIndex + 32 end
    if cubeCorners[7].W < isoLevel then cubeIndex = cubeIndex + 64 end
    if cubeCorners[8].W < isoLevel then cubeIndex = cubeIndex + 128 end

    local triangles = tri_table.triangulation[cubeIndex]
    for i = 0, #triangles - 1, 3 do 
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
            color = vector3(0.8, 0.3, 0.3)
        }

        table.insert(marching_cubes.triangles, triangle)
    end
end

return marching_cubes
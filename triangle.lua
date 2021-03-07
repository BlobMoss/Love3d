local triangle = {}

local vector = require "vector"

--Function for copying table by value rather than by reference
function copyTriangle(t)
    return {
        copyVector3(t[1]), 
        copyVector3(t[2]), 
        copyVector3(t[3]),
        ["color"] = copyVector3(t.color)
    }
end

--Tables being passed as references actually worked out in my favour!
function triangle.clipAgainstPlane(planePoint, planeNormal, inputTri)
    --Normalize normal just in case
    planeNormal = vector.normalize(planeNormal)

    function triangle.pointDistanceToPlane(point)
        local normal = vector.normalize(point)
        return (planeNormal.X * point.X + planeNormal.Y * point.Y + planeNormal.Z * point.Z - vector.dot(planeNormal, planePoint))
    end

    local pointsInside = {}
    local pointsOutside = {}

    local dist1 = triangle.pointDistanceToPlane(inputTri[1])
    local dist2 = triangle.pointDistanceToPlane(inputTri[2])
    local dist3 = triangle.pointDistanceToPlane(inputTri[3])

    --Points with a positive distance to the plane are inside it
    if dist1 >= 0.0 then 
        table.insert(pointsInside, inputTri[1])
    else 
        table.insert(pointsOutside, inputTri[1])
    end   
    
    if dist2 >= 0.0 then 
        table.insert(pointsInside, inputTri[2])
    else 
        table.insert(pointsOutside, inputTri[2])
    end
    
    if dist3 >= 0.0 then 
        table.insert(pointsInside, inputTri[3])
    else 
        table.insert(pointsOutside, inputTri[3])
    end

    --No points inside plane means triangle can be discarded
    if #pointsInside == 0 then
        return {} 
    end

    if #pointsInside == 3 then
        --All points inside means that the entire triangle should remain intact
        return { inputTri } 
    end

    if #pointsInside == 1 and #pointsOutside == 2 then
        --This is to keep any other information like color data
        local outputTri1 = inputTri
 
        --The one point on the inside should be kept
        outputTri1[1] = pointsInside[1]

        --The two other points should be intersecting the plane
        outputTri1[2] = vector.intersectPlane(planePoint, planeNormal, pointsInside[1], pointsOutside[1])
        outputTri1[3] = vector.intersectPlane(planePoint, planeNormal, pointsInside[1], pointsOutside[2])

        return { outputTri1 } 
    end

    if (#pointsInside == 2 and #pointsOutside == 1) then
        --This is to keep any other information like color data
        local outputTri1 = inputTri
        local outputTri2 = copyTriangle(inputTri)

        --First triangle:

        --Keep the two inside points for the first triangle
        outputTri1[1] = pointsInside[1]
        outputTri1[2] = pointsInside[2]

        --The last point should be the first intersection
        outputTri1[3] = vector.intersectPlane(planePoint, planeNormal, pointsInside[1], pointsOutside[1])

        --Second triangle:

        --The first point should be the second point on the inside
        outputTri2[1] = pointsInside[2]

        --The other two points are placed along the plane with one being already calculated
        outputTri2[2] = outputTri1[3]
        outputTri2[3] = vector.intersectPlane(planePoint, planeNormal, pointsInside[2], pointsOutside[1])

        return { outputTri1, outputTri2 } 
    end
end

return triangle
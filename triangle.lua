local triangle = {}

local vector = require "vector"

--Function for copying table by value rather than by reference
--Why does lua work like this? I do not know
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
    local pointsInsideCount = 0
    local pointsOutsideCount = 0

    local dist1 = triangle.pointDistanceToPlane(inputTri[1])
    local dist2 = triangle.pointDistanceToPlane(inputTri[2])
    local dist3 = triangle.pointDistanceToPlane(inputTri[3])

    --Points with a positive distance to the plane are inside it
    if dist1 >= 0.0 then 
        table.insert(pointsInside, copyVector3(inputTri[1]))
        pointsInsideCount = pointsInsideCount + 1
    else 
        table.insert(pointsOutside, copyVector3(inputTri[1]))
    end   
    
    if dist2 >= 0.0 then 
        table.insert(pointsInside, copyVector3(inputTri[2]))
        pointsInsideCount = pointsInsideCount + 1
    else 
        table.insert(pointsOutside, copyVector3(inputTri[2]))
    end
    
    if dist3 >= 0.0 then 
        table.insert(pointsInside, copyVector3(inputTri[3]))
        pointsInsideCount = pointsInsideCount + 1
    else 
        table.insert(pointsOutside, copyVector3(inputTri[3]))
    end

    pointsOutsideCount = 3 - pointsInsideCount

    --No points inside plane means triangle can be discarded
    if pointsInsideCount == 0 then
        return {} 
    end

    if pointsInsideCount == 3 then
        --All points inside means that the entire triangle should remain intact
        return { copyTriangle(inputTri) } 
    end

    if pointsInsideCount == 1 and pointsOutsideCount == 2 then
        --This is to keep any other information like color data
        local outputTri1 = copyTriangle(inputTri)
 
        --The one point on the inside should be kept
        outputTri1[1] = copyVector3(pointsInside[1])

        --The two other points should be intersecting the plane
        outputTri1[2] = vector.intersectPlane(planePoint, planeNormal, copyVector3(pointsInside[1]), copyVector3(pointsOutside[1]))
        outputTri1[3] = vector.intersectPlane(planePoint, planeNormal, copyVector3(pointsInside[1]), copyVector3(pointsOutside[2]))

        return { copyTriangle(outputTri1) } 
    end

    if (pointsInsideCount == 2 and pointsOutsideCount == 1) then
        --This is to keep any other information like color data
        local outputTri1 = copyTriangle(inputTri)
        local outputTri2 = copyTriangle(inputTri)

        --First triangle:

        --Keep the two inside points for the first triangle
        outputTri1[1] = copyVector3(pointsInside[1])
        outputTri1[2] = copyVector3(pointsInside[2])

        --The last point should be the first intersection
        outputTri1[3] = vector.intersectPlane(planePoint, planeNormal, copyVector3(pointsInside[1]), copyVector3(pointsOutside[1]))

        --Second triangle:

        --The first point should be the second point on the inside
        outputTri2[1] = copyVector3(pointsInside[2])

        --The other two points are placed along the plane with one being already calculated
        outputTri2[2] = copyVector3(outputTri1[3])
        outputTri2[3] = vector.intersectPlane(planePoint, planeNormal, copyVector3(pointsInside[2]), copyVector3(pointsOutside[1]))

        return { copyTriangle(outputTri1), copyTriangle(outputTri2) } 
    end
end

return triangle
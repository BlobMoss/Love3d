local vector = {}

--I guess this would be a constructor in löve2D
function vector3(X, Y, Z)
    return {
        ["X"] = X,
        ["Y"] = Y,
        ["Z"] = Z,
        ["W"] = 1.0
    }
end

--Function for copying table by value rather than by reference
--Why does lua work like this? I do not know
function copyVector3(v)
    return { 
        ["X"] = v.X, 
        ["Y"] = v.Y, 
        ["Z"] = v.Z,
        ["W"] = v.W
    }
end

function vector.add(v1, v2)
    return vector3(v1.X + v2.X, v1.Y + v2.Y, v1.Z + v2.Z)
end

function vector.sub(v1, v2)
    return vector3(v1.X - v2.X, v1.Y - v2.Y, v1.Z - v2.Z)
end

function vector.mul(v, n)
    return vector3(v.X * n, v.Y * n, v.Z * n)
end

function vector.div(v, n)
    return vector3(v.X / n, v.Y / n, v.Z / n)
end

--Returns a measure of similarity between v1 and v2 (this thing is magical)
function vector.dot(v1, v2)
    return v1.X * v2.X + v1.Y * v2.Y + v1.Z * v2.Z
end

function vector.length(v)
    --Dot can also be used to raise each value to the power of 2
    return math.sqrt(vector.dot(v, v))
end

--Returns v with length of 1.0
function vector.normalize(v)
    local length = vector.length(v)
    return vector.div(v, length)
end

--Vector used for getting the line with a 90 degree angle to bot v1 and v2
function vector.cross(v1, v2)
    local o = vector3(0.0, 0.0, 0.0)
    o.X = v1.Y * v2.Z - v1.Z * v2.Y
    o.Y = v1.Z * v2.X - v1.X * v2.Z
    o.Z = v1.X * v2.Y - v1.Y * v2.X
    return o
end

--Vector by matrix multiplication
function vector.mulMatrix(v, m)
    local o = vector3(0.0, 0.0, 0.0)
    o.X = v.X * m[1][1] + v.Y * m[2][1] + v.Z * m[3][1] + v.W * m[4][1]
    o.Y = v.X * m[1][2] + v.Y * m[2][2] + v.Z * m[3][2] + v.W * m[4][2]
    o.Z = v.X * m[1][3] + v.Y * m[2][3] + v.Z * m[3][3] + v.W * m[4][3]
    o.W = v.X * m[1][4] + v.Y * m[2][4] + v.Z * m[3][4] + v.W * m[4][4]
    return o
end

--Returns point where line intersects plane
function vector.intersectPlane(planePoint, planeNormal, lineStart, lineEnd)
    --Normalize normal just in case
    planeNormal = vector.normalize(planeNormal)

    --Dot working its magic
    local dnp = -vector.dot(planeNormal, planePoint)
    local dsn = vector.dot(lineStart, planeNormal)
    local den = vector.dot(lineEnd, planeNormal)

    local t = (-dnp - dsn) / (den - dsn)

    --Full line is the line from start to end
    local fullLine = vector.sub(lineEnd, lineStart)
    --Cut line is the full line scaled by "t"
    local cutLine = vector.mul(fullLine, t)
    --Subtracting cut line from the full line gives point of intersection
    local intersection = vector.add(lineStart, cutLine)

    return intersection
end

return vector
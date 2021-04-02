local vector = {}

--I guess this would be the equivalent of a c# constructor in löve2D
function vector3(x, y, z)
    return {
        X = x,
        Y = y,
        Z = z,
        W = 1.0
    }
end

--Creates a vector3 with a default value
function vector.newIdentity()
    return {
        X = 0.0,
        Y = 0.0,
        Z = 0.0,
        W = 1.0
    }
end
local newIdentity = vector.newIdentity

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
local dot = vector.dot

function vector.length(v)
    --Dot can also be used to raise each value to the power of 2
    return math.sqrt(vector.dot(v, v))
end

--Returns v with length of 1.0
function vector.normalize(v)
    local l = vector.length(v)
    return vector.div(v, l)
end

--Vector used for getting the line with a 90 degree angle to bot v1 and v2
function vector.cross(v1, v2)
    local o = newIdentity()
    o.X = v1.Y * v2.Z - v1.Z * v2.Y
    o.Y = v1.Z * v2.X - v1.X * v2.Z
    o.Z = v1.X * v2.Y - v1.Y * v2.X
    return o
end

--Vector by matrix multiplication
function vector.mulMatrix(v, m)
    local o = newIdentity()
    o.X = v.X * m[1] + v.Y * m[2] + v.Z * m[3] + v.W * m[4]
    o.Y = v.X * m[5] + v.Y * m[6] + v.Z * m[7] + v.W * m[8]
    o.Z = v.X * m[9] + v.Y * m[10] + v.Z * m[11] + v.W * m[12]
    o.W = v.X * m[13] + v.Y * m[14] + v.Z * m[15] + v.W * m[16]
    return o
end

--Returns point where line intersects plane
function vector.intersectPlane(planePoint, planeNormal, lineStart, lineEnd)
    --Dot working its magic
    local dot1 = -dot(planeNormal, planePoint)
    local dot2 = dot(lineStart, planeNormal)
    local dot3 = dot(lineEnd, planeNormal)

    local t = (-dot1 - dot2) / (dot3 - dot2)

    --Full line is the line from start to end
    local fullLine = vector.sub(lineEnd, lineStart)
    --Cut line is the full line scaled by "t"
    local cutLine = vector.mul(fullLine, t)
    --Subtracting cut line from the full line gives point of intersection
    return vector.add(lineStart, cutLine)
end

return vector
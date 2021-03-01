local vector = {}

function vector3(X, Y, Z)
    return {
        ["X"] = X,
        ["Y"] = Y,
        ["Z"] = Z,
        ["W"] = 1
    }
end

function vector.add(v1, v2)
    return vector3(v1.X + v2.X, v1.Y + v2.Y, v1.Z + v2.Z)
end

function vector.sub(v1, v2)
    return vector3(v1.X - v2.X, v1.Y - v2.Y, v1.Z - v2.Z)
end

function vector.mul(v1, n)
    return vector3(v1.X * n, v1.Y * n, v1.Z * n)
end

function vector.div(v1, n)
    return vector3(v1.X / n, v1.Y / n, v1.Z / n)
end

function vector.dotProduct(v1, v2)
    return v1.X * v2.X + v1.Y * v2.Y + v1.Z * v2.Z
end

function vector.length(v)
    return math.sqrt(vector.dotProduct(v, v))
end

function vector.normalize(v)
    local length = vector.length(v)
    return vector.div(v, length)
end

function vector.crossProduct(v1, v2)
    local v = vector3(0, 0, 0)
    v.X = v1.Y * v2.Z - v1.Z * v2.Y
    v.Y = v1.Z * v2.X - v1.X * v2.Z
    v.Z = v1.X * v2.Y - v1.Y * v2.X
    return v
end

return vector
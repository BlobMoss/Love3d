--Math
local vector = require "math/vector"

local matrix = {}

--Creates a 4 by 4 matrix with a default value
function matrix.newIdentity()
    return {
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    }
end
local newIdentity = matrix.newIdentity

local cos = math.cos
local sin = math.sin

function matrix.newRotationX(angle) --Angle in radians
    local o = newIdentity()
    o[1] = 1.0
	o[6] = cos(angle)
	o[10] = sin(angle)
	o[7] = -sin(angle)
	o[11] = cos(angle)
	o[16] = 1.0
    return o
end

function matrix.newRotationY(angle) --Angle in radians
    local o = newIdentity()
    o[1] = cos(angle)
	o[9] = sin(angle)
	o[3] = -sin(angle)
	o[6] = 1.0
	o[11] = cos(angle)
	o[16] = 1.0
    return o
end

function matrix.newRotationZ(angle) --Angle in radians
    local o = newIdentity()
    o[1] = cos(angle)
	o[5] = sin(angle)
	o[2] = -sin(angle)
	o[6] = cos(angle)
	o[11] = 1.0
	o[16] = 1.0
    return o
end

function matrix.newTranslation(x, y, z)
    local o = newIdentity()
	o[4] = x
	o[8] = y
	o[12] = z
    return o
end

function matrix.newProjection(fovDeg, aspectRatio, near, far)
    local fovRad = 1.0 / math.tan(fovDeg * 0.5 / 180.0 * math.pi)
    local o = newIdentity()
    o[1] = aspectRatio * fovRad
	o[6] = fovRad
	o[11] = far / (far - near)
	o[12] = (-far * near) / (far - near)
	o[15] = 1.0
	o[16] = 0.0
    return o
end

--Matrix by matrix multiplication
function matrix.mulMatrix(m1, m2)
    local o = {}
    for y = 0, 12, 4 do --columns
        for x = 1, 4 do --rows
            o[x + y] = 
            m1[x]      * m2[1 + y] + 
            m1[x + 4]  * m2[2 + y] + 
            m1[x + 8]  * m2[3 + y] + 
            m1[x + 12] * m2[4 + y]
        end
    end
    return o
end

function matrix.pointAt(position, target, upv)
    local forward = vector.normalize(vector.sub(target, position))

    local up = vector.normalize(vector.sub(upv, vector.mul(forward, vector.dot(upv, forward))))

    local right = vector.cross(up, forward)

    local o = {}
    o[1] = right.X
    o[2] = up.X
    o[3] = forward.X
    o[4] = position.X
    o[5] = right.Y
    o[6] = up.Y
    o[7] = forward.Y
    o[8] = position.Y
    o[9] = right.Z
    o[10] = up.Z
    o[11] = forward.Z
    o[12] = position.Z
    o[13] = 0.0
    o[14] = 0.0
    o[15] = 0.0
    o[16] = 1.0
    return o
end

--Does not work for all matrices
function matrix.simpleInverse(m)
    local o = {}
    o[1] = m[1]
    o[2] = m[5]
    o[3] = m[9]
    o[4] = -(m[4] * o[1] + m[8] * o[2] + m[12] * o[3])

    o[5] = m[2]
    o[6] = m[6]
    o[7] = m[10]
    o[8] = -(m[4] * o[5] + m[8] * o[6] + m[12] * o[7])

    o[9] = m[3]
    o[10] = m[7]
    o[11] = m[11]
    o[12] = -(m[4] * o[9] + m[8] * o[10] + m[12] * o[11])
    
    o[13] = 0.0
    o[14] = 0.0
    o[15] = 0.0
    o[16] = 1.0
    return o
end

return matrix
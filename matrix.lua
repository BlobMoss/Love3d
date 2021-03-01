local matrix = {}

local vector = require "vector"

function matrix.newIdentity()
    local o = {
        { 1.0, 0.0, 0.0, 0.0 },
        { 0.0, 1.0, 0.0, 0.0 },
        { 0.0, 0.0, 1.0, 0.0 },
        { 0.0, 0.0, 0.0, 1.0 }
    }
    return o
end

function matrix.newRotationX(angle) --angle in radians
    local o = matrix.newIdentity()
    o[1][1] = 1.0
	o[2][2] = math.cos(angle)
	o[2][3] = math.sin(angle)
	o[3][2] = -math.sin(angle)
	o[3][3] = math.cos(angle)
	o[4][4] = 1.0
    return o
end

function matrix.newRotationY(angle) --angle in radians
    local o = matrix.newIdentity()
    o[1][1] = math.cos(angle)
	o[1][3] = math.sin(angle)
	o[3][1] = -math.sin(angle)
	o[2][2] = 1.0
	o[3][3] = math.cos(angle)
	o[4][4] = 1.0
    return o
end

function matrix.newRotationZ(angle) --angle in radians
    local o = matrix.newIdentity()
    o[1][1] = math.cos(angle)
	o[1][2] = math.sin(angle)
	o[2][1] = -math.sin(angle)
	o[2][2] = math.cos(angle)
	o[3][3] = 1.0
	o[4][4] = 1.0
    return o
end

function matrix.newTranslation(x, y, z)
    local o = matrix.newIdentity()
    o[1][1] = 1.0
	o[2][2] = 1.0
	o[3][3] = 1.0
	o[4][4] = 1.0

	o[4][1] = x
	o[4][2] = y
	o[4][3] = z
    return o
end

function matrix.newProjection(fovDeg, aspectRatio, near, far)
    local fovRad = 1.0 / math.tan(fovDeg * 0.5 / 180.0 * math.pi)
    local o = matrix.newIdentity()
    o[1][1] = aspectRatio * fovRad
	o[2][2] = fovRad
	o[3][3] = far / (far - near)
	o[4][3] = (-far * near) / (far - near)
	o[3][4] = 1.0
	o[4][4] = 0.0
    return o
end

function matrix.mulMatrix(m1, m2)
    local o = matrix.newIdentity()
    for i = 1, 4, 1 do --columns
        for j = 1, 4, 1 do --rows
            o[j][i] = m1[j][1] * m2[1][i] + m1[j][2] * m2[2][i] + m1[j][3] * m2[3][i] + m1[j][4] * m2[4][i];
        end
    end
    return o
end

function matrix.pointAt(position, target, up)
    local newForward = vector.sub(target, position)
    newForward = vector.normalize(newForward)

    local a = vector.mul(newForward, vector.dotProduct(up, newForward))
    local newUp = vector.sub(up, a)
    newUp = vector.normalize(newUp)

    local newRight = vector.crossProduct(newUp, newForward)

    local o = matrix.newIdentity()
    o[1][1] = newRight.X
    o[1][2] = newRight.Y
    o[1][3] = newRight.Z
    o[1][4] = 0.0
	o[2][1] = newUp.X
    o[2][2] = newUp.Y
    o[2][3] = newUp.Z
    o[2][4] = 0.0
	o[3][1] = newForward.X
    o[3][2] = newForward.Y
    o[3][3] = newForward.Z
    o[3][4] = 0.0
	o[4][1] = position.X
    o[4][2] = position.Y
    o[4][3] = position.Z
    o[4][4] = 1.0
    return o
end

function matrix.simpleInverse(m)
    local o = matrix.newIdentity()
    o[1][1] = m[1][1]
    o[1][2] = m[2][1]
    o[1][3] = m[3][1]
    o[1][4] = 0.0
    o[2][1] = m[1][2]
    o[2][2] = m[2][2]
    o[2][3] = m[3][2]
    o[2][4] = 0.0
    o[3][1] = m[1][3]
    o[3][2] = m[2][3]
    o[3][3] = m[3][3]
    o[3][4] = 0.0
    o[4][1] = -(m[4][1] * o[1][1] + m[4][2] * o[2][1] + m[4][3] * o[3][1])
    o[4][2] = -(m[4][1] * o[1][2] + m[4][2] * o[2][2] + m[4][3] * o[3][2])
    o[4][3] = -(m[4][1] * o[1][3] + m[4][2] * o[2][3] + m[4][3] * o[3][3])
    o[4][4] = 1.0
    return o
end

return matrix
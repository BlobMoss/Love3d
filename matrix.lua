local matrix = {}

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

function matrix.mulVector(m, v)
    local o = {}
    o.X = v.X * m[1][1] + v.Y * m[2][1] + v.Z * m[3][1] + v.W * m[4][1]
    o.Y = v.X * m[1][2] + v.Y * m[2][2] + v.Z * m[3][2] + v.W * m[4][2]
    o.Z = v.X * m[1][3] + v.Y * m[2][3] + v.Z * m[3][3] + v.W * m[4][3]
    o.W = v.X * m[1][4] + v.Y * m[2][4] + v.Z * m[3][4] + v.W * m[4][4]
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

return matrix
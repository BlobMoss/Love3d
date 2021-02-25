local matrix = {}

function matrix.multiplyVector(vec3, mat4x4)
    local o = {}
    
    o.X = vec3.X * mat4x4[1][1] + vec3.Y * mat4x4[2][1] + vec3.Z * mat4x4[3][1] + mat4x4[4][1]
    o.Y = vec3.X * mat4x4[1][2] + vec3.Y * mat4x4[2][2] + vec3.Z * mat4x4[3][2] + mat4x4[4][2]
    o.Z = vec3.X * mat4x4[1][3] + vec3.Y * mat4x4[2][3] + vec3.Z * mat4x4[3][3] + mat4x4[4][3]
    local W = vec3.X * mat4x4[1][4] + vec3.Y * mat4x4[2][4] + vec3.Z * mat4x4[3][4] + mat4x4[4][4]

    if W ~= 0.0 then
        o.X = o.X / W
        o.Y = o.Y / W
        o.Z = o.Z / W
    end

    return o
end

return matrix
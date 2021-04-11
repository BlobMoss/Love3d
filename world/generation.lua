--Math
local vector = require "math/vector"
local triangle = require "math/triangle"

local content = require "content"

local generation = {}

function generation.generatePointValue(x, y, z)
    if y == 0 then return 1000.0 end
    if y == Chunkheight then return -1000.0 end --Water
    
    --I have messed with these constants for a while and they can still be very much improved
    local w = 0.0
    w = w + noise(x, y, z, 0.03, 0.70) --General shape
    w = w + noise(x, y, z, 0.12, 0.55) --Spicy shapes
    w = w * 44.0 + 3.0 - y * 0.75 --More mass further down

    --Limit the density below ground and mid air for easier terraforming
    w = math.max(math.min(w, SurfaceLevel + 8.0), SurfaceLevel - 8.0)
    return w
end

function noise(x, y, z, frequency, amplitude)
    --The noise sampling can be offset by a random number (Seed) to generate a new world every time
    return love.math.noise(
        x * frequency + Seed, 
        y * frequency, 
        z * frequency
    ) * amplitude
end

local sandColor  = vector3(0.90, 0.80, 0.70)
local grassColor = vector3(0.40, 0.45, 0.20)
local rockColor  = vector3(0.40, 0.30, 0.20)
local snowColor  = vector3(0.90, 0.90, 1.00)

local interval1 = 0.15
local interval2 = 0.35
local interval3 = 0.45
local interval4 = 0.55

local up = vector3(0.0, 1.0, 0.0)
function generation.generateTriangleColor(t)
    local avg = triangle.centre(t)

    --triangles at the bottom are water colored
    if math.ceil(avg.Y) == Chunkheight then 
        --Add noise to water color
        return vector3(0.3, 0.4 + noise(avg.X, avg.Y, avg.Z, 0.3, 0.3), 0.6)
    end

    local p = 1.0 - avg.Y / Chunkheight

    if p < interval1 then
        p = p / interval1
        return vector.lerp(grassColor, sandColor, p)
    elseif p < interval2 then
        p = (p - interval1) / (interval2 - interval1) 
        return vector.lerp(rockColor, grassColor, p)
    elseif p < interval3 then
        p = (p - interval2) / (interval3 - interval2) 
        return vector.lerp(rockColor, rockColor, p)
    elseif p < interval4 then
        p = (p - interval3) / (interval4 - interval3) 
        return vector.lerp(snowColor, rockColor, p)
    else
        p = (p - interval4) / (1.0 - interval4) 
        return vector.lerp(snowColor, snowColor, p)
    end
end

local treeColor  = vector3(0.30, 0.4, 0.20)
local trunkColor = vector3(0.40, 0.30, 0.20)

function generation.generateVegetation(t, triangles)
    local avg = triangle.centre(t)

    local p = 1.0 - avg.Y / Chunkheight

    if p > interval1 and p < interval2 - 0.1 then 
        local lineA = vector.sub(t[2], t[1])
        local lineB = vector.sub(t[3], t[1])
    
        local normal = vector.cross(lineA, lineB)
        normal = vector.normalize(normal)
    
        local flatness = -vector.dot(normal, vector3(0.0, 1.0, 0.0))
    
        if flatness > 0.85 and 0.3 > noise(avg.X, avg.Y, avg.Z, 1.0, 1.0) then
            local treeTriangles = content.loadModel("models/tree.obj")
    
            for ii = 1, #treeTriangles do
                local tt = treeTriangles[ii]
                local tavg = triangle.centre(tt)
                
                if tavg.Y < -1.9 then 
                    tt.color = treeColor
                else
                    tt.color = trunkColor
                end

                local scale = noise(avg.X, avg.Y, avg.Z, 1.0, 1.0)
                tt[1] = vector.mul(tt[1], scale)
                tt[2] = vector.mul(tt[2], scale)
                tt[3] = vector.mul(tt[3], scale)

                tt[1] = vector.add(tt[1], avg)
                tt[2] = vector.add(tt[2], avg)
                tt[3] = vector.add(tt[3], avg)
    
                table.insert(triangles, tt)
            end
        end   
    end 
end

return generation
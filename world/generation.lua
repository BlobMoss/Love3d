local generation = {}

function generation.generatePointValue(x, y, z)
    if y == 0 then return 1000.0 end
    if y == Chunkheight then return -1000.0 end
    
    local value = 0.0
    value = value + noise(x, y, z, 0.01, 0.7) --General shape
    value = value + noise(x, y, z, 0.15, 0.4) --Details
    value = value * 32.0 + 5.0 - y * 1.0 --More mass further down
    return value
end

function noise(x, y, z, frequency, amplitude)
    --The noise sampling can be offset by a random number (Seed) to generate a new world every time
    return love.math.noise(
        x * frequency + Seed, 
        y * frequency, 
        z * frequency
    ) * amplitude
end

return generation
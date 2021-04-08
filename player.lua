--Math
local vector = require "math/vector"

local world = require "world/world"

local player = {}

local vector_add = vector.add
local vector_sub = vector.sub

local isKeyDown = love.keyboard.isDown
local isMouseDown = love.mouse.isDown

local up = vector3(0.0, 1.0, 0.0)

--Camera movement settings
local speed = 4.0
local mouseSensitivity = 0.002

--Brush settings
local brushRange = 12.0
local brushRadius = 2.0
local maxBrushRadius = 6.0
local minBrushRadius = 1.5
local brushOpacity = 5.0

function player.update(dt)
    handleMovement(dt)

    if isMouseDown(1) or isMouseDown(2) then
        handlePainting(dt)
    end
end

function handleMovement(dt)
    --Camera rotation with mouse
    local mouseX, mouseY = love.mouse.getPosition()

    local deltaX = WindowCentreX - mouseX
    local deltaY = WindowCentreY - mouseY

    love.mouse.setPosition(WindowCentreX, WindowCentreY)

    --I do not think dt is required here
    CameraRotY = CameraRotY + deltaX * mouseSensitivity
    CameraRotX = CameraRotX + deltaY * mouseSensitivity

    --Limit X rotation to not flip the screen
    CameraRotX = math.min(math.max(CameraRotX, -math.pi * 0.499), math.pi * 0.499)

    --Camera movement with keyboard
    local forward = vector.normalize(CameraLookDirection)
    local right = vector.cross(up, forward)

    local movement = vector.newIdentity()

    if isKeyDown("s") then
        movement = vector_sub(movement, forward)
    end
    if isKeyDown("w") then
        movement = vector_add(movement, forward)
    end
    if isKeyDown("a") then
        movement = vector_sub(movement, right)
    end
    if isKeyDown("d") then
        movement = vector_add(movement, right)
    end
    if isKeyDown("space") then
        movement = vector_sub(movement, up)
    end
    if isKeyDown("lshift") then
        movement = vector_add(movement, up)
    end

    if vector.length(movement) > 0.0 then
        movement = vector.normalize(movement)
    end
    
    movement = vector.mul(movement, speed * dt)
    
    CameraPosition = vector_add(CameraPosition, movement)
end

function handlePainting(dt)
    local paintPoint = findPaintPoint()

    if paintPoint == nil then return end

    for x = -brushRadius, brushRadius do 
        for y = -brushRadius, brushRadius do 
            for z = -brushRadius, brushRadius do 
                local dist = math.sqrt(x * x + y * y + z * z)

                local value = math.min((brushRadius - dist) * -brushOpacity / brushRadius * dt, 0.0)
                if isMouseDown(1) then 
                    value = math.max((brushRadius - dist) * brushOpacity / brushRadius * dt, 0.0) 
                end

                world.addPointValue(paintPoint.X + x, paintPoint.Y + y, paintPoint.Z + z, value)
            end
        end
    end
end

function findPaintPoint()
    local origin = CameraPosition
        
    local increment = 0.5

    local vectorIncrement = vector.mul(CameraLookDirection, increment)

    for i = 0.0, brushRange, increment do
        local gridPos = vector.round(origin)

        origin = vector.add(origin, vectorIncrement)

        if world.getPointValue(gridPos.X, gridPos.Y, gridPos.Z) < SurfaceLevel then
            if isMouseDown(2) then 
                origin = vector.sub(origin, vector.mul(CameraLookDirection, brushRadius * 0.5))
            end

            return origin
        end
    end

    return 
end

function love.wheelmoved(x, y)
    if y < 0.0 then
        brushRadius = math.min(brushRadius + 0.2, maxBrushRadius)
    elseif y > 0.0 then
        brushRadius = math.max(brushRadius - 0.2, minBrushRadius)
    end
    print(brushRadius)
end

return player
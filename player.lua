--Math
local vector = require "math/vector"

local world = require "world/world"

local player = {}

local vector_add = vector.add
local vector_sub = vector.sub
local vector_mul = vector.mul

local isKeyDown = love.keyboard.isDown
local isMouseDown = love.mouse.isDown

local up = vector3(0.0, 1.0, 0.0)

local velocity = vector3(0.0, 0.0, 0.0)
local colliderRadius = 1.0

--Camera movement settings
local speed = 21.0
local mouseSensitivity = 0.002
local scrollSensitivity = 0.3

--Brush settings
BrushRadius = 2.0
MaxBrushRadius = 8.0
MinBrushRadius = 1.5
local brushRange = 12.0
local brushOpacity = 5.0

function player.load()
    CameraPosition.Y = Chunkheight / 2.0
end

function player.update(dt)
    handleCollision(dt)

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

    --Only normalize if player is moving at all
    if vector.length(movement) > 0.0 then
        movement = vector.normalize(movement)
    end
    
    movement = vector_mul(movement, speed * dt)
    
    velocity = vector_add(velocity, movement)

    velocity = vector_mul(velocity, 0.8)

    CameraPosition = vector.add(CameraPosition, vector_mul(velocity, dt))
end

--The simpleste form of triangle to sphere collision
function handleCollision(dt)
    local chunk = Chunks[math.floor(CameraPosition.X / ChunkWidth)][math.floor(CameraPosition.Z / ChunkLength)]

    if chunk.triangles == nil then return end

    for i = 1, #chunk.triangles do
        local t = chunk.triangles[i]

        for ii = 1, 3 do
            local v = t[ii]
            local dist = vector.distance(CameraPosition, v)

            --If player is too close to a vertex, add velocity in the direction of the triangle's normal
            if dist < colliderRadius then
                local lineA = vector_sub(t[2], t[1])
                local lineB = vector_sub(t[3], t[1])

                local normal = vector.cross(lineA, lineB)
                normal = vector.normalize(normal)

                velocity = vector_add(velocity, vector_mul(normal, speed * dt))
                --Return to only allow one collision between every camera movement
                return
            end
        end
    end
end

function handlePainting(dt)
    local paintPoint = findPaintPoint()

    if paintPoint == nil then return end

    for x = -BrushRadius, BrushRadius do 
        for y = -BrushRadius, BrushRadius do 
            for z = -BrushRadius, BrushRadius do 
                --Points farther away from the brush are less affected to form a sphere shape
                local dist = math.sqrt(x * x + y * y + z * z)
                dist = (BrushRadius - dist) * dt / BrushRadius

                local value = math.min(dist * -brushOpacity, 0.0)
                if isMouseDown(1) then 
                    value = math.max(dist * brushOpacity, 0.0) 
                end

                world.addPointValue(paintPoint.X + x, paintPoint.Y + y, paintPoint.Z + z, value)
            end
        end
    end
end

function findPaintPoint()
    local origin = CameraPosition
        
    local increment = 0.25

    local vectorIncrement = vector_mul(CameraLookDirection, increment)

    for i = 0.0, brushRange, increment do
        local gridPos = vector.round(origin)

        --Step in the direction of the camera
        origin = vector_add(origin, vectorIncrement)

        if world.getPointValue(gridPos.X, gridPos.Y, gridPos.Z) < SurfaceLevel then
            --Offset brush towards camera if adding terrain
            if isMouseDown(2) then 
                origin = vector_sub(origin, vector_mul(CameraLookDirection, BrushRadius * 0.5))
            end

            return origin
        end
    end
    return 
end

function love.wheelmoved(x, y)
    if y < 0.0 then
        BrushRadius = math.min(BrushRadius + scrollSensitivity, MaxBrushRadius)
    elseif y > 0.0 then
        BrushRadius = math.max(BrushRadius - scrollSensitivity, MinBrushRadius)
    end
end

return player
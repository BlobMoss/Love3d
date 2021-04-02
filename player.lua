--Math
local vector = require "math/vector"
local matrix = require "math/matrix"

local player = {}

local vector_add = vector.add
local vector_sub = vector.sub

local speed = 3.0
local mouseSensitivity = 0.002

local up = vector3(0.0, 1.0, 0.0)

local isKeyDown = love.keyboard.isDown

function player.load()
    
end

function player.update(dt)
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

    if movement.X ~= 0.0 and movement.Y ~= 0.0 and movement.Z ~= 0.0 then
        movement = vector.normalize(movement)
    end
    movement = vector.mul(movement, speed * dt)
    CameraPosition = vector_add(CameraPosition, movement)
end

return player
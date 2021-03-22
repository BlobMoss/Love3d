local player = {}

local vector = require "vector"
local matrix = require "matrix"
local triangle = require "triangle"

local speed = 3.0
local mouseSensitivity = 0.002

function player.load()
    
end

function player.update(dt)
    --Only control player if the player is in the window
    if (WindowFocused == false) then
        return
    end

    --Camera rotation with mouse
    local mouseX, mouseY = love.mouse.getPosition()

    local deltaX = WindowCentreX - mouseX
    local deltaY = WindowCentreY - mouseY

    love.mouse.setPosition(WindowCentreX, WindowCentreY)

    --I do not think dt is required here
    CameraRotY = CameraRotY + deltaX * mouseSensitivity
    CameraRotX = CameraRotX + deltaY * mouseSensitivity

    --Limit X rotation to not flip the screen
    CameraRotX = math.min(math.max(CameraRotX, -math.pi * 0.49), math.pi * 0.49)

    --Camera movement with keyboard
    local up = vector3(0.0, 1.0, 0.0)
    local forward = vector.normalize(CameraLookDirection)
    local right = vector.cross(up, forward)

    local movement = vector.newIdentity()

    if love.keyboard.isDown("s") then
        movement = vector.sub(movement, forward)
    end
    if love.keyboard.isDown("w") then
        movement = vector.add(movement, forward)
    end
    if love.keyboard.isDown("a") then
        movement = vector.sub(movement, right)
    end
    if love.keyboard.isDown("d") then
        movement = vector.add(movement, right)
    end
    if love.keyboard.isDown("space") then
        movement = vector.sub(movement, up)
    end
    if love.keyboard.isDown("lshift") then
        movement = vector.add(movement, up)
    end

    if movement.X ~= 0.0 and movement.Y ~= 0.0 and movement.Z ~= 0.0 then
        movement = vector.normalize(movement)
    end
    movement = vector.mul(movement, speed * dt)
    CameraPosition = vector.add(CameraPosition, movement)
end

return player
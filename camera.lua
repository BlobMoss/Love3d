local camera = {}

camera.depth = 4.0

camera.angleX = 0.0
camera.angleY = 0.0
camera.angleZ = 0.0

camera.position = { 
    {0.0}, {0.0}, {0.0} 
}

function camera.update(dt)
    if love.keyboard.isDown("w") then
        camera.angleX = camera.angleX + dt
    end
    if love.keyboard.isDown("s") then
        camera.angleX = camera.angleX - dt
    end
    if love.keyboard.isDown("a") then
        camera.angleY = camera.angleY + dt
    end
    if love.keyboard.isDown("d") then
        camera.angleY = camera.angleY - dt
    end

    if love.keyboard.isDown("left") then
        camera.position[1][1] = camera.position[1][1] + dt
    end
    if love.keyboard.isDown("right") then
        camera.position[1][1] = camera.position[1][1] - dt
    end
    if love.keyboard.isDown("up") then
        camera.position[2][1] = camera.position[2][1] + dt
    end
    if love.keyboard.isDown("down") then
        camera.position[2][1] = camera.position[2][1] - dt
    end
end

return camera
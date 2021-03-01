local vector = require "vector"
local matrix = require "matrix"
local content = require "content"

--Functions for copying tables by value rather than by reference
--Why does lua work like this? I do not know
function copyVector3(v)
    return { 
        ["X"] = v.X, 
        ["Y"] = v.Y, 
        ["Z"] = v.Z,
        ["W"] = v.W
    }
end

function copyTriangle(t)
    return {
        copyVector3(t[1]), 
        copyVector3(t[2]), 
        copyVector3(t[3]),
        ["color"] = copyVector3(t.color)
    }
end

function love.load()
    cameraPos = vector3(0, 0, 0)
    cameraLookDir = vector3(0, 0, 0)

    cameraRotY = 0
    cameraRotX = 0
    
    angle = 0.0

    --Load content
    anchor = {}
    anchor.triangles = content.loadModel("models/anchor.obj")

    --Build projection matrix
	local fov = 90.0
	local aspectRatio = love.graphics.getWidth() / love.graphics.getHeight()
    local near = 0.1
	local far = 1000.0
    projMat = matrix.newProjection(fov, aspectRatio, near, far)
end

function love.update(dt)
    local up = vector3(0, 1, 0)
    local forward = vector.normalize(cameraLookDir)

    local a = vector.mul(forward, vector.dotProduct(up, forward))
    up = vector.sub(up, a)
    up = vector.normalize(up)

    local right = vector.crossProduct(up, forward)

    local rightVelocity = vector.mul(right, 2.0 * dt)
    local upVelocity = vector.mul(up, 2.0 * dt)
    local forwardVelocity = vector.mul(forward, 2.0 * dt)

    if love.keyboard.isDown("s") then
        cameraPos = vector.sub(cameraPos, forwardVelocity)
    end
    if love.keyboard.isDown("w") then
        cameraPos = vector.add(cameraPos, forwardVelocity)
    end
    if love.keyboard.isDown("a") then
        cameraPos = vector.sub(cameraPos, rightVelocity)
    end
    if love.keyboard.isDown("d") then
        cameraPos = vector.add(cameraPos, rightVelocity)
    end
    if love.keyboard.isDown("space") then
        cameraPos = vector.sub(cameraPos, upVelocity)
    end
    if love.keyboard.isDown("lshift") then
        cameraPos = vector.add(cameraPos, upVelocity)
    end

    if love.keyboard.isDown("up") then
        cameraRotX = cameraRotX + 1.0 * dt
    end
    if love.keyboard.isDown("down") then
        cameraRotX = cameraRotX - 1.0 * dt
    end
    if love.keyboard.isDown("left") then
        cameraRotY = cameraRotY + 1.0 * dt
    end
    if love.keyboard.isDown("right") then
        cameraRotY = cameraRotY - 1.0 * dt
    end

    --angle = angle + dt

    --Set rotation and translation matrices
    local rotMatX = matrix.newRotationX(angle)
    local rotMatZ = matrix.newRotationZ(angle * 0.5)

    local transMat = matrix.newTranslation(0.0, 0.0, 7.0)

    --Multiply the world matrix by rotation and translation
    worldMat = matrix.newIdentity()
    worldMat = matrix.mulMatrix(worldMat, rotMatX)
    worldMat = matrix.mulMatrix(worldMat, rotMatZ)

    worldMat = matrix.mulMatrix(worldMat, transMat)

    --Set view matrix
    local up = vector3(0, 1, 0)
    local target = vector3(0, 0, 1)

    local cameraRotMatX = matrix.newRotationX(cameraRotX)
    local cameraRotMatY = matrix.newRotationY(cameraRotY)

    local cameraRotMat = matrix.newIdentity()
    local cameraRotMat = matrix.mulMatrix(cameraRotMat, cameraRotMatX)
    local cameraRotMat = matrix.mulMatrix(cameraRotMat, cameraRotMatY)

    cameraLookDir = vector.mulMatrix(target, cameraRotMat)
    target = vector.add(cameraPos, cameraLookDir)

    local cameraMat = matrix.pointAt(cameraPos, target, up)
    viewMat = matrix.simpleInverse(cameraMat)
end

function love.draw(dt)
    drawMesh(anchor)
end

function drawMesh(mesh)
    local trianglesToDraw = {}

    for i = 1, #mesh.triangles, 1 do 
        local triangle = copyTriangle(mesh.triangles[i])

        local transformed = copyTriangle(triangle)
        transformed[1] = vector.mulMatrix(triangle[1], worldMat)
        transformed[2] = vector.mulMatrix(triangle[2], worldMat)
        transformed[3] = vector.mulMatrix(triangle[3], worldMat)

        --Calculate and normalize surface normals
        local lineA = vector.sub(transformed[2], transformed[1])
        local lineB = vector.sub(transformed[3], transformed[1])

        local normal = vector.crossProduct(lineA, lineB)

        normal = vector.normalize(normal)

        --Check if triangle is visable using dot product
        local cameraRay = vector.sub(transformed[1], cameraPos)
        local visable = vector.dotProduct(normal, cameraRay) < 0.0

        if visable then
            --Set color of each triangle based on similarity to light direction
            local lightDirection = vector3(0.0, -0.5, -1.0)
            lightDirection = vector.normalize(lightDirection)

            local dotProduct = math.max(vector.dotProduct(lightDirection, normal))
            transformed.color = vector.mul(transformed.color, math.max(0.1, dotProduct))

            local viewed = copyTriangle(transformed)
            viewed[1] = vector.mulMatrix(viewed[1], viewMat)
            viewed[2] = vector.mulMatrix(viewed[2], viewMat)
            viewed[3] = vector.mulMatrix(viewed[3], viewMat)

            --Project triangle into 2D
            local projected = copyTriangle(viewed)
            projected[1] = vector.mulMatrix(projected[1], projMat)
            projected[2] = vector.mulMatrix(projected[2], projMat)
            projected[3] = vector.mulMatrix(projected[3], projMat)

            projected[1] = vector.div(projected[1], projected[1].W)
            projected[2] = vector.div(projected[2], projected[2].W)
            projected[3] = vector.div(projected[3], projected[3].W)

            --Center triangle on screen
            local screenOffset = vector3(1, 1, 0)
            projected[1] = vector.add(projected[1], screenOffset)
            projected[2] = vector.add(projected[2], screenOffset)
            projected[3] = vector.add(projected[3], screenOffset)
        
            projected[1].X = projected[1].X * 0.5 * love.graphics.getWidth()
            projected[1].Y = projected[1].Y * 0.5 * love.graphics.getHeight()
            projected[2].X = projected[2].X * 0.5 * love.graphics.getWidth()
            projected[2].Y = projected[2].Y * 0.5 * love.graphics.getHeight()
            projected[3].X = projected[3].X * 0.5 * love.graphics.getWidth()
            projected[3].Y = projected[3].Y * 0.5 * love.graphics.getHeight()

            --Add triangle to list to draw later
            table.insert(trianglesToDraw, projected)
        end
    end
    --Sort triangles by depth as I do not feel like working with depth buffers in love2d
    table.sort(trianglesToDraw, 
    function(t1, t2)
        local avg1 = (t1[1].Z + t1[2].Z + t1[2].Z) / 3.0
        local avg2 = (t2[1].Z + t2[2].Z + t2[2].Z) / 3.0
        return avg1 > avg2
    end)

    for i = 1, #trianglesToDraw, 1 do
        drawTriangle(trianglesToDraw[i])
    end
end

function drawTriangle(triangle)
    love.graphics.setColor(triangle.color.X, triangle.color.Y, triangle.color.Z, 1)
    love.graphics.polygon('fill', 
    triangle[1].X, triangle[1].Y, 
    triangle[2].X, triangle[2].Y, 
    triangle[3].X, triangle[3].Y)
end
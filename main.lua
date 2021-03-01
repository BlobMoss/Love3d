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
    angle = 0.0

    cameraPosition = vector3(0, 0, 0)

    --Load content
    anchor = {}
    anchor.triangles = content.loadModel("models/anchor.obj")

    --Set projection matrix
	local fov = 90.0
	local aspectRatio = love.graphics.getWidth() / love.graphics.getHeight()
    local near = 0.1
	local far = 1000.0
    projMat = matrix.newProjection(fov, aspectRatio, near, far)
end

function love.update(dt)
    angle = angle + dt

    --Set rotation and translation matrices
    local rotMatX = matrix.newRotationX(angle)
    --local rotMatY = matrix.newRotationY(angle)
    local rotMatZ = matrix.newRotationZ(angle * 0.5)
    local transMat = matrix.newTranslation(0.0, 0.0, 7.0)

    --Multiply the world matrix by rotation and translation
    worldMat = matrix.newIdentity()
    worldMat = matrix.mulMatrix(worldMat, rotMatX)
    --worldMat = matrix.mulMatrix(worldMat, rotMatY)
    worldMat = matrix.mulMatrix(worldMat, rotMatZ)
    worldMat = matrix.mulMatrix(worldMat, transMat)
end

function love.draw(dt)
    drawMesh(anchor)
end

function drawMesh(mesh)
    local trianglesToDraw = {}

    for i = 1, #mesh.triangles, 1 do 
        local triangle = copyTriangle(mesh.triangles[i])

        local transformed = copyTriangle(triangle)
        transformed[1] = matrix.mulVector(worldMat, triangle[1])
        transformed[2] = matrix.mulVector(worldMat, triangle[2])
        transformed[3] = matrix.mulVector(worldMat, triangle[3])

        --Calculate and normalize surface normals
        local lineA = vector.sub(transformed[2], transformed[1])
        local lineB = vector.sub(transformed[3], transformed[1])

        local normal = vector.crossProduct(lineA, lineB)

        normal = vector.normalize(normal)

        --Check if triangle is visable using dot product
        local cameraRay = vector.sub(transformed[1], cameraPosition)
        local visable = vector.dotProduct(normal, cameraRay) < 0.0

        if visable then
            --Set color of each triangle based on similarity to light direction
            local lightDirection = vector3(0.0, 0.0, -1.0)
            lightDirection = vector.normalize(lightDirection)

            local dotProduct = math.max(vector.dotProduct(lightDirection, normal))
            transformed.color = vector.mul(transformed.color, dotProduct)

            --Project triangle into 2D
            local projected = copyTriangle(transformed)
            projected[1] = matrix.mulVector(projMat, projected[1])
            projected[2] = matrix.mulVector(projMat, projected[2])
            projected[3] = matrix.mulVector(projMat, projected[3])

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
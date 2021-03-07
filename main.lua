local vector = require "vector"
local matrix = require "matrix"
local triangle = require "triangle"

local marching_cubes = require "marching_cubes"

local content = require "content"

windowWidth = love.graphics.getWidth()
windowHeight = love.graphics.getHeight()

local cameraPos = vector.newIdentity()
local cameraLookDir = vector.newIdentity()

local cameraRotY = 0.0
local cameraRotX = 0.0

local worldMat = {}
local viewMat = {}
local projMat = {}

local angle = 0.0

local anchorMesh = {}
local worldMesh = {}

function love.load()
    love.graphics.setBackgroundColor(0.15, 0.15, 0.175, 1.0)

    --Load content
    anchorMesh.triangles = content.loadModel("models/anchor.obj")
    
    worldMesh.triangles = marching_cubes.generate()
    print("Marching cubes generated " .. #worldMesh.triangles .. " triangles")

    --Build projection matrix
	local fov = 90.0
	local aspectRatio = love.graphics.getWidth() / love.graphics.getHeight()
    local near = 0.1
	local far = 1000.0
    projMat = matrix.newProjection(fov, aspectRatio, near, far)
end

function love.update(dt)
    local up = vector3(0.0, 1.0, 0.0)
    local forward = vector.normalize(cameraLookDir)
    local right = vector.cross(up, forward)

    local rightVelocity = vector.mul(right, 3.0 * dt)
    local upVelocity = vector.mul(up, 3.0 * dt)
    local forwardVelocity = vector.mul(forward, 3.0 * dt)

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

    --Set world matrix
    worldMat = matrix.newIdentity()

    --Set view matrix
    local up = vector3(0.0, 1.0, 0.0)
    local target = vector3(0.0, 0.0, 1.0)

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
    --drawTriangles(anchorMesh.triangles)
    drawTriangles(worldMesh.triangles)
end

function drawTriangles(triangles)
    local trianglesToDraw = {}

    for i = 1, #triangles do 
        local tTransformed = copyTriangle(triangles[i])
        tTransformed[1] = vector.mulMatrix(triangles[i][1], worldMat)
        tTransformed[2] = vector.mulMatrix(triangles[i][2], worldMat)
        tTransformed[3] = vector.mulMatrix(triangles[i][3], worldMat)

        --Calculate and normalize surface normals
        local lineA = vector.sub(tTransformed[2], tTransformed[1])
        local lineB = vector.sub(tTransformed[3], tTransformed[1])

        local normal = vector.cross(lineA, lineB)
        normal = vector.normalize(normal)

        --Triangle is visible if normal is opposite of camera view
        local cameraRay = vector.sub(tTransformed[1], cameraPos)
        local visable = vector.dot(normal, cameraRay) < 0.0

        if visable then
            --Set color of each triangle based on similarity to light direction
            local lightDirection = vector3(0.0, -1.0, -1.0)
            lightDirection = vector.normalize(lightDirection)

            local dot = math.max(vector.dot(lightDirection, normal))
            tTransformed.color = vector.mul(tTransformed.color, 0.5 + dot * 0.5)

            tTransformed[1] = vector.mulMatrix(tTransformed[1], viewMat)
            tTransformed[2] = vector.mulMatrix(tTransformed[2], viewMat)
            tTransformed[3] = vector.mulMatrix(tTransformed[3], viewMat)

            local clippedTriangles = triangle.clipAgainstPlane(vector3(0.0, 0.0, 0.1), vector3(0.0, 0.0, 1.0), tTransformed)

            for i = 1, #clippedTriangles do 
                --Project triangle into 2D
                local tProjected = clippedTriangles[i]
                tProjected[1] = vector.mulMatrix(tProjected[1], projMat)
                tProjected[2] = vector.mulMatrix(tProjected[2], projMat)
                tProjected[3] = vector.mulMatrix(tProjected[3], projMat)

                tProjected[1] = vector.div(tProjected[1], tProjected[1].W)
                tProjected[2] = vector.div(tProjected[2], tProjected[2].W)
                tProjected[3] = vector.div(tProjected[3], tProjected[3].W)

                --Center triangle on screen
                local screenOffset = vector3(1.0, 1.0, 0.0)
                tProjected[1] = vector.add(tProjected[1], screenOffset)
                tProjected[2] = vector.add(tProjected[2], screenOffset)
                tProjected[3] = vector.add(tProjected[3], screenOffset)
            
                tProjected[1].X = tProjected[1].X * 0.5 * windowWidth
                tProjected[1].Y = tProjected[1].Y * 0.5 * windowHeight
                tProjected[2].X = tProjected[2].X * 0.5 * windowWidth
                tProjected[2].Y = tProjected[2].Y * 0.5 * windowHeight
                tProjected[3].X = tProjected[3].X * 0.5 * windowWidth
                tProjected[3].Y = tProjected[3].Y * 0.5 * windowHeight

                --Add triangle to list to draw later
                table.insert(trianglesToDraw, tProjected)
            end
        end
    end

    --Sort triangles by average vertex depth as I do not feel like working with depth buffers
    table.sort(trianglesToDraw, 
    function(t1, t2)
        local avg1 = (t1[1].Z + t1[2].Z + t1[2].Z) / 3.0
        local avg2 = (t2[1].Z + t2[2].Z + t2[2].Z) / 3.0
        return avg1 > avg2
    end)

    for i = 1, #trianglesToDraw do
        
        local listOfTriangles = { trianglesToDraw[i] }

        local listOfClippedTriangles = {}

        --Seems to work fine without this segment so I guess it could be removed for performance
        --[[ 
        --Loop once for every edge e of the screen
        for e = 1, 4 do 
            for t = 1, #listOfTriangles do 
                local clipped = {}

                if e == 1 then 
                    clipped = triangle.clipAgainstPlane(vector3(0.0, 0.0, 0.0), vector3(0.0, 1.0, 0.0), listOfTriangles[t])
                elseif e == 2 then
                    clipped = triangle.clipAgainstPlane(vector3(0.0, windowHeight - 1.0, 0.0), vector3(0.0, -1.0, 0.0), listOfTriangles[t])
                elseif e == 3 then
                    clipped = triangle.clipAgainstPlane(vector3(0.0, 0.0, 0.0), vector3(1.0, 0.0, 0.0), listOfTriangles[t])
                elseif e == 4 then
                    clipped = triangle.clipAgainstPlane(vector3(windowWidth - 1.0, 0.0, 0.0), vector3(-1.0, 0.0, 0.0), listOfTriangles[t])
                end

                --Add every new triangle to a seperate list
                for c = 1, #clipped do 
                    table.insert(listOfClippedTriangles, clipped[c])
                end
            end
            --Empty list of original triangles
            listOfTriangles = {}
            --And fill it with clipped ones
            for c = 1, #listOfClippedTriangles do
                table.insert(listOfTriangles, listOfClippedTriangles[c])
            end
        end
        --]]

        for t = 1, #listOfTriangles do 
            draw2DTriangle(listOfTriangles[t])
        end
    end
end

function draw2DTriangle(t)
    love.graphics.setColor(t.color.X, t.color.Y, t.color.Z, 1.0)
    love.graphics.polygon('fill', 
    t[1].X, t[1].Y, 
    t[2].X, t[2].Y, 
    t[3].X, t[3].Y)
end
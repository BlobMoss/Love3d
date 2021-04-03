--Math
local vector = require "math/vector"
local matrix = require "math/matrix"
local triangle = require "math/triangle"

local graphics = {}

--This is a way to minimize loop-ups and increase performance
local vector_add = vector.add
local vector_sub = vector.sub
local vector_div = vector.div
local vector_normalize = vector.normalize
local vector_mulMatrix = vector.mulMatrix
local matrix_mulMatrix = matrix.mulMatrix

local trianglesToDraw = {}

--Constants
local up = vector3(0.0, 1.0, 0.0)

local lightDirection = vector3(0.0, -1.0, -1.0)
lightDirection = vector_normalize(lightDirection)

local cameraClipPlane = vector3(0.0, 0.0, 0.1)
local cameraClipPlaneNormal = vector_normalize(cameraClipPlane)

local screenOffset = vector3(1.0, 1.0, 0.0)

--Matrices
local worldMat = matrix.newIdentity()
local viewMat = matrix.newIdentity()
local projMat = matrix.newIdentity()

function graphics.load()
    --Build projection matrix
	local fov = 90.0
	local aspectRatio = WindowWidth / WindowHeight
    local near = 0.1
	local far = 1000.0
    projMat = matrix.newProjection(fov, aspectRatio, near, far)
end

function graphics.update(dt)
    --Set world matrix
    worldMat = matrix.newIdentity()

    --Set view matrix
    local target = vector3(0.0, 0.0, 1.0)

    local cameraRotMatX = matrix.newRotationX(CameraRotX)
    local cameraRotMatY = matrix.newRotationY(CameraRotY)

    local cameraRotMat = matrix.newIdentity()
    local cameraRotMat = matrix_mulMatrix(cameraRotMat, cameraRotMatX)
    local cameraRotMat = matrix_mulMatrix(cameraRotMat, cameraRotMatY)

    CameraLookDirection = vector_mulMatrix(target, cameraRotMat)
    target = vector_add(CameraPosition, CameraLookDirection)

    local cameraMat = matrix.pointAt(CameraPosition, target, up)
    viewMat = matrix.simpleInverse(cameraMat)
end

function graphics.draw()
    --Sort triangles by average vertex depth as I do not feel like working with pixel depth
    table.sort(trianglesToDraw, 
    function(t1, t2)
        local avg1 = (t1[1].Z + t1[2].Z + t1[3].Z) / 3
        local avg2 = (t2[1].Z + t2[2].Z + t2[3].Z) / 3
        return avg1 > avg2
    end)
    
    for i = 1, #trianglesToDraw do
        draw2DTriangle(trianglesToDraw[i])
    end
    
    trianglesToDraw = {}
end

function graphics.drawMesh(mesh)
    drawTriangles(mesh.triangles)
end

function drawTriangles(triangles)

    for i = 1, #triangles do 
        local tTransformed = copyTriangle(triangles[i])
        tTransformed[1] = vector_mulMatrix(tTransformed[1], worldMat)
        tTransformed[2] = vector_mulMatrix(tTransformed[2], worldMat)
        tTransformed[3] = vector_mulMatrix(tTransformed[3], worldMat)

        --Calculate and normalize surface normals
        local lineA = vector_sub(tTransformed[2], tTransformed[1])
        local lineB = vector_sub(tTransformed[3], tTransformed[1])

        local normal = vector.cross(lineA, lineB)
        normal = vector_normalize(normal)

        --Triangle is visible if normal is opposite of camera view
        local cameraRay = vector_sub(tTransformed[1], CameraPosition)
        local visable = vector.dot(normal, cameraRay) < 0.0

        if visable then
            --Set color of each triangle based on similarity to light direction
            local dot = math.max(vector.dot(lightDirection, normal))
            tTransformed.color = vector.mul(tTransformed.color, 0.5 + dot * 0.5)

            tTransformed[1] = vector_mulMatrix(tTransformed[1], viewMat)
            tTransformed[2] = vector_mulMatrix(tTransformed[2], viewMat)
            tTransformed[3] = vector_mulMatrix(tTransformed[3], viewMat)

            --Clip triangles against screen to not render anything behind the camera
            local clippedTriangles = triangle.clipAgainstPlane(cameraClipPlane, cameraClipPlaneNormal, tTransformed)

            for i = 1, #clippedTriangles do 
                --Project triangle into 2D
                local tProjected = clippedTriangles[i]
                tProjected[1] = vector_mulMatrix(tProjected[1], projMat)
                tProjected[2] = vector_mulMatrix(tProjected[2], projMat)
                tProjected[3] = vector_mulMatrix(tProjected[3], projMat)

                tProjected[1] = vector_div(tProjected[1], tProjected[1].W)
                tProjected[2] = vector_div(tProjected[2], tProjected[2].W)
                tProjected[3] = vector_div(tProjected[3], tProjected[3].W)

                --Center triangle on screen
                tProjected[1] = vector_add(tProjected[1], screenOffset)
                tProjected[2] = vector_add(tProjected[2], screenOffset)
                tProjected[3] = vector_add(tProjected[3], screenOffset)
            
                tProjected[1].X = tProjected[1].X * WindowCentreX
                tProjected[1].Y = tProjected[1].Y * WindowCentreY
                tProjected[2].X = tProjected[2].X * WindowCentreX
                tProjected[2].Y = tProjected[2].Y * WindowCentreY
                tProjected[3].X = tProjected[3].X * WindowCentreX
                tProjected[3].Y = tProjected[3].Y * WindowCentreY

                --Add triangle to list to sort and draw later
                table.insert(trianglesToDraw, tProjected)
            end
        end
    end
end

function draw2DTriangle(t)
    LG.setColor(t.color.X, t.color.Y, t.color.Z, 1.0)
    LG.polygon('fill',
    t[1].X, t[1].Y, 
    t[2].X, t[2].Y, 
    t[3].X, t[3].Y)
end

return graphics
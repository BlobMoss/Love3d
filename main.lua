local matrix = require "matrix"

--Constructors?
function vector3(X, Y, Z)
    return {
        ["X"] = X,
        ["Y"] = Y,
        ["Z"] = Z
    }
end

function emptyMatrix4x4()
    return {
        { 0.0, 0.0, 0.0, 0.0 },
        { 0.0, 0.0, 0.0, 0.0 },
        { 0.0, 0.0, 0.0, 0.0 },
        { 0.0, 0.0, 0.0, 0.0 }
    }
end

--Projection matrix
projMat = emptyMatrix4x4()

--Rotation matrices
rotMatX = emptyMatrix4x4()
rotMatY = emptyMatrix4x4()
rotMatZ = emptyMatrix4x4()

bonk = {}

angle = 0.0

cameraPosition = vector3(0, 0, 0)

--Functions for copying tables by value rather than by reference
function copyVector3(vec3)
    return { 
        ["X"] = vec3.X, 
        ["Y"] = vec3.Y, 
        ["Z"] = vec3.Z 
    }
end

function copyTriangle(tri)
    return {
        copyVector3(tri[1]), 
        copyVector3(tri[2]), 
        copyVector3(tri[3]),
        ["color"] = copyVector3(tri.color)
    }
end

function loadModel(filename)
    local o = {}

    local file = love.filesystem.lines(filename)
    local lines = {}
    local vertices = {}

    for line in file do 
		table.insert(lines, line)
	end

    for _, line in ipairs(lines) do
        if string.sub(line, 1, 1) == "v" then
            local vertexString = split(line, "%S+")
            local vertex = vector3(tonumber(vertexString[2]), tonumber(vertexString[3]), tonumber(vertexString[4]))
            table.insert(vertices, vertex)
        end
        if string.sub(line, 1, 1) == "f" then
            local faceString = split(line, "%S+")
            local face = { 
                tonumber(faceString[2]), 
                tonumber(faceString[3]), 
                tonumber(faceString[4]) 
            }
            local triangle = {
                vertices[face[1]],
                vertices[face[2]],
                vertices[face[3]]
            }
            triangle.color = vector3(1.0, 1.0, 1.0)
            table.insert(o, triangle)
        end
    end

    return o
end

function split (inputString, seperator)
    local o = {}
    for substring in string.gmatch(inputString, seperator) do
        table.insert(o, substring)
    end
    return o
end

function love.load()
    --Load triangles into mesh
    bonk.triangles = loadModel("content/models/bonk.obj")

    --[[
    cube.triangles = {
        { vector3(0.0, 0.0, 0.0), vector3(0.0, 1.0, 0.0), vector3(1.0, 1.0, 0.0), ["color"] = vector3(1.0, 1.0, 1.0) },
        { vector3(0.0, 0.0, 0.0), vector3(1.0, 1.0, 0.0), vector3(1.0, 0.0, 0.0), ["color"] = vector3(1.0, 1.0, 1.0) },

        { vector3(1.0, 0.0, 0.0), vector3(1.0, 1.0, 0.0), vector3(1.0, 1.0, 1.0), ["color"] = vector3(1.0, 1.0, 1.0) },
        { vector3(1.0, 0.0, 0.0), vector3(1.0, 1.0, 1.0), vector3(1.0, 0.0, 1.0), ["color"] = vector3(1.0, 1.0, 1.0) },

        { vector3(1.0, 0.0, 1.0), vector3(1.0, 1.0, 1.0), vector3(0.0, 1.0, 1.0), ["color"] = vector3(1.0, 1.0, 1.0) },
        { vector3(1.0, 0.0, 1.0), vector3(0.0, 1.0, 1.0), vector3(0.0, 0.0, 1.0), ["color"] = vector3(1.0, 1.0, 1.0) },

        { vector3(0.0, 0.0, 1.0), vector3(0.0, 1.0, 1.0), vector3(0.0, 1.0, 0.0), ["color"] = vector3(1.0, 1.0, 1.0) },
        { vector3(0.0, 0.0, 1.0), vector3(0.0, 1.0, 0.0), vector3(0.0, 0.0, 0.0), ["color"] = vector3(1.0, 1.0, 1.0) },

        { vector3(0.0, 1.0, 0.0), vector3(0.0, 1.0, 1.0), vector3(1.0, 1.0, 1.0), ["color"] = vector3(1.0, 1.0, 1.0) },
        { vector3(0.0, 1.0, 0.0), vector3(1.0, 1.0, 1.0), vector3(1.0, 1.0, 0.0), ["color"] = vector3(1.0, 1.0, 1.0) },

        { vector3(1.0, 0.0, 1.0), vector3(0.0, 0.0, 1.0), vector3(0.0, 0.0, 0.0), ["color"] = vector3(1.0, 1.0, 1.0) },
        { vector3(1.0, 0.0, 1.0), vector3(0.0, 0.0, 0.0), vector3(1.0, 0.0, 0.0), ["color"] = vector3(1.0, 1.0, 1.0) }
    }
    --]]

    --Fill projection matrix with trigonometric magic
	local near = 0.1
	local far = 1000.0
	local fov = 90.0
	local aspectRatio = love.graphics.getWidth() / love.graphics.getHeight()
	local fovRad = 1.0 / math.tan(fov * 0.5 / 180.0 * 3.1415)

	projMat[1][1] = aspectRatio * fovRad
	projMat[2][2] = fovRad
	projMat[3][3] = far / (far - near)
	projMat[4][3] = (-far * near) / (far - near)
	projMat[3][4] = 1.0
	projMat[4][4] = 0.0
end

function love.update(dt)
    angle = angle + dt

    --Fill rotation matrices with more trigonomagic
    rotMatZ[1][1] = math.cos(angle)
	rotMatZ[1][2] = math.sin(angle)
	rotMatZ[2][1] = -math.sin(angle)
	rotMatZ[2][2] = math.cos(angle)
	rotMatZ[3][3] = 1
	rotMatZ[4][4] = 1

    rotMatX[1][1] = 1
	rotMatX[2][2] = math.cos(angle * 0.5)
	rotMatX[2][3] = math.sin(angle * 0.5)
	rotMatX[3][2] = -math.sin(angle * 0.5)
	rotMatX[3][3] = math.cos(angle * 0.5)
	rotMatX[4][4] = 1
end

function love.draw(dt)
    local trianglesToDraw = {}

    for i = 1, #bonk.triangles, 1 do 
        local tri = copyTriangle(bonk.triangles[i])

        --Rotate triangle
        local rotatedZ = copyTriangle(tri)
        rotatedZ[1] = matrix.multiplyVector(rotatedZ[1], rotMatZ)
        rotatedZ[2] = matrix.multiplyVector(rotatedZ[2], rotMatZ)
        rotatedZ[3] = matrix.multiplyVector(rotatedZ[3], rotMatZ)

        local rotatedX = copyTriangle(rotatedZ)
        rotatedX[1] = matrix.multiplyVector(rotatedX[1], rotMatX)
        rotatedX[2] = matrix.multiplyVector(rotatedX[2], rotMatX)
        rotatedX[3] = matrix.multiplyVector(rotatedX[3], rotMatX)

        --Translate triangle into screen
        local translated = copyTriangle(rotatedX)
        translated[1].Z = translated[1].Z + 10.0
        translated[2].Z = translated[2].Z + 10.0
        translated[3].Z = translated[3].Z + 10.0

        --Calculate surface normals using cross product
        local lineA = {}
        local lineB = {}
        local normal = {}

        lineA.X = translated[2].X - translated[1].X
        lineA.Y = translated[2].Y - translated[1].Y
        lineA.Z = translated[2].Z - translated[1].Z

        lineB.X = translated[3].X - translated[1].X
        lineB.Y = translated[3].Y - translated[1].Y
        lineB.Z = translated[3].Z - translated[1].Z

        normal.X = lineA.Y * lineB.Z - lineA.Z * lineB.Y
        normal.Y = lineA.Z * lineB.X - lineA.X * lineB.Z
        normal.Z = lineA.X * lineB.Y - lineA.Y * lineB.X

        --Normalize normals
        local length = math.sqrt(normal.X * normal.X + normal.Y * normal.Y + normal.Z * normal.Z)
        normal.X = normal.X / length
        normal.Y = normal.Y / length
        normal.Z = normal.Z / length

        --Check if triangle is visable using dot product
        local visable = 
        normal.X * (translated[1].X - cameraPosition.X) + 
        normal.Y * (translated[1].Y - cameraPosition.Y) + 
        normal.Z * (translated[1].Z - cameraPosition.Z) < 0.0
        
        if visable then
            --Lighting
            lightDirection = vector3(0.0, 0.0, -1.0)
            local length = math.sqrt(lightDirection.X * lightDirection.X + lightDirection.Y * lightDirection.Y + lightDirection.Z * lightDirection.Z)
            lightDirection.X = lightDirection.X / length
            lightDirection.Y = lightDirection.Y / length
            lightDirection.Z = lightDirection.Z / length

            local dotProduct = normal.X * lightDirection.X + normal.Y * lightDirection.Y + normal.Z * lightDirection.Z 
            translated.color.X = translated.color.X * dotProduct
            translated.color.Y = translated.color.Y * dotProduct
            translated.color.Z = translated.color.Z * dotProduct

            --Project triangle
            local projected = copyTriangle(translated)
            projected[1] = matrix.multiplyVector(projected[1], projMat)
            projected[2] = matrix.multiplyVector(projected[2], projMat)
            projected[3] = matrix.multiplyVector(projected[3], projMat)

            --Center triangle
            local centered = copyTriangle(projected)
            centered[1].X = centered[1].X + 1
            centered[1].Y = centered[1].Y + 1
            centered[2].X = centered[2].X + 1
            centered[2].Y = centered[2].Y + 1
            centered[3].X = centered[3].X + 1
            centered[3].Y = centered[3].Y + 1

            centered[1].X = centered[1].X * 0.5 * love.graphics.getWidth()
            centered[1].Y = centered[1].Y * 0.5 * love.graphics.getHeight()
            centered[2].X = centered[2].X * 0.5 * love.graphics.getWidth()
            centered[2].Y = centered[2].Y * 0.5 * love.graphics.getHeight()
            centered[3].X = centered[3].X * 0.5 * love.graphics.getWidth()
            centered[3].Y = centered[3].Y * 0.5 * love.graphics.getHeight()

            table.insert(trianglesToDraw, centered)
        end
    end
    --Sort triangles by depth
    

    for i = 1, #trianglesToDraw, 1 do
        drawTriangle(trianglesToDraw[i])
    end
end

function drawTriangle(tri)
    love.graphics.setColor(tri.color.X, tri.color.Y, tri.color.Z, 1)
    love.graphics.polygon('fill', tri[1].X, tri[1].Y, tri[2].X, tri[2].Y,tri[3].X, tri[3].Y)
end
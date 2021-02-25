local matrix = require "matrix"

--Projection matrix
projMat = {
    { 0.0, 0.0, 0.0, 0.0 },
    { 0.0, 0.0, 0.0, 0.0 },
    { 0.0, 0.0, 0.0, 0.0 },
    { 0.0, 0.0, 0.0, 0.0 }
}

--Rotation matrices
rotMatX = {
    { 0.0, 0.0, 0.0, 0.0 },
    { 0.0, 0.0, 0.0, 0.0 },
    { 0.0, 0.0, 0.0, 0.0 },
    { 0.0, 0.0, 0.0, 0.0 }
}
rotMatY = {
    { 0.0, 0.0, 0.0, 0.0 },
    { 0.0, 0.0, 0.0, 0.0 },
    { 0.0, 0.0, 0.0, 0.0 },
    { 0.0, 0.0, 0.0, 0.0 }
}
rotMatZ = {
    { 0.0, 0.0, 0.0, 0.0 },
    { 0.0, 0.0, 0.0, 0.0 },
    { 0.0, 0.0, 0.0, 0.0 },
    { 0.0, 0.0, 0.0, 0.0 }
}

cube = {}

angle = 0.0

function love.load()

    cube.triangles = {
        { { ["X"] = 0.0, ["Y"] = 0.0, ["Z"] = 0.0 },    { ["X"] = 0.0, ["Y"] = 1.0, ["Z"] = 0.0 },    { ["X"] = 1.0, ["Y"] = 1.0, ["Z"] = 0.0 } },
        { { ["X"] = 0.0, ["Y"] = 0.0, ["Z"] = 0.0 },    { ["X"] = 1.0, ["Y"] = 1.0, ["Z"] = 0.0 },    { ["X"] = 1.0, ["Y"] = 0.0, ["Z"] = 0.0 } },

        { { ["X"] = 1.0, ["Y"] = 0.0, ["Z"] = 0.0 },    { ["X"] = 1.0, ["Y"] = 1.0, ["Z"] = 0.0 },    { ["X"] = 1.0, ["Y"] = 1.0, ["Z"] = 1.0 } },
        { { ["X"] = 1.0, ["Y"] = 0.0, ["Z"] = 0.0 },    { ["X"] = 1.0, ["Y"] = 1.0, ["Z"] = 1.0 },    { ["X"] = 1.0, ["Y"] = 0.0, ["Z"] = 1.0 } },

        { { ["X"] = 1.0, ["Y"] = 0.0, ["Z"] = 1.0 },    { ["X"] = 1.0, ["Y"] = 1.0, ["Z"] = 1.0 },    { ["X"] = 0.0, ["Y"] = 1.0, ["Z"] = 1.0 } },
        { { ["X"] = 1.0, ["Y"] = 0.0, ["Z"] = 1.0 },    { ["X"] = 0.0, ["Y"] = 1.0, ["Z"] = 1.0 },    { ["X"] = 0.0, ["Y"] = 0.0, ["Z"] = 1.0 } },

        { { ["X"] = 0.0, ["Y"] = 0.0, ["Z"] = 1.0 },    { ["X"] = 0.0, ["Y"] = 1.0, ["Z"] = 1.0 },    { ["X"] = 0.0, ["Y"] = 1.0, ["Z"] = 0.0 } },
        { { ["X"] = 0.0, ["Y"] = 0.0, ["Z"] = 1.0 },    { ["X"] = 0.0, ["Y"] = 1.0, ["Z"] = 0.0 },    { ["X"] = 0.0, ["Y"] = 0.0, ["Z"] = 0.0 } },

        { { ["X"] = 0.0, ["Y"] = 1.0, ["Z"] = 0.0 },    { ["X"] = 0.0, ["Y"] = 1.0, ["Z"] = 1.0 },    { ["X"] = 1.0, ["Y"] = 1.0, ["Z"] = 1.0 } },
        { { ["X"] = 0.0, ["Y"] = 1.0, ["Z"] = 0.0 },    { ["X"] = 1.0, ["Y"] = 1.0, ["Z"] = 1.0 },    { ["X"] = 1.0, ["Y"] = 1.0, ["Z"] = 0.0 } },

        { { ["X"] = 1.0, ["Y"] = 0.0, ["Z"] = 1.0 },    { ["X"] = 0.0, ["Y"] = 0.0, ["Z"] = 1.0 },    { ["X"] = 0.0, ["Y"] = 0.0, ["Z"] = 0.0 } },
        { { ["X"] = 1.0, ["Y"] = 0.0, ["Z"] = 1.0 },    { ["X"] = 0.0, ["Y"] = 0.0, ["Z"] = 0.0 },    { ["X"] = 1.0, ["Y"] = 0.0, ["Z"] = 0.0 } }
    }

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
    for i = 1, #cube.triangles, 1 
    do 
        local tri = newTriangle(cube.triangles[i])

        --Rotate triangle
        local rotatedZ = newTriangle(tri)
        rotatedZ[1] = matrix.multiplyVector(rotatedZ[1], rotMatZ)
        rotatedZ[2] = matrix.multiplyVector(rotatedZ[2], rotMatZ)
        rotatedZ[3] = matrix.multiplyVector(rotatedZ[3], rotMatZ)

        local rotatedX = newTriangle(rotatedZ)
        rotatedX[1] = matrix.multiplyVector(rotatedX[1], rotMatX)
        rotatedX[2] = matrix.multiplyVector(rotatedX[2], rotMatX)
        rotatedX[3] = matrix.multiplyVector(rotatedX[3], rotMatX)

        --Translate triangle into screen
        local translated = newTriangle(rotatedX)
        translated[1].Z = translated[1].Z + 3.0
        translated[2].Z = translated[2].Z + 3.0
        translated[3].Z = translated[3].Z + 3.0

        --print("X: " .. tri[1].X)
        --print("Y: " .. tri[1].Y)
        --print("Z: " .. tri[1].Z)

        --Project triangle
        local projected = newTriangle(translated)
        projected[1] = matrix.multiplyVector(projected[1], projMat)
        projected[2] = matrix.multiplyVector(projected[2], projMat)
        projected[3] = matrix.multiplyVector(projected[3], projMat)

        --Scale triangle
        local centered = newTriangle(projected)
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

        drawTriangle(centered)
    end
end

function drawTriangle(tri)
    love.graphics.polygon('line', tri[1].X, tri[1].Y, tri[2].X, tri[2].Y,tri[3].X, tri[3].Y)
end

function newVector3(vec3)
    return { 
        ["X"] = vec3.X, 
        ["Y"] = vec3.Y, 
        ["Z"] = vec3.Z 
    }
end

function newTriangle(tri)
    return {
        newVector3(tri[1]), 
        newVector3(tri[2]), 
        newVector3(tri[3])
    }
end
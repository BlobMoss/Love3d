local matrix = require "matrix"
local camera = require "camera"

cube = {
    { {-0.5}, {-0.5}, {-0.5} },
    { {0.5}, {-0.5}, {-0.5} },
    { {-0.5}, {0.5}, {-0.5} },
    { {0.5}, {0.5}, {-0.5} },
    { {-0.5}, {-0.5}, {0.5} },
    { {0.5}, {-0.5}, {0.5} },
    { {-0.5}, {0.5}, {0.5} },
    { {0.5}, {0.5}, {0.5} }
}

function love.load()
    
end

function love.update(dt)
    camera.update(dt)
end

function love.draw(dt)
    for i = 1, #cube, 1 
    do 
        local point = matrix.add(cube[i], camera.position) 

        point = matrix.multiply(matrix.rotationX(camera.angleX), point)
        point = matrix.multiply(matrix.rotationY(camera.angleY), point)
        point = matrix.multiply(matrix.rotationZ(camera.angleZ), point)

        point = matrix.multiply(matrix.perspective(camera.depth, point), point)
        
        love.graphics.points(point[1][1] * 500 + 400, point[2][1] * 500 + 300)
    end
end

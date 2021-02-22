local matrix = require "matrix"

depth = 4.0

cube = {
    { {-0.5}, {-0.5}, {-0.5} 
    },
    { {0.5}, {-0.5}, {-0.5} 
    },
    { {-0.5}, {0.5}, {-0.5} 
    },
    { {0.5}, {0.5}, {-0.5} 
    },
    { {-0.5}, {-0.5}, {0.5} 
    },
    { {0.5}, {-0.5}, {0.5} 
    },
    { {-0.5}, {0.5}, {0.5} 
    },
    { {0.5}, {0.5}, {0.5} 
    }
}

function love.load()
    
end

function love.update(dt)
    angle = angle + dt
end

function love.draw(dt)
    for i = 1, #cube, 1 
    do 
        local point = cube[i]

        point = matrix.multiply(matrix.rotationX(angle), point)
        point = matrix.multiply(matrix.rotationY(angle), point)
        point = matrix.multiply(matrix.rotationZ(angle), point)

        local z = 1 / (depth - point[3][1])
        local projection = {
            {z, 0, 0},
            {0, z, 0}
        }

        point = matrix.multiply(projection, point)
        
        love.graphics.points(point[1][1] * 500 + 400, point[2][1] * 500 + 300)
    end
end

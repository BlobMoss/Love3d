local world = {}

world.points = {}

world.width = 16
world.height = 16
world.depth = 16

function world.load()
    for x = 1, world.width, 1 do 
        world.points[x] = {}
        for y = 1, world.height, 1 do 
            world.points[x][y] = {}
            for z = 1, world.depth, 1 do 
                world.points[x][y][z] = love.math.random(0, 1)
            end
        end
    end
    print(world.points[1][1][1])
end

return world
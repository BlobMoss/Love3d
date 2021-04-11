local player = require "player"

local ui = {}

local title
local background
local pressSpace
local pressSpaceYOffset = 0.0 
local t = 0.0

function ui.load()
    title = love.graphics.newImage("images/title.png")
    background = love.graphics.newImage("images/title_background.png")
    pressSpace = love.graphics.newImage("images/press_space_to_start.png")
end

function ui.drawMenu()
    love.graphics.draw(background)
    love.graphics.draw(title, (WindowWidth - title:getWidth()) * 0.5, (WindowHeight - title:getHeight()) * 0.5 - 200)
    love.graphics.draw(pressSpace, (WindowWidth - pressSpace:getWidth()) * 0.5, (WindowHeight - pressSpace:getHeight()) * 0.5 - pressSpaceYOffset)
end

function ui.update(dt)
    t = t + dt
    pressSpaceYOffset = math.sin(t * 3.0) * 10.0
end

function ui.draw()
    drawCursor()

    drawBrushSize()

    --drawFps()
end

function drawCursor()
    LG.setColor(1.0, 1.0, 1.0, 0.75)
    LG.line(WindowCentreX, WindowCentreY - 6,    WindowCentreX, WindowCentreY + 6)
    LG.line(WindowCentreX - 6, WindowCentreY,    WindowCentreX + 6, WindowCentreY)
end

function drawBrushSize()
    LG.setColor(0.0, 0.0, 0.0, 0.25)
    LG.circle("fill", 75, WindowHeight - 75, 60.0)
    LG.setColor(1.0, 1.0, 1.0, 0.75)
    LG.circle("line", 75, WindowHeight - 75, 60.0)
    local fraction = (BrushRadius - MinBrushRadius) / (MaxBrushRadius - MinBrushRadius)
    LG.circle("fill", 75, WindowHeight - 75, 60.0 * 0.2 + 60.0 * 0.8 * fraction)
end

function drawFps()
    LG.setColor(1.0, 1.0, 1.0)
    LG.print("Fps: " .. tostring(love.timer.getFPS()), 10, 10)
end

return ui
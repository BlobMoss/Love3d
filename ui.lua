local player = require "player"

local ui = {}

local brushScale = 60.0

function ui.draw()
    drawCursor()

    drawBrushSize()

    drawFps()
end

function drawCursor()
    LG.setColor(1.0, 1.0, 1.0, 0.75)
    LG.line(WindowCentreX, WindowCentreY - 6,    WindowCentreX, WindowCentreY + 6)
    LG.line(WindowCentreX - 6, WindowCentreY,    WindowCentreX + 6, WindowCentreY)
end

function drawBrushSize()
    LG.setColor(0.0, 0.0, 0.0, 0.25)
    LG.circle("fill", 75, WindowHeight - 75, brushScale)
    LG.setColor(1.0, 1.0, 1.0, 0.75)
    LG.circle("line", 75, WindowHeight - 75, brushScale)
    local fraction = (BrushRadius - MinBrushRadius) / (MaxBrushRadius - MinBrushRadius)
    LG.circle("fill", 75, WindowHeight - 75, brushScale * 0.2 + brushScale * 0.8 * fraction)
end

function drawFps()
    LG.setColor(1.0, 1.0, 1.0)
    LG.print("Fps: " .. tostring(love.timer.getFPS()), 10, 10)
end

return ui
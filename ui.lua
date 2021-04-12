local player = require "player"

local ui = {}

local title

local background

local pressSpace
local pressSpaceYOffset = 0.0 
local t = 0.0

local escQuit

function ui.load()
    --Title screen components
    title = LG.newImage("images/title.png")
    background = LG.newImage("images/title_background.png")
    pressSpace = LG.newImage("images/press_space_to_start.png")
    escQuit = LG.newImage("images/quit.png")

    --Control screen components
    controlsBackground = LG.newImage("images/controls_background.png")
    controls = LG.newImage("images/controls.png")
    escBack = LG.newImage("images/back.png")
end

function ui.update(dt)
    t = t + dt
    pressSpaceYOffset = math.sin(t * 3.0) * 10.0
end

function ui.draw()
    if Gamestate == 0 then
        drawMenu()

    elseif Gamestate == 1 then
        drawCursor()

        drawBrushSize()

        --drawFps()

    elseif Gamestate == 2 then
        drawControls()
    end
end

function drawMenu()
    LG.setColor(1.0, 1.0, 1.0, 1.0)
    LG.draw(background)
    LG.draw(title, (WindowWidth - title:getWidth()) * 0.5, (WindowHeight - title:getHeight()) * 0.5 - 200)
    LG.draw(pressSpace, (WindowWidth - pressSpace:getWidth()) * 0.5, (WindowHeight - pressSpace:getHeight()) * 0.5 - pressSpaceYOffset)
    LG.draw(escQuit, 0, WindowHeight - escQuit:getHeight())
end

function drawControls()
    LG.setColor(1.0, 1.0, 1.0, 1.0)
    LG.draw(controlsBackground)
    LG.draw(controls)
    LG.draw(escBack, 0, WindowHeight - escBack:getHeight())
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
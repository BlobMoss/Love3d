--Math
local vector = require "math/vector"
local matrix = require "math/matrix"
local triangle = require "math/triangle"

--Modules
local graphics = require "graphics"
local world = require "world/world"
local player = require "player"
local content = require "content"
local ui = require "ui"

LG = love.graphics

--Window information
WindowWidth = LG.getWidth()
WindowHeight = LG.getHeight()

WindowCentreX = WindowWidth * 0.5
WindowCentreY = WindowHeight * 0.5

BackgroundColor = vector3(0.20, 0.35, 0.40)
FogDistance = 10.0

--This is the value to decrease if you need more performance
RenderDistance = 2.2

--Camera variables
CameraPosition = vector.newIdentity()
CameraLookDirection = vector.newIdentity()

CameraRotY = 0.0
CameraRotX = 0.0

function love.load()
    love.mouse.setVisible(false)
    love.mouse.setPosition(WindowCentreX, WindowCentreY)

    LG.setBackgroundColor(BackgroundColor.X, BackgroundColor.Y, BackgroundColor.Z)
 
    world.load()

    player.load()

    graphics.load()
end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit() 
    end

    world.update()

    player.update(dt)

    graphics.update(dt)
end

function love.draw(dt)
    world.drawChunks()

    graphics.draw()

    ui.draw()
end
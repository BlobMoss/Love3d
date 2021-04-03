--Math
local vector = require "math/vector"
local matrix = require "math/matrix"
local triangle = require "math/triangle"

--Modules
local graphics = require "graphics"
local world = require "world/world"
local marching_cubes = require "world/marching_cubes"
local player = require "player"
local content = require "content"

LG = love.graphics

--Window information
WindowWidth = LG.getWidth()
WindowHeight = LG.getHeight()

WindowCentreX = WindowWidth * 0.5
WindowCentreY = WindowHeight * 0.5

BackgroundColor = vector3(0.15, 0.15, 0.175)
FogDistance = 10.0

--This is the value to decrease if you need more performance
RenderDistance = 2.2

--Camera variables
CameraPosition = vector.newIdentity()
CameraLookDirection = vector.newIdentity()

CameraRotY = 0.0
CameraRotX = 0.0

--local anchorMesh = {}

function love.load()
    love.mouse.setVisible(false)
    love.mouse.setPosition(WindowCentreX, WindowCentreY)

    LG.setBackgroundColor(BackgroundColor.X, BackgroundColor.Y, BackgroundColor.Z)
 
    --anchorMesh.triangles = content.loadModel("models/anchor.obj")
    
    world.load()

    graphics.load()
end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit() 
    end

    player.update(dt)

    world.update()

    graphics.update(dt)
end

function love.draw(dt)
    world.drawChunks()

    graphics.draw()

    LG.setColor(1.0, 1.0, 1.0)
    LG.print("Fps: " .. tostring(love.timer.getFPS()), 10, 10)
end
--Math
local vector = require "math/vector"
local matrix = require "math/matrix"
local triangle = require "math/triangle"

--Modules
local graphics = require "graphics"
local content = require "content"

local marching_cubes = require "marching_cubes"

local player = require "player"

LG = love.graphics

--Window information
WindowWidth = LG.getWidth()
WindowHeight = LG.getHeight()

WindowCentreX = WindowWidth * 0.5
WindowCentreY = WindowHeight * 0.5

WindowFocused = true

--Camera variables
CameraPosition = vector.newIdentity()
CameraLookDirection = vector.newIdentity()

CameraRotY = 0.0
CameraRotX = 0.0

--Meshes
local anchorMesh = {}
local worldMesh = {}

function love.load()
    love.mouse.setVisible(false)
    love.mouse.setPosition(WindowCentreX, WindowCentreY)

    LG.setBackgroundColor(0.15, 0.15, 0.175, 1.0)

    --Load content
    anchorMesh.triangles = content.loadModel("models/anchor.obj")
    
    worldMesh.triangles = marching_cubes.generate()
    print("Marching cubes generated " .. #worldMesh.triangles .. " triangles")

    graphics.load()
end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit() 
    end

    player.update(dt)

    graphics.update(dt)
end

function love.draw(dt)
    graphics.drawMesh(worldMesh)

    LG.setColor(1.0, 1.0, 1.0)
    LG.print("Fps: " .. tostring(love.timer.getFPS()), 10, 10)
end

function love.focus(f)
    WindowFocused = f
end
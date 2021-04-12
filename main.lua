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

--0: title
--1: playing
--2: controls
Gamestate = 0

--To prevent chaining presses from closing the game
local escPressed = false

function love.load()
    LG.setBackgroundColor(BackgroundColor.X, BackgroundColor.Y, BackgroundColor.Z)

    ui.load()
end

function start()
    Gamestate = 1

    love.mouse.setPosition(WindowCentreX, WindowCentreY)
 
    world.load()

    player.load()

    graphics.load()
end

function love.update(dt)
    if Gamestate == 0 then 
        if love.keyboard.isDown("escape") and escPressed == false then
            love.event.quit() 
        end
        if love.keyboard.isDown("space") then
            start()
        end
        if love.keyboard.isDown("c") then
            Gamestate = 2
        end

        love.mouse.setVisible(true)

    elseif Gamestate == 1 then 
        
        if love.keyboard.isDown("escape") and escPressed == false then
            escPressed = true
            Gamestate = 0
        end

        love.mouse.setVisible(false)

        world.update()

        player.update(dt)
    
        graphics.update(dt)

    elseif Gamestate == 2 then 
        if love.keyboard.isDown("escape") and escPressed == false then
            escPressed = true
            Gamestate = 0
        end

        love.mouse.setVisible(true)
    end

    if love.keyboard.isDown("escape") == false then
        escPressed = false
    end

    ui.update(dt)
end

function love.draw(dt)
    if Gamestate == 1 then 
        world.drawChunks()

        graphics.draw()
    end

    ui.draw()
end
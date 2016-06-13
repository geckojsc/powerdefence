oo = require "oo"
cam = (require "camera")()
flux = require "flux"
assets = require "assets"
input = require "input"
local limitFrameRate = require "limitframerate"
local Scene = require "Scene"
local Player = require "Player"
local EnemyGrunt = require "EnemyGrunt"
local lighting = require "lighting"
local mode = require "mode"
local ForceField = require "ForceField"
local Orb = require "Orb"
local HUD = require "HUD"

local piefiller = require "external.piefiller"

local animSpeed = 1
debugMode = false -- global debug flag (toggle: F1). Use as you wish
profilerEnabled = false

player1 = nil
player2 = nil

orb = nil

-- for scaling the window
BASE_WIDTH = 400
BASE_HEIGHT = 240


function love.load(arg)
	
    -- allows debugging (specifically breakpoints) in ZeroBrane
    --if arg[#arg] == '-debug' then require('mobdebug').start() end

	-- for printing in zerobrane
	io.stdout:setvbuf("no")

	lf = love.filesystem
	ls = love.sound
	la = love.audio
	lp = love.physics
	lt = love.thread
	li = love.image
	lg = love.graphics
	lm = love.mouse
	lj = love.joystick
	lw = love.window

	assets.load()

	love.mouse.setVisible(false)

	-- lg.setFont(assets.font)

	globalTimer = 0

	math.randomseed(os.time())

	scene = Scene.new()

    lighting.init()

	player1 = Player.new(1)
	scene:add(player1)

	EnemyGrunt.new(scene, 50, 50)
	EnemyGrunt.new(scene, -50, -50)
	EnemyGrunt.new(scene, -100, 100)


    orb = Orb.new(0,0)
    scene:add(orb)

	cam:zoomTo(2) -- set render scale
	cam:lookAt(0,0)
	
	pie = piefiller:new()
end


function love.update(dt)
	-- limitFrameRate(60)
	
	if profilerEnabled then pie:attach() end
    flux.update(dt*animSpeed) -- update tweening system
    globalTimer = globalTimer + dt
    scene:update(dt)

	local p1x, p1y = player1.body:getPosition()
	local p2x, p2y = p1x, p1y
	if player2 then
		p2x, p2y = player2.body:getPosition()
	end
	local ratio = 0.5
    cam:lookAt(lerp(p1x, p2x, ratio), lerp(p1y, p2y, ratio))

	-- no love.blah function for joystick axis change
    input.checkJoystickAxes()
	if profilerEnabled then pie:detach() end
end


function love.draw()
    lg.setBackgroundColor(253,233,137)
    lg.setColor(255,255,255)


    cam:attach()
		lg.draw(assets.background,-512,-512,0,1,1,0,0,0,0)

		ForceField:drawTop()
		scene:draw()
		ForceField:drawBottom()

    cam:detach()


    -- doesn't affect the output during the day
    lighting.renderLights()
    lighting.applyLights()

    HUD.draw()

    if debugMode then
        lg.setColor(255,0,0)
        love.graphics.print('debug on', 20, 20)
        love.graphics.print(string.format('FPS: %d', love.timer.getFPS()), 20, 40)
    end

    if input.lastAim == 'mouse' then
        lg.setColor(255,255,255)
        lg.draw(assets.reticule, input.mousex, input.mousey, 0, cam.scale*0.6, cam.scale*0.6, 7, 7)
    end
    lg.setColor(255,255,255)
	if profilerEnabled then pie:draw() end
end

function love.resize(w, h)
	local ratiox = w / BASE_WIDTH
	local ratioy = h / BASE_HEIGHT
	flux.to(cam, 1, {scale = math.max(ratiox, ratioy)})
end

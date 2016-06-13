local assets = {}

local function makeQuads(img, quadw, quadh)
	local w, h = img:getDimensions()
	local t = {}
	for y=0, h-1, quadh do
		for x=0, w-1, quadw do
			table.insert(t, lg.newQuad(x, y, quadw, quadh, w, h))
		end
	end
	return t
end

local function makeMask(img)
	local srcPixels = img:getData()
	local maskPixels = li.newImageData(srcPixels:getDimensions())
	maskPixels:mapPixel(function(x,y,r,g,b,a)
		r,g,b,a = srcPixels:getPixel(x,y)
		return 255, 255, 255, (a>0 and 255 or 0)
	end)
	return lg.newImage(maskPixels)
end

local function makeOutline(img)
	local srcPixels = img:getData()
	local w,h = srcPixels:getDimensions()
	local maskPixels = li.newImageData(w+2,h+2)
	local function tryGetPixel(x,y)
		if x < 0 or x >= w or y < 0 or y >= h then
			return 0
		end
		local r,g,b,a = srcPixels:getPixel(x, y)
		return a>0 and 1 or 0
	end
	maskPixels:mapPixel(function(x,y,r,g,b,a)
		x = x-1
		y = y-1
		local neighbours = tryGetPixel(x+1, y+1)
		                 + tryGetPixel(x,   y+1)
		                 + tryGetPixel(x-1, y+1)
		                 + tryGetPixel(x+1, y)
		                 + tryGetPixel(x-1, y)
		                 + tryGetPixel(x+1, y-1)
		                 + tryGetPixel(x,   y-1)
		                 + tryGetPixel(x-1, y-1)
		return 255, 255, 255, ((neighbours>0 and neighbours<8) and 255 or 0)
	end)
	return lg.newImage(maskPixels)
end

function assets.load()

	lg.setDefaultFilter("nearest", "nearest") -- for sharp pixel zooming

	assets.player = {
		lg.newImage("assets/player_blue.png"),
		lg.newImage("assets/player_green.png"),
		lg.newImage("assets/player_pink.png"),
		lg.newImage("assets/player_yellow.png")
	}
	-- generate quads and masks:
	assets.playerq = makeQuads(assets.player[1], 16, 16)
	assets.playerm = {}
	for i,v in ipairs(assets.player) do
		assets.playerm[i] = makeMask(v)
	end

	assets.hearts = lg.newImage("assets/heart.png")
	assets.heartq = makeQuads(assets.hearts,32,32)
	assets.reticule = lg.newImage('assets/reticule.png')

	assets.weapons = {
        pistol = lg.newImage("assets/pistol.png"),
        machineGun = lg.newImage("assets/machinegun.png"),
        rocketLauncher = lg.newImage("assets/rocketlauncher.png"),
        laserRifle = lg.newImage("assets/laserrifle.png"),
        minigun = lg.newImage("assets/minigun.png"),
    }

    assets.weaponsq = {
        [assets.weapons.laserRifle] = makeQuads(assets.weapons.laserRifle, 32, 13),
        [assets.weapons.minigun] = makeQuads(assets.weapons.minigun, 46, 16),
    }
    assets.weaponsm = {
        [assets.weapons.pistol] = makeMask(assets.weapons.pistol),
        [assets.weapons.machineGun] = makeMask(assets.weapons.machineGun),
        [assets.weapons.rocketLauncher] = makeMask(assets.weapons.rocketLauncher),
        [assets.weapons.laserRifle] = makeMask(assets.weapons.laserRifle),
        [assets.weapons.minigun] = makeMask(assets.weapons.minigun),
    }
    assets.weaponso = {
        [assets.weapons.pistol] = makeOutline(assets.weapons.pistol),
        [assets.weapons.machineGun] = makeOutline(assets.weapons.machineGun),
        [assets.weapons.rocketLauncher] = makeOutline(assets.weapons.rocketLauncher),
        [assets.weapons.laserRifle] = makeOutline(assets.weapons.laserRifle),
        [assets.weapons.minigun] = makeOutline(assets.weapons.minigun),
    }
    assets.weaponsoq = {
        [assets.weapons.laserRifle] = makeQuads(assets.weaponso[assets.weapons.laserRifle], 34, 15),
        [assets.weapons.minigun] = makeQuads(assets.weaponso[assets.weapons.minigun], 48, 18),
    }


	assets.bullet = lg.newImage("assets/bullet.png")
    assets.rocket = lg.newImage("assets/rocket.png")
    
    assets.explosion = lg.newImage("assets/explosion.png")
    assets.explosionq = makeQuads(assets.explosion,64,64)

	assets.grunt = love.graphics.newImage("assets/grunt.png")
	assets.gruntq = makeQuads(assets.grunt, 32, 32)
  
    assets.soldier = lg.newImage("assets/soldier.png")
    assets.soldierq = makeQuads(assets.soldier, 32, 32)

	assets.lights = {
		surround = lg.newImage('assets/glow_white.png'),
		torch = lg.newImage('assets/torch_white.png')
    }

	assets.background = love.graphics.newImage("assets/placeholders/floor.png")
	assets.fft = love.graphics.newImage("assets/placeholders/forcefieldtop.png")
	assets.ffb = love.graphics.newImage("assets/placeholders/forcefieldbottom.png")
    assets.fft2 = love.graphics.newImage("assets/placeholders/forcefieldtop2.png")
	assets.ffb2 = love.graphics.newImage("assets/placeholders/forcefieldbottom2.png")
    assets.orb = love.graphics.newImage("assets/orb.png")
    assets.orbq = makeQuads(assets.orb, 32, 32)

	assets.gamefont = lg.newFont("assets/Skullboy.ttf", 16)
	assets.menufont = lg.newFont("assets/Little-League.ttf", 20)
end

return assets

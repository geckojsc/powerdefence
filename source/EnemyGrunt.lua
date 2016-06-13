local Anim = require "Anim"

local EnemyGrunt = oo.class()

local ANIM_WALK = {1,2,3,4,5,6, rate = 15}
local ANIM_DIE = {7,8,9,10,11,12,13,14,15,16, rate = 15, loop=false}

function EnemyGrunt:init(scene, x, y)
	scene:add(self)
	self.alive = true
	self.body = lp.newBody(scene.world, x, y, "dynamic")
	self.body:setFixedRotation(true)
	--self.shape = lp.newCircleShape(10)
	self.shape = lp.newRectangleShape(13,26)
	self.fixture = lp.newFixture(self.body, self.shape)
    self.fixture:setUserData({dataType='enemy', data=self})
	self.anim = Anim.new(ANIM_WALK)
	self.angle = 0
	self.speed = 20
	self.target = nil
	self.hp = 2
	self.depthOffset = 8
	-- updating the target is expensive
	self.targetUpdateRate = 0.5
	self.lastTargetUpdateTime = 0
	-- save the velocity which aims at the current target
	self.vx = 0
	self.vy = 0
end

function EnemyGrunt:update(dt)
    if globalTimer > self.lastTargetUpdateTime + self.targetUpdateRate then
        -- slow path: update target
        self.target = self.scene:getNearest("player", self)
        if self.target and self.alive then
            local x1, y1 = self.body:getPosition()
            local x2, y2 = self.target.body:getPosition()
            self.angle = math.atan2(y2-y1, x2-x1)
            self.vx = math.cos(self.angle) * self.speed
            self.vy = math.sin(self.angle) * self.speed
            self.body:setLinearVelocity(self.vx, self.vy)
        end
        self.lastTargetUpdateTime = globalTimer
    elseif not self.alive then
        -- dead path: handle physics at death
        local vx,vy = self.body:getLinearVelocity()
        if vx < 0.1 and vy < 0.1 then
            self.body:setLinearVelocity(0, 0)
        else
            self.angle = math.atan2(vy,vx)
            self.body:setLinearVelocity(vx*0.9, vy*0.9)
        end
    else
        -- fast path: set the velocity to the same as the previous velocity
        self.body:setLinearVelocity(self.vx, self.vy)
    end
	self.anim:update(dt)
end

function EnemyGrunt:draw()
	local x, y = self.body:getPosition()
	local dir = math.abs(self.angle) > math.pi/2 and 1 or -1
	lg.draw(assets.grunt, assets.gruntq[self.anim.frame], x, y, 0, dir, 1, 15, 16)
end


function EnemyGrunt:takeDamage()
    self.hp = self.hp - 1
    if self.hp <= 0 then
		self.alive = false
		self.type = 'deadEnemy'
		self.anim:play(ANIM_DIE)
		self.fixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
    end
end

return EnemyGrunt

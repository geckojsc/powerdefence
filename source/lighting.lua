
require 'gameConfig'
local coordinator = require 'coordinator'

local lighting = {}


function lighting.init()
    lighting.canvas = lg.newCanvas()
end


function lighting.renderLights()
    love.graphics.setCanvas(lighting.canvas)
        lg.setColor(ambientDarkness, ambientDarkness, ambientDarkness)
        lg.rectangle('fill', 0, 0, lg.getDimensions())
        cam:attach()

            -- orb glow
            local orb = coordinator.gameData.orb
            if orb then
                lg.setColor(0.6, 0.6, 0)
                local scale = 1 + math.sin(globalTimer*3)*0.2
                local orbX, orbY = orb.body:getPosition()
                lg.draw(assets.lights.surround, orbX, orbY, 0, scale, scale, 256, 256)

                -- orb mask
                lg.setColor(0.2, 0.2, 0.2)
                lg.draw(assets.orbm, assets.orbq[clamp(7 - orb.hp, 1, 7)],
                    orb.body:getX(), orb.body:getY(), 0, 1, 1, 16, 16)

            end

            lg.setColor(0, 0.2, 0.4)
            local originx, originy = 10, 128

            -- player1 torch
            if player1:isAlive() then
                local angle = player1.aimAngle
                local x = player1.body:getX()+10*math.cos(angle)
                local y = player1.body:getY()+10*math.sin(angle)
                lg.draw(assets.lights.torch, x, y, angle, 0.4, 0.4, originx, originy)

                -- draw glow
                lg.setColor(0.4, 0.4, 0.4)
                x = player1.body:getX()
                y = player1.body:getY()
                lg.draw(assets.playerm[1], assets.playerq[player1.anim.frame], x, y, player1.rotation, 1, 1, 8, 8)
            end

            -- player2 torch
            if player2 and player2:isAlive() then
                angle = player2.aimAngle
                x = player2.body:getX()+10*math.cos(angle)
                y = player2.body:getY()+10*math.sin(angle)
                lg.draw(assets.lights.torch, x, y, angle, 0.4, 0.4, originx, originy)

                -- draw glow
                lg.setColor(0.4, 0.4, 0.4)
                x = player2.body:getX()
                y = player2.body:getY()
                lg.draw(assets.playerm[2], assets.playerq[player2.anim.frame], x, y, player2.rotation, 1, 1, 8, 8)
            end

            -- explosions
            local allExplosions = scene.types.explosion
            if allExplosions then
                for _, e in ipairs(allExplosions) do
                    lg.setColor(0.2, 0.2, 0.2)
                    local scale = 0.5
                    lg.draw(assets.lights.surround, e.body:getX(), e.body:getY(), 0, scale, scale, 256, 256)
                end
            end

            -- flames
            local allFlames = scene.types.flame
            if allFlames then
                for _, e in ipairs(allFlames) do
                    lg.setColor(0.0, 0.4, 0.4)
                    local scale = 0.1 + 0.1*math.random()
                    lg.draw(assets.lights.surround, e.body:getX(), e.body:getY(), 0, scale, scale, 256, 256)
                end
            end

            -- glowsticks
            local allGlowsticks = scene.types.glowstick
            if allGlowsticks then
                for _, e in ipairs(allGlowsticks) do
                    lg.setColor(1 - e.r, 1 - e.g, 1 - e.b)
                    local scale = e.fuse/e.maxfuse * (0.95 + 0.05*math.random())
                    lg.draw(assets.lights.surround, e.body:getX(), e.body:getY(), 0, scale, scale, 256, 256)
                end
            end

            local allLasers = scene.types.laser
            if allLasers then
                for _, e in ipairs(allLasers) do
                    lg.setColor(0.0, 0.0, 0.2)
                    local scale = 0.02
                    lg.draw(assets.lights.surround, e.body:getX(), e.body:getY(), 0, scale, scale, 256, 256)
                end
            end

            -- muzzle flares
            local allFlares = scene.types.muzzleFlare
            if allFlares then
                for _, e in ipairs(allFlares) do
                    lg.setColor(0.2, 0.2, 0.2)
                    local scale = 0.25*e.scale * (0.8 + 0.4*math.random())
                    lg.draw(assets.lights.surround, e.x, e.y, 0, scale, scale, 256, 256)
                end
            end

        cam:detach()
    love.graphics.setCanvas()
end

function lighting.applyLights()
    lg.setBlendMode('subtract')
        lg.setColor(1, 1, 1, coordinator.gameData.lightingAmount)
        lg.draw(lighting.canvas)
    lg.setBlendMode('alpha')
end


return lighting

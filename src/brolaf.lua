local brolaf_mt = {}
brolaf = {}
brolaf.cur = nil

function brolaf.new(options)
	local self = setmetatable({}, {__index=brolaf_mt})

	local options = options or {}
	self.position = options.position or vec2.new(8.5*32, 5.5*32)

	self.attackCool = 0

	self.speed = 100
	self.totalHp = 5
	self.hp = self.totalHp
	self.damage = 1
	self.rangeDamage = 40
	self.rateDamage = 0.1
	self.currentTimerHit = self.rateDamage
	self.currentDirection = vec2.new(0, 0)
	self.rangeTakeItem = 15
	self.timeHyperKill = 0
	self.positionHPUI = { x = 544, y = 64 }
	self.positionBONUSUI = { x = 544, y = 80 }
	self.positionMSGCENTER = { x = 237, y = 124 }
	self.positionKILLUI = { x = 544, y = 96 }
	self.numberEnemiesKill = 0

	self.currentDrawDirection = "down"

	if not options.noReplace then
		brolaf.cur = self
	end
	return self
end

function brolaf.update( dt )
	if brolaf.cur then
		brolaf.cur:update(dt)
	end
end

function brolaf.draw(  )
	if brolaf.cur then
		brolaf.cur:draw()
	end
end

function brolaf.position(  )
	if brolaf.cur then
		return brolaf.cur.position
	end
	return vec2.new(0, 0)
end

function brolaf.takeDamage( damage )
	if brolaf.cur then
		brolaf.cur:takeDamage(damage)
	end
end

function brolaf.addHP( hp )
	if brolaf.cur then
		brolaf.cur:addHP(hp)
	end
end

function brolaf.addTimeHyperKill( timeHyperKill )
	if brolaf.cur then
		brolaf.cur:addTimeHyperKill(timeHyperKill)
	end
end

function brolaf_mt:update( dt )
	if room then
		-- Movement
		currentDirection = vec2.new(0, 0)
		-- Left
		if ((not self.joystick and love.keyboard.isDown("left", "q", "a"))
			or
			(self.joystick and (self.joystick:isGamepadDown("dpleft") or useful.dead(self.joystick:getGamepadAxis("leftx")) < 0)))
			then
				tempNewPosition = self.position:add(vec2.new(-self.speed * dt, 0))
				if room.cur:IsPathWalkablePixel(tempNewPosition) then
					currentDirection = currentDirection:add(vec2.new(-self.speed  * dt, 0))
				elseif room.cur:IsTileDoorPixel(tempNewPosition) then
				    room.new({ noReplace = false, PreviousPosition = room.cur.WorldPosition, DirectionDoor = "left", Player = self })
				end
		end
		-- Right
		if ((not self.joystick and love.keyboard.isDown("right", "d"))
			or
			(self.joystick and (self.joystick:isGamepadDown("dpright") or useful.dead(self.joystick:getGamepadAxis("leftx")) > 0)))
			then
				tempNewPosition = self.position:add(vec2.new(self.speed * dt, 0))
				if room.cur:IsPathWalkablePixel(tempNewPosition) then
					currentDirection = currentDirection:add(vec2.new(self.speed * dt, 0))
				elseif room.cur:IsTileDoorPixel(tempNewPosition) then
				    room.new({ noReplace = false, PreviousPosition = room.cur.WorldPosition, DirectionDoor = "right", Player = self })
				end
		end
		-- Down
		if ((not self.joystick and love.keyboard.isDown("down", "s"))
			or
			(self.joystick and (self.joystick:isGamepadDown("dpdown") or useful.dead(self.joystick:getGamepadAxis("lefty")) > 0)))
			then
				tempNewPosition = self.position:add(vec2.new(0, self.speed * dt))
				if room.cur:IsPathWalkablePixel(tempNewPosition) then
					currentDirection = currentDirection:add(vec2.new(0, self.speed * dt))
				elseif room.cur:IsTileDoorPixel(tempNewPosition) then
				    room.new({ noReplace = false, PreviousPosition = room.cur.WorldPosition, DirectionDoor = "down", Player = self })
				end
		end
		-- Up
		if ((not self.joystick and love.keyboard.isDown("up", "z", "w"))
			or
			(self.joystick and (self.joystick:isGamepadDown("dpup") or useful.dead(self.joystick:getGamepadAxis("lefty")) < 0)))
			then
				tempNewPosition = self.position:add(vec2.new(0, -self.speed * dt))
				if room.cur:IsPathWalkablePixel(tempNewPosition) then
					currentDirection = currentDirection:add(vec2.new(0, -self.speed * dt))
				elseif room.cur:IsTileDoorPixel(tempNewPosition) then
				    room.new({ noReplace = false, PreviousPosition = room.cur.WorldPosition, DirectionDoor = "up", Player = self })
				end
		end
		self.position = self.position:add(currentDirection)
		if not currentDirection.x == 0 or not currentDirection.y == 0 then
			self.currentDirection = currentDirection
		end
	end
	if currentDirection.x<-0.5 then
		self.currentDrawDirection="left"
	elseif currentDirection.x>0.5 then
		self.currentDrawDirection="right"
	elseif currentDirection.y<-0.5 then
		self.currentDrawDirection="up"
	elseif currentDirection.y>0.5 then
		self.currentDrawDirection="down"
	end

	-- Shoot
	self.currentTimerHit = self.currentTimerHit + dt
	if self.timeHyperKill > 0 then
		self.timeHyperKill = self.timeHyperKill - dt
		if self.timeHyperKill < 0 then
			self.timeHyperKill = 0
		end
	end
	if ((not self.joystick and (love.keyboard.isDown("return", " ") or love.mouse.isDown("l", "m", "r")))
		or
		(self.joystick and (self.joystick:isGamepadDown("a", "b", "x", "y", "leftshoulder","rightshoulder") or
		useful.dead(self.joystick:getGamepadAxis("triggerleft")) > 0 or useful.dead(self.joystick:getGamepadAxis("triggerright")) > 0)))
		and self.currentTimerHit >= self.rateDamage then
			self.attackCool = 1
			enemyClosest = enemy.findClosest(self.position, self.rangeDamage, self.currentDirection)
			if enemyClosest then
				if self.timeHyperKill > 0 then
					if enemyClosest:takeDamage(enemyClosest.hp) then
						self.numberEnemiesKill = self.numberEnemiesKill + 1
					end
				else
					if enemyClosest:takeDamage(self.damage) then
						self.numberEnemiesKill = self.numberEnemiesKill + 1
					end
				end
				self.currentTimerHit = 0
			end
	end
	self.attackCool = self.attackCool - dt * 10
	-- Check items
	itemClosest = item.findClosest(self.position, self.rangeTakeItem)
	if itemClosest then
		itemClosest:pickUp(self)
	end
end

function brolaf_mt:draw()
	local drawWord = ({
		left = "left",
		right = "right",
		up = "back",
		down = "front"
	})[self.currentDrawDirection];
	love.graphics.draw("Viking_idle_"..drawWord, math.floor(self.position.x), math.floor(self.position.y), 0, 1, 1, 16,32)
	love.graphics.print("HP "..self.hp, self.positionHPUI.x, self.positionHPUI.y)
	love.graphics.print("BONUS "..math.floor(self.timeHyperKill), self.positionBONUSUI.x, self.positionBONUSUI.y)
	love.graphics.print("Kill "..self.numberEnemiesKill, self.positionKILLUI.x, self.positionKILLUI.y)
	
	local offsetx = font:getWidth(G.MESSAGE_TO_DISPLAY) / 2
	local offsety = font:getHeight() /2
	local shake = G.SHAKE
	love.graphics.print(G.MESSAGE_TO_DISPLAY, self.positionMSGCENTER.x ,self.positionMSGCENTER.y,G.SHAKE,3,3,offsetx,offsety)

	if math.ceil((1-self.attackCool)*6)>0 and math.ceil((1-self.attackCool)*6)<7 then
		local anim = math.ceil((1-self.attackCool)*6)
		local attRot = ({
			left = math.pi/2,
			right = -math.pi/2,
			up = math.pi,
			down = 0
		})[self.currentDrawDirection];
		love.graphics.draw("Swoosh_viking_"..anim,math.floor(self.position.x), math.floor(self.position.y)-16,attRot,1,1,20,-5)
	end
end

function brolaf_mt:takeDamage( damage )
	self.hp = self.hp - damage
	if self.hp <= 0 then
		self.hp = 0
		print ("Dead")
		menu = require("menu")
		gstate.switch(menu)
	end
end

function brolaf_mt:addHP( hp )
	self.hp = self.hp + hp
	if self.hp > self.totalHp then
		self.hp = self.totalHp
	end
end

function brolaf_mt:addTimeHyperKill( timeHyperKill )
	self.timeHyperKill = timeHyperKill
end
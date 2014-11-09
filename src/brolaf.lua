local brolaf_mt = {}
brolaf = {}
brolaf.cur = nil

function brolaf.new(options)
	local self = setmetatable({}, {__index=brolaf_mt})

	local options = options or {}
	self.position = options.position or vec2.new(4.5*32, 4.5*32)

	self.speed = 0.4
	self.totalHp = 5
	self.hp = self.totalHp
	self.damage = 1
	self.rangeDamage = 30
	self.rateDamage = 0.1
	self.currentTimerHit = self.rateDamage
	self.currentDirection = vec2.new(0, 0)
	self.rangeTakeItem = 15
	self.timeHyperKill = 0

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
				tempNewPosition = self.position:add(vec2.new(-self.speed, 0))
				if room.cur:IsPathWalkablePixel(tempNewPosition) then
					currentDirection = currentDirection:add(vec2.new(-self.speed, 0))
				elseif room.cur:IsTileDoorPixel(tempNewPosition) then
				    room.new({ noReplace = false, PreviousPosition = room.cur.WorldPosition, DirectionDoor = "left", Player = self })
				end
		end
		-- Right
		if ((not self.joystick and love.keyboard.isDown("right", "d"))
			or
			(self.joystick and (self.joystick:isGamepadDown("dpright") or useful.dead(self.joystick:getGamepadAxis("leftx")) > 0)))
			then
				tempNewPosition = self.position:add(vec2.new(self.speed, 0))
				if room.cur:IsPathWalkablePixel(tempNewPosition) then
					currentDirection = currentDirection:add(vec2.new(self.speed, 0))
				elseif room.cur:IsTileDoorPixel(tempNewPosition) then
				    room.new({ noReplace = false, PreviousPosition = room.cur.WorldPosition, DirectionDoor = "right", Player = self })
				end
		end
		-- Down
		if ((not self.joystick and love.keyboard.isDown("down", "s"))
			or
			(self.joystick and (self.joystick:isGamepadDown("dpdown") or useful.dead(self.joystick:getGamepadAxis("lefty")) > 0)))
			then
				tempNewPosition = self.position:add(vec2.new(0, self.speed))
				if room.cur:IsPathWalkablePixel(tempNewPosition) then
					currentDirection = currentDirection:add(vec2.new(0, self.speed))
				elseif room.cur:IsTileDoorPixel(tempNewPosition) then
				    room.new({ noReplace = false, PreviousPosition = room.cur.WorldPosition, DirectionDoor = "down", Player = self })
				end
		end
		-- Up
		if ((not self.joystick and love.keyboard.isDown("up", "z", "w"))
			or
			(self.joystick and (self.joystick:isGamepadDown("dpup") or useful.dead(self.joystick:getGamepadAxis("lefty")) < 0)))
			then
				tempNewPosition = self.position:add(vec2.new(0, -self.speed))
				if room.cur:IsPathWalkablePixel(tempNewPosition) then
					currentDirection = currentDirection:add(vec2.new(0, -self.speed))
				elseif room.cur:IsTileDoorPixel(tempNewPosition) then
				    room.new({ noReplace = false, PreviousPosition = room.cur.WorldPosition, DirectionDoor = "up", Player = self })
				end
		end
		self.position = self.position:add(currentDirection)
		if not currentDirection.x == 0 or not currentDirection.y == 0 then
			self.currentDirection = currentDirection
		end
	end

	-- Shoot
	self.currentTimerHit = self.currentTimerHit + dt
	self.timeHyperKill = self.timeHyperKill - dt
	if ((not self.joystick and (love.keyboard.isDown("return", "space") or love.mouse.isDown("l", "m", "r")))
		or
		(self.joystick and (self.joystick:isGamepadDown("a", "b", "x", "y", "leftshoulder","rightshoulder") or
		useful.dead(self.joystick:getGamepadAxis("triggerleft")) > 0 or useful.dead(self.joystick:getGamepadAxis("triggerright")) > 0)))
		and self.currentTimerHit >= self.rateDamage then
			enemyClosest = enemy.findClosest(self.position, self.rangeDamage, self.currentDirection)
			if enemyClosest then
				if self.timeHyperKill > 0 then
					enemyClosest:takeDamage(enemyClosest.hp)
				else
					enemyClosest:takeDamage(self.damage)
				end
				self.currentTimerHit = 0
			end
	end

	-- Check items
	itemClosest = item.findClosest(self.position, self.rangeTakeItem)
	if itemClosest then
		itemClosest:pickUp(self)
	end
end

function brolaf_mt:draw()
	love.graphics.circle("fill", self.position.x, self.position.y, 4)
end

function brolaf_mt:takeDamage( damage )
	self.hp = self.hp - damage
	if self.hp <= 0 then
		self.hp = 0
		print ("Dead")
		menu = require("menu")
		gstate.switch(menu)
	else
		print ("HP ", self.hp)
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
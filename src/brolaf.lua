local brolaf_mt = {}
brolaf = {}
brolaf.cur = nil

function brolaf.new(options)
	local self = setmetatable({}, {__index=brolaf_mt})

	local options = options or {}
	self.position = options.position or vec2.new(40, 40)

	self.speed = 0.4
	self.hp = 5
	self.damage = 1
	self.rangeDamage = 10
	self.rateDamage = 0.5
	self.currentTimerHit = self.rateDamage
	self.currentDirection = vec2.new(0, 0)

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

function brolaf_mt:update( dt )
	-- Movement
	currentDirection = vec2.new(0, 0)
	-- Left
	if ((not self.joystick and love.keyboard.isDown("left", "q", "a"))
		or
		(self.joystick and (self.joystick:isGamepadDown("dpleft") or useful.dead(self.joystick:getGamepadAxis("leftx")) < 0)))
		and room and room.cur:IsPathWalkablePixel(self.position:add(vec2.new(-self.speed, 0)))
		then
			currentDirection = currentDirection:add(vec2.new(-self.speed, 0))
	end
	-- Right
	if ((not self.joystick and love.keyboard.isDown("right", "d"))
		or
		(self.joystick and (self.joystick:isGamepadDown("dpright") or useful.dead(self.joystick:getGamepadAxis("leftx")) > 0)))
		and room and room.cur:IsPathWalkablePixel(self.position:add(vec2.new(self.speed, 0)))
		then
			currentDirection = currentDirection:add(vec2.new(self.speed, 0))
	end
	-- Down
	if ((not self.joystick and love.keyboard.isDown("down", "s"))
		or
		(self.joystick and (self.joystick:isGamepadDown("dpdown") or useful.dead(self.joystick:getGamepadAxis("lefty")) > 0)))
		and room and room.cur:IsPathWalkablePixel(self.position:add(vec2.new(0, self.speed)))
		then
			currentDirection = currentDirection:add(vec2.new(0, self.speed))
	end
	-- Up
	if ((not self.joystick and love.keyboard.isDown("up", "z", "w"))
		or
		(self.joystick and (self.joystick:isGamepadDown("dpup") or useful.dead(self.joystick:getGamepadAxis("lefty")) < 0)))
		and room and room.cur:IsPathWalkablePixel(self.position:add(vec2.new(0, -self.speed)))
		then
			currentDirection = currentDirection:add(vec2.new(0, -self.speed))
	end
	self.position = self.position:add(currentDirection)
	if not currentDirection.x == 0 or not currentDirection.y == 0 then
		self.currentDirection = currentDirection
	end

	-- Shoot
	self.currentTimerHit = self.currentTimerHit + dt
	if ((not self.joystick and (love.keyboard.isDown("return", "space") or love.mouse.isDown("l", "m", "r")))
		or
		(self.joystick and (self.joystick:isGamepadDown("a", "b", "x", "y", "leftshoulder","rightshoulder") or
		useful.dead(self.joystick:getGamepadAxis("triggerleft")) > 0 or useful.dead(self.joystick:getGamepadAxis("triggerright")) > 0)))
		and self.currentTimerHit >= self.rateDamage then
			enemyClosest = enemy.findClosest(self.position, self.rangeDamage, self.currentDirection)
			if enemyClosest then
				enemyClosest:takeDamage(self.damage)
				self.currentTimerHit = 0
			end
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
	else
		print ("HP ", self.hp)
	end
end
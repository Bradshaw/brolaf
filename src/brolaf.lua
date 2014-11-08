local brolaf_mt = {}
brolaf = {}
brolaf.cur = nil

local direction = { "left", "right", "down", "up" }

function brolaf.new(options)
	local self = setmetatable({}, {__index=brolaf_mt})

	local options = options or {}
	self.position = options.position or { x = 0, y = 0 }
	self.direction = "down"

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

function brolaf_mt:update( dt )
	-- Movement
	newPosition = { x = self.position.x, y = self.position.y }
	-- Left
	if (not self.joystick and love.keyboard.isDown("left", "q", "a"))
		or
		(self.joystick and (self.joystick:isGamepadDown("dpleft") or useful.dead(self.joystick:getGamepadAxis("leftx")) < 0))
		then
			newPosition.x = newPosition.x - 1
			self.direction = "left"
	end
	-- Right
	if (not self.joystick and love.keyboard.isDown("right", "d"))
		or
		(self.joystick and (self.joystick:isGamepadDown("dpright") or useful.dead(self.joystick:getGamepadAxis("leftx")) > 0))
		then
			newPosition.x = newPosition.x + 1
			self.direction = "right"
	end
	-- Down
	if (not self.joystick and love.keyboard.isDown("down", "s"))
		or
		(self.joystick and (self.joystick:isGamepadDown("dpdown") or useful.dead(self.joystick:getGamepadAxis("lefty")) > 0))
		then
			newPosition.y = newPosition.y + 1
			self.direction = "down"
	end
	-- Up
	if (not self.joystick and love.keyboard.isDown("up", "z", "w"))
		or
		(self.joystick and (self.joystick:isGamepadDown("dpup") or useful.dead(self.joystick:getGamepadAxis("lefty")) < 0))
		then
			newPosition.y = newPosition.y - 1
			self.direction = "up"
	end
	--if map.cur and map.cur.isPossible(newPosition) then
		self.position = newPosition
	--end

	-- Shoot
	if (not self.joystick and (love.keyboard.isDown("return", "space") or love.mouse.isDown("l", "m", "r")))
		or
		(self.joystick and (self.joystick:isGamepadDown("a", "b", "x", "y", "leftshoulder","rightshoulder") or
		useful.dead(self.joystick:getGamepadAxis("triggerleft")) > 0 or useful.dead(self.joystick:getGamepadAxis("triggerright")) > 0)) then
			print ("Shoot")
	end
end

function brolaf_mt:draw()
	love.graphics.circle("fill", self.position.x, self.position.y, 4)
end

local brolaf_mt = {}
brolaf = {}
brolaf.cur = nil

direction = { "left", "right", "down", "up" }
azerty = { "q", "d", "s", "z" }
qwerty = { "a", "d", "s", "w" }
mode = azerty

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
	--if map.cur then
		-- Movement
		newPosition = { x = self.position.x, y = self.position.y }
		-- Left
		if (not self.joystick and love.keyboard.isDown(mode[1]))
		   or
		   (self.joystick and (self.joystick:isGamepadDown("dpleft") or useful.dead(self.joystick:getGamepadAxis("leftx")) < 0))
		   --and map.cur.isPossible(newPosition)
		   then
				newPosition.x = newPosition.x - 1
				self.direction = "left"
		end
		-- Right
		if (not self.joystick and love.keyboard.isDown(mode[2]))
		   or
		   (self.joystick and (self.joystick:isGamepadDown("dpright") or useful.dead(self.joystick:getGamepadAxis("leftx")) > 0))
		   --and map.cur.isPossible(newPosition)
		   then
				newPosition.x = newPosition.x + 1
				self.direction = "right"
		end
		-- Down
		if (not self.joystick and love.keyboard.isDown(mode[3]))
		   or
		   (self.joystick and (self.joystick:isGamepadDown("dpdown") or useful.dead(self.joystick:getGamepadAxis("lefty")) > 0))
		   --and map.cur.isPossible(newPosition)
		   then
				newPosition.y = newPosition.y + 1
				self.direction = "down"
		end
		-- Up
		if (not self.joystick and love.keyboard.isDown(mode[4]))
		   or
		   (self.joystick and (self.joystick:isGamepadDown("dpup") or useful.dead(self.joystick:getGamepadAxis("lefty")) < 0))
		   --and map.cur.isPossible(newPosition)
		   then
				newPosition.y = newPosition.y - 1
				self.direction = "up"
		end
		self.position = newPosition

		-- Shoot
		if (not self.joystick and (love.keyboard.isDown("return") or love.keyboard.isDown("space") or love.mouse.isDown("l") or love.mouse.isDown("m") or love.mouse.isDown("r")))
		   or
		   (self.joystick and (self.joystick:isGamepadDown("a") or self.joystick:isGamepadDown("b") or
		   self.joystick:isGamepadDown("x") or self.joystick:isGamepadDown("y") or
		   self.joystick:isGamepadDown("leftshoulder") or self.joystick:isGamepadDown("rightshoulder") or
		   useful.dead(self.joystick:getGamepadAxis("triggerleft")) > 0 or useful.dead(self.joystick:getGamepadAxis("triggerright")) > 0)) then
				print ("Shoot")
		end
	--end
end

function brolaf_mt:draw()
	love.graphics.circle("fill", self.position.x, self.position.y, 4)
end

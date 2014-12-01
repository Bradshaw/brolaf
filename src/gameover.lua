local state = {}

local GameOverTexture = { name = fudge.current:getPiece("game over"), 	position = { x = 0, y = 43 }, startTime = 1 }
local CurrentTimer = 0

local lastBlast = -1
local shake = 0
local shakeamt = 10
local countToMenu = 5

function state:init()
end


function state:enter( pre )
	brolaf.new({noReplace = false})
	CurrentTimer = 0
	countToMenu = 5
	lastBlast = -1
	shake = 0
	shakeamt = 10
end


function state:leave( next )
end


function state:update(dt)
	countToMenu = countToMenu - dt
	if countToMenu<0 then
		gstate.switch(menu)
	end
	shake = shake - shake * dt*3
	if math.floor(CurrentTimer)>lastBlast and CurrentTimer<=GameOverTexture.startTime+1 then
		lastBlast = CurrentTimer
		shake = 1
	end
	CurrentTimer = CurrentTimer + dt
end


function state:draw()
	screenCanvas:clear()
	love.graphics.setCanvas(screenCanvas)


	-- Do drawing between here...
	--love.graphics.rectangle("fill",0,0,640,360)
	love.graphics.translate(
		shakeamt*math.sin(love.timer.getTime()*23)*shake,
		shakeamt*math.sin(love.timer.getTime()*33)*shake
	)

	if GameOverTexture.startTime < CurrentTimer then
		love.graphics.draw(GameOverTexture.name, GameOverTexture.position.x, GameOverTexture.position.y)
	end

	-- And here

	love.graphics.setCanvas()
	love.graphics.draw(
		screenCanvas,
		love.graphics.getWidth()/2,
		love.graphics.getHeight()/2,
		0,
		G.SCALE,
		G.SCALE,
		screenCanvas:getWidth()/2,
		screenCanvas:getHeight()/2
	)
end


function state:errhand(msg)
end


function state:focus(f)
end


function state:keypressed(key, isRepeat)
	if key=='escape' then
		gstate.switch(menu)
	end
end


function state:keyreleased(key, isRepeat)
end


function state:mousefocus(f)
end


function state:mousepressed(x, y, btn)
end


function state:mousereleased(x, y, btn)
end


function state:quit()
end


function state:resize(w, h)
end


function state:textinput( t )
end


function state:threaderror(thread, errorstr)
end


function state:visible(v)
end


function state:gamepadaxis(joystick, axis)
end


function state:gamepadpressed(joystick, btn)
	if joystick:isGamepadDown("start") then
		brolaf.cur.joystick = joystick
		gstate.switch(game)
	end
	if joystick:isGamepadDown("back") then
		gstate.switch(menu)
	end
end


function state:gamepadreleased(joystick, btn)
end


function state:joystickadded(joystick)
end


function state:joystickaxis(joystick, axis, value)
end


function state:joystickhat(joystick, hat, direction)
end


function state:joystickpressed(joystick, button)
end


function state:joystickreleased(joystick, button)
end


function state:joystickremoved(joystick)
end

return state
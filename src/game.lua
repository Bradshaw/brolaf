local state = {}

function state:init()
end

gameLastEnterRoom = 0
gamePauseOnNewRoom = 3
gameSlowDuration = .5
GlobalTimeFactor = .5


function GetBias(time,bias)
	return (time / ((((1.0/bias) - 2.0)*(1.0 - time))+1.0));
end

function gamegetDt(dt)
	local diff = love.timer.getTime() - gameLastEnterRoom

	G.MESSAGE_TO_DISPLAY = ""
	G.SHAKE = 0

	index = 1
	gamePauseOnNewRoom = 0
	repeat
		gamePauseOnNewRoom = numberDifficulty[index].timerPause
		index = index + 1
	until index > #numberDifficulty or not (numberDifficulty[index].startNumberLevel < room.numberRoomsGenerate)
	
	if diff < gamePauseOnNewRoom then
		local nbtd = math.floor(gamePauseOnNewRoom - diff + 1)
		G.MESSAGE_TO_DISPLAY = tostring(nbtd)

		return 0
	end
	diff = diff - gamePauseOnNewRoom

	if diff > gameSlowDuration then
		return dt
	end
	G.MESSAGE_TO_DISPLAY = "!!! SKOLL !!!"
	G.SHAKE = math.sin(diff * 70) * .3
	local ratio = diff / gameSlowDuration
	ratio = GetBias(ratio,.112)
	return dt * ratio
end

function state:enter( pre )
	room.numberRoomsGenerate = 0
	room.new({noReplace = false})
end


function state:leave( next )
end


function state:update(dt)
	local rdt = gamegetDt(dt) * GlobalTimeFactor
	if rdt~= 0 then
		brolaf.update(rdt)
		enemy.update(rdt)
		item.update(rdt)
	end
end


function state:draw()
	screenCanvas:clear()
	love.graphics.setCanvas(screenCanvas)


	-- Do drawing between here...
	--love.graphics.rectangle("fill",0,0,640,360)
	room.draw()
	brolaf.draw()
	enemy.draw()
	item.draw()

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
		menu = require("menu")
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
	if joystick:isGamepadDown("start") and brolaf.cur then
		brolaf.cur.joystick = joystick
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
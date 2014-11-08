local state = {}

function state:init()
	room.new()
	brolaf.new()
	enemy.new()
end


function state:enter( pre )
end


function state:leave( next )
end


function state:update(dt)
	local rdt = dt *0.25
	brolaf.update(rdt)
	enemy.update(rdt)
end


function state:draw()
	screenCanvas:clear()
	love.graphics.setCanvas(screenCanvas)


	-- Do drawing between here...
	love.graphics.rectangle("fill",0,0,640,360)
	room.draw()
	brolaf.draw()
	enemy.draw()

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
		love.event.push('quit')
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
	if joystick:isGamepadDown("back") and brolaf.cur then
		brolaf.cur.joystick = nil
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
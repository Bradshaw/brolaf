local state = {}

local TitleMenuTextures =
{
	{ name = fudge.current:getPiece("ecran-titre_0005_Explosion"), 					position = { x =  95, y =   0 }, startTime = 3 },
	{ name = fudge.current:getPiece("ecran-titre_0004_II"), 						position = { x = 217, y =  40 }, startTime = 2 },
	{ name = fudge.current:getPiece("ecran-titre_0003_SHAPE"), 						position = { x = 126, y =  62 }, startTime = 1 },
	{ name = fudge.current:getPiece("ecran-titre_0002_yeux"), 						position = { x = 304, y =  97 }, startTime = 1.5 },
	{ name = fudge.current:getPiece("ecran-titre_0000_The-infinite--viking-quest"), position = { x = 175, y = 135 }, startTime = 0 },
}
local TitlePlayTexture = { name = fudge.current:getPiece("ecran-titre_0001_PLAY"), 	position = { x = 222, y = 298 }, startTime = 4 }
local TimerDisplayPlay = 0.75
local TimerNotDisplayPlay = 0.5
local CurrentTimerDisplayPlay = 0
local CurrentTimer = 0

local lastBlast = -1
local shake = 0
local shakeamt = 10


function state:init()
end


function state:enter( pre )
	brolaf.new({noReplace = false})
	TimerDisplayPlay = 0.75
	TimerNotDisplayPlay = 0.5
	CurrentTimerDisplayPlay = 0
	CurrentTimer = 0

	lastBlast = -1
	shake = 0
	shakeamt = 10
end


function state:leave( next )
end


function state:update(dt)
	shake = shake - shake * dt*3
	if math.floor(CurrentTimer)>lastBlast and CurrentTimer<=TitlePlayTexture.startTime+1 then
		lastBlast = CurrentTimer
		shake = 1
	end
	CurrentTimer = CurrentTimer + dt
	CurrentTimerDisplayPlay = CurrentTimerDisplayPlay + dt
	if CurrentTimerDisplayPlay > TimerDisplayPlay + TimerNotDisplayPlay then
		CurrentTimerDisplayPlay = 0
	end
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

	for i,v in ipairs(TitleMenuTextures) do
		if v.startTime < CurrentTimer then
			if v.startTime~=1.5 or
				(math.sin(love.timer.getTime()*30)*math.sin(love.timer.getTime())*math.sin(love.timer.getTime()*0.3))<0.7 then
				love.graphics.draw(v.name, v.position.x, v.position.y)
			end
		end
	end
	if TitlePlayTexture.startTime < CurrentTimer and CurrentTimerDisplayPlay < TimerDisplayPlay then
		love.graphics.draw(TitlePlayTexture.name, TitlePlayTexture.position.x, TitlePlayTexture.position.y)
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
		love.event.push('quit')
	end
	if key=='return' or key==' ' then
		game = require("game")
		gstate.switch(game)
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
		game = require("game")
		gstate.switch(game)
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
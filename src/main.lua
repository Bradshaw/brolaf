require("useful")
require("Stack")

G = {
	TILE_SIZE = 32,
	MESSAGE_TO_DISPLAY ="",
	SHAKE = 0,
}

function love.load(arg)
	love.mouse.setVisible(false)

	local hr = love.graphics.getWidth()/640
	local vr = love.graphics.getHeight()/360
	G.SCALE = math.floor(math.min(hr,vr))

	font = love.graphics.newFont("Romulus.ttf", 16)
	love.graphics.setFont(font)

 	fudge = require("fudge")
 	sprites = fudge.new("Assets",{
 		npot = true,
 	})
 	fudge.set({
 		current = sprites,
 		monkey = true,
 	})
 	sprites.image:setFilter("nearest","nearest")

 	kludgedraw = love.graphics.draw

	love.graphics.draw = function(dr, x, y, ...)
		kludgedraw(dr, math.floor(x),math.floor(y),...)
	end


 	sprites:chopToAnimation("Swoosh_viking",6)
	sprites:chopToAnimation("Viking_move_down", 4)
	sprites:chopToAnimation("Viking_move_left", 4)
	sprites:chopToAnimation("Viking_move_right", 4)
	sprites:chopToAnimation("Viking_move_up", 4)
	
	sprites:chopToAnimation("draugr_move_down", 4)
	sprites:chopToAnimation("draugr_move_left", 4)
	sprites:chopToAnimation("draugr_move_right", 4)
	sprites:chopToAnimation("draugr_move_up", 4)
	
	sprites:chopToAnimation("Sangliours_move_down", 4)
	sprites:chopToAnimation("Sangliours_move_left", 4)
	sprites:chopToAnimation("Sangliours_move_right", 4)
	sprites:chopToAnimation("Sangliours_move_up", 4)

 	screenCanvas = love.graphics.newCanvas(640,360)
 	screenCanvas:setFilter("nearest","nearest")


 	local seed = nil or os.time()
	math.randomseed(seed)

	
	require("vec2")
	require("brolaf")
	require("enemy")
	require("item")
	require("room")
	require("tile")

	gstate = require "gamestate"
	game = require("game")
	gameover = require("gameover")
	menu = require("menu")
	gstate.registerEvents()
	gstate.switch(menu)
end

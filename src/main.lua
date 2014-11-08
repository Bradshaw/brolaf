require("useful")

G = {
	SCALE = __DEBUG__ and 1 or 2,
	TRUC = 5
}

function love.load(arg)
 	
 	fudge = require("fudge")
 	sprites = fudge.new("Assets",{
 		npot = true,
 	})
 	fudge.set({
 		current = sprites,
 		monkey = true,
 	})
 	sprites.image:setFilter("nearest","nearest")

 	screenCanvas = love.graphics.newCanvas(640,360)
 	screenCanvas:setFilter("nearest","nearest")


 	local seed = 10 or os.time()
	math.randomseed(seed)

	
	require("vec2")
	require("brolaf")
	require("enemy")
	require("room")
	require("tile")

	gstate = require "gamestate"
	game = require("game")
	gstate.registerEvents()
	gstate.switch(game)
end

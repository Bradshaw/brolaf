require("useful")
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


 	local seed = 10 or os.time()
	math.randomseed(seed)

	love.window.setMode( 1280, 720)
	
	require("brolaf")
	require("enemy")
	require("room")
	require("tile")

	gstate = require "gamestate"
	game = require("game")
	gstate.registerEvents()
	gstate.switch(game)
end

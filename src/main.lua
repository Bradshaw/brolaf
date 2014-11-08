require("useful")
function love.load(arg)
 	

 	local seed = 10 or os.time()
	math.randomseed(seed)

	love.window.setMode( 1280, 720)
	
	require("brolaf")
	require("enemy")
	require("Room")
	require("Tile")

	gstate = require "gamestate"
	game = require("game")
	gstate.registerEvents()
	gstate.switch(game)
end

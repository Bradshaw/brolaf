require("useful")
function love.load(arg)

	math.randomseed(os.time())

	require("brolaf")
	require("enemy")

	gstate = require "gamestate"
	game = require("game")
	gstate.registerEvents()
	gstate.switch(game)
end

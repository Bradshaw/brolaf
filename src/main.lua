require("useful")
function love.load(arg)
	gstate = require "gamestate"
	game = require("game")
	gstate.registerEvents()
	gstate.switch(game)
end
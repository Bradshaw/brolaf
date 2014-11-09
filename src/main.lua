require("useful")
require("Stack")

G = {
	SCALE = __DEBUG__ and 1 or 3,
	TILE_SIZE = 32,
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


 	local seed = nil or os.time()
	math.randomseed(seed)

	
	require("vec2")
	require("brolaf")
	require("enemy")
	require("item")
	require("room")
	require("tile")

	gstate = require "gamestate"
	menu = require("menu")
	gstate.registerEvents()
	gstate.switch(menu)
end

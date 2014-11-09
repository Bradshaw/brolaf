require("useful")
require("Stack")

G = {
	TILE_SIZE = 32,
}

function love.load(arg)

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

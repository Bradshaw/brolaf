require("useful")

Textures =
{
	WallDown 		= love.graphics.newImage("Assets/Wall_down1.png"),
	WallDownLeft 	= love.graphics.newImage("Assets/Wall_downleft.png"),
	WallDownRight 	= love.graphics.newImage("Assets/Wall_downright.png"),
	WallLeft 		= love.graphics.newImage("Assets/Wall_left1.png"),
	WallRight 		= love.graphics.newImage("Assets/Wall_right1.png"),
	WallUp 			= love.graphics.newImage("Assets/Wall_up1.png"),
	WallUpLeft 		= love.graphics.newImage("Assets/Wall_upleft.png"),
	WallUpRight 	= love.graphics.newImage("Assets/Wall_upright.png"),
	PlaceHolderFloor= love.graphics.newImage("Assets/PlaceHolderFloor.png"),
}

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

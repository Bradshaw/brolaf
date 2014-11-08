local tile_mt = {}
tile = {}
tile.all = {}

tile.Textures =
{
	WallUp 			= fudge.current:getPiece("Wall_up1"),
	WallDown 		= fudge.current:getPiece("Wall_down1"),
	WallLeft 		= fudge.current:getPiece("Wall_left1"),
	WallRight 		= fudge.current:getPiece("Wall_right1"),
	WallUpVar 			= fudge.current:getPiece("Wall_up3"),
	WallDownVar 		= fudge.current:getPiece("Wall_down3"),
	WallLeftVar 		= fudge.current:getPiece("Wall_left3"),
	WallRightVar 		= fudge.current:getPiece("Wall_right3"),
	WallDownLeft 	= fudge.current:getPiece("Wall_downleft"),
	WallDownRight 	= fudge.current:getPiece("Wall_downright"),
	WallUpLeft 		= fudge.current:getPiece("Wall_upleft"),
	WallUpRight 	= fudge.current:getPiece("Wall_upright"),
	Rock			= fudge.current:getPiece("Rock"),
	Ground1			= fudge.current:getPiece("Ground1"),
	Placeholder		= fudge.current:getPiece("PlaceHolderFloor"),
}

tile.GPInfos = {
	Wall = {
		Walkable = false,
	},	
	Floor = {
		Walkable = true,
	},
	Door = 
	{
		Walkable = false,
	},
}


function tile.new(options)
	local self = setmetatable({}, {__index=tile_mt}) 	

 	local options = options or {}

 	self.Position = {}

	self.Position.x = options.x or 0
	self.Position.y = options.y or 0
	
	self.Texture = options.Texture or "WallUp"
	self.Image = tile.Textures[self.Texture]

 	table.insert(tile.all, self)
	return self
end

function tile.update( dt )
	local i = 1
	while i<=#tile.all do
		local v = tile.all[i]
		if v.purge then
			table.remove(tile.all, i)
		else
			v:update(dt)
			i = i+1
		end

	end
end

function tile.draw(  )
	for i,v in ipairs(tile.all) do
		v:draw()
	end
end

function tile_mt:update( dt )

end

function tile_mt:draw()

	local posx = (self.Position.x  -1 ) * self.Image:getWidth()
	local posy = (self.Position.y - 1 ) * self.Image:getHeight()

	love.graphics.draw(self.Image, posx, posy)
end

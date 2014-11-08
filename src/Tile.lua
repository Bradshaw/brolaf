local tile_mt = {}
tile = {}
tile.all = {}

tile.Textures =
{
	WallDown 		= fudge.current:getPiece("Wall_down1"),
	WallDownLeft 	= fudge.current:getPiece("Wall_downleft"),
	WallDownRight 	= fudge.current:getPiece("Wall_downright"),
	WallLeft 		= fudge.current:getPiece("Wall_left1"),
	WallRight 		= fudge.current:getPiece("Wall_right1"),
	WallUp 			= fudge.current:getPiece("Wall_up1"),
	WallUpLeft 		= fudge.current:getPiece("Wall_upleft"),
	WallUpRight 	= fudge.current:getPiece("Wall_upright"),
	Ground1			= fudge.current:getPiece("Ground1"),
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

tile.Dimentions = {x = 32, y = 32} -- WARNING MAGIC VALUE DID 

function tile.new(options)
	local self = setmetatable({}, {__index=tile_mt}) 	

 	local options = options or {}

 	self.Position = {}

	self.Position.x = options.x or 0
	self.Position.y = options.y or 0
	
	self.Texture = options.Texture or "WallUp"
	self.Image = tile.Textures[self.Texture]

	tile.Dimentions = {
		x = self.Image:getWidth(), 
		y = self.Image:getHeight(), 
	}
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

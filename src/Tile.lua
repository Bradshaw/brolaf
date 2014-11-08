local Tile_mt = {}
Tile = {}
Tile.all = {}

function Tile.new(options)
	local self = setmetatable({}, {__index=Tile_mt}) 	

 	local options = options or {}

 	self.Position = {}

	self.Position.x = options.x or 0
	self.Position.y = options.y or 0
	
	self.Texture = options.Texture or "WallUp"
	self.Image = Textures[self.Texture]
	print(self.Texture)

 	table.insert(Tile.all, self)
	return self
end

function Tile.update( dt )
	local i = 1
	while i<=#Tile.all do
		local v = Tile.all[i]
		if v.purge then
			table.remove(Tile.all, i)
		else
			v:update(dt)
			i = i+1
		end

	end
end

TILE_SCALE = 2

function Tile.draw(  )
	for i,v in ipairs(Tile.all) do
		v:draw()
	end
end

function Tile_mt:update( dt )

end

function Tile_mt:draw()

	local posx = (self.Position.x  -1 ) * self.Image:getWidth() * TILE_SCALE
	local posy = (self.Position.y - 1 ) * self.Image:getHeight() * TILE_SCALE

	love.graphics.draw(self.Image, posx, posy,nil, TILE_SCALE, TILE_SCALE)
end

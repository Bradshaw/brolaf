local Tile_mt = {}
Tile = {}
Tile.all = {}

function Tile.new(options)
	local self = setmetatable({}, {__index=Tile_mt}) 	

 	local options = options or {}

 	self.Position = {}

	self.Position.x = options.x or 0
	self.Position.y = options.y or 0
	
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


TILE_WIDTH 		= 65
TILE_HEIGHT 	= 57
TILE_PAD		= 15

function Tile.draw(  )
	for i,v in ipairs(Tile.all) do
		v:draw()
	end
end

function Tile_mt:update( dt )

end

function Tile_mt:draw()
	local ofst = TILE_PAD / 2
	local posx = (self.Position.x  -1 ) * (TILE_WIDTH + TILE_PAD) + ofst
	local posy = (self.Position.y - 1 ) * (TILE_HEIGHT + TILE_PAD) + ofst
	local vertices = 
	{
		posx				, posy, 
		posx + TILE_WIDTH	, posy,
		posx + TILE_WIDTH	, posy + TILE_HEIGHT,
		posx				, posy + TILE_HEIGHT,
	}

	-- passing the table to the function as a second argument
	love.graphics.polygon('fill', vertices)
end

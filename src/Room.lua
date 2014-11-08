local Room_mt = {}
Room = {}
Room.all = {}

RoomWidth = 16
RoomHeight = 10

function Room.new(options)
	local self = setmetatable({}, {__index=Room_mt})

	local options = options or {}

	self.WorldPosition = options.WorldPosition or {x = 0, y = 0}

	self.Tiles = {}
	self.Enemies = {}
	self.Items = {}
	
	self:CreatTiles()

	table.insert(Room.all, self)
	return self
end

function Room.update( dt )
	local i = 1
	while i<=#Room.all do
		local v = Room.all[i]
		if v.purge then
			table.remove(Room.all, i)
		else
			v:update(dt)
			i = i+1
		end

	end
end

function Room.draw(  )
	for i,v in ipairs(Room.all) do
		v:draw()
	end
end

function Room_mt:update( dt )

end

function Room_mt:draw()
	for _,tile in ipairs(self.Tiles) do
		tile:draw()
	end
end

function Room_mt:CreatTiles()
	
	local px = 1
	local py = 1
	local tx = "WallUpLeft"
	local tile = Tile.new({x = px,y = py,Texture = tx})
	table.insert(self.Tiles,tile)
	for i = 2, (RoomWidth - 1) do
		px = i
		tx = "WallUp"
		tile = Tile.new({x = px,y = py,Texture = tx})
		table.insert(self.Tiles,tile)
	end
	px = RoomWidth
	local tx = "WallUpRight"
	tile = Tile.new({x = px,y = py,Texture = tx})
	table.insert(self.Tiles, tile)
	
	for j = 2,RoomHeight - 1 do 
		tx = "WallLeft"
		tile = Tile.new({x = 1, y = j, Texture = tx})
		table.insert(self.Tiles,tile)
		for i = 2,RoomWidth do
			tx = "PlaceHolderFloor"
			tile = Tile.new({x = i, y = j, Texture = tx})
			table.insert(self.Tiles,tile)
		end
		tx = "WallRight"
		tile = Tile.new({x = RoomWidth, y = j, Texture = tx})
		table.insert(self.Tiles,tile)
	end

	py = RoomHeight
	tx = "WallDownLeft"
	tile = Tile.new({x = 1,y = py,Texture = tx})
	table.insert(self.Tiles,tile)
	for i = 2, (RoomWidth - 1) do
		px = i
		tx = "WallDown"
		tile = Tile.new({x = px,y = py,Texture = tx})
		table.insert(self.Tiles,tile)
	end
	px = RoomWidth
	local tx = "WallDownRight"
	tile = Tile.new({x = px,y = py,Texture = tx})
	table.insert(self.Tiles, tile)
end 

function Room_mt:GetTilesInfos(px,py)
	local index = py + px * RoomWidth
	return self.Tiles[index] , self.Enemies[Index], self.Items[index]
end

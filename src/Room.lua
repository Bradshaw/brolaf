local room_mt = {}
room = {}
room.all = {}

roomWidth = 16
roomHeight = 10

function room.new(options)
	local self = setmetatable({}, {__index=room_mt})

	local options = options or {}

	self.WorldPosition = options.WorldPosition or {x = 0, y = 0}

	self.Tiles = {}
	self.Enemies = {}
	self.Items = {}
	
	self:CreatTiles()

	table.insert(room.all, self)
	return self
end

function room.update( dt )
	local i = 1
	while i<=#room.all do
		local v = room.all[i]
		if v.purge then
			table.remove(room.all, i)
		else
			v:update(dt)
			i = i+1
		end

	end
end

function room.draw(  )
	for i,v in ipairs(room.all) do
		v:draw()
	end
end

function room_mt:update( dt )

end

function room_mt:draw()
	for _,tile in ipairs(self.Tiles) do
		tile:draw()
	end
end

function room_mt:CreatTiles()
	
	local px = 1
	local py = 1
	local tx = "WallUpLeft"
	local t = tile.new({x = px,y = py,Texture = tx})
	table.insert(self.Tiles,tile)
	for i = 2, (roomWidth - 1) do
		px = i
		tx = "WallUp"
		t = tile.new({x = px,y = py,Texture = tx})
		table.insert(self.Tiles,t)
	end
	px = roomWidth
	local tx = "WallUpRight"
	t = tile.new({x = px,y = py,Texture = tx})
	table.insert(self.Tiles, t)
	
	for j = 2,roomHeight - 1 do 
		tx = "WallLeft"
		t = tile.new({x = 1, y = j, Texture = tx})
		table.insert(self.Tiles,t)
		for i = 2,roomWidth do
			tx = "PlaceHolderFloor"
			t = tile.new({x = i, y = j, Texture = tx})
			table.insert(self.Tiles,t)
		end
		tx = "WallRight"
		t = tile.new({x = roomWidth, y = j, Texture = tx})
		table.insert(self.Tiles,t)
	end

	py = roomHeight
	tx = "WallDownLeft"
	t = tile.new({x = 1,y = py,Texture = tx})
	table.insert(self.Tiles,t)
	for i = 2, (roomWidth - 1) do
		px = i
		tx = "WallDown"
		t = tile.new({x = px,y = py,Texture = tx})
		table.insert(self.Tiles,t)
	end
	px = roomWidth
	local tx = "WallDownRight"
	t = tile.new({x = px,y = py,Texture = tx})
	table.insert(self.Tiles, t)
end 

function room_mt:GetTilesInfos(px,py)
	local index = py + px * roomWidth
	return self.Tiles[index] , self.Enemies[Index], self.Items[index]
end

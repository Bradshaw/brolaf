local Room_mt = {}
Room = {}
Room.all = {}

RoomWidth = 16
RoomHeight = 10

function Room.new()
	local self = setmetatable({}, {__index=Room_mt})

	self.Tiles = {}
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
	for _,tile in pairs(self.Tiles) do
		tile:draw()
	end
end

function Room_mt:CreatTiles()
	for i =1,RoomWidth do
		for j =1,RoomHeight do
			local tile = Tile.new({x = i, y = j})
			table.insert(self.Tiles, tile)
		end
	end
end 

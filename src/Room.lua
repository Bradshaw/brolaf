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

	self.LogicTiles = {}
	
	self:CreatTiles()
	self:InstanciateTiles()

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
	
	for j = 1, roomHeight do
		for i = 1, roomWidth do
			local tt = "Floor"
			if (j == 1) or (i == 1) or (j == roomHeight) or (i == roomWidth) then
				tt ="Wall"
			end
			table.insert(self.LogicTiles,{
					x = i,
					y = j,
					tileType = tt, 
				})
		end
	end
end 

function room_mt:InstanciateTiles()
	for _,tileInfos in ipairs(self.LogicTiles) do
		tileInfos.Texture = "Ground1"
		if tileInfos.tileType == "Wall" then
			tileInfos.Texture = self:GetWallText(tileInfos.x,tileInfos.y)
		end
		table.insert(self.Tiles, tile.new(tileInfos))
	end
end

function room_mt:GetWallText(x,y)
	local wUp = false
	local wLeft = false
	local wRight = false
	local wDown = false
	if self:GetTilesInfos(x,y - 1).tileType == "Wall" then
		wUp = true
	end
	if self:GetTilesInfos(x - 1,y).tileType == "Wall" then
		wLeft = true
	end
	if self:GetTilesInfos(x + 1,y).tileType == "Wall" then
		wRight = true
	end
	if self:GetTilesInfos(x,y + 1).tileType == "Wall" then
		wDown = true
	end
	
	local texture = "WallUp"
	if wDown and wRight then
		texture = "WallUpLeft"
	elseif wDown and wLeft then
		texture = "WallUpRight"
	elseif wUp and wRight then
		texture = "WallDownLeft"
	elseif wUp and wLeft then
		texture = "WallDownRight"
	elseif wDown then
		texture = "WallUp"
	elseif wUp then
		texture = "WallDown"
	elseif wLeft then
		texture = "WallRight"
	elseif wRight then
		texture = "WallLeft"
	end
	return texture

end


function room_mt:GetTilesInfos(px,py)
	local index = px + py * roomWidth
	return self.LogicTiles[index] or {}
end

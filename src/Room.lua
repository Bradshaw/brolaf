local room_mt = {}
room = {}
room.all = {}

roomWidth = 16
roomHeight = 10

lRandom = love.math.random

function room.new(options)
	local self = setmetatable({}, {__index=room_mt})

	local options = options or {}

	self.WorldPosition = options.WorldPosition or {x = 0, y = 0}
	local roomSeed = self.WorldPosition.x + 2500 * self.WorldPosition.y + 28460
	roomSeed = (roomSeed~=0) and roomSeed or 1
	print("room seed " .. roomSeed)
	love.math.setRandomSeed(roomSeed)


	self.Tiles = {}
	self.Enemies = {}
	self.Items = {}

	self.LogicTiles = {}
	
	self:CreatTiles() -- init room
-- room generation and stuff
	while not isRoomValid do
		self:PlaceWalls(7)

		isRoomValid = self:CheckRoomIntegrity()
	end


	
	self:InstanciateTiles() -- instanciate tiles

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

function room_mt:PlaceWalls(nb)
	for i = 1,nb do
		self:PlaceRandomWall()
	end
end

function room_mt:PlaceRandomWall()
	local wp = {
		{x = -1, y =  0},
		{x =  1, y =  0},
		{x =  0, y = -1},
		{x =  0, y =  1},
	}

	rx = math.ceil(lRandom(roomWidth - 1)) 
	ry = math.ceil(lRandom(roomHeight - 1)) 
	local ti = self:GetTilesInfos(rx,ry)
	print(ti.tileType)
	if ti and (ti ~= {}) and (ti.tileType ~= "Wall") then
		ti.tileType = "Wall"
		self:SetTileInfos(ti)
	end
	local d = wp[math.ceil(lRandom(#wp))]

	local dx = rx + d.x
	local dy = ry + d.y
	ti = self:GetTilesInfos(dx,dy)
	if ti and (ti ~= {}) and (ti.tileType ~= "Wall") then
		ti.tileType = "Wall"
		self:SetTileInfos(ti)
	end

	d = wp[math.ceil(lRandom(#wp))]
	dx = rx + d.x
	dy = ry + d.y
	ti = self:GetTilesInfos(dx,dy)
	if ti and (ti ~= {}) and (ti.tileType ~= "Wall") then
		ti.tileType = "Wall"
		self:SetTileInfos(ti)
	end
end

function room_mt:SetTileInfos(infos)
	local index = (infos.x) + (infos.y-1) * roomWidth
	self.LogicTiles[index] = infos
end

function room_mt:GetTilesInfos(px,py)
	local index = (px) + (py-1) * roomWidth
	return self.LogicTiles[index] or {x = px, y = py, "Wall" }
end

function room_mt:IsTileWalkable(px,py)
	local ti = self:GetTilesInfos(px,py)
	return tile.GPInfos[ti.tileType].Walkable
end

function room_mt:IsPathBlocked(px,py)
	return not self:IsTileWalkable(px,py)
end

function room_mt:IsPathWalkablePixel(px,py)
	local x,y = self:getIntegerCoordinate(px,py)
	return self:IsTileWalkable(x,y)
end

function room_mt:IsPathBlockedPixel(px,py)
	local x,y = self:getIntegerCoordinate(px,py)
	return self:IsPathBlocked(x,y)
end

function room_mt:CheckRoomIntegrity()
	for j = 1, roomHeight do
		for i = 1, roomWidth do
			print(tostring(self:IsPathBlockedPixel(i*32,j *32)))
		end
	end

	return true
end

function room_mt:getIntegerCoordinate(pixelX,pixelY)
	local x = math.ceil(pixelX / tile.Dimentions.x)
	local y = math.ceil(pixelY / tile.Dimentions.y)
	return x ,y
end

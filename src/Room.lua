local room_mt = {}
room = {}
room.cur = nil

roomWidth = 16
roomHeight = 10

nbEnemy = 4

lRandom = love.math.random

function room.resetVars()
	enemy.all = {}
	tile.all = {}
end

function room.new(options)
	local self = setmetatable({}, {__index=room_mt})

	local options = options or {}

	-- Reset list of items and enemies
	if not options.noReplace then
		enemy.all = {}
		item.all = {}
		tile.all = {}
	end

	self.WorldPosition = options.WorldPosition or {x = 0, y = 0}
	local roomSeed = self.WorldPosition.x + 2500 * self.WorldPosition.y + 2848
	roomSeed = (roomSeed~=0) and roomSeed or 1
	print("room seed " .. roomSeed)
	love.math.setRandomSeed(roomSeed)

	local isRoomValid = false
	while not isRoomValid do
		room.resetVars()

		self.Tiles = {}

		self.LogicTiles = {}

		
		self:CreatTiles() -- init room
		-- room generation and stuff
		
		self:PlaceWalls(7)

		self.Doors = {}
		self:PlaceFourDoors()

		isRoomValid = self:CheckRoomIntegrity()
	end
	
	self:InstanciateTiles() -- instanciate tiles

	if not options.noReplace then
		room.cur = self
	end
	return self
end

function room.update( dt )
	if room.cur then
		room.cur:update(dt)
	end
end

function room.draw(  )
	if room.cur then
		room.cur:draw(dt)
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
		if tileInfos.tileType == "Door" then
			tileInfos.Texture ="Placeholder"
		elseif tileInfos.x==1 or tileInfos.x==16 or tileInfos.y==1 or tileInfos.y==10 then
			local conString = "Wall"
			local edges = 0
			if tileInfos.y==1 then
				edges = edges+1
				conString = conString.."Up"
			elseif tileInfos.y==10 then
				edges = edges+1
				conString = conString.."Down"
			end
			if tileInfos.x==1 then
				edges = edges+1
				conString = conString.."Left"
			elseif tileInfos.x==16 then
				edges = edges+1
				conString = conString.."Right"
			end
			if edges == 1 and lRandom()>0.6 then
				conString = conString.."Var"
			end
			tileInfos.Texture = conString
		elseif tileInfos.tileType == "Wall" then
			tileInfos.Texture = "Rock"
		else
			tileInfos.Texture = "Ground1"
		end
		table.insert(self.Tiles, tile.new(tileInfos))
	end
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

	rx = math.ceil(lRandom(roomWidth - 2))
	ry = math.ceil(lRandom(roomHeight - 2))
	local ti = self:GetTilesInfos(rx,ry)

	if ti.tileType ~= "Wall" then
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

function displayTi(ti)
	print("("..ti.x..","..ti.y..") " ..ti.tileType)
end

function room_mt:PlaceFourDoors()
	self.Doors = {}
	local rx = math.ceil(lRandom(roomWidth - 2))
	local door = {x = rx, y = 1, tileType = "Door"}
	self:SetTileInfos(door)
	table.insert(self.Doors,door)
	displayTi(door)

	rx = math.ceil(lRandom(roomWidth - 2))
	door = {x = rx, y = roomHeight, tileType = "Door"}
	self:SetTileInfos(door)
	table.insert(self.Doors,door)
	displayTi(door)

	local ry = math.ceil(lRandom(roomHeight - 2))
	door = {x = 1, y = ry, tileType = "Door"}
	self:SetTileInfos(door)
	table.insert(self.Doors,door)
	displayTi(door)
	
	ry = math.ceil(lRandom(roomHeight - 2))
	door = {x = roomWidth, y = ry, tileType = "Door"}
	self:SetTileInfos(door)
	table.insert(self.Doors,door)
	displayTi(door)
end

function room_mt:SetTileInfos(infos)
	local index = (infos.x) + (infos.y-1) * roomWidth
	self.LogicTiles[index] = infos
end

function room_mt:GetTilesInfos(px,py)
	local index = px + (py-1) * roomWidth

	local ret = self.LogicTiles[index] 
	if not ret then 
		print("outofbound ", px , "," , py)
	end
	return ret or {x = px, y = py,tileType = "Wall" }
end

function room_mt:IsTileWalkable(px,py)
	local ti = self:GetTilesInfos(px,py)
	return tile.GPInfos[ti.tileType].Walkable
end

function room_mt:IsPathBlocked(px,py)
	return not self:IsTileWalkable(px,py)
end

function room_mt:IsPathWalkablePixel(position)
	local x,y = self:getIntegerCoordinate(position.x, position.y)
	return self:IsTileWalkable(x,y)
end

function room_mt:IsPathBlockedPixel(position)
	local x,y = self:getIntegerCoordinate(position.x, position.y)
	return self:IsPathBlocked(x,y)
end

function room_mt:isVisibleFrom(fromX, fromY, toX, toY)
	return useful.bline(fromX,fromY,toX,toY,function(x,y)
		return self:IsPathBlocked(x,y)
	end)
end

function room_mt:isVisibleFromPixel(positionFrom, positionCheck)
	local xFrom, yFrom = self:getIntegerCoordinate(positionFrom.x, positionFrom.y)
	local xTo, yTo = self:getIntegerCoordinate(positionCheck.x, positionCheck.y)
	return self:isVisibleFrom(xFrom, yFrom, xTo, yTo)
end


function room_mt:CheckRoomIntegrity()

	local floodList = self:FloodRoom()
	for _,door in pairs(self.Doors)do
		if not table.find(floodList,door) then
			return false
		end
	end

	for i= 1 , nbEnemy do
		local ep = self:getTileFromSelection(floodList)
		self:CreateEnemyAtPosition(ep)
		table.remove(floodList,table.find(floodList,ep))
	end

	if lRandom(2) > 1 then
		local ip = self:getTileFromSelection(floodList)
		self:CreateItemAtPosition(ip)
		table.remove(floodList,table.find(floodList,ip))
	end

	return true
end

room.AbortThreshold = 1000

function room_mt:FloodRoom()
	local loopAcc = 0
	floodedTiles = {}
	floodingTiles = Stack:Create()
	local start = self.Doors[1]
	floodingTiles:push(start)
	print("start Flood (",start.x,",",start.y,")")
	while floodingTiles:getn() > 0  and loopAcc < room.AbortThreshold do
		loopAcc = loopAcc + 1
		print(loopAcc)
		local current = floodingTiles:pop(1)
		table.insert(floodedTiles,current)

		local ti
		ti = self:GetTilesInfos(current.x + 1,current.y)
		if (ti.tileType ~= "Wall") and not table.find(floodedTiles,ti) then
			if not floodingTiles:find(ti) then
				floodingTiles:push(ti)
			end
		end
		ti = self:GetTilesInfos(current.x - 1,current.y)
		if (ti.tileType ~= "Wall") and not table.find(floodedTiles,ti) then
			if not floodingTiles:find(ti) then
				floodingTiles:push(ti)
			end
		end
		ti = self:GetTilesInfos(current.x    ,current.y + 1)
		if (ti.tileType ~= "Wall") and not table.find(floodedTiles,ti) then
			if not floodingTiles:find(ti) then
				floodingTiles:push(ti)
			end
		end
		ti = self:GetTilesInfos(current.x    ,current.y - 1)
		if (ti.tileType ~= "Wall") and not table.find(floodedTiles,ti) then
			if not floodingTiles:find(ti) then
				floodingTiles:push(ti)
			end
		end
	end
	print("endflood with " , #floodedTiles , " tile")
	return floodedTiles
end

function room_mt:getIntegerCoordinate(pixelX,pixelY)
	local x = math.ceil(pixelX / G.TILE_SIZE)
	local y = math.ceil(pixelY / G.TILE_SIZE)
	return x ,y
end

function room_mt:getPixelPositions(px,py)
	local x = px * G.TILE_SIZE - G.TILE_SIZE/2
	local y = py * G.TILE_SIZE - G.TILE_SIZE/2
	return x, y
end

function room_mt:getRandomPositionInRoom()
	local rx = math.ceil(lRandom(roomWidth - 2)) 
	local ry = math.ceil(lRandom(roomHeight - 2))
	return rx,ry
end

function room_mt:getTileFromSelection(selection)
	local found = false
	local ri
	while not found do
		ri = math.ceil(lRandom(#selection))
		found = selection[ri].tileType ~= "Door"
	end
	return selection[ri]
end

function room_mt:addRandomEnemies(nb)
	for i = 1,nb do
		self:addEnemyAtRandomPosition()
	end
end

function room_mt:CreateEnemyAtPosition(infos)
	
	local x,y = self:getPixelPositions(infos.x,infos.y)

	local enemyType = enemyTypes[math.ceil(lRandom(#enemyTypes))]

	enemy.new({
		position = vec2.new(x,y),
		typeEnemy = enemyType
	})
end

function room_mt:CreateItemAtPosition(infos)
	local x,y = self:getPixelPositions(infos.x,infos.y)

	local itemType = itemTypes[math.ceil(lRandom(#itemTypes))]

	item.new({
		position = vec2.new(x,y),
		typeitem = itemType
	})
end

local room_mt = {}
room = {}
room.cur = nil

roomWidth = 16
roomHeight = 10

nbEnemy = 4

positionCoordinateUI = { x = 544, y = 16 }

lRandom = love.math.random

local direction = {
	left  = { x =  1, y =  0 },
	right = { x = -1, y =  0 },
	down  = { x =  0, y = -1 },
	up    = { x =  0, y =  1 },
	zero  = { x =  0, y =  0 }
}
local directionPosition = {
	left  = { index = 4, nextDoor = "right" },
	right = { index = 3, nextDoor = "left"  },
	down  = { index = 1, nextDoor = "up"    },
	up    = { index = 2, nextDoor = "down"  },
	zero  = { index = 1, nextDoor = "up"    }
}

function room_mt:resetVars()
	enemy.all = {}
	tile.all = {}
	item.all = {}
	self.Doors = {}
	self.Tiles = {}
	self.LogicTiles = {}
end

function room.new(options)
	local self = setmetatable({}, {__index=room_mt})

	local options = options or {}

	directionTemp = direction[options.DirectionDoor or "zero"]
	self.WorldPosition = (options.PreviousPosition or vec2.new(0, 0)):add(directionTemp)
	local roomSeed = self.WorldPosition.x + 2500 * self.WorldPosition.y + 2848
	roomSeed = (roomSeed~=0) and roomSeed or 1
	print("room seed " .. roomSeed)
	love.math.setRandomSeed(roomSeed)

	local isRoomValid = false
	while not isRoomValid do
		self:resetVars()

		self:CreatTiles() -- init room
		-- room generation and stuff
		
		self:PlaceWalls(7)

		self:PlaceFourDoors()

		isRoomValid = self:CheckRoomIntegrity()
	end
	
	self:InstanciateTiles() -- instanciate tiles

	if options.Player then
		directionPositionTemp = directionPosition[options.DirectionDoor or "zero"]
		directionPlayerTemp = direction[directionPositionTemp.nextDoor]
		door = self.Doors[directionPositionTemp.index]
		px, py = self:getPixelPositions(door.x + directionPlayerTemp.x, door.y + directionPlayerTemp.y)
		print ("new position door.x ", door.x, " door.y ", door.y)
		print ("new position directionTemp.x ", directionTemp.x, " directionTemp.y ", directionTemp.y)
		print ("new position x ", px, " y ", py)
		options.Player.position = vec2.new(px, py)
	end
	if not options.noReplace then
		room.cur = self
	end
	gameLastEnterRoom = love.timer.getTime()
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
	love.graphics.print("X "..self.WorldPosition.x.." Y "..self.WorldPosition.y, positionCoordinateUI.x, positionCoordinateUI.y)
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

	rx = math.ceil(lRandom(roomWidth - 2)) + 1
	ry = math.ceil(lRandom(roomHeight - 2)) + 1
	local ti = self:GetTilesInfos(rx,ry)

	if ti and (ti ~= {}) and ti.tileType ~= "Wall" then
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
	local rx = math.ceil(lRandom(roomWidth - 2)) + 1
	local door = {x = rx, y = 1, tileType = "Door"}
	self:SetTileInfos(door)
	table.insert(self.Doors,door)
	displayTi(door)
	self:SetTileInfos({x = rx, y = 2, tileType = "Floor"})

	rx = math.ceil(lRandom(roomWidth - 2)) + 1
	door = {x = rx, y = roomHeight, tileType = "Door"}
	self:SetTileInfos(door)
	table.insert(self.Doors,door)
	displayTi(door)
	self:SetTileInfos({x = rx, y = roomHeight - 1, tileType = "Floor"})

	local ry = math.ceil(lRandom(roomHeight - 2)) + 1
	door = {x = 1, y = ry, tileType = "Door"}
	self:SetTileInfos(door)
	table.insert(self.Doors,door)
	displayTi(door)
	self:SetTileInfos({x = 2, y = ry , tileType = "Floor"})
	
	ry = math.ceil(lRandom(roomHeight - 2)) + 1
	door = {x = roomWidth, y = ry, tileType = "Door"}
	self:SetTileInfos(door)
	table.insert(self.Doors,door)
	displayTi(door)
	self:SetTileInfos({x = roomWidth - 1, y = ry , tileType = "Floor"})
end

function room_mt:SetTileInfos(infos)
	local index = (infos.x) + (infos.y-1) * roomWidth
	self.LogicTiles[index] = infos
end

function room_mt:GetTilesInfos(px,py)
	local index = px + (py-1) * roomWidth

	local ret = self.LogicTiles[index] 
	if not ret then 
		--print("outofbound ", px , "," , py)
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

function room_mt:IsTileDoor(posX,posY)
	return (self:GetTilesInfos(posX,posY).tileType == "Door")
end

function room_mt:IsTileDoorPixel(position)
	local x,y = self:getIntegerCoordinate(position.x, position.y)
	return self:IsTileDoor(x,y)
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
		local ep = self:getTileFromSelection(floodList , 2)
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
	while floodingTiles:getn() > 0  and loopAcc < room.AbortThreshold do
		loopAcc = loopAcc + 1
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
	local rx = math.ceil(lRandom(roomWidth - 2))  + 1
	local ry = math.ceil(lRandom(roomHeight - 2)) + 1
	return rx,ry
end

function room_mt:getTileFromSelection(selection,margin)
	local found = false
	local margin = margin or 0
	local ri

	while not found do
		ri = math.ceil(lRandom(#selection))
		found = selection[ri].tileType ~= "Door"
		found = found and selection[ri].x > margin and selection[ri].y > margin
		found = found and selection[ri].x < (roomWidth - margin) and selection[ri].y < (roomHeight -margin)
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

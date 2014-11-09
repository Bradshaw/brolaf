local enemy_mt = {}
enemy = {}
enemy.all = {}

enemyTypes = {"skeleton", "boar"}
local enemiesDescriptor = {
	skeleton = {
		idle = "draugr_idle_",
		move = "draugr_move_",
		hp = 2,
		speed = 50,
		damage = 1,
		rangeDamage = 30,
		rateDamage = 0.4,
		timeBeforeHit = 20
	},
	boar = {
		idle = "Sangliours_idle_",
		move = "Sangliours_move_",
		hp = 4,
		speed = 200,
		damage = 2,
		rangeDamage = 30,
		rateDamage = 0.4,
		timeBeforeCharge = 0.75
	}
}

function enemy.new(options)
	local self = setmetatable({}, {__index=enemy_mt})
	local options = options or {}

	self.currentDrawDirection = ({"left","right","up","down"})[math.random(1,4)]

	self.position = options.position or vec2.new(250, 250)
	self.typeEnemy = enemiesDescriptor[options.typeEnemy or "skeleton"]
	self.currentTimerHit = 0
	self.hp = self.typeEnemy.hp
	self.isMoving = false

	if self.typeEnemy.timeBeforeCharge then
		self.currentTimerBeforeCharge = love.math.random() * self.typeEnemy.timeBeforeCharge;
		self.directionCharge = vec2.new(0, 0)
	end

	table.insert(enemy.all, self)
	return self
end

function enemy.update( dt )
	local i = 1
	while i<=#enemy.all do
		local v = enemy.all[i]
		if v.purge then
			table.remove(enemy.all, i)
		else
			v:update(dt)
			i = i+1
		end
	end
end

function enemy.findClosest( posPlayer, sizeVisible, directionVisible )
	local i = 1
	local closest = -1
	local indexClosest = 0
	while i<=#enemy.all do
		local v = enemy.all[i]
		lengthTemp = v.position:sub(posPlayer):length()
		if (closest < 0 or closest > lengthTemp) and
		   useful.isClosest(v.position, posPlayer, sizeVisible) and directionVisible:sameSign(posPlayer:sub(v.position)) then
				closest = lengthTemp
				indexClosest = i
		end
		i = i+1
	end
	if indexClosest == 0 then
		return nil
	end
	return enemy.all[indexClosest]
end

function enemy.draw(  )
	for i,v in ipairs(enemy.all) do
		v:draw()
	end
end

function enemy_mt:update( dt )
	self.isMoving = false
	if self.typeEnemy.timeBeforeCharge then
		self.currentTimerHit = self.currentTimerHit + dt
		if self.currentTimerBeforeCharge < self.typeEnemy.timeBeforeCharge then
			self.charging = false
			self.currentTimerBeforeCharge = self.currentTimerBeforeCharge + dt
			if self.currentTimerBeforeCharge >= self.typeEnemy.timeBeforeCharge then
				self.directionCharge = brolaf:position():sub(self.position):normalized()
			end
		else
			self.charging = true
			newPosition = self.position:add(self.directionCharge:mul(self.typeEnemy.speed * dt))
			local directionMovement = self.directionCharge
			if directionMovement.x<-0.5 then
				self.currentDrawDirection="left"
			elseif directionMovement.x>0.5 then
				self.currentDrawDirection="right"
			elseif directionMovement.y<-0.5 then
				self.currentDrawDirection="up"
			elseif directionMovement.y>0.5 then
				self.currentDrawDirection="down"
			end
			if room and room.cur:IsPathWalkablePixel(newPosition) and not self:hit(dt) then
				self.position = newPosition
				self.isMoving = true
			else
				self.currentTimerBeforeCharge = 0
			end
		end
	else
		if not self:hit(dt) then
			if room.cur:isVisibleFromPixel(self.position, brolaf:position()) then
				directionMovement = brolaf:position():sub(self.position):normalized()
				newPosition = self.position:add(directionMovement:mul(self.typeEnemy.speed * dt))
				if room and room.cur:IsPathWalkablePixel(newPosition) then
					self.position = newPosition
					self.isMoving = true
				end

				if directionMovement.x<-0.5 then
					self.currentDrawDirection="left"
				elseif directionMovement.x>0.5 then
					self.currentDrawDirection="right"
				elseif directionMovement.y<-0.5 then
					self.currentDrawDirection="up"
				elseif directionMovement.y>0.5 then
					self.currentDrawDirection="down"
				end
			end
		end
	end
end

function enemy_mt:hit( dt )
	if useful.isClosest(self.position, brolaf:position(), self.typeEnemy.rangeDamage) then
		self.currentTimerHit = self.currentTimerHit + dt
		if self.currentTimerHit >= self.typeEnemy.rateDamage then
			brolaf.takeDamage(self.typeEnemy.damage)
			self.currentTimerHit = 0
		end
		return true
	end
	return false
end

function enemy_mt:draw()
	local drawWord = ({
		left = "left",
		right = "right",
		up = "back",
		down = "front"
	})[self.currentDrawDirection];
	local vib = 0
	if not self.charging and self.currentTimerBeforeCharge then
		vib = (self.currentTimerBeforeCharge / self.typeEnemy.timeBeforeCharge)*3
	end

	if not self.currentTimerBeforeCharge then
		if self.currentTimerHit >= self.typeEnemy.rateDamage /2 then
			love.graphics.print("AGROUGROU",self.position.x-font:getWidth("AGROUGROU")/2,self.position.y-42)
		end
	end

	if not self.isMoving then
		love.graphics.draw(self.typeEnemy.idle..drawWord, self.position.x+math.sin(love.timer.getTime()*320)*vib, self.position.y+math.sin(love.timer.getTime()*150)*vib,0,1,1,16,32)
	else
		love.graphics.draw("ani_"..self.typeEnemy.move..self.currentDrawDirection, self.position.x+math.sin(love.timer.getTime()*320)*vib, self.position.y+math.sin(love.timer.getTime()*150)*vib,0,1,1,16,32)
	end
	if self.charging then
		love.graphics.print("GRUIIIIK",self.position.x-font:getWidth("GRUIIIIK")/2,self.position.y-42)
	end
end

function enemy_mt:takeDamage( damage )
	self.hp = self.hp - damage
	if self.hp <= 0 then
		self.hp = 0
		self.purge = true
		return true
	end
	return false
end

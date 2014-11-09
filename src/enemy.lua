local enemy_mt = {}
enemy = {}
enemy.all = {}

enemyTypes = {"skeleton", "boar"}
local enemiesDescriptor = {
	skeleton = {
		hp = 2,
		speed = 50,
		damage = 1,
		rangeDamage = 30,
		rateDamage = 0.4,
		timeBeforeHit = 20
	},
	boar = {
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
	self.typeEnemyName = options.typeEnemy or "skeleton"
	self.currentTimerHit = 0
	self.hp = self.typeEnemy.hp

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
	if self.typeEnemy.timeBeforeCharge then
		if self.currentTimerBeforeCharge < self.typeEnemy.timeBeforeCharge then
			self.currentTimerBeforeCharge = self.currentTimerBeforeCharge + dt
			if self.currentTimerBeforeCharge >= self.typeEnemy.timeBeforeCharge then
				self.directionCharge = brolaf:position():sub(self.position):normalized()
			end
		else
			newPosition = self.position:add(self.directionCharge:mul(self.typeEnemy.speed * dt))
			if room and room.cur:IsPathWalkablePixel(newPosition) then
				self.position = newPosition
				self:hit(dt)
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
				end

				if directionMovement.x<-0.1 then
					self.currentDrawDirection="left"
				elseif directionMovement.x>0.1 then
					self.currentDrawDirection="right"
				elseif directionMovement.y<-0.1 then
					self.currentDrawDirection="up"
				elseif directionMovement.y>0.1 then
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
	local drawWord = (self.typeEnemyName=="skeleton" and "draugr_idle_" or "Sangliours_idle_")..({
		left = "left",
		right = "right",
		up = "back",
		down = "front"
	})[self.currentDrawDirection];

	love.graphics.draw(drawWord,self.position.x, self.position.y,0,1,1,16,32)

	--r, g, b, a = love.graphics.getColor()
	--love.graphics.setColor(0, 0, 255, 255)
	--love.graphics.circle("fill", self.position.x, self.position.y, 4)
	--love.graphics.setColor(r, g, b, a)
end

function enemy_mt:takeDamage( damage )
	self.hp = self.hp - damage
	if self.hp <= 0 then
		self.hp = 0
		self.purge = true
	end
end

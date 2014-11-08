local enemy_mt = {}
enemy = {}
enemy.all = {}

enemyTypes = {"skeleton","boar"}
local enemiesDescriptor = {
	skeleton = {
		speed = 180,
		damage = 1,
		rangeDamage = 10,
		rateDamage = 0.5,
		timeBeforeHit = 20
	},
	boar = {
		speed = 700,
		damage = 2,
		rangeDamage = 10,
		rateDamage = 0.5,
		timeBeforeCharge = 2
	}
}

function enemy.new(options)
	local self = setmetatable({}, {__index=enemy_mt})
	local options = options or {}

	self.position = options.position or vec2.new(500, 500)
	self.typeEnemy = enemiesDescriptor[options.typeEnemy or "skeleton"]
	self.currentTimerHit = 0

	if self.typeEnemy.timeBeforeCharge then
		self.currentTimerBeforeCharge = 0
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
			--if map.cur and map.isPossible(newPosition) then
				self.position = newPosition
				self:hit(dt)
			--else
			--self.currentTimerBeforeCharge = 0
			--end
		end
	else
		if not self:hit(dt) then
			--directionMovement = map.nextPosition(self.position, brolaf.position())
			directionMovement = brolaf:position():sub(self.position):normalized()
			newPosition = self.position:add(directionMovement:mul(self.typeEnemy.speed * dt))
			--if map.cur and map.isPossible(newPosition) then
				self.position = newPosition
			--end
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
	r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0, 0, 255, 255)
	love.graphics.circle("fill", self.position.x, self.position.y, 4)
	love.graphics.setColor(r, g, b, a)
end


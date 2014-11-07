local enemy_mt = {}
enemy = {}
enemy.all = {}

function enemy.new(options)
	local self = setmetatable({}, {__index=enemy_mt})
	local options = options or {}

	self.x = options.x or 10
	self.y = options.y or 10

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

end

function enemy_mt:draw()
	love.graphics.circle("fill", self.x, self.y, 4)
end


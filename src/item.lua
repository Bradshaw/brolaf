local item_mt = {}
item = {}
item.all = {}

itemTypes = {"beer","beer","beer","beer","beer", "hydromel"}
local itemsDescriptor = {
	beer = {
		hp = 2
	},
	hydromel = {
		timeHyperKill = 15
	}
}

function item.new(options)
	local self = setmetatable({}, {__index=item_mt})
	local options = options or {}

	self.position = options.position or vec2.new(250, 250)
	self.typeitemname = options.typeitem or "beer"
	self.typeitem = itemsDescriptor[options.typeitem or "beer"]

	table.insert(item.all, self)
	return self
end

function item.update( dt )
	local i = 1
	while i<=#item.all do
		local v = item.all[i]
		if v.purge then
			table.remove(item.all, i)
		else
			v:update(dt)
			i = i+1
		end
	end
end

function item.findClosest( posPlayer, sizeDropable )
	local i = 1
	local closest = -1
	local indexClosest = 0
	while i<=#item.all do
		local v = item.all[i]
		lengthTemp = v.position:sub(posPlayer):length()
		if (closest < 0 or closest > lengthTemp) and useful.isClosest(v.position, posPlayer, sizeDropable) then
			closest = lengthTemp
			indexClosest = i
		end
		i = i+1
	end
	if indexClosest == 0 then
		return nil
	end
	return item.all[indexClosest]
end

function item.draw(  )
	for i,v in ipairs(item.all) do
		v:draw()
	end
end

function item_mt:update( dt )
end

function item_mt:draw()
	love.graphics.draw(self.typeitemname,self.position.x,self.position.y,0,1,1,16,32)
end

function item_mt:pickUp( hero )
	if self.typeitem.hp then
		hero:addHP(self.typeitem.hp)
	end
	if self.typeitem.timeHyperKill then
		hero:addTimeHyperKill(self.typeitem.timeHyperKill)
	end
	self.purge = true
end

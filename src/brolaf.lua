local brolaf_mt = {}
brolaf = {}
brolaf.all = {}

function brolaf.new()
	local self = setmetatable({}, {__index=brolaf_mt})

	table.insert(brolaf.all, self)
	return self
end

function brolaf.update( dt )
	local i = 1
	while i<=#brolaf.all do
		local v = brolaf.all[i]
		if v.purge then
			table.remove(brolaf.all, i)
		else
			v:update(dt)
			i = i+1
		end

	end
end

function brolaf.draw(  )
	for i,v in ipairs(brolaf.all) do
		v:draw()
	end
end

function brolaf_mt:update( dt )

end

function brolaf_mt:draw()

end

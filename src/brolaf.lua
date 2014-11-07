local brolaf_mt = {}
brolaf = {}
brolaf.cur = nil

function brolaf.new(options)
	local self = setmetatable({}, {__index=brolaf_mt})

	local options = options or {}

	if not options.noReplace then
		brolaf.cur = self
	end
	return self
end

function brolaf.update( dt )
	if brolaf.cur then
		brolaf:update(dt)
	end
end

function brolaf.draw(  )
	if brolaf.cur then
		brolaf:draw()
	end
end

function brolaf_mt:update( dt )

end

function brolaf_mt:draw()

end

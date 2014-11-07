useful = {}
local ID = 0

function useful.getNumID()
	ID = ID+1
	return ID
end

function useful.getStrID()
	return string.format("%06d",useful.getNumID())
end
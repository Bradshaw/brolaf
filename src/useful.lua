useful = {}
local ID = 0

math.tau = math.pi * 2

function useful.getNumID()
	ID = ID+1
	return ID
end

function useful.getStrID()
	return string.format("%06d",useful.getNumID())
end

function useful.clamp(input, min, MAX)
	return math.min(MAX,math.max(min,input))
end

function useful.tri(cond, yes, no)
	if cond then
		return yes
	end
	return no
end

function useful.dead(n, zone)
	local zone = 0.3
	return useful.tri(math.abs(n) > zone, n, 0)
end
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

function useful.isClosest(pos1, pos2, sizeVisible)
	return pos2:sub(pos1):length() <= sizeVisible
end

function useful.lerp(a, b, n)
	return b*n+(1-n)*a
end

function useful.bline(x0, y0, x1, y1, plot)
 
	local dx = math.abs(x1 - x0)
	local sx = x0 < x1 and 1 or -1
	local dy = math.abs(y1 - y0)
	local sy = y0 < y1 and 1 or -1
	local err = (dx>dy and dx or -dy)/2

	while true do
		if plot(x0,y0) then
			return false
		end
		if x0 == x1 and y0 == y1 then
			break
		end
		local e2 = err
		if e2 > -dx then
			err = err - dy
			x0 = x0 + sx
		end
		if e2 < dy then
			err = err + dx
			y0 = y0 + sy
		end
	end
	return true
end
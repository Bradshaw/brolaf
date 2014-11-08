local vec2_mt = {}
vec2 = {}

function vec2.new(x, y)
	local self = setmetatable({}, {__index=vec2_mt})
	if x == nil then
		self.x = 0
	else
		self.x = x
	end

	if y == nil then
		self.y = 0
	else
		self.y = y
	end
	return self
end

function vec2_mt:add(other)
	local newVec = vec2.new(self.x + other.x, self.y + other.y)
	return newVec
end

function vec2_mt:sub(other)
	local newVec = vec2.new(self.x - other.x, self.y - other.y)
	return newVec
end

function vec2_mt:mul(scalar)
	local newVec = vec2.new(self.x * scalar, self.y * scalar)
	return newVec
end

function vec2_mt:dot(other)
    return self.x * other.x + self.y * other.y;
end

function vec2_mt:rotateDegrees(angle)
	angle = degreeToRadian(angle);
	return self:rotateRadians(angle);
end

function vec2_mt:rotateRadians(angle)
	local newVec = vec2(0, 0)
	newVec.x = self.x * math.cos(angle) - self.y * math.sin(angle);
	newVec.y = self.x * math.sin(angle) + self.y * math.cos(angle);
	return newVec;
end

function vec2_mt:normalized()
	local len = self:length()
    return vec2.new(self.x / len, self.y / len);
end

function vec2_mt:length()
	return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2))
end

function vec2_mt:getRotation()
    local norm = self:normalized()
    return radianToDegree(math.atan2(norm.y, norm.x))
end
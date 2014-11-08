local fudge_mt = {}
local piece_mt = {}
local anim_mt = {}
local fudge = {}

fudge.anim_prefix = "ani_"

local old_draw = love.graphics.draw
local monkey_draw
local anim_draw = function(anim, frame, ...)
	monkey_draw(anim:getPiece(frame), ...)
end

monkey_draw = function(im, ...)
	if fudge.current and type(im)=="string" then
		--Get associate and draw it
		if im:sub(1,fudge.anim_prefix:len())==fudge.anim_prefix then
			monkey_draw(fudge.current:getAnimation(im), ...)
		else
			local fud = fudge.current:getPiece(im)
			old_draw(fud.img, fud.quad, ...)
		end
	elseif type(im)=="table" and im.img and im.quad then
		old_draw(im.img, im.quad, ...)
	elseif type(im)=="table" and im.batch then
		old_draw(im.batch)
	elseif type(im)=="table" and im.framerate then
		anim_draw(im, math.floor(love.timer.getTime()*im.framerate), ...)
	else
		old_draw(im, ...)
	end
end

local sortAreas = function(a, b)
	return (a.tex:getHeight()*a.tex:getWidth()) > (b.tex:getHeight()*b.tex:getWidth())
end
local sortMaxLengths = function(a, b)
	return math.max(a.tex:getHeight(),a.tex:getWidth()) > math.max(b.tex:getHeight(),b.tex:getWidth())
end
local sortWidths = function(a, b)
	return a.tex:getWidth() > b.tex:getWidth()
end
local sortHeights = function(a, b)
	return a.tex:getHeight() > b.tex:getHeight()
end

local split = function(str, sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        str:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end


local AABB = function(l1, t1, r1, b1, l2, t2, r2, b2)
	if (
		t2>=b1 or
		l2>=r1 or
		t1>=b2 or
		l1>=r2
	) then
		return false
	else
		return true
	end
end

local imAABB = function(i1, ox1, oy1, i2, ox2, oy2)
	return AABB(
		ox1,
		oy1,
		ox1+i1:getWidth(),
		oy1+i1:getHeight(),
		ox2,
		oy2,
		ox2+i2:getWidth(),
		oy2+i2:getHeight()
	)
end

local getAllImages = function(folder)
	local images = {}
	for i,v in ipairs(love.filesystem.getDirectoryItems(folder)) do
		table.insert(images, {
			name = split(v, ".")[1],
			tex = love.graphics.newImage(folder.."/"..v)
		})
		--table.insert(images, love.graphics.newImage(folder.."/"..v))
		--table.insert(images, love.graphics.newImage(folder.."/"..v))
	end
	return images
end

local putrows = function(t, mx)
	local rows = {}
	local currentRow = 1
	local x = 0
	local y = 0
	for i,v in ipairs(t) do
		if x+v.tex:getWidth()>mx then
			x=0
			y=y+rows[currentRow][1].tex:getHeight()
			currentRow = currentRow+1
		end
		if not rows[currentRow] then
			rows[currentRow] = {}
		end
		table.insert(rows[currentRow],{
			tex = v,
			x=x,
			y=y
		})
		x = x+v.tex:getWidth()
	end
	return rows
end


local pack = function(t, mx)
	local tcop = {}
	for i,v in ipairs(t) do
		tcop[i] = v
	end
	local packed = {}
	local points = {
		{x = 0, y = 0}
	}
	local maxHeight = 0
	while #tcop>=1 do
		table.sort(points, function( a, b )
			if a.y==b.y then
				return a.x<b.x
			else
				return a.y<b.y
			end
		end)
		local im = tcop[1]
		local p = 1
		local placed = false
		while not placed do
			local collides = false
			local outofbounds = false
			if points[p].x + im.tex:getWidth() > mx then
				outofbounds = true
			end
			if not outofbounds then
				for i,v in ipairs(packed) do
					if imAABB(im.tex,points[p].x,points[p].y, v.tex, v.x, v.y) then
						collides = true
					end
				end
			end
			if outofbounds or collides then
				p=p+1
			else
				maxHeight = math.max(maxHeight, points[p].y+im.tex:getHeight())
				table.insert(packed,{
					tex = im.tex,
					name = im.name,
					x = points[p].x,
					y = points[p].y,
					w = im.tex:getWidth(),
					h = im.tex:getHeight()
				})
				---[[
				table.insert(points,{
					x = points[p].x,
					y = points[p].y+im.tex:getHeight()
				})
				--]]
				---[[
				table.insert(points, {
					x = points[p].x+im.tex:getWidth(),
					y = points[p].y
				})
				--]]
				local maxy = points[p].y+im.tex:getHeight()
				for i,v in ipairs(packed) do
					maxy = math.max(maxy, v.y+v.tex:getHeight())
				end
				---[[
				table.insert(points, {
					x = 0,
					y = maxy
				})
				--]]
				table.remove(points, p)
				table.remove(tcop, 1)
				placed = true
			end
		end
	end
	return packed, maxHeight
end

function fudge.import(name)
	local self = require(name)
	setmetatable(self, {__index=fudge_mt})
	for k,v in pairs(self.pieces) do
		setmetatable(v, {__index=piece_mt})
	end
	return self
end

function fudge.new(folder, options)
	local timeAtStart = love.timer.getTime()
	local options = options or {}
	local self = setmetatable({},{__index=fudge_mt})
	self.images = getAllImages(folder)
	---[[
	local maxWidth = 0
	local area = 0
	for i,v in ipairs(self.images) do
		maxWidth = math.max(maxWidth, v.tex:getWidth())
		area = area + v.tex:getWidth()*v.tex:getHeight()
	end
	--]]
	local width = options.npot and maxWidth or 16
	while width<maxWidth do
		width = width * 2
	end
	local testWidths = options.npot and
	{
		width * 1,
		width * 2,
		width * 3,
		width * 4,
		width * 5,
		width * 6
	}

	or
	{
		width * 1,
		width * 2,
		width * 4,
		width * 8,
		width * 16,
		width * 32
	}
	local testSorts = {
		sortAreas,
		sortMaxLengths
	}
	local bestArea = math.huge
	local bestWidth = -1
	local bestSort = function() end
	local height = 0
	local maxHeight = 0
	for j,sortAlgo in ipairs(testSorts) do
		for i,w in ipairs(testWidths) do
			local h
			table.sort(self.images, sortAlgo)
			self.pack, h = pack(self.images, w)
			local h2 = 2
			while h2<h do
				h2 = h2 * 2
			end
			local comph = options.npot and h or h2
			if w*comph < bestArea then
				bestArea = w*comph
				bestWidth = w
				bestSort = sortAlgo
			end
		end
	end
	table.sort(self.images, bestSort)
	self.pack, maxHeight = pack(self.images, bestWidth)
	width = bestWidth
	if maxHeight>0 then
		height = options.npot and maxHeight or 16
		while height<maxHeight do
			height = height * 2
		end
	end
	self.width = width
	self.height = height
	self.canv = love.graphics.newCanvas(width, height)
	local old_cv = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canv)
	love.graphics.push()
		love.graphics.origin()
		love.graphics.setColor(255,255,255,255)
		for i,v in ipairs(self.pack) do
			love.graphics.draw(v.tex,v.x,v.y)
		end
	love.graphics.pop()
	love.graphics.setCanvas(old_cv)
	self.image = love.graphics.newImage(self.canv:getImageData())
	self.pieces = {}
	for i,v in ipairs(self.pack) do
		self.pieces[v.name] = {
			img = self.image,
			quad = love.graphics.newQuad(v.x, v.y, v.w, v.h, width, height),
			w = v.w,
			h = v.h,
			x = v.x,
			y = v.y
		}
		setmetatable(self.pieces[v.name], {__index=piece_mt})
	end
	self.batch = love.graphics.newSpriteBatch(self.image, (options and options.batchSize or nil))
	self.canv = nil
	self.images = nil
	self.pack = nil
	self.area = area
	self.time = math.floor((love.timer.getTime()-timeAtStart)*100)/100
	self.anim = {}
	return self
end

function fudge.set(option, value)
	if type(option)=="table" then
		for k,v in pairs(option) do
			fudge.set(k, v)
		end
		return
	end
	;({
		current = function(v)
			fudge.current = v
		end,
		monkey = function(v)
			if (v) then
				love.graphics.draw = monkey_draw
			else
				love.graphics.draw = old_draw
			end
		end,
		anim_prefix = function(v)
			local old_prefix = fudge.anim_prefix
			fudge.anim_prefix = v
			--[[
				Do prefix fixing here
			]]
		end
	})[option](value)
end

fudge.draw = monkey_draw

function fudge_mt:getPiece(name)
	if not self.pieces[name] then
		error("There is no piece named \""..name.."\"")
		return
	end
	return self.pieces[name]
end

function fudge_mt:getAnimation(name, frame)
	if frame then
		return self:getAnimation(name):getPiece(frame)
	else
		if not self.anim[name] then
			error("There is no animation named \""..name.."\"")
		end
		return self.anim[name]
	end
end

function fudge_mt:chopToAnimation(piecename, number, options)
	local options = options or {}
	local numlen = (""..number):len()
	local piece = self:getPiece(piecename)
	local stepsize = piece:getWidth()/number
	local animation = {}
	for i=1,number do
		self.pieces[piecename.."_"..string.format("%0"..numlen.."d", i)] = {
			img = self.image,
			quad = love.graphics.newQuad(
				piece.x+(i-1)*stepsize,
				piece.y,
				stepsize,
				piece.h,
				self.width,
				self.height)
		}
		table.insert(animation, piecename.."_"..string.format("%0"..numlen.."d", i))
	end
	self:animate((options.name or piecename), animation, options)
end

function fudge_mt:animate(name, frames, options)
	local options = options or {}
	local prefix = options.prefix or fudge.anim_prefix
	self.anim[prefix..name] = setmetatable({
		framerate = options.framerate or 10
	}, {__index = anim_mt})
	for i,v in ipairs(frames) do
		table.insert(self.anim[prefix..name], self:getPiece(v))
	end
end

function fudge_mt:addb(piece, ...)
	piece = type(piece)=="string" and self:getPiece(piece) or piece
	self.batch:add(piece.quad, ...)
end

function fudge_mt:clearb()
	self.batch:clear()
end

function fudge_mt:setImageFilter(...)
	self.image:setFilter(...)
end

function fudge_mt:export(name, options)
	local options = options or {}
	local image_extension = options.image_extension or "png"
	self.image:getData():encode(name.."."..image_extension)
	local string = "local f = {"
	string = string.."width="..self.width..","
	string = string.."height="..self.height..","
	string = string.."image=love.graphics.newImage('"..name.."."..image_extension.."')}\n"
	string = string.."f.batch=love.graphics.newSpriteBatch(f.image, "..self.batch:getBufferSize()..")\n"
	string = string.."f.pieces = {}\n"
	for k,v in pairs(self.pieces) do
		string = string.."f.pieces['"..k.."']={"
		string = string.."img=f.image,"
		string = string.."quad=love.graphics.newQuad("..v.x..","..v.y..","..v.w..","..v.h..","..self.width..","..self.height.."),"
		string = string.."x="..v.x..","
		string = string.."y="..v.y..","
		string = string.."w="..v.w..","
		string = string.."h="..v.h.."}\n"
	end
	string = string.."f.anim = {}\n"
	string = string.."return f"
	love.filesystem.write(name..".lua", string)
end

function fudge_mt:rename(old, new)
	if self.pieces[new] then
		error("There is already a piece with name: \""..new.."\".")
		return
	end
	if not self.pieces[old] then
		error("There is no piece named \""..old.."\" to rename")
		return
	end
	self.pieces[new], self.pieces[old] = self.pieces[old], nil
end

function piece_mt:getWidth()
	return self.w
end

function piece_mt:getHeight()
	return self.h
end

function anim_mt:getPiece(frame)
	return self[((frame-1)%#self)+1]
end

return fudge
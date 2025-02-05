

local floor = math.floor









-- Use this function to check if a box has been clicked by the mouse
function CheckIfBoxIsHovered(XMin, XMax, YMin, YMax)
	local Selected = false
	if love.mouse.getX() > XMin and love.mouse.getX() < XMax then
		if love.mouse.getY() > YMin and love.mouse.getY() < YMax then  
			Selected = true
		end
	end
	
return
Selected
end



-- this function displays text and checks for any clicks inside the text area.
-- If the text is double clicked, the "Activate" function is called.
local DebugClickBox = true
local PrintButtonPush = false
local Refreshed = true
function RenderClickableText(Text, XMin, XMax, YMin, YMax, ActivationFunc)

	local CenterX = (XMin+XMax)/2
	local CenterY = ((YMin+YMax)/2)-8
	local WidthLimit = CenterX/4

	if DebugClickBox then
		love.graphics.rectangle("line", XMin, YMin, math.abs(XMin-XMax), math.abs(YMin-YMax))
	end

	love.graphics.printf(Text, XMin, CenterY, math.abs(XMin-XMax), "center")

	if CheckIfBoxIsHovered(XMin, XMax, YMin, YMax) and love.mouse.isDown(1) and Refreshed then
		ActivationFunc()
		Refreshed = false
		if PrintButtonPush then
			print(Text)
		end
	end


end






local sizex
local sizey
function TextureButton(Image, x, y, sx, sy, ActivationFunc, r, ox, oy)
	
	sizex = Image:getWidth()*sx
	sizey = Image:getHeight()*sy
	
	if r == nil then r = 0 end
	if ox == nil then ox = 0 end
	if oy == nil then oy = 0 end
	love.graphics.draw(Image, x+(ox*sx), y+(oy*sy), r, sx, sy, ox, oy)

	if CheckIfBoxIsSelected(x, x+sizex, y, y+sizey) and love.mouse.isDown(1) and Refreshed then
		ActivationFunc()
		Refreshed = false
	end


end



function love.mousereleased( x, y, button, istouch, presses)
	Refreshed = true
end





function serialize(object, multiline, depth, name)
	depth = depth or 0
	if multiline == nil then multiline = true end
	local padding = string.rep('    ', depth) -- can use '\t' if printing to file
	local r = padding -- result string
	if name then -- should start from name
		r = r .. (
			-- enclose in brackets if not string or not a valid identifier
			-- thanks to Boolsheet from #love@irc.oftc.net for string pattern
			(type(name) ~= 'string' or name:find('^([%a_][%w_]*)$') == nil)
			and ('[' .. (
				(type(name) == 'string')
				and string.format('%q', name)
				or tostring(name))
				.. ']')
			or tostring(name)) .. ' = '
	end
	if type(object) == 'table' then
		r = r .. '{' .. (multiline and '\n' or ' ')
		local length = 0
		for i, v in ipairs(object) do
			r = r .. serialize(v, multiline, multiline and (depth + 1) or 0) .. ','
				.. (multiline and '\n' or ' ')
			length = i
		end
		for i, v in pairs(object) do
			local itype = type(i) -- convert type into something easier to compare:
			itype =(itype == 'number') and 1
				or (itype == 'string') and 2
				or (itype == 'boolean') and 3
				--or error('Serialize: Unsupported index type "' .. itype .. '"')
			local skip = -- detect if item should be skipped
				((itype == 1) and ((i % 1) == 0) and (i >= 1) and (i <= length)) -- ipairs part
				or ((itype == 2) and (string.sub(i, 1, 1) == '_')) -- prefixed string
			if not skip then
				r = r .. serialize(v, multiline, multiline and (depth + 1) or 0, i) .. ','
					.. (multiline and '\n' or ' ')
			end
		end
		r = r .. (multiline and padding or '') .. '}'
	elseif type(object) == 'string' then
		r = r .. string.format('%q', object)
	elseif type(object) == 'number' or type(object) == 'boolean' then
		r = r .. tostring(object)
	else
		print('Unserializeable value "' .. tostring(object) .. '"')
		r = r.. "nil"
	end
	return r
end



function math.clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end



function InRange(val, min, max)
	
	if val >= min and val <= max then
		return true
	else
		return false
	end

end



local abs = math.abs
function MoveTowardsZero(Val, Amount)

	if abs(Val) <= Amount then
		Val = 0
	end
	
	if Val > 0 then
		Val = Val - Amount
	elseif Val < 0 then 
		Val = Val + Amount
	end

return
Val
end

function MoveTowardValue(Value, ToVal, Increment)

	if abs(Value-ToVal) <= Increment then
		Value = ToVal
	end
	
	if Value > ToVal then
		Value = Value - Increment
	elseif Value < ToVal then 
		Value = Value + Increment
	end

return
Value
end

function NormalizeVal(Value)

	if Value < 0 then
		Value = -1
	elseif Value > 0 then
		Value = 1
	elseif Value == 0 then
		Value = 0
	end


return
Value
end




function math.randf(min, max, precision)
	local precision = precision or 0
	local num = math.random()
	local range = math.abs(max - min)
	local offset = range * num
	local randomnum = min + offset
	return math.floor(randomnum * math.pow(10, precision) + 0.5) / math.pow(10, precision)
end

function math.round(n)
return floor(n+0.5)
end






function NormalizedRGB(r, g, b)
	r = r / 255
	g = g / 255
	b = b / 255
return
r, g, b
end






function table.copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.copy(orig_key)] = table.copy(orig_value)
        end
        setmetatable(copy, table.copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end




function lerp(a, b, t)
	return a + (b - a) * t
end

-- rotational lerp function, uses radians
function rLerp(A, B, w)
    local CS = (1-w)*math.cos(A) + w*math.cos(B)
    local SN = (1-w)*math.sin(A) + w*math.sin(B)
    return math.atan2(SN,CS)
end


function drawRotatedRectangle(mode, x, y, width, height, angle)
	-- We cannot rotate the rectangle directly, but we
	-- can move and rotate the coordinate system.
	local offx = -(width/2)
	local offy = -(height/2)
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(angle)
	love.graphics.rectangle(mode, offx, offy, width, height) -- origin in the top left corner
--	love.graphics.rectangle(mode, -width/2, -height/2, width, height) -- origin in the middle
	love.graphics.circle("line", 0, -offy, 2)
	love.graphics.pop()
end




function OldScaledDraw(Img, x, y, W, H)

	local dw = W / Img:getWidth()
	local dh = H / Img:getHeight()
	love.graphics.draw(Img, x, y, 0, dw, dh)


end


function ScaledDraw(Img, x, y, Size)

	local Scale = Size / Img:getWidth()
	love.graphics.draw(Img, x, y, 0, Scale, Scale)


end


clamp = math.clamp
randi = math.random



function NewNumberArray(X, Y, BX, BY)
	local a = {}
	for x=X, BX do
		for y=Y, BY do
			if a[x] == nil then a[x] = {} end
			a[x][y] = 0
		end
	end
return
a
end



function FormatGrid(Grid, MinX, MaxX, MinY, MaxY)
	for x=MinX, MaxX do
		for y=MinY, MaxY do
			if Grid[x] == nil then Grid[x] = {} end
			Grid[x][y] = {}
		end
	end
end

function GetRandomIndex(Array)
	
	if #Array > 0 then
		return Array[math.random(1, #Array)]
	else
		return nil
	end


end



function IsPointInTriangle(px, py, x1, y1, x2, y2, x3, y3)


  local sab = (x1 - px)*(y2 - py) - (y1 - py)*(x2 - px) < 0
  if sab ~= ((x2 - px)*(y3 - py) - (y2 - py)*(x3 - px) < 0) then
    return false
  end
  return sab == ((x3 - px)*(y1 - py) - (y3 - py)*(x1 - px) < 0)
end










function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end












function table.insideout(t)

	local ft = {}
	
	for k, v in pairs(t) do
		ft[v] = k
	end



return
ft
end




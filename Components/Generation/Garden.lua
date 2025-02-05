print("STARTING GENERATION!")
require("Libraries/Utils")
local ffi = require("ffi")
require("love.math")

function math.round(n)
	return math.floor(n+0.5)
end





local BlockMem, HeightMem, ObjectMem, PlanetSize, BlockNames, ObjectNames = ...
print(serialize(ObjectNames))
local BlockData = ffi.cast("unsigned short(*)["..PlanetSize.."]", BlockMem:getFFIPointer())
local HeightData = ffi.cast("unsigned char(*)["..PlanetSize.."]", HeightMem:getFFIPointer())
local ObjectData = ffi.cast("unsigned short(*)["..PlanetSize.."]", ObjectMem:getFFIPointer())

local function SetBlock(x, z, Type, Height)
	if x >= 0 and z >= 0 and x < PlanetSize and z < PlanetSize then	
		BlockData[x][z] = BlockNames[Type].ID
		HeightData[x][z] = Height		
	end
end

local function SetObject(x, z, Type)	
	if x >= 0 and z >= 0 and x < PlanetSize and z < PlanetSize then	
		ObjectData[x][z] = ObjectNames[Type].ID	
	end
end



for x=0, PlanetSize-1 do
	for z=0, PlanetSize-1 do
		ObjectData[x][z] = 0
	end
end


local BlockTypes = {}
BlockTypes[1] = "Dirt"
BlockTypes[2] = "Grass"

local HeightMx
for x=0, PlanetSize-1 do
	for z=0, PlanetSize-1 do

		HeightMx = math.floor((love.math.noise(x / 1100, z / 1100) ^ 5) * 255)
		SetBlock(x, z, 
			BlockTypes[1 + math.round(love.math.noise(x / 25, z / 25) * 1)],
			1 + math.floor(love.math.noise(x / 300, z / 300) * HeightMx)
		)
		

		if love.math.noise(x / 100, z / 100) > 0.5 then
			SetObject(x, z, "Bush")
		elseif love.math.noise(x / 100, z / 100) > 0.3 then
			SetObject(x, z, "Tree")
		elseif love.math.noise(x / 100, z / 100) > 0.1 then
			SetObject(x, z, "MantisFruit")
		end
		if x % 16 == 0 and z % 16 == 0 then
			SetObject(x, z, "House")
		end
	end
end







print("DONE GENERATING!")
love.thread.getChannel("Planet Generation"):push(true)


local sub = string.sub
local ceil = math.ceil
local floor = math.floor
local ffi = require("ffi")

ffi.cdef([[
	typedef struct {
		unsigned char x, y, z, w;
		// bt = block type, 1 and 2 because evemntually we will store in 2 bytes
		unsigned char bt_1, bt_2, uv, ao;
	} vertex;
	
    void* malloc(size_t);                   
    void free(void*);
    void* realloc(void*, size_t);
	void *memcpy(void *dest, const void * src, size_t n);
]])



local VertexDataSize = ffi.sizeof("vertex")
local RegionSize = 255



local HeightMem, BlockMem, BlockTypes, PlanetSize, rx, rz = ...


local HeightData = ffi.cast("unsigned char(*)["..PlanetSize.."]", HeightMem:getFFIPointer())
local BlockData = ffi.cast("unsigned short(*)["..PlanetSize.."]", BlockMem:getFFIPointer())



local VertexCountIncrement = (VertexDataSize * 4) * (RegionSize ^ 2)
local MemSize = VertexCountIncrement
local MeshMemory = ffi.C.malloc(VertexCountIncrement)
local Verts = ffi.cast("vertex *", MeshMemory)

local CurrentHeight = 0
local HasFace
local BlockType
local VertSize = 1
local MeshIndex = 0

local TL_Brightness = 1
local BL_Brightness = 1
local BR_Brightness = 1
local TR_Brightness = 1
local AO_Incr = 45





local function CheckForResize()
	if MeshIndex * VertexDataSize > MemSize then
		local NewMem = ffi.C.realloc(MeshMemory, MemSize + VertexCountIncrement)
		MeshMemory = NewMem
		MemSize = MemSize + VertexCountIncrement
		--MeshMemory:release()
		--MeshMemory = NewMem
		Verts = ffi.cast("vertex *", MeshMemory)
		print("*************", MemSize)
	end
end

local WorldBlockX = rx * RegionSize
local WorldBlockZ = rz * RegionSize
local _bx, _bz
local AdjustedPlanetSize = PlanetSize-1
local function GetHeight(x, z)
	_bx = WorldBlockX+x
	_bz = WorldBlockZ+z
	if _bx < 0 or _bz < 0 or _bx > AdjustedPlanetSize or _bz > AdjustedPlanetSize then
		return 255
	else
		return HeightData[_bx][_bz]	
	end
end


for x=0, (RegionSize-1) do
	for z=0, (RegionSize-1)  do
	
		--print(x, z, MeshIndex, MeshMemory:getSize() / VertexDataSize)
		
		-- Increase the size of the chunk of memory used to store the vertexes if you are above its size
		CheckForResize()
		
		
		
		BlockType = BlockData[WorldBlockX+x][WorldBlockZ+z]	
		TextureIndex = BlockTypes[BlockType]
		
		----------------- Top Face -----------------------
		-- Always going to have top faces
		
		CurrentHeight = GetHeight(x, z)
	
		
		
		
		TL_Brightness = 255
		BL_Brightness = 255
		BR_Brightness = 255
		TR_Brightness = 255
		if GetHeight(x-1, z) > CurrentHeight then TL_Brightness = TL_Brightness - AO_Incr BL_Brightness = BL_Brightness - AO_Incr end
		if GetHeight(x+1, z) > CurrentHeight then TR_Brightness = TR_Brightness - AO_Incr BR_Brightness = BR_Brightness - AO_Incr end
		if GetHeight(x, z-1) > CurrentHeight then BL_Brightness = BL_Brightness - AO_Incr BR_Brightness = BR_Brightness - AO_Incr end
		if GetHeight(x, z+1) > CurrentHeight then TL_Brightness = TL_Brightness - AO_Incr TR_Brightness = TR_Brightness - AO_Incr end	
		if GetHeight(x-1, z+1) > CurrentHeight then TL_Brightness = TL_Brightness - AO_Incr end
		if GetHeight(x+1, z+1) > CurrentHeight then TR_Brightness = TR_Brightness - AO_Incr end
		if GetHeight(x-1, z-1) > CurrentHeight then BL_Brightness = BL_Brightness - AO_Incr end
		if GetHeight(x+1, z-1) > CurrentHeight then BR_Brightness = BR_Brightness - AO_Incr end
		
		
		Verts[MeshIndex].x = x
		Verts[MeshIndex].y = -CurrentHeight
		Verts[MeshIndex].z = z+VertSize
		Verts[MeshIndex].bt_1 = TextureIndex.TopImageIndex
		Verts[MeshIndex].uv = 0
		Verts[MeshIndex].ao = TL_Brightness
		Verts[MeshIndex].w = 1
		
		Verts[MeshIndex+1].x = x
		Verts[MeshIndex+1].y = -CurrentHeight
		Verts[MeshIndex+1].z = z
		Verts[MeshIndex+1].bt_1 = TextureIndex.TopImageIndex
		Verts[MeshIndex+1].uv = 1
		Verts[MeshIndex+1].ao = BL_Brightness
		Verts[MeshIndex+1].w = 1
		
		Verts[MeshIndex+2].x = x+VertSize
		Verts[MeshIndex+2].y = -CurrentHeight
		Verts[MeshIndex+2].z = z
		Verts[MeshIndex+2].bt_1 = TextureIndex.TopImageIndex
		Verts[MeshIndex+2].uv = 2
		Verts[MeshIndex+2].ao = BR_Brightness
		Verts[MeshIndex+2].w = 1
		
		Verts[MeshIndex+3].x = x+VertSize
		Verts[MeshIndex+3].y = -CurrentHeight
		Verts[MeshIndex+3].z = z+VertSize
		Verts[MeshIndex+3].bt_1 = TextureIndex.TopImageIndex
		Verts[MeshIndex+3].uv = 3
		Verts[MeshIndex+3].ao = TR_Brightness
		Verts[MeshIndex+3].w = 1

		MeshIndex = MeshIndex + 4
		
		
		-- Now loop downwards and cover any open faces
		
		for y=CurrentHeight, 1, -1 do
			
			
			HasFace = false			

			----------------- Front Face ---------------------
			if GetHeight(x, z-1) < y then
				
				HasFace = true

				TL_Brightness = 255
				BL_Brightness = 255
				BR_Brightness = 255
				TR_Brightness = 255
				if GetHeight(x-1, z-1) == y then TL_Brightness = TL_Brightness - AO_Incr BL_Brightness = BL_Brightness - AO_Incr end
				if GetHeight(x+1, z-1) == y then TR_Brightness = TR_Brightness - AO_Incr BR_Brightness = BR_Brightness - AO_Incr end
				if GetHeight(x, z-1) == y-1 then BL_Brightness = BL_Brightness - AO_Incr BR_Brightness = BR_Brightness - AO_Incr end
		
				Verts[MeshIndex].x = x
				Verts[MeshIndex].y = -y
				Verts[MeshIndex].z = z
				Verts[MeshIndex].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex].uv = 0
				Verts[MeshIndex].ao = TL_Brightness
				Verts[MeshIndex].w = 1
				
				Verts[MeshIndex+1].x = x
				Verts[MeshIndex+1].y = -y+VertSize
				Verts[MeshIndex+1].z = z
				Verts[MeshIndex+1].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex+1].uv = 1
				Verts[MeshIndex+1].ao = BL_Brightness
				Verts[MeshIndex+1].w = 1
				
				Verts[MeshIndex+2].x = x+VertSize
				Verts[MeshIndex+2].y = -y+VertSize
				Verts[MeshIndex+2].z = z
				Verts[MeshIndex+2].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex+2].uv = 2
				Verts[MeshIndex+2].ao = BR_Brightness
				Verts[MeshIndex+2].w = 1
				
				Verts[MeshIndex+3].x = x+VertSize
				Verts[MeshIndex+3].y = -y
				Verts[MeshIndex+3].z = z
				Verts[MeshIndex+3].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex+3].uv = 3
				Verts[MeshIndex+3].ao = TR_Brightness
				Verts[MeshIndex+3].w = 1

				MeshIndex = MeshIndex + 4
				
				CheckForResize()
			end
			
			----------------- Left Face ----------------------
			if GetHeight(x-1, z) < y then
				
				HasFace = true

				TL_Brightness = 255
				BL_Brightness = 255
				BR_Brightness = 255
				TR_Brightness = 255
				if GetHeight(x-1, z+1) == y then TL_Brightness = TL_Brightness - AO_Incr BL_Brightness = BL_Brightness - AO_Incr end
				if GetHeight(x+1, z-1) == y then TR_Brightness = TR_Brightness - AO_Incr BR_Brightness = BR_Brightness - AO_Incr end
				if GetHeight(x-1, z) == y-1 then BL_Brightness = BL_Brightness - AO_Incr BR_Brightness = BR_Brightness - AO_Incr end
				
				Verts[MeshIndex].x = x
				Verts[MeshIndex].y = -y
				Verts[MeshIndex].z = z+VertSize
				Verts[MeshIndex].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex].uv = 0
				Verts[MeshIndex].ao = TL_Brightness
				Verts[MeshIndex].w = 1
				
				Verts[MeshIndex+1].x = x
				Verts[MeshIndex+1].y = -y+VertSize
				Verts[MeshIndex+1].z = z+VertSize
				Verts[MeshIndex+1].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex+1].uv = 1
				Verts[MeshIndex+1].ao = BL_Brightness
				Verts[MeshIndex+1].w = 1
				
				Verts[MeshIndex+2].x = x
				Verts[MeshIndex+2].y = -y+VertSize
				Verts[MeshIndex+2].z = z
				Verts[MeshIndex+2].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex+2].uv = 2
				Verts[MeshIndex+2].ao = BR_Brightness
				Verts[MeshIndex+2].w = 1
				
				Verts[MeshIndex+3].x = x
				Verts[MeshIndex+3].y = -y
				Verts[MeshIndex+3].z = z
				Verts[MeshIndex+3].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex+3].uv = 3
				Verts[MeshIndex+3].ao = TR_Brightness
				Verts[MeshIndex+3].w = 1

				MeshIndex = MeshIndex + 4	
				
				CheckForResize()
				
			end
			
			----------------- Right Face ---------------------
			if GetHeight(x+1, z) < y then
				
				HasFace = true

				TL_Brightness = 255
				BL_Brightness = 255
				BR_Brightness = 255
				TR_Brightness = 255
				if GetHeight(x+1, z-1) == y then TL_Brightness = TL_Brightness - AO_Incr BL_Brightness = BL_Brightness - AO_Incr end
				if GetHeight(x+1, z+1) == y then TR_Brightness = TR_Brightness - AO_Incr BR_Brightness = BR_Brightness - AO_Incr end
				if GetHeight(x+1, z) == y-1 then BL_Brightness = BL_Brightness - AO_Incr BR_Brightness = BR_Brightness - AO_Incr end
				
				Verts[MeshIndex].x = x+VertSize
				Verts[MeshIndex].y = -y
				Verts[MeshIndex].z = z
				Verts[MeshIndex].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex].uv = 0
				Verts[MeshIndex].ao = TL_Brightness
				Verts[MeshIndex].w = 1
				
				Verts[MeshIndex+1].x = x+VertSize
				Verts[MeshIndex+1].y = -y+VertSize
				Verts[MeshIndex+1].z = z
				Verts[MeshIndex+1].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex+1].uv = 1
				Verts[MeshIndex+1].ao = BL_Brightness
				Verts[MeshIndex+1].w = 1
				
				Verts[MeshIndex+2].x = x+VertSize
				Verts[MeshIndex+2].y = -y+VertSize
				Verts[MeshIndex+2].z = z+VertSize
				Verts[MeshIndex+2].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex+2].uv = 2
				Verts[MeshIndex+2].ao = BR_Brightness
				Verts[MeshIndex+2].w = 1
				
				Verts[MeshIndex+3].x = x+VertSize
				Verts[MeshIndex+3].y = -y
				Verts[MeshIndex+3].z = z+VertSize
				Verts[MeshIndex+3].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex+3].uv = 3
				Verts[MeshIndex+3].ao = TR_Brightness
				Verts[MeshIndex+3].w = 1

				MeshIndex = MeshIndex + 4	
				
				CheckForResize()
				
			end
			
			----------------- Back Face ----------------------
			if GetHeight(x, z+1) < y then
				
				HasFace = true

				TL_Brightness = 255
				BL_Brightness = 255
				BR_Brightness = 255
				TR_Brightness = 255
				if GetHeight(x+1, z+1) == y then TL_Brightness = TL_Brightness - AO_Incr BL_Brightness = BL_Brightness - AO_Incr end
				if GetHeight(x-1, z+1) == y then TR_Brightness = TR_Brightness - AO_Incr BR_Brightness = BR_Brightness - AO_Incr end
				if GetHeight(x, z+1) == y-1 then BL_Brightness = BL_Brightness - AO_Incr BR_Brightness = BR_Brightness - AO_Incr end
				
				Verts[MeshIndex].x = x+VertSize
				Verts[MeshIndex].y = -y
				Verts[MeshIndex].z = z+VertSize
				Verts[MeshIndex].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex].uv = 0
				Verts[MeshIndex].ao = TL_Brightness
				Verts[MeshIndex].w = 1
				
				Verts[MeshIndex+1].x = x+VertSize
				Verts[MeshIndex+1].y = -y+VertSize
				Verts[MeshIndex+1].z = z+VertSize
				Verts[MeshIndex+1].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex+1].uv = 1
				Verts[MeshIndex+1].ao = BL_Brightness
				Verts[MeshIndex+1].w = 1
				
				Verts[MeshIndex+2].x = x
				Verts[MeshIndex+2].y = -y+VertSize
				Verts[MeshIndex+2].z = z+VertSize
				Verts[MeshIndex+2].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex+2].uv = 2
				Verts[MeshIndex+2].ao = BR_Brightness
				Verts[MeshIndex+2].w = 1
				
				Verts[MeshIndex+3].x = x
				Verts[MeshIndex+3].y = -y
				Verts[MeshIndex+3].z = z+VertSize
				Verts[MeshIndex+3].bt_1 = TextureIndex.SideImageIndex
				Verts[MeshIndex+3].uv = 3
				Verts[MeshIndex+3].ao = TR_Brightness
				Verts[MeshIndex+3].w = 1

				MeshIndex = MeshIndex + 4
				
				CheckForResize()
				
			end

			if not HasFace then
				break
			end
			
		end
		
		
		
	end
end




-- When we are done trim vertex memory down to the exact size needed
local TrimmedData = love.data.newByteData(MemSize)
ffi.copy(TrimmedData:getFFIPointer(), MeshMemory, MemSize)




---------------
-- Set the vertex map when we are done so that we can use 4 vertices to draw a square instead of 6
local VertexMapSize = MeshIndex*(6 / 4)
local VertexMapMemory = love.data.newByteData(VertexMapSize * 4)
local VertexMap = ffi.cast("unsigned int *", VertexMapMemory:getFFIPointer())
local VertexMapIndex = 0
for i=0, MeshIndex-1, 4 do
	VertexMap[VertexMapIndex] = i -- Top Left Corner
	VertexMap[VertexMapIndex+1] = i+1 -- Bot Left Corner
	VertexMap[VertexMapIndex+2] = i+2 -- Bot Right Corner
	VertexMap[VertexMapIndex+3] = i+2 -- Bot Right Corner
	VertexMap[VertexMapIndex+4] = i+3 -- Top Right Corner
	VertexMap[VertexMapIndex+5] = i -- Top Left Corner
	VertexMapIndex = VertexMapIndex + 6
end


print("DONE REMESGHIUNG!")
love.thread.getChannel("Remesh Threads"):push({Verts = TrimmedData, VertMap = VertexMapMemory, rx = rx, rz = rz})


























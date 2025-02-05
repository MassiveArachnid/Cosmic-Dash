


local DRAWLIMIT = 1500000

local Sprite3D = {}




local VS = 1
Sprite3D.SpriteVerts = {
{ -VS, VS, 0, 0,1 },
{ VS, VS, 0, 1,1 },
{ VS, -VS, 0, 1,0 },
{ -VS, -VS, 0, 0,0 },
{ -VS, VS, 0, 0,1 },
{ VS, -VS, 0, 1,0 }
}




Sprite3D.Shader = love.graphics.newShader("Components/Shaders/Sprite3D.shader")














----------------------------------------------------------
----------------------------------------------------------
local CullPos1X 
local CullPos1Y 
local CullPos2X 
local CullPos2Y
local CullPos3X
local CullPos3Y
function Sprite3D.SetCullTriangleData(x1, y1, x2, y2, x3, y3)

	CullPos1X = x1
	CullPos1Y = y1
	CullPos2X = x2
	CullPos2Y = y2
	CullPos3X = x3
	CullPos3Y = y3

end




----------------------------------------------------------
----------------------------------------------------------

ffi.cdef([[
    void* malloc(size_t);                   
    void free(void*);
    void* realloc(void*, size_t);
	void* memcpy(void *dest, const void * src, size_t n);
]])

-----------------
local _sab
local function IsSpriteInCullBounds(px, py, x1, y1, x2, y2, x3, y3)
	_sab = (x1 - px)*(y2 - py) - (y1 - py)*(x2 - px) < 0
	if _sab ~= ((x2 - px)*(y3 - py) - (y2 - py)*(x3 - px) < 0) then
		return false
	end
	return _sab == ((x3 - px)*(y1 - py) - (y3 - py)*(x1 - px) < 0)
end
-----------------
-- Stores a list of instances using the same texture
local RenderQueueIndex = 0
local RenderCount = 0
local RenderQueue = ffi.new("float["..DRAWLIMIT.." * 7]")
local RenderTextures = {}
local RenderTextureIDs = {}
local RenderTextureCount = 0
local InsideArea
function Sprite3D.Add(Texture, x, y, z, Alpha, Frame, Scale)
	InsideArea = IsSpriteInCullBounds(
		x,
		z,
		CullPos1X,
		CullPos1Y,
		CullPos2X,
		CullPos2Y,
		CullPos3X,
		CullPos3Y
	)
	
	

	if true then
		
		if RenderTextures[Texture] == nil then
			RenderTextures[Texture] = {ID = RenderTextureCount+1, DrawCount = 0}
			RenderTextureIDs[RenderTextureCount+1] = RenderTextures[Texture]
			RenderTextureCount = RenderTextureCount + 1
		end
		
		RenderQueue[RenderQueueIndex] = RenderTextures[Texture].ID
		RenderQueue[RenderQueueIndex+1] = x
		RenderQueue[RenderQueueIndex+2] = y
		RenderQueue[RenderQueueIndex+3] = z
		
		if Scale == nil then
			Scale = 1
		end
		
		RenderQueue[RenderQueueIndex+4] = Scale -- EMPTY DONT USE UNTIL WE UTILIZE THE A COMPONENT OF POSITION (PROB SCALE)
		
		if Alpha == nil then
			Alpha = 255
		end
		
		if Frame == nil then
			Frame = 0
		end
		
		RenderQueue[RenderQueueIndex+5] = Alpha
		RenderQueue[RenderQueueIndex+6] = Frame
		
		RenderQueueIndex = RenderQueueIndex + 7
		
		RenderCount = RenderCount + 1
		
		RenderTextures[Texture].DrawCount = RenderTextures[Texture].DrawCount + 1
		
	end
	
end






----------------------------------------------------------
----------------------------------------------------------
local RenderMesh = G3D.newModel(Sprite3D.SpriteVerts, nil, nil, {0,0,0})
local InstanceImageSize = 128

local PositionData = love.image.newImageData(InstanceImageSize, InstanceImageSize, "rgba32f")
local PositionArray = ffi.cast("float *", PositionData:getFFIPointer())
local PositionImage = love.graphics.newImage(PositionData)

local Alpha_FramesData = love.image.newImageData(InstanceImageSize, InstanceImageSize, "rg8")
local Alpha_FramesArray = ffi.cast("unsigned char *", Alpha_FramesData:getFFIPointer())
local Alpha_FramesImage = love.graphics.newImage(Alpha_FramesData)


function Sprite3D.Render()
	
	
	
	--
	local PositionDataPos = 0
	local Alpha_FramesDataPos = 0
	for k, v in pairs(RenderTextures) do
	
		v.I_PositionCurrent = 0
		v.I_PositionStart = PositionDataPos
		PositionDataPos = PositionDataPos + (v.DrawCount * 4)
		
		v.I_Alpha_FramesCurrent = 0
		v.I_Alpha_FramesStart = Alpha_FramesDataPos
		Alpha_FramesDataPos = Alpha_FramesDataPos + (v.DrawCount * 2)
		
	end
	
	

	local Tx, P_Index, AF_Index
	local RQ = RenderQueue
	
	-- Set data for positions
	for i=0, (RenderCount * 7)-1, 7 do
		--print("I", i)
		-- Get the texture table associated with this sprite draw command
		Tx = RenderTextureIDs[RQ[i]]
		-- Set the draw command at the index inside of the range allocated for this texture
		P_Index = Tx.I_PositionStart + Tx.I_PositionCurrent
		AF_Index = Tx.I_Alpha_FramesStart + Tx.I_Alpha_FramesCurrent
		-- Add the draw command data
		PositionArray[P_Index] = RQ[i+1]
		PositionArray[P_Index+1] = RQ[i+2]
		PositionArray[P_Index+2] = RQ[i+3]
		PositionArray[P_Index+3] = RQ[i+4]
		Alpha_FramesArray[AF_Index] = RQ[i+5]
		Alpha_FramesArray[AF_Index+1] = RQ[i+6]
		-- Increment the position for this texture down x amount of floats
		Tx.I_PositionCurrent = Tx.I_PositionCurrent + 4
		Tx.I_Alpha_FramesCurrent = Tx.I_Alpha_FramesCurrent + 2
	end
	

	
	
	
	
	--for x=0, 31 do
		--print(PositionData:getPixel(x, 0))
	--end
	
	--RenderMesh:setScale(3, 3, 3)
	
	-- Render instances
	love.graphics.setShader(Sprite3D.Shader)
	
	Sprite3D.Shader:send("viewMatrix", G3D.camera.viewMatrix)
	
	Sprite3D.Shader:send("projectionMatrix", G3D.camera.projectionMatrix)
	
	-- Send position data to shader
	PositionImage:replacePixels(PositionData)
	Alpha_FramesImage:replacePixels(Alpha_FramesData)
	
	Sprite3D.Shader:send("InstancePositions", PositionImage)
	
	Sprite3D.Shader:send("InstanceAlpha_Frames", Alpha_FramesImage)
	
	Sprite3D.Shader:send("InstanceImgSize", InstanceImageSize)
	
	
	
	
	
	for k, v in pairs(RenderTextures) do
		
		-- Set texture for these instances
		Sprite3D.Shader:send("InstanceArrayTexture", k)
		
		-- Send the index we start at for this texture
		Sprite3D.Shader:send("InstanceStartIndex", (v.I_PositionStart / 4) + 0)
	
	
		-- So we can draw at correct aspect ratio
		Sprite3D.Shader:send("AspectScale", k:getHeight() / k:getWidth())
		

		RenderMesh:drawInstanced(Sprite3D.Shader, v.DrawCount)
		
	end
	
	love.graphics.setShader()
	
	
	RenderCount = 0
	RenderQueueIndex = 0
	RenderTextures = {}
	RenderTextureIDs = {}
	RenderTextureCount = 0
	
	
	
end









return
Sprite3D







local Regions = {}

Regions.List = {}

Regions.RemeshThreads = {}
Regions.RemeshThreadCode = love.filesystem.read("Components/Threads/RemeshRegion.lua")


--------------
Regions.RegionSize = 255
Regions.RegionLoadDistance = 1 -- How far out region files are loaded from the players current region
Regions.MeshShader = love.graphics.newShader("Components/Shaders/Region Meshes.shader")
Regions.ObjectShader = love.graphics.newShader("Components/Shaders/Region Objects.shader")



--Regions.ShortRegionData = "unsigned short["..Regions.RegionDimensions.x.."]["..Regions.RegionDimensions.y.."]["..Regions.RegionDimensions.z.."]"
--Regions.CharRegionData = "unsigned char["..Regions.RegionDimensions.x.."]["..Regions.RegionDimensions.y.."]["..Regions.RegionDimensions.z.."]"
---------------


-- Make a new region with empty data
function Regions.Update()
	
	
	-- Only generate one region per update
	local GeneratedAlready = false
	
	local CamRegionX = math.floor(G3D.camera.position[1]/Regions.RegionSize)
	local CamRegionZ = math.floor(G3D.camera.position[3]/Regions.RegionSize)
	local Limit = (Planets.Dimensions[CurrentPlanet.PlanetSize].Size / Regions.RegionSize)-1
	
	for x=CamRegionX-Regions.RegionLoadDistance, CamRegionX+Regions.RegionLoadDistance do
		for z=CamRegionZ-Regions.RegionLoadDistance, CamRegionZ+Regions.RegionLoadDistance do
			if x >= 0 and x <= Limit and z >= 0 and z <= Limit then
				
				-- Load any regions in range
				if Regions.List[x] == nil then
					Regions.List[x] = {}
				end
				
				
				-- Make a region if it can exist inside the planet abd we havent already
				if Regions.List[x][z] == nil then
					Regions.New(x, z)
				end
				
				-- Make any loaded regions refrfeshed
				if Regions.List[x] ~= nil and Regions.List[x][z] ~= nil then
					Regions.List[x][z].Refreshed = true
				end				
			end
		end
	end
	
	
	for x in pairs(Regions.List) do
		for z in pairs(Regions.List[x]) do
			local Region = Regions.List[x][z]
			
			-- Generate region info
			if Region.NeedsGeneration and not Region.Generating then
				Regions.CreateGenerationThread(x, z)
				Region.Generating = true
			end
			
			-- create a remesh thread
			if Region.NeedsMesh and CurrentPlanet.Generated then
				if not Region.MeshingInProgress then
					Regions.CreateRemeshThread(x, z)
					Region.MeshingInProgress = true
				end
			end
			
			if not Region.NeedsMesh then
				-- Check if the object data needs to be recalculated
				if Region.ObjectTypesModified then
					Regions.RecalculateObjects(Region)
				end
				
				if Region.ObjectFlagsModified then
					Regions.SetObjectFlags(Region)
				end
			end
			
			-- When the regvion is done being created it can be removed safely
			if not Region.NeedsMesh and not Region.NeedsGeneration then
				if not Region.Refreshed then
					Regions.Unload(x, z)
				else
					Region.Refreshed = false
				end
			end
			
			
		end
	end
	
	
	Regions.CheckThreadsProgress()
end


-- Make a new region with empty data
function Regions.New(x, z)

	local RegionSize = Regions.RegionSize	

	Regions.List[x][z] = {
		x = x,
		z = z,
		-----------
		Model = nil,
		-----------
		ObjectTypesModified = true,
		ObjectFlagsModified = true,
		InstanceTextures = {},
		ObjectPositionData = love.image.newImageData(RegionSize, RegionSize, "rg8"),
		ObjectFlagsData = love.image.newImageData(RegionSize, RegionSize, "rg8"),
		-----------
		ObjectPositionImage = nil,
		ObjectFlagsImage = nil,
		ObjectInstanceMesh = G3D.newModel(Sprite3D.SpriteVerts, nil, nil, {0,0,0}),
		-----------
		Refreshed = true, -- If this region is discovered (or in range) this will be flagged as true
		MeshingInProgress = false,
		NeedsMesh = true,
	}
	
	Regions.List[x][z].ObjectPositionImage = love.graphics.newImage(Regions.List[x][z].ObjectPositionData)
	Regions.List[x][z].ObjectFlagsImage = love.graphics.newImage(Regions.List[x][z].ObjectFlagsData)
	
	--[[
		mini mountains
		HeightMax = math.floor((love.math.noise(ax / 1100, az / 1100) ^ 5) * 300)
		NewRegion.HeightData[bx][bz] = 1 + (math.floor(love.math.noise(ax / 300, az / 100) * 100) / 300) * HeightMax
		NewRegion.BlockData[bx][bz] = 1 + math.round(love.math.noise(ax / 25, az / 25) * 1)
	]]
	
	-- Check if this region has data already
	--if love.filesystem.getInfo(Systems.Current.."/"..Planets.Current)

end


-- Save a region to storage and close it
function Regions.Unload(x, z)
	Regions.List[x][z].Model.mesh:release()
	Regions.List[x][z] = nil
end


function Regions.CreateRemeshThread(x, z)

	local DesiredRegion = Regions.List[x][z]
	local NewIndex = #Regions.RemeshThreads+1
	Regions.RemeshThreads[NewIndex] = love.thread.newThread(Regions.RemeshThreadCode)
	Regions.RemeshThreads[NewIndex]:start(
		CurrentPlanet.HeightMemory, 
		CurrentPlanet.BlockMemory, 
		Blocks.Types, 
		Planets.Dimensions[CurrentPlanet.PlanetSize].Size,
		x, 
		z
	)
	
end


local RegionVertexFormat = {
    {"VertexPosition", "byte", 4},
    {"VertInfo", "byte", 4},
}
function Regions.CheckThreadsProgress()

    local t = love.thread.getChannel("Remesh Threads"):pop()
    if t then
		
		--local MeshVerts = ffi.cast("RegionVertex *", t.Verts:getFFIPointer())
		--local VertexMap = ffi.cast("unsigned int *", t.VertMap:getFFIPointer())
		local rx = t.rx
		local rz = tonumber(t.rz)
		
		print("Creating region mesh at position:", rx, rz)
		
		Regions.List[rx][rz].MeshingInProgress = false
		Regions.List[rx][rz].NeedsMesh = false
		
		Regions.List[rx][rz].Model = G3D.newModel(
			t.Verts, 
			Blocks.GlobalBlockTextureAtlas, 
			RegionVertexFormat, 
			{rx * Regions.RegionSize, -Regions.RegionSize, rz * Regions.RegionSize}
		)
		
		
		--Regions.List[rx][rz].Model.mesh:setVertices(t.Verts)
		Regions.List[rx][rz].Model.mesh:setVertexMap(t.VertMap, "uint32")
		
		--Regions.List[rx][rz].Model:setScale(sx,sy,sz)
		--Regions.List[rx][rz].Model:setTranslation(rx * Regions.RegionSize, 0, rz * Regions.RegionSize)
		
	end

end


function Regions.RecalculateObjects(Region)
	
	print("Startubg Calc", Region.x, Region.z)
	
	local RegionSize = Regions.RegionSize
	
	local RenderGrid = ffi.new("unsigned short ["..RegionSize.."]["..RegionSize.."]")
	local TextureIDs = {}
	local TextureIndex = 1
	
	Region.InstanceTextures = {}
	
	-- Iterate over the objects in the region, add them to an array and build information for their instanced mesh
	local RS = RegionSize
	local ObjTex
	for x=Region.x*RS, (Region.x*RS)+(RS-1) do
		for z=Region.z*RS, (Region.z*RS)+(RS-1) do
			--print("dd", CurrentPlanet.ObjectTypes[x][z], x, z, Planets.Dimensions[CurrentPlanet.PlanetSize].Size)
			
			if CurrentPlanet.ObjectTypes[x][z] ~= 0 then
					
				CurrentTexture = Objects.Types[CurrentPlanet.ObjectTypes[x][z]].Image
				
				if Region.InstanceTextures[CurrentTexture] == nil then
					Region.InstanceTextures[CurrentTexture] = {ID = TextureIndex, CurrentIndex = nil, StartIndex = nil, InstanceCount = 0}
					TextureIDs[TextureIndex] = Region.InstanceTextures[CurrentTexture]
					TextureIndex = TextureIndex + 1
				end
				
				RenderGrid[x - Region.x*RS][z - Region.z*RS] = Region.InstanceTextures[CurrentTexture].ID
				
				Region.InstanceTextures[CurrentTexture].InstanceCount = Region.InstanceTextures[CurrentTexture].InstanceCount + 1				

			end
		end
	end
	
	
	-- Determine boundries and positions for each instance texture that will be stored in the instancing image data
	local ImageDataPos = 0
	for k, v in pairs(Region.InstanceTextures) do
		v.CurrentIndex = 0
		v.StartIndex = ImageDataPos
		ImageDataPos = ImageDataPos + (v.InstanceCount * 2)
	end
	
	
	-- Now we take all of the draw calls out of the RenderGrid and store them in their orderly positions inside of the image data
	local ImgDataArray = ffi.cast("unsigned char *", Region.ObjectPositionData:getFFIPointer())
	
	
	local Tx, Pos
	for x=0, RegionSize-1 do
		for z=0, RegionSize-1 do
			if RenderGrid[x][z] ~= 0 then
				-- Get the texture table associated with this draw command
				Tx = TextureIDs[RenderGrid[x][z]]
				-- Set the draw command x,z at the index inside of the range allocated for this texture
				Pos = Tx.StartIndex + Tx.CurrentIndex
				-- Add the draw command data
				ImgDataArray[Pos] = x
				ImgDataArray[Pos+1] = z
				-- Increment the position for this texture down 2
				Tx.CurrentIndex = Tx.CurrentIndex + 2
			end
		end
	end
	
	Region.ObjectPositionImage:replacePixels(Region.ObjectPositionData)
	Region.ObjectTypesModified = false
	print("Endbug Calc", Region.x, Region.z)
	
end


function Regions.SetObjectFlags(Region)

	local Arr = ffi.cast("unsigned char *", Region.ObjectFlagsData:getFFIPointer())
	
	local Index = 0
	for x=0, Regions.RegionSize-1 do
		for z=0, Regions.RegionSize-1 do
			Arr[Index] = math.random(100, 255)
			Arr[Index+1] = 0
			Index = Index + 2
		end
	end
	Region.ObjectFlagsImage:replacePixels(Region.ObjectFlagsData)
	Region.ObjectFlagsModified = false
end


function Regions.DrawMeshes()


	
	local bx, bz
	for rx in pairs(Regions.List) do
		for rz in pairs(Regions.List[rx]) do
			local Region = Regions.List[rx][rz]
			if Region.Model ~= nil then
				-- Draw region mesh
				Regions.MeshShader:send("modelMatrix", Region.Model.matrix)
				Region.Model:draw()		
			end
		end
	end

end


function Regions.DrawObjects()
	
	local bx, bz
	for rx in pairs(Regions.List) do
		for rz in pairs(Regions.List[rx]) do
		
			local Region = Regions.List[rx][rz]
			
			if Region.Model ~= nil then
				
				Regions.ObjectShader:send("InstanceData", Region.ObjectPositionImage)
				
				Regions.ObjectShader:send("InstanceFlagData", Region.ObjectFlagsImage)
				
				Regions.ObjectShader:send("RegionPos",{Region.x*Regions.RegionSize, Regions.RegionSize, Region.z*Regions.RegionSize})
	
				for k, v in pairs(Region.InstanceTextures) do
					
					-- Set the texture for these instances
					Region.ObjectInstanceMesh:setTexture(k)
					
					-- Send the index we start at for this texture
					Regions.ObjectShader:send("InstanceStartIndex", (v.StartIndex / 2) + 0)

					Region.ObjectInstanceMesh:drawInstanced(Regions.ObjectShader, v.InstanceCount)
					
				end
				
			end
			
		end
	end

end

































return
Regions
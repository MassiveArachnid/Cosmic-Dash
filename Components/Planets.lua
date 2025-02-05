


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local Planets = {}
Planets.SpawnDistance = {Min = 50, Max = 300}
Planets.Dimensions = {
	["Small"] = {Size = 1024, Height = 128},
	["Medium"] = {Size = 2048, Height = 128},
	["Large"] = {Size = 4096, Height = 256},
	["Massive"] = {Size = 8192, Height = 256},
}
Planets.Types = {"Garden"}--, "Toxic Garden", "Martian", "Ice", "Ocean"}
Planets.Names = {
	Prefixes = {"Dusty", "Ugly", "Frozen", "Cold", "Chilly", "Trashy", "Scorching", "Seething", "Hopeless"},
	Suffixes = {"Trash Bin", "Cluster", "Wasteland", "Rock", "Planet", "Home", "Colony", "Graveyard", "Gem"},
}
Planets.GenerationThreads =  {}
Planets.GenerationThreadCode = {
	["Garden"] = love.filesystem.read("Components/Generation/Garden.lua"),
}
-------------------------------------------------------------------------------
-- test region data fluff
local t = {}



--	for i=1, 134000000 do
--		for i=1, 1048576 do
--			t[i] = "x"
--		end
--	end
--local s = table.concat(t)
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function Planets.New(SystemName, Distance, OrbitSpeed, OrbitTilt)
	
	
	local NewPlanet = {
		Name = "",
		x = 0,
		y = 0,
		z = 0,
		System = SystemName,
		PlanetCover = nil,
		PlanetType = "",
		PlanetSize = "",
		OrbitDistance = Distance,
		OrbitRotation = Rotation,
		OrbitTilt = OrbitTilt,
		OrbitSpeed = OrbitSpeed,
		OrbitTimer = (((math.pi / 2) / OrbitSpeed) * math.random(1, 1000)),
		-------
		BlockMemory = nil,
		HeightMemory = nil,
		HeatMemory = nil,
		GasTypeMemory = nil,
		GasAmountMemory = nil,
		ObjectTypeMemory = nil,
		ObjectData_1_Memory = nil,
		ObjectData_2_Memory = nil,
		ObjectData_3_Memory = nil,
		ObjectData_4_Memory = nil,
		--
		Blocks = nil,
		Height = nil,
		Heat = nil,
		GasTypes = nil,
		GasAmounts = nil,
		ObjectTypes = nil,
		ObjectData_1 = nil,
		ObjectData_2 = nil,
		ObjectData_3 = nil,
		ObjectData_4 = nil,
		-------
		HeightMap = nil,
		-------
		Generated = false,
		GenerationStarted = false,
		-------
		Atmosphere = "",
		Temperature = 0,
		SeaLevel = 0,
		Heat = {},
		Radiation = {},
		Gases = {},
		-------
		Units = {},
		PermanentUnits = {},
		Items = {},
		-------
		Mesh = nil,
		OrbitLineMesh = nil,
		-------
		RandomGenerationX = math.random(1, 9999999),
		RandomGenerationZ = math.random(1, 9999999),
	}


	
	-- Random planet type
	NewPlanet.PlanetType = Planets.Types[math.random(1, #Planets.Types)]
	
	
	-- Random size of planet
	local r = math.random(1, 100)
	if r <= 5 then
		NewPlanet.PlanetSize = "Massive"
	elseif r <= 35 then
		NewPlanet.PlanetSize = "Large"
	elseif r <= 80 then
		NewPlanet.PlanetSize = "Medium"
	else
		NewPlanet.PlanetSize = "Small"
	end
	
	
	-- Random sea level
	NewPlanet.SeaLevel = math.random(Planets.Dimensions[NewPlanet.PlanetSize].Height*0.25, Planets.Dimensions[NewPlanet.PlanetSize].Height*0.75)

	-- Random planet cover
	NewPlanet.PlanetCover = nil--love.graphics.newImage("Assets/Planet Covers/"..NewPlanet.PlanetType..".png")
	
	-- Generate heat layers
	NewPlanet.Temperature = math.random(50, 110)
	
	NewPlanet.Atmosphere = "Oxygen"
	
	-- Random name
	NewPlanet.Name = NewPlanet.Name..Planets.Names.Prefixes[math.random(1, #Planets.Names.Prefixes)]
	NewPlanet.Name = NewPlanet.Name.." "..Planets.Names.Suffixes[math.random(1, #Planets.Names.Suffixes)]
	




	local PD = Planets.Dimensions[NewPlanet.PlanetSize].Size ^ 2




	print("Planet size", Planets.Dimensions[NewPlanet.PlanetSize].Size)
	---------------------------
	-- Make planet data path
	local PlanetPath = "Systems/"..SystemName.."/Planets/"..NewPlanet.Name.."/"
	love.filesystem.createDirectory(PlanetPath)
	










return
NewPlanet
end



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
Planets.UpdateCurrent = function(dt)

	--[[
    local g = love.thread.getChannel("Generation Threads"):pop()
    if g then
		
		--print("Creating region mesh at position:", rx, rz)
		
		CurrentPlane.HeightData = ffi.cast("unsigned short(*)["..(Regions.RegionSize+2).."]", ffi.cast("void*", g[2]))
		Regions.List[rx][rz].BlockData = ffi.cast("unsigned short(*)["..(Regions.RegionSize+2).."]", ffi.cast("void*", g[1]))
		Regions.List[rx][rz].ObjectData = ffi.cast("unsigned short(*)["..(Regions.RegionSize+2).."]", ffi.cast("void*", g[3]))
		Regions.List[rx][rz].NeedsGeneration = false
	end
	]]
	
	
	if not CurrentPlanet.Generated and not CurrentPlanet.GenerationStarted then
	
		local NewIndex = #Planets.GenerationThreads+1
		Planets.GenerationThreads[NewIndex] = love.thread.newThread(Planets.GenerationThreadCode[CurrentPlanet.PlanetType])
		Planets.GenerationThreads[NewIndex]:start(
			CurrentPlanet.BlockMemory, 
			CurrentPlanet.HeightMemory, 
			CurrentPlanet.ObjectTypeMemory, 
			Planets.Dimensions[CurrentPlanet.PlanetSize].Size,
			Blocks.Names,
			Objects.Names
		)
		
		CurrentPlanet.GenerationStarted = true
	end
	
    local t = love.thread.getChannel("Planet Generation"):pop()
    if t then
		local PS = Planets.Dimensions[CurrentPlanet.PlanetSize].Size
		CurrentPlanet.Generated = true
		CurrentPlanet.HeightMap = love.graphics.newImage(love.image.newImageData(PS, PS, "r8", CurrentPlanet.HeightMemory))
	end	
	
	
end



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
Planets.LoadBlockData = function(Planet)
	
	local PDTotal = Planets.Dimensions[Planet.PlanetSize].Size ^ 2
	local PD = Planets.Dimensions[Planet.PlanetSize].Size
	local FilePath = "Systems/"..CurrentSystem.Name.."/Planets/"..Planet.Name.."/BlockData"
	
	if love.filesystem.getInfo(FilePath) == nil then
		
		Planet.BlockMemory = love.data.newByteData(ffi.sizeof("unsigned short") * PDTotal)
		Planet.HeightMemory = love.data.newByteData(ffi.sizeof("unsigned char") * PDTotal)
		Planet.HeatMemory = love.data.newByteData(ffi.sizeof("short") * PDTotal)
		Planet.GasTypeMemory = love.data.newByteData(ffi.sizeof("unsigned char") * PDTotal)
		Planet.GasAmountMemory = love.data.newByteData(ffi.sizeof("unsigned char") * PDTotal)
		Planet.ObjectTypeMemory = love.data.newByteData(ffi.sizeof("unsigned short") * PDTotal)
		Planet.ObjectData_1_Memory = love.data.newByteData(ffi.sizeof("unsigned char") * PDTotal)
		Planet.ObjectData_2_Memory = love.data.newByteData(ffi.sizeof("unsigned char") * PDTotal)
		Planet.ObjectData_3_Memory = love.data.newByteData(ffi.sizeof("unsigned char") * PDTotal)
		Planet.ObjectData_4_Memory = love.data.newByteData(ffi.sizeof("unsigned char") * PDTotal)
		
		Planet.Blocks = ffi.cast("unsigned short(*)["..PD.."]", Planet.BlockMemory:getFFIPointer())
		Planet.Height = ffi.cast("unsigned char(*)["..PD.."]", Planet.HeightMemory:getFFIPointer())
		Planet.Heat = ffi.cast("short(*)["..PD.."]", Planet.HeatMemory:getFFIPointer())
		Planet.GasTypes = ffi.cast("unsigned char(*)["..PD.."]", Planet.GasTypeMemory:getFFIPointer())
		Planet.GasAmounts = ffi.cast("unsigned char(*)["..PD.."]", Planet.GasAmountMemory:getFFIPointer())
		Planet.ObjectTypes = ffi.cast("unsigned short(*)["..PD.."]", Planet.ObjectTypeMemory:getFFIPointer())
		Planet.ObjectData_1 = ffi.cast("unsigned char(*)["..PD.."]", Planet.ObjectData_1_Memory:getFFIPointer())
		Planet.ObjectData_2 = ffi.cast("unsigned char(*)["..PD.."]", Planet.ObjectData_2_Memory:getFFIPointer())
		Planet.ObjectData_3 = ffi.cast("unsigned char(*)["..PD.."]", Planet.ObjectData_3_Memory:getFFIPointer())
		Planet.ObjectData_4 = ffi.cast("unsigned char(*)["..PD.."]", Planet.ObjectData_4_Memory:getFFIPointer())		
	
	else
		
		local UncompressedData, size = love.filesystem.read(FilePath)
		local DecompressedData = love.data.decompress("string", "zlib", UncompressedData)
		
		local PlanetData = loadstring(DecompressedData)()

		Planet.BlockMemory = love.data.newByteData(PlanetData.BlockMemory)
		Planet.HeightMemory = love.data.newByteData(PlanetData.HeightMemory)
		Planet.HeatMemory = love.data.newByteData(PlanetData.HeatMemory)
		Planet.GasTypeMemory = love.data.newByteData(PlanetData.GasTypeMemory)
		Planet.GasAmountMemory = love.data.newByteData(PlanetData.GasAmountMemory)
		Planet.ObjectTypeMemory = love.data.newByteData(PlanetData.ObjectTypeMemory)
		Planet.ObjectData_1_Memory = love.data.newByteData(PlanetData.ObjectData_1_Memory)
		Planet.ObjectData_2_Memory = love.data.newByteData(PlanetData.ObjectData_2_Memory)
		Planet.ObjectData_3_Memory = love.data.newByteData(PlanetData.ObjectData_3_Memory)
		Planet.ObjectData_4_Memory = love.data.newByteData(PlanetData.ObjectData_4_Memory)
		
		Planet.Blocks = ffi.cast("unsigned short(*)["..PD.."]", Planet.BlockMemory:getFFIPointer())
		Planet.Height = ffi.cast("unsigned char(*)["..PD.."]", Planet.HeightMemory:getFFIPointer())
		Planet.Heat = ffi.cast("short(*)["..PD.."]", Planet.HeatMemory:getFFIPointer())
		Planet.GasTypes = ffi.cast("unsigned char(*)["..PD.."]", Planet.GasTypeMemory:getFFIPointer())
		Planet.GasAmounts = ffi.cast("unsigned char(*)["..PD.."]", Planet.GasAmountMemory:getFFIPointer())
		Planet.ObjectTypes = ffi.cast("unsigned short(*)["..PD.."]", Planet.ObjectTypeMemory:getFFIPointer())
		Planet.ObjectData_1 = ffi.cast("unsigned char(*)["..PD.."]", Planet.ObjectData_1_Memory:getFFIPointer())
		Planet.ObjectData_2 = ffi.cast("unsigned char(*)["..PD.."]", Planet.ObjectData_2_Memory:getFFIPointer())
		Planet.ObjectData_3 = ffi.cast("unsigned char(*)["..PD.."]", Planet.ObjectData_3_Memory:getFFIPointer())
		Planet.ObjectData_4 = ffi.cast("unsigned char(*)["..PD.."]", Planet.ObjectData_4_Memory:getFFIPointer())
		
	end
	
end
	


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
Planets.UnloadBlockData = function(Planet)



	local SaveTable = {
		BlockMemory = Planet.BlockMemory:getString(),
		HeightMemory = Planet.HeightMemory:getString(),
		HeatMemory = Planet.HeatMemory:getString(),
		GasTypeMemory = Planet.GasTypeMemory:getString(),
		GasAmountMemory = Planet.GasAmountMemory:getString(),
		ObjectTypeMemory = Planet.ObjectTypeMemory:getString(),
		ObjectData_1_Memory = Planet.ObjectData_1_Memory:getString(),
		ObjectData_2_Memory = Planet.ObjectData_2_Memory:getString(),
		ObjectData_3_Memory = Planet.ObjectData_3_Memory:getString(),
		ObjectData_4_Memory = Planet.ObjectData_4_Memory:getString(),
	}
	
	Planet.BlockMemory:release()
	Planet.HeightMemory:release()
	Planet.HeatMemory:release()
	Planet.GasTypeMemory:release()
	Planet.GasAmountMemory:release()
	Planet.ObjectTypeMemory:release()
	Planet.ObjectData_1_Memory:release()
	Planet.ObjectData_2_Memory:release()
	Planet.ObjectData_3_Memory:release()
	Planet.ObjectData_4_Memory:release()

	Planet.Blocks = nil
	Planet.Height = nil
	Planet.Heat = nil
	Planet.GasTypes = nil
	Planet.GasAmounts = nil
	Planet.ObjectTypes = nil
	Planet.ObjectData_1 = nil
	Planet.ObjectData_2 = nil
	Planet.ObjectData_3 = nil
	Planet.ObjectData_4 = nil


	local PlanetData = love.data.compress("string", "zlib", "local p = "..serialize(SaveTable, false).."return p", 9)
	love.filesystem.write("Systems/"..Planet.System.."/Planets/"..Planet.Name.."/BlockData", PlanetData)


end
















return
Planets





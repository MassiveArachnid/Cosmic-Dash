



local Systems = {}

Systems.PlanetDistanceIncrement = {Min = 100, Max = 1000}
Systems.DayLength = {Min = 100, Max = 1000}





function Systems.New(Name)
	
	local SystemPath = "Systems/"..Name.."/"
	love.filesystem.remove(SystemPath)
	
	
	local NewSystem = {
		Name = Name,
		Bodies = {},
		Ships = {},
	}
	
	CurrentSystem = NewSystem
	
	
	----------------------------
	-- Create save data 
	love.filesystem.createDirectory(SystemPath)
	love.filesystem.createDirectory(SystemPath.."Planets/")
	love.filesystem.write(SystemPath.."ships.data", "")
	
	
	-----------------------------
	-- Randomly generate planets
	local Increment = 10000
	local Dist = Increment * math.random(1, 8)
	for v=3, math.random(3, 15) do
		-- How many years it takes for the planet to move around the sun
		local YearDays = math.random(50, 1000)
		local NewPlanet = Planets.New(Name, Dist, math.random(10, 90), math.random(-5, 5))
		NewSystem.Bodies[NewPlanet.Name] = NewPlanet
		CurrentPlanet = NewPlanet
		Dist = Dist + (Increment * math.random(0, 2))
	end
	
	Planets.LoadBlockData(CurrentPlanet)
	--print(serialize(NewSystem))
end





--- EVENTUALLY THIS WILL BE MODIFIED TO JUST USE SPRITES
local verts = {
{ -.5, .5, 0, 0,1 },
{ .5, .5, 0, 1,1 },
{ .5, -.5, 0, 1,0 },
{ -.5, -.5, 0, 0,0 },
{ -.5, .5, 0, 0,1 },
{ .5, -.5, 0, 1,0 }
}

local abs = math.abs
local function _PlanetSortFunc(t, a, b)
	local Dist_1 = abs(t[b].x - G3D.camera.position[1]) + abs(t[b].y - G3D.camera.position[2]) + abs(t[b].z - G3D.camera.position[3])
	local Dist_2 = abs(t[a].x - G3D.camera.position[1]) + abs(t[a].y - G3D.camera.position[2]) + abs(t[a].z - G3D.camera.position[3])
	return Dist_1 < Dist_2
end
function Systems.Draw()
	
	if CurrentSystem ~= nil then
	
		local vx,vy,vz = G3D.camera.getLookVector()
		local dir = math.pi/2 - math.atan2( vz, vx )
		local pitch = math.tan( -vy )
	

		for k, v in spairs(CurrentSystem.Bodies, _PlanetSortFunc) do
			
			
			
			-- Give planet a mesh if it doesant ghave one
			if v.mesh == nil then
				local texture = love.graphics.newImage("Assets/Planet Covers/"..v.PlanetType..".png", {mipmaps = false})
				texture:setFilter("nearest", "nearest", 1)
				--texture:setMipmapFilter("nearest", 1)
				v.mesh = G3D.newModel(verts, texture, nil, {0,0,0}) -- "Assets/Temp/Quad.obj"
			end
			
			-- GFIve it a orbin line mesh if needed
			if v.OrbitLineMesh == nil then		
				local texture = love.graphics.newImage("Assets/Resources/Orbit Line.png", {mipmaps = false})
				texture:setFilter("nearest", "nearest", 8)
				--texture:setMipmapFilter("nearest", 1)
				v.OrbitLineMesh = G3D.newModel("Assets/Resources/Orbit Line Plane.obj", texture, nil, {0,0,0})		
				v.OrbitLineMesh:setScale(v.OrbitDistance,v.OrbitDistance,v.OrbitDistance)			
				v.OrbitLineMesh:setTranslation(0, 5000, 0)			
			end
			
			--print(v.OrbitSpeed)
			
			local Size = Planets.Dimensions[v.PlanetSize].Size * 2
			v.mesh:setScale(Size,Size,Size)
			
			v.OrbitTimer = v.OrbitTimer + (((math.pi / 2) / v.OrbitSpeed) * _GlobalDT)
			
			v.x = math.cos(v.OrbitTimer)*v.OrbitDistance
			v.y = math.sin(v.OrbitTimer)*v.OrbitTilt
			v.z = math.sin(v.OrbitTimer)*v.OrbitDistance
			v.mesh:setTranslation(v.x, v.y, v.z)
			
			v.mesh:setRotation(0, dir, pitch)
			v.mesh:draw()
			v.OrbitLineMesh:draw()
			
		end
	
	end
	


end




return
Systems





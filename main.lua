




---------------------------- Utility
AutoSwap = require("Libraries/AutoSwap")
ffi = require("ffi")
Socket = require("socket")
CDefs = require("Components/CDefs")
require("Libraries/Utils")
profile = require("Libraries/Profile")
G3D = require("Libraries/G3D")
PrintOutlined = require("Libraries/PrintOutlined")

---------------------------- Main Components
Systems = AutoSwap.Require("Components/Systems")
Planets = AutoSwap.Require("Components/Planets")
Regions = AutoSwap.Require("Components/Regions")
Blocks = AutoSwap.Require("Components/Blocks")
Objects = AutoSwap.Require("Components/Objects")
Player = AutoSwap.Require("Components/Player")
Sprite3D = AutoSwap.Require("Components/Sprite3D")
Units = AutoSwap.Require("Components/Units")
Items = AutoSwap.Require("Components/Items")
GUI = AutoSwap.Require("Components/GUI")
Music = AutoSwap.Require("Components/Music")
Effects = AutoSwap.Require("Components/Effects")
Waves = AutoSwap.Require("Components/Waves")








local verts = {
{ -.5, .5, 0, 0,1 },
{ .5, .5, 0, 1,1 },
{ .5, -.5, 0, 1,0 },
{ -.5, -.5, 0, 0,0 },
{ -.5, .5, 0, 0,1 },
{ .5, -.5, 0, 1,0 }
}



local Triangle1 = G3D.newModel(verts, "Assets/Temp/dumma.png", nil, {0,4,0}) -- "Assets/Temp/Quad.obj"
local Triangle2 = G3D.newModel(verts, "Assets/Temp/dumma.png", nil, {0,4,0}) -- "Assets/Temp/Quad.obj"
local Triangle3 = G3D.newModel(verts, "Assets/Temp/dumma.png", nil, {0,4,0}) -- "Assets/Temp/Quad.obj"



--local earth = G3D.newModel("Assets/Temp/G3D Assets/sphere.obj", "Assets/Temp/G3d Assets/earth.png", nil, {4,0,0})
--local TestQuad = G3D.newModel(verts, "Assets/Temp/plant 1.png", {0,4,0}) -- "Assets/Temp/Quad.obj"
--local moon = G3D.newModel("Assets/Temp/G3D Assets/sphere.obj", "Assets/Temp/G3d Assets/moon.png", nil, {4,5,0}, nil, 0.5)
local background = G3D.newModel("Assets/Temp/G3D Assets/sphere.obj", "Assets/Temp/sky.png", nil, {0,0,0})
local sky = G3D.newModel("Assets/Temp/G3D Assets/sphere.obj", "Assets/Temp/sky_transp.png", nil, {0,0,0})
sky:setRotation(0, 0, math.rad(90))
local timer = 0

local plants = {}

local img = love.graphics.newImage("Assets/Temp/plant 1.png", {mipmaps = true})
img:setFilter("nearest", "nearest", 1)
img:setMipmapFilter("nearest", 1)

local img2 = love.graphics.newImage("Assets/Temp/plant 2.png", {mipmaps = true})
img2:setFilter("nearest", "nearest", 1)
img2:setMipmapFilter("nearest", 1)

local Sun = love.graphics.newImage("Assets/Planet Covers/Sun.png", {mipmaps = false})
Sun:setFilter("nearest", "nearest", 1)
local SunModel = G3D.newModel(verts, Sun, nil, {0,0,0})

















----------------------------
CurrentSystem = nil
CurrentPlanet = nil



function love.load()
	
	love.audio.setVolume(0)
	
	love.graphics.setColor255 = function(r, g, b)
		love.graphics.setColor(r/255, g/255, b/255)
	end


	love.graphics.setDefaultFilter("nearest", "nearest", 16)
	
	Objects.LoadObjectTypes()
	
	Blocks.CreateTextureAtlas()
	
	Effects.LoadEffectTypes()
	
	Systems.New("test system")
	
	Items.LoadItemTypes()
	
	Units.LoadUnitTypes()

	--Regions.New(0, 0)
	--Regions.CreateRemeshThread(0, 0)
	

	for x=-1, 1 do
		for z=-1, 1 do
			--Regions.New(x, z)
			--Regions.CreateRemeshThread(x, z)
		end
	end
	
	--Blocks.CreateBlockTextureAtlas()
	
	--MySolarSystem = SolarSystems.New("Test")
	
	--MyPlanet = MySolarSystem:newPlanet("Plunet")
	
	--MyPlanet:GenerateSurface("Plunet")
	
	Regions.MeshShader:send("BlockTextureArray", Blocks.ArrayImage)
	
	Regions.MeshShader:send("UVArray", {0.0, 1.0}, {0.0, 0.0}, {1.0, 0.0}, {1.0, 1.0})
	
	
	
	for x=0, 8 do
		for z=0, 8 do
			Units.CreateCreature("Rhino", 80+x, 80, 80+z)
		end
	end
	
end



_GlobalTimer = 0
_GlobalDT = 0
local timer = 0
local FreeCamEnabled = false
local FreeCamButtonRefreshed = true
function love.update(dt)

	AutoSwap.Update(dt)
	
	--profile.start()
	
	
	if CurrentPlanet ~= nil then
		Units.Update(dt)
		Planets.UpdateCurrent(dt)
		Regions.Update()
		Waves.Update(dt)
	end
	
	--profile.stop()
	--print(profile.report(10))
	
	Effects.Update(dt)
	
	Items.Update(dt)
	
	GUI.Update(dt)
	
	_GlobalDT = dt
	
	_GlobalTimer = _GlobalTimer + dt
	
    timer = timer + dt
    --moon:setTranslation(math.cos(timer)*5 + 4, 0, math.sin(timer)*5)
    --moon:setRotation(0, timer - math.pi/2, 0)
	if FreeCamEnabled then
		G3D.camera.firstPersonMovement(dt)
	end
	
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
	
	
	
	if love.keyboard.isDown("`") then
		if FreeCamButtonRefreshed then
			FreeCamEnabled = not FreeCamEnabled
		end
		FreeCamButtonRefreshed = false
	else
		FreeCamButtonRefreshed = true
	end
	
	
	
	if not FreeCamEnabled then
		G3D.camera.fov = math.rad(30)
		Player.Move(dt)
	else
		G3D.camera.fov = math.rad(90)
	end
	G3D.camera.updateProjectionMatrix()
	
end




local function RotatePointClockwise(px, py, angle)

	local theta = math.rad(angle)	
	local s = math.sin(theta)
	local c = math.cos(theta)
	local x = px * c + py * s;
	local y = -px * s + py * c;

return 
x, y
end


local skip = false
local TT = {}
local s = 0
function love.draw()
	
	

	
	


	
	
	local vx,vy,vz = G3D.camera.getLookVector()
	local dir = math.pi/2 - math.atan2( vz, vx )
	local pitch = math.tan( -vy )



	---------------------------------
	---------------------------------
	----- Draw space stuff
	love.graphics.setShader(G3D.shader)
	
	love.graphics.setDepthMode("always", false)	
	
	love.graphics.setMeshCullMode("none")
	background:setScale(1000000, 1000000, 1000000)
    background:draw()
	
	Systems.Draw()
	
	
	sky:setScale(20000, 20000, 20000)
	sky:draw()
	
	--SunModel:setRotation(0, dir, pitch) --  Billboard
	--SunModel:setScale(35000, 35000, 35000)
	--SunModel:draw()

	


	
	---------------------------------
	---------------------------------
	----- Draw regions
	
	love.graphics.setShader(Regions.MeshShader)
	
	love.graphics.setDepthMode("lequal", true)	
	
	love.graphics.setMeshCullMode("back")
	
	Regions.MeshShader:send("viewMatrix", G3D.camera.viewMatrix)
	
	Regions.MeshShader:send("projectionMatrix", G3D.camera.projectionMatrix)
	

	Regions.DrawMeshes()
	
	
	
	if CurrentPlanet.Generated then
	
		love.graphics.setShader(Regions.ObjectShader)
		
		love.graphics.setDepthMode("lequal", true)	
		
		love.graphics.setMeshCullMode("none")
		
		Regions.ObjectShader:send("viewMatrix", G3D.camera.viewMatrix)
		
		Regions.ObjectShader:send("projectionMatrix", G3D.camera.projectionMatrix)
		
		Regions.ObjectShader:send("PlanetHeightMap", CurrentPlanet.HeightMap)

		Regions.ObjectShader:send("InstanceImgSize", Regions.RegionSize)
		
		Regions.ObjectShader:send("Time", _GlobalTimer)		
		
		Regions.DrawObjects()
	
	end
	
	
	
	
	
	love.graphics.setShader(G3D.shader)
	










	---------------------------------
	---------------------------------
	----- Draw 3D sprites

	love.graphics.setMeshCullMode("none")
	

	-- Batching bounds calculation
	local CamRot = math.deg(dir) + 0
	local BatchDist = 5000
	local FOV = math.deg(G3D.camera.fov)
	
	local t1x, t1y = RotatePointClockwise(0, BatchDist, CamRot + ((-FOV) * 0.90))
	Triangle1:setTranslation(
		G3D.camera.position[1] + t1x,
		G3D.camera.position[2],
		G3D.camera.position[3] + t1y
	)
	
	local t2x, t2y = RotatePointClockwise(0, BatchDist, CamRot + (FOV * 0.90))
	Triangle2:setTranslation(
		G3D.camera.position[1] + t2x,
		G3D.camera.position[2],
		G3D.camera.position[3] + t2y
	)
	
	Triangle1:setRotation(0, dir, pitch)
	Triangle2:setRotation(0, dir, pitch)
	--Triangle1:draw()
	--Triangle2:draw()
	
	local CullPos1X = G3D.camera.position[1] + t1x
	local CullPos1Y = G3D.camera.position[3] + t1y
	local CullPos2X = G3D.camera.position[1] + t2x
	local CullPos2Y = G3D.camera.position[3] + t2y

	
	Sprite3D.SetCullTriangleData(CullPos1X, CullPos1Y, CullPos2X, CullPos2Y, G3D.camera.position[1], G3D.camera.position[3])
	
	
	Units.Draw()
	
	Player.DrawBody()

	Player.DrawUpdateAugurs(_GlobalDT)

	Effects.Draw()
	
	Items.Draw()
	
	Sprite3D.Render()	
	



	



	---------------------------------
	---------------------------------
	----- Draw GUI
	
	love.graphics.setShader()
	love.graphics.print("FPS: "..love.timer.getFPS(), 25, 25)
	love.graphics.print(serialize(G3D.camera.position, false), 25, 35)
	love.graphics.print(serialize(love.graphics.getStats()), 25, 45)
	
	love.graphics.setColor(1, 0, 0)
	love.graphics.print(math.floor(Player.Health).."/"..Player.MaxHealth, 100, 15)
	love.graphics.print(math.floor(Player.XP), 100, 25)
	love.graphics.setColor(1, 1, 1)
	
	
	GUI.Draw()
	
	
end



function love.mousemoved(x,y, dx,dy)
	if FreeCamEnabled then
		G3D.camera.firstPersonLook(dx,dy)
	end
end





















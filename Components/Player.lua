

local Player = {}



Player.Character = "Mario"

Player.Health = 100
Player.MaxHealth = 100
Player.Armor = 0
Player.Augurs = {
	["Rusty Crapshootd"] = {
		AnimX = math.random(1, 100), AnimZ = math.random(1, 100), x = 0, y = 0, z = 0, Damage = 50, Type = "Fire", 
		Radius = 2, Speed = 25, OrbitX = 1, XSpd = 4, ZSpd = 4, OrbitZ = 1, ParticleTimer = 0,
	},
}

Player.Level = 1
Player.XP = 0
Player.Food = 50
Player.FoodMax = 50
Player.Gas = 100
Player.Coins = 50


Player.InventorySize = 16
Player.HeldItemCount = 8



Player.Inventory = {}
for i=1, Player.InventorySize do
	Player.Inventory[i] = ""
end
Player.Inventory[1] = "Cement Brick"
Player.Inventory[2] = "Reinforced Cement Brick"
Player.Inventory[3] = "Brickseed"
Player.Inventory[4] = "Brickseed"
Player.Inventory[5] = "Brickseed"

Player.HeldItems = {}
for i=1, 8 do
	Player.HeldItems[i] = ""
end

Player.SelectedItem = 1

Player.x = 400
Player.y = 15
Player.z = 64

Player.Moving = false
Player.YVelocity = 0
Player.FallSpeed = 50

Player.LookDirection = {x = 0, z = 1}
Player.DesiredLook = 1
Player.LookRotationSpeed = 10

Player.Speed = 15

Player.CameraDistance = 13
Player.CameraHeight = 2
Player.PlayerFocusHeight = 1.5


Player.CameraAdjustmentHeight = 0
Player.DesiredCameraAdjustment = 0




Player.Update = function(dt)




end











local TurnRefreshed = true
Player.Move = function(dt)
	
	local PD = Planets.Dimensions[CurrentPlanet.PlanetSize].Size
	
	local bx = math.floor(Player.x)
	local by = math.floor(Player.y)
	local bz = math.floor(Player.z)
	
	
	if CurrentPlanet ~= nil and CurrentPlanet.Generated then
	
		local DestY = Player.y + Player.YVelocity * dt
		
		if CurrentPlanet.Height[bx][bz] < math.floor(DestY) then
			Player.y = DestY
			Player.YVelocity = Player.YVelocity - (Player.FallSpeed * dt)
			by = math.floor(Player.y)
		else
			Player.YVelocity = 0
		end
	end
	
	
	if love.keyboard.isDown("space") and Player.YVelocity == 0 then
		Player.YVelocity = 15
	end
	
	Player.Moving = false
	
	local MoveX = 0
	local MoveZ = 0
	local Diagonal = 0
	if love.keyboard.isDown("w") then
		Player.Moving = true
		Diagonal = Diagonal + 1
		if Player.DesiredLook == 1 then MoveZ = 1
		elseif Player.DesiredLook == 2 then MoveX = 1
		elseif Player.DesiredLook == 3 then MoveZ = -1
		elseif Player.DesiredLook == 4 then MoveX = -1
		end
	elseif love.keyboard.isDown("s") then
		Player.Moving = true
		Diagonal = Diagonal + 1
		if Player.DesiredLook == 1 then MoveZ = -1
		elseif Player.DesiredLook == 2 then MoveX = -1
		elseif Player.DesiredLook == 3 then MoveZ = 1
		elseif Player.DesiredLook == 4 then MoveX = 1
		end
	end
	if love.keyboard.isDown("a") then
		Player.Moving = true
		Diagonal = Diagonal + 1
		if Player.DesiredLook == 1 then MoveX = -1
		elseif Player.DesiredLook == 2 then MoveZ = 1
		elseif Player.DesiredLook == 3 then MoveX = 1
		elseif Player.DesiredLook == 4 then MoveZ = -1
		end
	elseif love.keyboard.isDown("d") then
		Player.Moving = true
		Diagonal = Diagonal + 1
		if Player.DesiredLook == 1 then MoveX = 1
		elseif Player.DesiredLook == 2 then MoveZ = -1
		elseif Player.DesiredLook == 3 then MoveX = -1
		elseif Player.DesiredLook == 4 then MoveZ = 1
		end
	end
	
	local AdjustedSpeed = Player.Speed
	if Diagonal == 2 then
		AdjustedSpeed = AdjustedSpeed * 0.75
	end
	
	local XIncr = (MoveX * (AdjustedSpeed * dt))
	local ZIncr = (MoveZ * (AdjustedSpeed * dt))
	
	local DestX = math.floor(Player.x + XIncr)
	local DestZ = math.floor(Player.z + ZIncr)
	
	local AutoJump = false
	if DestX >= 0 and DestX < PD and CurrentPlanet.Height[DestX][bz] < by then
		Player.x = Player.x + XIncr
	elseif Player.YVelocity == 0 then
		AutoJump = true
	end
	if DestZ >= 0 and DestZ < PD and CurrentPlanet.Height[bx][DestZ] < by then
		Player.z = Player.z + ZIncr
	elseif Player.YVelocity == 0 then
		AutoJump = true
	end
	
	if AutoJump then
		Player.YVelocity = 15
	end
	
	if love.keyboard.isDown("e") then
		if TurnRefreshed then
			Player.DesiredLook = Player.DesiredLook - 1
			if Player.DesiredLook < 1 then
				Player.DesiredLook = 4
			end
		end
		TurnRefreshed = false
	elseif love.keyboard.isDown("q") then
		if TurnRefreshed then
			Player.DesiredLook = Player.DesiredLook + 1
			if Player.DesiredLook > 4 then
				Player.DesiredLook = 1
			end
		end
		TurnRefreshed = false
	else
		TurnRefreshed = true
	end
	
	if Player.DesiredLook == 1 then
		Player.LookDirection.x = lerp(Player.LookDirection.x, 0, Player.LookRotationSpeed*dt)
		Player.LookDirection.z = lerp(Player.LookDirection.z, 1, Player.LookRotationSpeed*dt)
	elseif Player.DesiredLook == 2 then
		Player.LookDirection.x = lerp(Player.LookDirection.x, 1, Player.LookRotationSpeed*dt)
		Player.LookDirection.z = lerp(Player.LookDirection.z, 0, Player.LookRotationSpeed*dt)
	elseif Player.DesiredLook == 3 then
		Player.LookDirection.x = lerp(Player.LookDirection.x, 0, Player.LookRotationSpeed*dt)
		Player.LookDirection.z = lerp(Player.LookDirection.z, -1, Player.LookRotationSpeed*dt)
	elseif Player.DesiredLook == 4 then
		Player.LookDirection.x = lerp(Player.LookDirection.x, -1, Player.LookRotationSpeed*dt)
		Player.LookDirection.z = lerp(Player.LookDirection.z, 0, Player.LookRotationSpeed*dt)
	end
	
	
	local CamX = Player.x - (Player.LookDirection.x * Player.CameraDistance)
	local CamZ = Player.z - (Player.LookDirection.z * Player.CameraDistance)
	Player.DesiredCameraAdjustment = 0.5
	
	if math.floor(CamX) >= 0 and math.floor(CamX) < PD and math.floor(CamZ) >= 0 and math.floor(CamZ) < PD then
		if Player.y+0.5+Player.CameraHeight <= CurrentPlanet.Height[math.floor(CamX)][math.floor(CamZ)]+1 then
			Player.DesiredCameraAdjustment = Player.y-CurrentPlanet.Height[math.floor(CamX)][math.floor(CamZ)]
		end
	end
	
	Player.CameraAdjustmentHeight = lerp(Player.CameraAdjustmentHeight, Player.DesiredCameraAdjustment, 4*dt)
	
	
	G3D.camera.lookAt(
	
		-- Position
		CamX, 
		-Player.y+Player.CameraAdjustmentHeight-Player.CameraHeight, 
		CamZ, 
		
		-- Target
		Player.x, 
		-Player.y+Player.PlayerFocusHeight, 
		Player.z
	)
	
	
	
	
	
	
end






local img = love.graphics.newArrayImage({"Assets/Temp/Test Augur.png"}, {mipmaps = true})
Player.DrawUpdateAugurs = function(dt)
	
	
	for k, v in pairs(Player.Augurs) do
	
		v.AnimX = v.AnimX + v.XSpd * dt
		v.AnimZ = v.AnimZ + v.ZSpd * dt
		
		v.x = Player.x + math.sin(v.AnimX) * v.OrbitX
		v.z = Player.z + math.cos(v.AnimX) * v.OrbitZ
		
		Sprite3D.Add(img, v.x, Player.y-1, v.z, KeepY)
		
		v.ParticleTimer = v.ParticleTimer + dt
		
		if v.ParticleTimer >= 0.05 then
			Effects.NewParticle("Fire Trail", v.x, Player.y-1, v.z, 0.2, 1)
			v.ParticleTimer = 0
		end
	
	end
	

end





local TD = "Assets/Celestials/Characters/Mario/"
local IdleTex = love.graphics.newArrayImage({TD.."Idle/1.png", TD.."Idle/2.png", TD.."Idle/1.png", TD.."Idle/2.png"})
local MoveTex = love.graphics.newArrayImage({TD.."Move/1.png", TD.."Move/2.png", TD.."Move/3.png", TD.."Move/2.png"})
IdleTex:setFilter("linear", "linear")
IdleTex:setFilter("linear", "linear")
local SinVal = 0
local Frame = 1
local FrameTimer = 0
local IdleFrameTime = 0.4
local MoveFrameTime = 0.12
local AnimIdle = true
Player.DrawBody = function()
	
	
	
	FrameTimer = FrameTimer + _GlobalDT
	
	local TimerMax
	if not Player.Moving then
		TimerMax = IdleFrameTime
	else
		TimerMax = MoveFrameTime
	end
	
	if FrameTimer >= TimerMax then
		FrameTimer = 0
		Frame = Frame + 1
		if Frame > 4 then
			Frame = 1
		end
	end
	
	local ShakeAmount = 0.025
	SinVal = SinVal + _GlobalDT * 28
	local MoveShake = ShakeAmount + math.sin(SinVal) * (ShakeAmount/2)
	
	if Player.YVelocity < -1 then
		Sprite3D.Add(MoveTex, Player.x, Player.y-1, Player.z, nil, 3, 0.5)
		SinVal = 0
	elseif not Player.Moving then
		Sprite3D.Add(IdleTex, Player.x, Player.y-1, Player.z, nil, Frame, 0.5)
		SinVal = 0
	else
		Sprite3D.Add(MoveTex, Player.x, Player.y-(1-MoveShake*2), Player.z, nil, Frame, 0.5+MoveShake)
	end

	
	-- Show Held Item
	if Player.HeldItems[Player.SelectedItem] ~= "" then
		local ItemImg = Items.Types[Player.HeldItems[Player.SelectedItem]].Image
		Sprite3D.Add(
			ItemImg, 
			Player.x, Player.y-(0.3-MoveShake), Player.z, 
			nil, Frame, 0.3
		)
	end

end








return
Player
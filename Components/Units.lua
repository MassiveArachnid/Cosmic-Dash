










local Units = {}

Units.PlayerLevelDifficulty = 0.1
Units.Bounds = 250
Units.MonsterDamageRange = 0.75
Units.MonsterFallSpeed = 75
Units.AugurDropChance = 100 -- one out of this number
Units.Names = {}
Units.Types = {}
Units.MonstersByLevel = {}




Units.LoadUnitTypes = function()


	-----------------------------------------------------------------------------------------------------------------------------
	-- Load all objects types
	local files = love.filesystem.getDirectoryItems("Assets/Units")
	
	local Index = 0
	for k, file in ipairs(files) do
	
		local UnitType, Name = file:match("(.+)_(.+)")
		
		local Name = Name:sub(1)
		
		print("Loading Unit", file, UnitType, Name)
		
		Units.Types[Index] = require("Assets/Units/"..UnitType.."_"..Name.."/"..Name)
		
		
		local AnimImages = {}
		
		local CurrentFrameStart = 0
		
		for AnimName, AnimSpeed in pairs(Units.Types[Index].Animations) do
			
			local StartingFrame = CurrentFrameStart
			
			local AnimPath = "Assets/Units/"..UnitType.."_"..Name.."/"..AnimName
			
			local ImageFiles = love.filesystem.getDirectoryItems(AnimPath)
			
			for x, z in ipairs(ImageFiles) do		
				AnimImages[#AnimImages+1] = AnimPath.."/"..z
				CurrentFrameStart = CurrentFrameStart + 1
			end
			
			Units.Types[Index].Animations[AnimName] = {
				StartFrame = StartingFrame,
				EndFrame = CurrentFrameStart,
				Speed = AnimSpeed,
			}
			
			-- Offset to next image when done with this animation
			CurrentFrameStart = CurrentFrameStart + 1
		
		end
		
	
		Units.Types[Index].ArrayImage = love.graphics.newArrayImage(AnimImages, {mipmaps = true})
		
		--print(serialize(AnimImages))
		
		Units.Names[Name] = Units.Types[Index]
		Units.Names[Name].ID = Index
		
		Index = Index + 1
	end
	

end


local _UnitType
Units.CreateMonster = function(Type, x, y, z)
	
	_UnitType = Units.Names[Type]
	CurrentPlanet.Units[#CurrentPlanet.Units+1] = {
		Type = Type,
		TypeTable = Units.Names[Type],
		IsMonster = true,
		Health = _UnitType.Health,
		HealthMax = _UnitType.Health,
		Damage = _UnitType.Damage,
		Speed = _UnitType.Speed,
		JumpHeight = _UnitType.JumpHeight,
		XP = _UnitType.XP,
		MoveFluxVal = math.random(1, 100),
		AnimationTimer = 0,
		AnimationFrame = 0,
		Animation = "Idle",
		YVelocity = 0,
		x = x,
		y = y,
		z = z,
	}

end

Units.CreateCreature = function(Type, x, y, z)
	
	_UnitType = Units.Names[Type]
	CurrentPlanet.Units[#CurrentPlanet.Units+1] = {
		Type = Type,
		TypeTable = Units.Names[Type],
		IsMonster = false,
		Health = _UnitType.Health,
		HealthMax = _UnitType.Health,
		Speed = _UnitType.Speed,
		JumpHeight = _UnitType.JumpHeight,
		MoveFluxVal = math.random(1, 100),
		MoveDestination = {x = 0, z = 0},
		MoveTimer = 0,
		IdleTimer = math.random(0, 3),
		AnimationTimer = 0,
		AnimationFrame = 0,
		Animation = "Idle",
		YVelocity = 0,
		x = x,
		y = y,
		z = z,
	}

end


Units.Update = function(dt)

	local PD = Planets.Dimensions[CurrentPlanet.PlanetSize].Size
	
	
	local XIncr, ZIncr, DestX, DestZ
	local NeedsJump
	local RandomSpeed
	local MoveX, MoveZ, MoveY
	local Distance, TypeTable
	for k, v in pairs(CurrentPlanet.Units) do
	
		v.MoveFluxVal = v.MoveFluxVal + dt
		
		Distance = math.sqrt((v.x - Player.x) ^ 2 + (v.z - Player.z) ^ 2)
		
		-- Remove any units if outside of range
		if Distance > Units.Bounds then
			CurrentPlanet.Units[k] = nil
		end
		
		if v.IsMonster then
			
			----------------------
			-- Fall to the ground
			MoveY = v.y + v.YVelocity * dt
			
			if CurrentPlanet.Height[math.floor(v.x)][math.floor(v.z)] < math.floor(MoveY) then
				v.y = MoveY
				v.YVelocity = v.YVelocity - Units.MonsterFallSpeed * dt
			else
				v.YVelocity = 0
			end
			
			----------------------
			-- Move towards player
			
			v.Animation = "Move"
			
			RandomSpeed = v.Speed * love.math.noise(v.MoveFluxVal/10)
			
			MoveX = math.clamp(Player.x - v.x, -1, 1)
			MoveZ = math.clamp(Player.z - v.z, -1, 1)
			
			XIncr = (MoveX * (RandomSpeed * dt))
			ZIncr = (MoveZ * (RandomSpeed * dt))
			
			DestX = math.floor(v.x + XIncr)
			DestZ = math.floor(v.z + ZIncr)
			
			NeedsJump = false
			
			if DestX >= 0 and DestX < PD and CurrentPlanet.Height[DestX][math.floor(v.z)] < math.floor(v.y) then
				v.x = v.x + XIncr
			else
				NeedsJump = true
			end
			if DestZ >= 0 and DestZ < PD and CurrentPlanet.Height[math.floor(v.x)][DestZ] < math.floor(v.y) then
				v.z = v.z + ZIncr
			else
				NeedsJump = true
			end
			
			if NeedsJump and v.YVelocity then
				v.YVelocity = v.JumpHeight * 5
			end
			
			----------------------
			-- Damage player when near
			if Distance < Units.MonsterDamageRange then
				Player.Health = Player.Health - v.Damage * dt
			end
			
			----------------------
			-- Check if any augurs are hitting this monster
			for a, b in pairs(Player.Augurs) do
				if math.sqrt((v.x - b.x) ^ 2 + (v.y - Player.y) ^ 2 + (v.z - b.z) ^ 2) < b.Radius then
					v.Health = v.Health - b.Damage * dt
				end   
			end
			
			----------------------
			-- Remove and create random loot if dead
			if v.Health <= 0 then
				CurrentPlanet.Units[k] = nil
				if #v.TypeTable.Loot > 0 then
					if math.random(1, v.TypeTable.LootChance) == 1 then
						--Items.Create(v.TypeTable.Loot[math.random(1, #v.TypeTable.Loot)], v.x, v.y, v.z)
					end
				end
				
				-- If the unit is a monster, there is always a small chance an augur will drop
				if math.random(1, Units.AugurDropChance) == 1 then
					--Items.CreateRandomAugur(v.x, v.y, v.z)
				end
				if math.random(1, 2) == 1 then
					Effects.NewParticle("MonsterDeath_1", v.x, v.y, v.z, 2)
				else
					Effects.NewParticle("MonsterDeath_2", v.x, v.y, v.z, 2)
				end
				
				Effects.NewSound("Kill Enemy", v.x, v.y, v.z)
				
				
				-- Chance to drop a heart
				if math.random(1, 2) == 1 then
					Items.Create("Red Heart", v.x, v.y, v.z)
				end
				
				-- Create xp drops
				local XPCount = v.XP
				
				while XPCount > 0 do
					if XPCount > 10000 then
						XPCount = XPCount - 10000
						Items.Create("10000 XP", v.x, v.y, v.z)
					elseif XPCount > 1000 then
						XPCount = XPCount - 1000
						Items.Create("1000 XP", v.x, v.y, v.z)
					elseif XPCount > 100 then
						XPCount = XPCount - 100
						Items.Create("100 XP", v.x, v.y, v.z)
					elseif XPCount > 10 then
						XPCount = XPCount - 10
						Items.Create("10 XP", v.x, v.y, v.z)
					elseif XPCount >= 1 then
						XPCount = XPCount - 1
						Items.Create("1 XP", v.x, v.y, v.z)
					end
				end
			
			end
			
		end

		
		
		if not v.IsMonster then
		
			
			----------------------
			-- Fall to the ground
			MoveY = v.y + v.YVelocity * dt
			
			if CurrentPlanet.Height[math.floor(v.x)][math.floor(v.z)] < math.floor(MoveY) then
				v.y = MoveY
				v.YVelocity = v.YVelocity - Units.MonsterFallSpeed * dt
			else
				v.YVelocity = 0
			end
			
			----------------------
			-- Move around randomly or idle
			
			MoveX = 0
			MoveZ = 0
				
			if v.MoveTimer > 0 then
				MoveX = v.MoveDestination.x
				MoveZ = v.MoveDestination.z
				v.MoveTimer = v.MoveTimer - dt
				v.Animation = "Move"
			elseif v.IdleTimer > 0 then
				v.IdleTimer = v.IdleTimer - dt
				v.Animation = "Idle"
			else
				if math.random(1, 3) == 1 then
					v.IdleTimer = math.random(1, 8)
				else
					v.MoveTimer = math.random(1, 8)
					v.MoveDestination.x = math.random(-1, 1)
					v.MoveDestination.z = math.random(-1, 1)
				end
			end
		
			
			RandomSpeed = v.Speed * love.math.noise(v.MoveFluxVal/10)
			
			XIncr = (MoveX * (RandomSpeed * dt))
			ZIncr = (MoveZ * (RandomSpeed * dt))
			
			DestX = math.floor(v.x + XIncr)
			DestZ = math.floor(v.z + ZIncr)
			
			NeedsJump = false
			
			if DestX >= 0 and DestX < PD and CurrentPlanet.Height[DestX][math.floor(v.z)] < math.floor(v.y) then
				v.x = v.x + XIncr
			else
				NeedsJump = true
			end
			if DestZ >= 0 and DestZ < PD and CurrentPlanet.Height[math.floor(v.x)][DestZ] < math.floor(v.y) then
				v.z = v.z + ZIncr
			else
				NeedsJump = true
			end
			
			if NeedsJump and v.YVelocity then
				v.YVelocity = v.JumpHeight * 5
			end			
		
		end
	end


end

local abs = math.abs
Units.Draw = function()

	
	local AnimTable
	for k, v in pairs(CurrentPlanet.Units) do
		
		AnimTable = v.TypeTable.Animations[v.Animation]
		
		v.AnimationTimer = v.AnimationTimer + _GlobalDT * AnimTable.Speed
		
		if v.AnimationTimer > 0.1 then
			v.AnimationTimer = 0
			v.AnimationFrame = v.AnimationFrame + 1
			if AnimTable.StartFrame + v.AnimationFrame > AnimTable.EndFrame then
				v.AnimationFrame = 0
			end
		end
		
		Sprite3D.Add(v.TypeTable.ArrayImage, v.x, v.y-0.5, v.z, 255, AnimTable.StartFrame + v.AnimationFrame, v.TypeTable.Scale)
		
		
	end


end














return
Units
















local Waves = {}


Waves.TimerMin = 120
Waves.TimerMax = 480
Waves.Timer = 0
Waves.WarningRange = 60

Waves.Spawning = false
Waves.SpawnTimer = 0
Waves.SpawnsPerSecond = 5
Waves.SpawnRangeMin = 25
Waves.SpawnRangeMax = 100
Waves.SpawnHeight = 10

Waves.SpawnCoroutine = nil





Waves.Update = function(dt)


	Waves.Timer = Waves.Timer - dt
	
	if Waves.Timer <= 0 then
	
		if not Waves.Spawning then
			Waves.Spawning = true
			Waves.SpawnCoroutine = coroutine.create(Waves.SpawnCoroutineFunc)
		end
		
		
		
		if Waves.Spawning then
		
			Waves.SpawnTimer = Waves.SpawnTimer + dt
			
			local SpawnIncrement = 1 / Waves.SpawnsPerSecond
			while Waves.SpawnTimer >= SpawnIncrement do
				
				Waves.SpawnTimer = Waves.SpawnTimer - SpawnIncrement
				
				local Okay, Error = coroutine.resume(Waves.SpawnCoroutine)
				
				if not Okay then
					error(Error)
				end
				
			end
		
		end
		
	end
	
	Waves.Timer = math.clamp(Waves.Timer, 0, 999999999)
end


Waves.SpawnCoroutineFunc = function()
	
	local PD = Planets.Dimensions[CurrentPlanet.PlanetSize].Size
	local RX = math.random(1, 999999)
	local RZ = math.random(1, 999999)
	local SpawnNoiseVal = 0
	local UnitCount = 0
	
	for k, v in pairs(Waves.List[Player.Level]) do	
		for i=1, v do
			
			coroutine.yield()
			
			SpawnNoiseVal = SpawnNoiseVal + 0.1
			
			-- Find a suitable position to spawn the monster
			
			local NX = (love.math.noise(RX + SpawnNoiseVal) * 2) - 1
			local NZ = (love.math.noise(RZ + SpawnNoiseVal) * 2) - 1
			
			local DX, DZ
			if NX <= 0 then
				DX = -1
			else
				DX = 1
			end
			if NZ <= 0 then
				DZ = -1
			else
				DZ = 1
			end
			
			local DistX = (Waves.SpawnRangeMin * DX) + (NX * (Waves.SpawnRangeMax - Waves.SpawnRangeMin))
			local DistZ = (Waves.SpawnRangeMin * DZ) + (NZ * (Waves.SpawnRangeMax - Waves.SpawnRangeMin))
			
			local SpawnX = Player.x + DistX
			local SpawnZ = Player.z + DistZ
			
			if SpawnX < 0 then
				SpawnX = 0
			elseif SpawnX > PD then
				SpawnX = PD
			end
			if SpawnZ < 0 then
				SpawnZ = 0
			elseif SpawnZ > PD then
				SpawnZ = PD
			end
			
			-- Spawn a monster around the player
			Units.CreateMonster(
				k, 
				SpawnX, 
				CurrentPlanet.Height[SpawnX][SpawnZ]+Waves.SpawnHeight, 
				SpawnZ
			)
			
			UnitCount = UnitCount + 1
			--print(UnitCount)
		end		
	end
	
	Waves.Spawning = false
	Waves.Timer = math.random(Waves.TimerMin, Waves.TimerMax)
	--print("d")
end











Waves.List = {}
Waves.List[1] = {["Piggy"] = 250}
Waves.List[2] = {["Piggy"] = 7}
Waves.List[3] = {["Piggy"] = 25}







Waves.Music = {}
Waves.Music[1] = Music.List["A Cool Song"]
Waves.Music[2] = Music.List["A Cool Song"]
Waves.Music[3] = Music.List["A Cool Song"]

















return
Waves
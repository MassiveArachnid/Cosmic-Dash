

local Effects = {}


Effects.ParticleList = {}
Effects.SoundList = {}
Effects.MaxSoundDist = 10 
Effects.ParticleFramesPerSecond = 15
Effects.ParticleFadeStartTime = 1

Effects.AugurParticleTypes = {}
Effects.ParticleTypes = {}
Effects.SoundTypes = {}











Effects.LoadEffectTypes = function()



	-----------------------------------------------------------------------------------------------------------------------------
	
	local SoundFiles = love.filesystem.getDirectoryItems("Assets/Effects/Sounds")
	for k, file in ipairs(SoundFiles) do
		Effects.SoundTypes[file:sub(1, -5)] = love.audio.newSource("Assets/Effects/Sounds/"..file, "static")	
	end

	
	
	local function LoadParticleFiles(Directory)
	
		local Files = love.filesystem.getDirectoryItems(Directory)
		for k, file in ipairs(Files) do
			
			print(Directory, file)
			local ImageFiles = table.insideout(love.filesystem.getDirectoryItems(Directory..file))
			local Images = {}
			local ImageCount = 0
			
			for i=1, 9999 do
				if ImageFiles[i..".png"] ~= nil then
					Images[i] = Directory..file.."/"..i..".png"
					ImageCount = ImageCount + 1
					print("FOUND", i)
				else
					break
				end
			end
			
			if ImageCount > 0 then
				--print(serialize(Images))
				Effects.ParticleTypes[file] = love.graphics.newArrayImage(Images, {mipmaps = true})
			end
			
		end	
	
	end
	
	LoadParticleFiles("Assets/Effects/Particles/")
	LoadParticleFiles("Assets/Effects/Augur Particles/")

	


	--print(serialize(Effects.ParticleTypes))
	--error()

end





Effects.NewParticle = function(ParticleType, x, y, z, Scale, LifeTime)
	
	if Scale == nil then
		Scale = 1
	end
	
	if Effects.ParticleTypes[ParticleType] == nil then
		print("Effect", ParticleType, "Not found!")
	else
		Effects.ParticleList[#Effects.ParticleList+1] = {
			Image = Effects.ParticleTypes[ParticleType],
			x = x,
			y = y,
			z = z,
			Scale = Scale,
			LifeTime = LifeTime,
			FrameTimer = 0,
			Frame = 1
		}
	end
	
end



local _NewIndex, _SoundDist
Effects.NewSound = function(Type, x, y, z)
	
	_NewIndex = #Effects.SoundList+1
	Effects.SoundList[_NewIndex] = {
		Sound = Effects.SoundTypes[Type]:clone(),
		x = x,
		y = y,
		z = z,
	}
	
	Effects.SoundList[_NewIndex].Sound:play()
	Effects.SoundList[_NewIndex].Sound:setVolume(0)

end











Effects.Update = function(dt)
	
	--love.audio.setPosition(Player.x, Player.y, Player.z)
	
	for k, v in pairs(Effects.SoundList) do
	
		_SoundDist = math.sqrt((v.x - Player.x) ^ 2 + (v.y - Player.y) ^ 2 + (v.z - Player.z) ^ 2)
		v.Sound:setVolume(1 - (1 * (_SoundDist / Effects.MaxSoundDist)))
		
	end
end


Effects.Draw = function()
	
	local Alpha, CycledAnimation
	for k, v in pairs(Effects.ParticleList) do
		
		CycledAnimation = false
		
		v.y = v.y - _GlobalDT * 0.1
		
		if v.LifeTime ~= nil then
			Alpha = math.clamp((v.LifeTime / Effects.ParticleFadeStartTime) * 255, 0, 255)
			v.LifeTime = v.LifeTime - _GlobalDT
		else
			Alpha = 255
		end
		
		v.FrameTimer = v.FrameTimer + _GlobalDT
		
		
		
		
		-- Increment frames
		if v.FrameTimer > 1/Effects.ParticleFramesPerSecond then
			v.FrameTimer = 0
			v.Frame = v.Frame + 1
			if v.Frame > v.Image:getLayerCount() then
				v.Frame = 1
				CycledAnimation = true
			end
		end
		
		
		-- Delete when needed
		if v.LifeTime ~= nil and v.LifeTime <= 0 then
			-- Particles with a set duration
			Effects.ParticleList[k] = nil
		elseif v.LifeTime == nil and CycledAnimation then
			-- Particles with no duration, they are deleted when the animation is done
			Effects.ParticleList[k] = nil
		end
		
		
		Sprite3D.Add(v.Image, v.x, v.y, v.z, Alpha, v.Frame, v.Scale)

		
		
	end



end
































return
Effects
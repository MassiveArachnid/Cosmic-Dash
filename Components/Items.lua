


local Items = {}



Items.FallSpeed = 50
Items.Bounces = 1.5
Items.BounceForce = 10
Items.SpawnVelocity = 8
Items.Types = {}
Items.LoadDist = 500
Items.CollectibleMagnetRadius = 5
Items.PickupRadius = 1.5







Items.LoadItemTypes = function()

	-----------------------------------------------------------------------------------------------------------------------------
	-- Load all item type
	local function LoadItemCategory(CategoryType)
		local Directory = "Assets/Items/"..CategoryType.."/"
		local files = love.filesystem.getDirectoryItems(Directory)
		for k, Name in ipairs(files) do	
			Name = Name:sub(1, -5)
			print("LOAD ITEM", Name)
			Items.Types[Name] = {}
			Items.Types[Name].Category = CategoryType
			Items.Types[Name].Image = love.graphics.newArrayImage({Directory..Name..".png"}, {mipmaps = true})
			Items.Types[Name].Image:setMipmapFilter("linear", 0)
		end
	end

	LoadItemCategory("Resource")
	LoadItemCategory("Food")
	LoadItemCategory("Collectible")
	LoadItemCategory("Tool")
	
end



--NewItem("Shovel", "Tool", {Price = 123, Rarity = "some_rarity"})
--NewObjectTagInteraction("Shovel", "Small Plant", "Uproot Plant", function(ItemSlot, ot, ox, oz)



--end)






Items.Create = function(Type, x, y, z)

	CurrentPlanet.Items[#CurrentPlanet.Items+1] = {
		Type = Type,
		TypeTable = Items.Types[Type],
		x = x,
		y = y,
		z = z,	
		XVelocity = math.random(-Items.SpawnVelocity, Items.SpawnVelocity),
		YVelocity = 0,
		ZVelocity = math.random(-Items.SpawnVelocity, Items.SpawnVelocity),		
		Bounces = Items.Bounces,
		LifeTime = 0
	}


end










local CP = {}
CP["1 XP"] = function(P) P.XP = P.XP + 1 end
CP["10 XP"] = function(P) P.XP = P.XP + 10 end
CP["100 XP"] = function(P) P.XP = P.XP + 100 end
CP["1000 XP"] = function(P) P.XP = P.XP + 1000 end
CP["10000 XP"] = function(P) P.XP = P.XP + 10000 end
CP["Red Heart"] = function(P) P.Health = math.clamp(P.Health + P.MaxHealth * 0.1, 0, P.MaxHealth) end
	
Items.Update = function(dt)
	
	
	local PD = Planets.Dimensions[CurrentPlanet.PlanetSize].Size
	
	local DestX, DestZ, FloorHeight
	local Distance
	local InvSlot, InvHasSpace
	local SlideVelocity
	for k, v in pairs(CurrentPlanet.Items) do
		
		v.LifeTime = v.LifeTime + dt
		
		Distance = math.sqrt((v.x - Player.x) ^ 2 + (v.y - Player.y) ^ 2 + (v.z - Player.z) ^ 2)
		
		----------------------
		-- Fall to the ground
		MoveY = v.y + v.YVelocity * dt
		
		FloorHeight = CurrentPlanet.Height[math.floor(v.x)][math.floor(v.z)]
		
		if FloorHeight < MoveY then
			v.y = MoveY
			v.YVelocity = v.YVelocity - Items.FallSpeed * dt
		else
			v.y = FloorHeight
			if v.Bounces > 0 then
				v.YVelocity = Items.BounceForce * (v.Bounces / Items.Bounces)
				v.Bounces = v.Bounces - 1
			else
				v.YVelocity = 0
			end
			
		end
		
		----------------------
		-- Move item
		SlideVelocity = math.abs(v.XVelocity+v.ZVelocity)
		
		if SlideVelocity > 0 then
			
			DestX = math.floor(v.x + v.XVelocity * dt)
			DestZ = math.floor(v.z + v.ZVelocity * dt)
			
			if DestX >= 0 and DestX < PD and CurrentPlanet.Height[DestX][math.floor(v.z)] <= v.y then
				v.x = v.x + v.XVelocity * dt
			end
			if DestZ >= 0 and DestZ < PD and CurrentPlanet.Height[math.floor(v.x)][DestZ] <= v.y then
				v.z = v.z + v.ZVelocity * dt
			end

			v.XVelocity = lerp(v.XVelocity, 0, 1.5*dt)
			v.ZVelocity = lerp(v.ZVelocity, 0, 1.5*dt)
			

		end
		
		


		----------------------
		-- Pickup when player is near			
		if v.TypeTable.Category == "Collectible" then
			if Distance <= Items.CollectibleMagnetRadius then
				v.XVelocity = v.XVelocity + math.clamp((Player.x - v.x), -1, 1) * dt * 12
				v.ZVelocity = v.ZVelocity + math.clamp((Player.z - v.z), -1, 1) * dt * 12
			end
			if Distance <= Items.PickupRadius and v.LifeTime > 0.5 then
				CP[v.Type](Player)
				CurrentPlanet.Items[k] = nil
			end
		elseif v.LifeTime > 0.5 and Distance <= Items.PickupRadius then
			InvHasSpace = false
			
			for i=1, Player.InventorySize do
				
				if Player.Inventory[i] == "" then
					
					Player.Inventory[i] = v.Type
					
					CurrentPlanet.Items[k] = nil
					
					break					
					
				end
			end
		end
		
			
	end

end



Items.Draw = function()

	for k, v in pairs(CurrentPlanet.Items) do
		Sprite3D.Add(v.TypeTable.Image, v.x, v.y, v.z, 255, nil, 0.2)
	end

end
































return
Items


local GUI = {}


W = love.graphics.getWidth()
H = love.graphics.getHeight()


GUI.MenuNavOpen = false

GUI.InventoryOpen = false
GUI.CraftingOpen = false
GUI.StatScreenOpen = false
GUI.ClassScreenOpen = false

GUI.FontSize = W*0.020
GUI.FontType = "NicoBold-Regular"
GUI.KaphFont = love.graphics.newFont("Assets/Fonts/Kaph-Regular.ttf", H*0.030)
GUI.TitleKaphFont = love.graphics.newFont("Assets/Fonts/Kaph-Regular.ttf", H*0.05)
GUI.MiniKaphFont = love.graphics.newFont("Assets/Fonts/Kaph-Regular.ttf", H*0.02)

function love.resize(W, H)
	GUI.KaphFont = love.graphics.newFont("Assets/Fonts/Kaph-Regular.ttf", H*0.030)
	GUI.TitleKaphFont = love.graphics.newFont("Assets/Fonts/Kaph-Regular.ttf", H*0.05)
	GUI.MiniKaphFont = love.graphics.newFont("Assets/Fonts/Kaph-Regular.ttf", H*0.02)
end






--------------------------
--------------------------
--------------------------
--------------------------



local function _GUI_Image(Texture, ScreenX, ScreenY, OnScreenSize)
	
	local TW = Texture:getWidth()
	local TH = Texture:getHeight()
	local SX = (SW * OnScreenSize) / TW
	local STW = TW * SX
	love.graphics.draw(Texture, (SW*ScreenX)-(STW/2), (SH*ScreenY)-(STW/2), 0, SX, SX)

end




-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------

SW = love.graphics.getWidth()
SH = love.graphics.getHeight()
local NavButtonRefreshed = true
GUI.Update = function(dt)
	
	if love.keyboard.isDown("tab") then
		if NavButtonRefreshed then
			GUI.MenuNavOpen = not GUI.MenuNavOpen	
		end
		NavButtonRefreshed = false
	else
		NavButtonRefreshed = true
	end

	SW = love.graphics.getWidth()
	SH = love.graphics.getHeight()
	W = SW
	H = SH
	

end





local DefaultFont = love.graphics.newFont()
GUI.Draw = function()
	
	--love.graphics.setDefaultFilter("nearest", "nearest", 8)
	love.graphics.setFont(GUI.KaphFont)
	
	GUI.HUD()

	if GUI.MenuNavOpen then
	
		GUI.MenuNav()
		
		if GUI.InventoryOpen then
			GUI.Inventory()
		elseif GUI.CraftingOpen then
			GUI.Crafting()
		elseif GUI.StatScreenOpen then
			GUI.Skills()
		elseif GUI.ClassScreenOpen then
			GUI.Classes()
		end
		
	end
	
	love.graphics.setFont(DefaultFont)

end




local Bubble = love.graphics.newImage("Assets/GUI/Bubble.png")
local ItemContainer = love.graphics.newImage("Assets/GUI/Item Container.png")
local ItemCursor = love.graphics.newImage("Assets/GUI/Item Cursor.png")
local AdjustTime = 1
local OldHealth = 0
local OldFood = 0
local OldCoins = 0
local OldXP = 0
local SwapItemRefreshed = true
local ItemNameHintTimer = 0
local ItemNameHintTimerMax = 4
GUI.HUD = function()
	
	
	
	if love.keyboard.isDown("r") then
		if SwapItemRefreshed then
			Player.SelectedItem = Player.SelectedItem + 1
			ItemNameHintTimer = ItemNameHintTimerMax
			if Player.SelectedItem > 8 then
				Player.SelectedItem = 1
			end
		end
		SwapItemRefreshed = false
	else
		SwapItemRefreshed = true
	end

	
	
	
	love.graphics.push()
	
	local InterpolationTime = _GlobalDT/AdjustTime
	
	if math.abs(OldHealth-Player.Health) > 0 then
		OldHealth = OldHealth + ((1+(Player.Health - OldHealth)) * _GlobalDT)
		if math.abs(OldHealth-Player.Health) < 1 then
			OldHealth = Player.Health
		end
	end
	
	OldFood = math.round(lerp(OldHealth, Player.Health, InterpolationTime))
	OldCoins = math.round(lerp(OldHealth, Player.Health, InterpolationTime))
	OldXP = math.round(lerp(OldHealth, Player.Health, InterpolationTime))
	

	local HPString = "HP: "..math.round(Player.Health).."/"..Player.MaxHealth
	local FoodString = "Food: "..math.round(Player.Food).."/"..Player.FoodMax
	local CoinsString = "Coins: "..Player.Coins
	local XPString = "XP: "..Player.XP
	
	love.graphics.translate(-W*0.1, H*0.03)
	ScaledDraw(Bubble, W*0.145, -H*0.013, W*0.22)
	love.graphics.setColor255(255,96,96)
	love.graphics.printf(HPString, W*0.165, H*0.025, W*0.2, "left")
	love.graphics.setColor(1,1,1)
	
	love.graphics.translate(W*0.23, 0)
	ScaledDraw(Bubble, W*0.145, -H*0.013, W*0.22)
	love.graphics.setColor255(255,96,31)
	love.graphics.printf(FoodString, W*0.165, H*0.025, W*0.2, "left")
	love.graphics.setColor(1,1,1)
	
	love.graphics.translate(W*0.23, 0)
	ScaledDraw(Bubble, W*0.145, -H*0.013, W*0.22)
	love.graphics.setColor255(255,178,31)
	love.graphics.printf(CoinsString, W*0.165, H*0.025, W*0.2, "left")
	love.graphics.setColor(1,1,1)
	
	love.graphics.translate(W*0.23, 0)
	ScaledDraw(Bubble, W*0.145, -H*0.013, W*0.22)
	love.graphics.setColor255(162,33,255)
	love.graphics.printf(XPString, W*0.165, H*0.025, W*0.2, "left")
	love.graphics.setColor(1,1,1)
	
	
	if Waves.Timer <= Waves.WarningRange then
		love.graphics.setColor(1, 1, 1, 0.75 + (math.sin(_GlobalTimer * 3) / 4))
		love.graphics.print("Incoming Wave: "..math.ceil(Waves.Timer), 1000, 175)
		love.graphics.setColor(1, 1, 1, 1)
	end
	
	love.graphics.pop()
	

	-- Draw held inventory
	local XSpacing = W*0.055
	for i=8, 1, -1 do
		
		local ItemSize = W*0.06
		
		local DrawX = W*0.245+(i*XSpacing)
		local DrawY = H*0.89
		
		-- Draw item background
		ScaledDraw(ItemContainer, DrawX, DrawY, ItemSize)
		
		if Player.SelectedItem == i then
			ScaledDraw(ItemCursor, DrawX+W*0.002, DrawY-H*0.105, ItemSize)
		end
		
		
		
		if Player.HeldItems[i] ~= "" then
		
			ScaledDraw(Items.Types[Player.HeldItems[i]].Image, DrawX, DrawY, ItemSize)

			if Player.SelectedItem == i and ItemNameHintTimer > 0 then
				ItemNameHintTimer = ItemNameHintTimer - _GlobalDT
				love.graphics.printf(
					Player.HeldItems[i],  
					DrawX-W*0.07, H*0.76, W*0.2, "center"
				)
			end
		
		end
		
		
	end

	
	
end


local NavMenuImg = love.graphics.newImage("Assets/GUI/Menu Navigation.png")
GUI.MenuNav = function()
	
	ScaledDraw(NavMenuImg, W*0.82, H*0.2, W*0.15)
	
	love.graphics.setColor(0, 0, 0)
	
	love.graphics.setFont(GUI.KaphFont)
	
	love.graphics.print("-Nav Menu-", W*0.8355, H*0.225)
	
	love.graphics.setFont(GUI.MiniKaphFont)
	
	love.graphics.translate(0, -H*0.02)
	RenderClickableText("Inventory", W*0.84, W*0.955, H*0.3, H*0.36, function()
		GUI.InventoryOpen = true
		GUI.CraftingOpen = false
		GUI.StatScreenOpen = false
		GUI.ClassScreenOpen = false	
	end)
	RenderClickableText("Crafting", W*0.84, W*0.955, H*0.38, H*0.44, function()
		GUI.InventoryOpen = false
		GUI.CraftingOpen = true
		GUI.StatScreenOpen = false
		GUI.ClassScreenOpen = false	
	end)
	RenderClickableText("Stats", W*0.84, W*0.955, H*0.46, H*0.52, function()
		GUI.InventoryOpen = false
		GUI.CraftingOpen = false
		GUI.StatScreenOpen = true
		GUI.ClassScreenOpen = false	
	end)
	RenderClickableText("Classes", W*0.84, W*0.955, H*0.54, H*0.6, function()
		GUI.InventoryOpen = false
		GUI.CraftingOpen = false
		GUI.StatScreenOpen = false
		GUI.ClassScreenOpen = true	
	end)
	
	love.graphics.origin()
	
	love.graphics.setColor(1,1,1)

	
	

end


local MenuBackground = love.graphics.newImage("Assets/GUI/Menu Background.png")
local TestIcon = love.graphics.newImage("Assets/Items/Resource/Cement Brick.png")
local ItemPreview = love.graphics.newImage("Assets/GUI/Item Preview.png")
local ThrowAway = love.graphics.newImage("Assets/GUI/Throw Away.png")
local HeldItem = ""
local GrabbedInventorySlot = 0
local GrabbedHeldItemSlot = 0
local HoveredInventorySlot = nil
local HoveredHeldItemSlot = nil
local DropItemHovered = false
GUI.Inventory = function()
	
	ScaledDraw(MenuBackground, W*0.25, H*0.2, W*0.50)
	
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(GUI.TitleKaphFont)
	love.graphics.printf("Inventory", W*0.4, H*0.23, W*0.2, "center")
	love.graphics.setFont(GUI.KaphFont)
	love.graphics.setColor(1, 1, 1)
	
	
	HoveredInventorySlot = nil
	HoveredHeldItemSlot = nil
	DropItemHovered = false
	
	-- Draw inventory
	local XSpacing = W*0.028
	local YSpacing = H*0.05
	local XLimit = 8
	local HasSlot
	for i=(XLimit^2)-1, 0, -1 do
		
		if i > Player.InventorySize-1 then
			love.graphics.setColor(1, 1, 1, 0.04)
			HasSlot = false
		else
			love.graphics.setColor(1, 1, 1, 1)
			HasSlot = true
		end
		
		local X = i % XLimit
		local Y = math.floor(i / XLimit)
		
		local DrawX = W*0.26+(X*XSpacing)
		local DrawY = H*0.305+(Y*YSpacing)
		
		-- Draw item background
		ScaledDraw(ItemContainer, DrawX, DrawY, W*0.031)
		
		local ItemSize = W*0.031
		
	
		if HasSlot then
			
			-- Check for hover
			if CheckIfBoxIsHovered(DrawX, DrawX+ItemSize, DrawY, DrawY+ItemSize) then
				HoveredInventorySlot = i+1
			end
			
			-- Check for selection
			if Player.Inventory[i+1] ~= "" then
			
				ScaledDraw(Items.Types[Player.Inventory[i+1]].Image, DrawX, DrawY, ItemSize)
				
				if CheckIfBoxIsHovered(DrawX, DrawX+ItemSize, DrawY, DrawY+ItemSize) then
					if HeldItem == "" and love.mouse.isDown(1) then				
						HeldItem = Player.Inventory[i+1]	
						GrabbedInventorySlot = i+1
						GrabbedHeldItemSlot = nil
						Player.Inventory[i+1] = ""
					end
				end
				
				-- Draw stack count
				--love.graphics.setColor(0, 0, 0)
				--love.graphics.setFont(GUI.MiniKaphFont)
				--PrintOutlined(InventorySlot.Amount, DrawX+W*0.014, DrawY+H*0.03, W*0.0008, 1,1,1,1, 0,0,0,1)
				--love.graphics.setFont(GUI.KaphFont)
				
			end
		
		end
	
	end
	
	love.graphics.setColor(1, 1, 1, 1)
	
	
	
	-- Draw held inventory
	for i=8, 1, -1 do
		
		local ItemSize = W*0.031
		
		local DrawX = W*0.475+(i*XSpacing)
		local DrawY = H*0.655
		
		-- Draw item background
		ScaledDraw(ItemContainer, DrawX, DrawY, ItemSize)
		

		-- Check for hover
		if CheckIfBoxIsHovered(DrawX, DrawX+ItemSize, DrawY, DrawY+ItemSize) then
			HoveredHeldItemSlot = i
		end

		-- Check for selection
		if Player.HeldItems[i] ~= "" then
		
			ScaledDraw(Items.Types[Player.HeldItems[i]].Image, DrawX, DrawY, ItemSize)
			
			if CheckIfBoxIsHovered(DrawX, DrawX+ItemSize, DrawY, DrawY+ItemSize) then
				if HeldItem == "" and love.mouse.isDown(1) then
					HeldItem = Player.HeldItems[i]	
					GrabbedInventorySlot = nil
					GrabbedHeldItemSlot = i
					Player.HeldItems[i] = ""					
				end
			end		
		end
		
	end
	
	
	-- Draw hovered item
	love.graphics.setColor(0, 0, 0)
	
	love.graphics.setFont(GUI.KaphFont)
	love.graphics.printf("Cement Brick", W*0.52, H*0.31, W*0.2, "center")
	
	love.graphics.setFont(GUI.MiniKaphFont)
	love.graphics.printf("Concrete brick is a mixture of cement and aggregate, usually sand, formed in molds and cured. Certain mineral colours are added to produce a concrete brick resembling clay.", W*0.49, H*0.48, W*0.25, "center")
	love.graphics.setFont(GUI.KaphFont)
	
	love.graphics.setColor(1, 1, 1)	
	ScaledDraw(ItemPreview, W*0.59, H*0.355, W*0.06)
	ScaledDraw(TestIcon, W*0.595, H*0.365, W*0.05)
	
	
	-- Drop bin
	local DX = W*0.11
	local DY = H*0.21
	local DS = W*0.13
	ScaledDraw(ThrowAway, DX, DY, DS)
	love.graphics.printf("Drop", W*0.125, H*0.43, W*0.1, "center")
	if CheckIfBoxIsHovered(DX, DX+DS, DY, DY+DS) then
		DropItemHovered = true
	end
	
	
	if HeldItem ~= "" then
		
		if not love.mouse.isDown(1) then
			-- Check for drop on a new slot
			if HoveredInventorySlot ~= nil and HoveredInventorySlot ~= GrabbedInventorySlot then
				Player.Inventory[HoveredInventorySlot] = HeldItem
			elseif HoveredHeldItemSlot ~= nil and HoveredHeldItemSlot ~= GrabbedHeldItemSlot then
				Player.HeldItems[HoveredHeldItemSlot] = HeldItem
			elseif GrabbedInventorySlot ~= nil then
				if DropItemHovered then
					Items.Create(HeldItem, Player.x, Player.y, Player.z)
					Player.Inventory[GrabbedInventorySlot] = ""
				else
					Player.Inventory[GrabbedInventorySlot] = HeldItem
				end
			elseif GrabbedHeldItemSlot ~= nil then
				if DropItemHovered then
					Items.Create(HeldItem, Player.x, Player.y, Player.z)
					Player.HeldItems[GrabbedHeldItemSlot] = ""
				else
					Player.HeldItems[GrabbedHeldItemSlot] = HeldItem
				end
			end
			
			HeldItem = ""	
			
		else
			
			local Size = W*0.05
			ScaledDraw(
				Items.Types[HeldItem].Image, 
				love.mouse.getX()-(Size/2), 
				love.mouse.getY()-(Size/2), 
				Size
			)
		
		end
	
	end
	
	
end

GUI.Crafting = function()

	ScaledDraw(MenuBackground, W*0.25, H*0.2, W*0.50)
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(GUI.TitleKaphFont)
	love.graphics.printf("Crafting", W*0.4, H*0.23, W*0.2, "center")
	love.graphics.setFont(GUI.KaphFont)
	love.graphics.setColor(0.3, 0.3, 0.3)
	love.graphics.printf("- Chemistry bench -", W*0.35, H*0.29, W*0.3, "center")
	love.graphics.setFont(GUI.KaphFont)
	
	
	love.graphics.setColor(1, 1, 1)
	
	-- Draw recipes
	local RecipeCount = 14
	local XSpacing = W*0.028
	local YSpacing = H*0.05
	local XLimit = 8
	local HasSlot
	local Count = 0
	
	for y=0, 6 do
		for x=0, 7 do
		
			Count = Count + 1
			if Count > RecipeCount then
				love.graphics.setColor(1, 1, 1, 0.04)
			else
				love.graphics.setColor(1, 1, 1, 1)
			end
			
			
			local DrawX = W*0.26+(x*XSpacing)
			local DrawY = H*0.35+(y*YSpacing)
			
			-- Draw item background
			ScaledDraw(ItemContainer, DrawX, DrawY, W*0.031)
			
		end
	end
	
	love.graphics.setColor(0, 0, 0)
	love.graphics.printf("Oxygen Generator", W*0.47, H*0.35, W*0.3, "center")
	
	love.graphics.setFont(GUI.MiniKaphFont)
	love.graphics.printf("Oxygen generators create oxygen and hydrogen using water and electricity", W*0.49, H*0.55, W*0.25, "center")
	
	love.graphics.printf("8x Scrap Metal, 4x Electrical Components", W*0.49, H*0.64, W*0.25, "center")
	love.graphics.setFont(GUI.KaphFont)
	
	love.graphics.setColor(1, 1, 1, 1)
	ScaledDraw(TestIcon, W*0.57, H*0.38, W*0.1)	
	
	
	
end


local ToolTipColors = {}
ToolTipColors["Legendary"] = {r = 1, g = 1, b = 1}
local function GearTooltip(x, y)
	love.graphics.translate(H*0.0, W*0.02)
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(GUI.MiniKaphFont)
	love.graphics.printf("Killer Whipsnapper", W*0.3, H*0.28, W*0.4, "left")
	love.graphics.printf("Legendary", W*0.3, H*0.31, W*0.4, "left")
	love.graphics.printf("Sniper", W*0.4, H*0.31, W*0.4, "left")
	love.graphics.printf("Blood", W*0.4, H*0.34, W*0.4, "left")
	love.graphics.printf("Wind", W*0.3, H*0.34, W*0.4, "left")
	love.graphics.printf("Hit Damage: 123", W*0.3, H*0.367, W*0.4, "left")
	love.graphics.printf("Hit Speed: 0.8s", W*0.3, H*0.39, W*0.4, "left")
	love.graphics.printf("Speed: 1.4", W*0.3, H*0.415, W*0.4, "left")
	love.graphics.printf("Energy: 500", W*0.3, H*0.44, W*0.4, "left")
	love.graphics.printf("Cooldown: 2.3s", W*0.3, H*0.465, W*0.4, "left")
	--love.graphics.printf("Killer Whipsnapper", W*0.16, H*0.28, W*0.4, "center")
	--love.graphics.printf("Killer Whipsnapper", W*0.16, H*0.28, W*0.4, "center")
end
local CharTestImage = love.graphics.newImage("Assets/Celestials/Characters/Mario/Idle/1.png")
GUI.Skills = function()

	ScaledDraw(MenuBackground, W*0.25, H*0.2, W*0.50)
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(GUI.TitleKaphFont)
	love.graphics.printf("Stats", W*0.4, H*0.23, W*0.2, "center")
	love.graphics.setFont(GUI.KaphFont)
	love.graphics.setColor(0.3, 0.3, 0.3)
	love.graphics.printf("Mario", W*0.4, H*0.29, W*0.2, "center")
	
	love.graphics.setColor(1, 1, 1)
	ScaledDraw(ItemContainer, W*0.28, H*0.3, W*0.05)
	ScaledDraw(ItemContainer, W*0.28, H*0.4, W*0.05)
	ScaledDraw(ItemContainer, W*0.28, H*0.5, W*0.05)
	ScaledDraw(ItemContainer, W*0.665, H*0.3, W*0.05)
	ScaledDraw(ItemContainer, W*0.665, H*0.4, W*0.05)
	ScaledDraw(ItemContainer, W*0.665, H*0.5, W*0.05)
	
	ScaledDraw(ItemContainer, W*0.37, H*0.64, W*0.05)
	ScaledDraw(ItemContainer, W*0.44, H*0.64, W*0.05)
	ScaledDraw(ItemContainer, W*0.51, H*0.64, W*0.05)
	ScaledDraw(ItemContainer, W*0.58, H*0.64, W*0.05)
	
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(GUI.MiniKaphFont)
	love.graphics.print("HP 1332", W*0.38, H*0.55)
	love.graphics.print("Armor 10", W*0.55, H*0.55)
	love.graphics.print("Speed 1.5", W*0.55, H*0.58)
	love.graphics.print("Haste 24%", W*0.38, H*0.58)
	
	love.graphics.setColor(1, 1, 1)
	
	ScaledDraw(CharTestImage, W*0.463, H*0.35, W*0.07)





	--GearTooltip(W*0.28, H*0.3)

	love.graphics.setColor(1, 1, 1)
	
end

GUI.Classes = function()

	ScaledDraw(MenuBackground, W*0.25, H*0.2, W*0.50)
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(GUI.TitleKaphFont)
	love.graphics.printf("Classes", W*0.4, H*0.23, W*0.2, "center")
	love.graphics.setFont(GUI.KaphFont)
	love.graphics.setColor(1, 1, 1)
	
	local SkillCount = 0
	local XSpacing = W*0.028
	local YSpacing = H*0.05
	
	
	for Branch=0, 2 do		
		
		for x=0, 2 do
			for y=0, 6 do

				if y % 3 ~= 0 or x == 1 then
			
					local DrawX = W*0.305+(x*XSpacing)
					local DrawY = H*0.37+(y*YSpacing)
					
					love.graphics.setColor(0, 0, 0)
					love.graphics.setFont(GUI.MiniKaphFont)
					love.graphics.printf("Controller", W*0.25, H*0.315, W*0.2, "center")
					love.graphics.setColor(1, 1, 1)
					
					-- Draw item background
					ScaledDraw(ItemContainer, DrawX, DrawY, W*0.031)
				
				end			
				

			end
		end
		
		love.graphics.translate(W*0.15, 0)
		
	end
	
	
end


































return
GUI
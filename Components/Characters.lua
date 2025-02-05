
local Characters = {}

Characters.List = {}






local function NewCharacter(Name, Race, Health, Haste, Armor, Speed, JumpHeight)

	local RaceTable = Celestials.Races[Race]
	
	Characters.List[Name] = {
		Health = RaceTable.Health+Health,
		Haste = RaceTable.Haste+Haste,
		Armor = RaceTable.Armor+Armor,
		Speed = RaceTable.Speed+Speed,
		JumpHeight = RaceTable.JumpHeight+JumpHeight,
		MoveImage = nil,
		IdleImage = nil,
	}
	
	--local Files = love.filesystem.getDirectoryItems("Assets/Ce)
	--for k, file in ipairs(Files) do
		
	--end
	
	
	
end


NewCharacter("Mario", "Hume", 15, 0, 0, 0, 0.5)
































return
Characters
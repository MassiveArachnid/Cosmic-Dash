



local AutoSwap = {}






AutoSwap.Paths = {}
AutoSwap.LoadedModules = {}
AutoSwap.ModuleCopies = {}







local function tablecopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[tablecopy(orig_key)] = tablecopy(orig_value)
        end
        setmetatable(copy, tablecopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end



AutoSwap.Require = function(Path)
	
	local Module = require(Path)
	
	local FilePath = Path .. ".lua"
	
	print(Path)
	-- Add this module path to a list of paths so we can 
	-- check to see if the file has been modified after 'require'
	AutoSwap.Paths[Path] = love.filesystem.getInfo(FilePath).modtime
	
	-- Store a reference to the loaded module incase we need to modify it later
	AutoSwap.LoadedModules[Path] = Module
	
	-- Store a copy of the loaded module so we can compare any changes
	AutoSwap.ModuleCopies[Path] = tablecopy(Module)
	
return
Module
end






local CheckTimer = 0
local CheckInterval = 0.1
AutoSwap.Update = function(dt)

	CheckTimer = CheckTimer + dt
	
	if CheckTimer > CheckInterval then
		CheckTimer = 0
		
		local FileModTime
		for Path, OldModTime in pairs(AutoSwap.Paths) do
			
			local FilePath = Path .. ".lua"
			
			FileModTime = love.filesystem.getInfo(FilePath).modtime
			
			if FileModTime > OldModTime then
				
				print("Check ----------------------")
				
				AutoSwap.Paths[Path] = FileModTime
				
				-- Check for any differences in values between the 
				-- loaded module and the changed version of it
				local ChangedModule = dofile(love.filesystem.getSourceBaseDirectory().."/Game/"..Path..".lua")
				local HasChanges = false

				for Key, Val in pairs(ChangedModule) do
					if ChangedModule[Key] ~= AutoSwap.ModuleCopies[Path][Key] then
						HasChanges = true		
						print("Key:", Key, "CHANGED FROM", AutoSwap.LoadedModules[Path][Key], "TO", ChangedModule[Key])
						AutoSwap.LoadedModules[Path][Key] = ChangedModule[Key]
					end
				end
				print(serialize(ChangedModule))
				print("***AFTER")
				print(serialize(AutoSwap.ModuleCopies[Path]))				
				-- Store the changed file as a new copy
				if HasChanges then
					AutoSwap.ModuleCopies[Path] = tablecopy(ChangedModule)
				end
			end
		
		end
	
	end




end












return
AutoSwap
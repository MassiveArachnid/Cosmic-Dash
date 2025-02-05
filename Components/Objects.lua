






local Objects = {}


Objects.Types = {}
Objects.Names = {}






Objects.LoadObjectTypes = function()


	-----------------------------------------------------------------------------------------------------------------------------
	-- Load all objects types
	local files = love.filesystem.getDirectoryItems("Assets/Objects")

	for k, file in ipairs(files) do
	
		local Index, ObjectType = file:match("(.+)_(.+)")
		
		Index = tonumber(Index)
		
		local ObjectName = ObjectType:sub(1)
		
		print(file, Index, ObjectName)
		
		Objects.Types[Index] = require("Assets/Objects/"..Index.."_"..ObjectName.."/"..ObjectName)
		
		Objects.Types[Index].Image = love.graphics.newImage("Assets/Objects/"..Index.."_"..ObjectName.."/texture.png", {mipmaps = true})
		Objects.Types[Index].Image:setMipmapFilter("nearest", 1)
		
		Objects.Names[ObjectName] = Objects.Types[Index]
		Objects.Names[ObjectName].ID = Index

	end
	

end







-- Causes larger recalculation
Objects.Add = function(Region, Type, x, z)

	if Region.Objects[x] == nil then
		Region.Objects[x] = {}
	end
	Region.Objects[x][z] = {Type = Type}

end





-- Causes larger recalculation
Objects.Remove = function(Region, Type, x, y, z)


	Region.Objects[x][z] = nil


end





-- Causes small recalculation
Objects.SetFlags = function(x, z, Size, ShaderType)

	



end 




































return
Objects
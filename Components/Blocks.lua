















local Blocks = {}
Blocks.ArrayImage = nil
Blocks.TextureSize = 128
Blocks.Types = {}
Blocks.Names = {}
Blocks.UVs = {}






Blocks.CreateTextureAtlas = function()
	
	
	-----------------------------------------------------------------------------------------------------------------------------
	-- Load all block types
	
	local BlockImages = {}
	
	local files = love.filesystem.getDirectoryItems("Assets/Blocks")

	for k, file in ipairs(files) do
	
		local Index, BlockType = file:match("(.+)_(.+)")
		
		Index = tonumber(Index)
		
		local BlockName = BlockType:sub(1)
		
		print(file, Index, BlockName)

		local Index_Top = #BlockImages+1
		local Index_Side = #BlockImages+2
		
		Blocks.Types[Index] = {
			Name = BlockName,
			TopImageIndex = Index_Top,
			SideImageIndex = Index_Side,
		}
		Blocks.Names[BlockName] = {
			ID = Index,
			TopImageIndex = Index_Top,
			SideImageIndex = Index_Side,
		}
		
		BlockImages[Index_Top] = "Assets/Blocks/"..Index.."_"..BlockName.."/Top.png"
		BlockImages[Index_Side] = "Assets/Blocks/"..Index.."_"..BlockName.."/Side.png"
		
	end
	
	
	Blocks.ArrayImage = love.graphics.newArrayImage(BlockImages, {mipmaps = true})
	
end


















return
Blocks





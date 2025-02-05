
local Gases = {}









-- Gas zones are areas of the game world that will be filled with Gases.
-- When a vent adds gas to a block it will create a zone and expand out, using flood fill to find its way around.
-- Upon hitting another zone or a world level that contains gas, it will mix with any other gases it combined with.
-- The flood fill will only travel as far as the concentration of gas is visible. The amount of area that is diffusing 
-- with other gases will determine how large the flood fill will be. Additionally, gas zones should be able to overlap without issue.

Gases.CreateGasZone = function(x, y, z)

	local NewGasZone = {
		Blocks = {}, -- A table filled with block indexes that the zone is currently occupying
		Contents = {}, -- A table filled with the gases inside the zone and their concentrations
		Temperature = 75, -- Holds the current temperature of the gas zone
	}

end




























return
Gases
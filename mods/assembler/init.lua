assembler = {}
local mp = minetest.get_modpath("assembler")
dofile(mp.."/machine_base.lua")

local orig_func = technic.get_recipe
technic.get_recipe = function(typename, items)
	if typename == "4x4assemble" then
		local result, new_input = minetest.get_craft_result({
			method = "normal",
			width = 4,
			items = items})
		-- Compatibility layer
		if not result or not result.item or result.item:is_empty() then
			return nil
		else
			return {time = 1,
			        new_input = new_input.items,
			        output = result.item}
		end
	end
	if typename == "5x5assemble" then
		local result, new_input = minetest.get_craft_result({
			method = "normal",
			width = 5,
			items = items})
		-- Compatibility layer
		if not result or not result.item or result.item:is_empty() then
			return nil
		else
			return {time = 1,
			        new_input = new_input.items,
			        output = result.item}
		end
	end
	return orig_func(typename, items)
end

technic.register_recipe_type("4x4assemble", {description = "4x4 Assembly" })
assembler.register_base_machine({
	typename = "4x4assemble",
	size = 4,
	machine_name = "assembler",
	machine_desc = "LV Assembler",
	tier = "LV",
	demand = {200},
	speed = 1,
})
technic.register_recipe_type("5x5assemble", {description = "5x5 Assembly" })
assembler.register_base_machine({
	typename = "5x5assemble",
	size = 5,
	machine_name = "assembler",
	machine_desc = "MV Assembler",
	tier = "MV",
	demand = {400},
	speed = 1,
})
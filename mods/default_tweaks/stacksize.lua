local bigstacktbl = {["spriteguns:bullet_12"] = 32, ["spriteguns:bullet_45"] = 64, ["spriteguns:bullet_762"] = 45,
	["currency:minegeld"] = 10000, ["currency:minegeld_5"] = 2000, ["currency:minegeld_10"] = 1000}
minetest.register_on_mods_loaded(function()
	for itemname, def in pairs(minetest.registered_items) do
		if bigstacktbl[itemname] then
			minetest.override_item(itemname, {stack_max = bigstacktbl[itemname], _bigstack = true})
		elseif not minetest.registered_tools[itemname] and (not def.stack_max or (def.stack_max > 32 and not def._bigstack)) then
			minetest.override_item(itemname, {stack_max = 32})
		end
	end
end)
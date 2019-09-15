if not minetest.get_modpath("ctf_crafting") then
	-- Regular Grenade
	local coal = "default:coal_lump"
	local fragmentation = "default:steel_ingot"
	if minetest.get_modpath("technic") then
		coal = "technic:coal_dust"
		fragmentation = "technic:lead_dust"
	end
	minetest.register_craft({
		type = "shaped",
		output = "grenades_basic:frag",
		recipe = {
			{"default:steel_ingot", "tnt:gunpowder", "default:steel_ingot"},
			{"technic:lead_dust", "tnt:gunpowder", "technic:lead_dust"},
			{"default:steel_ingot", "tnt:gunpowder", "default:steel_ingot"}
		},
	})

	-- Smoke Grenade

	minetest.register_craft({
		type = "shaped",
		output = "grenades_basic:smoke",
		recipe = {
			{"dye:white", "dye:white", "dye:white"},
			{"default:steel_ingot", coal, "default:steel_ingot"},
			{"default:steel_ingot", "tnt:gunpowder", "default:steel_ingot"}
		}
	})

	--Flashbang Grenade

	minetest.register_craft({
		type = "shaped",
		output = "grenades_basic:flashbang",
		recipe = {
			{"default:steel_ingot", "tnt:gunpowder", "default:steel_ingot"},
			{coal, "tnt:gunpowder", coal},
			{"default:steel_ingot", "tnt:gunpowder", "default:steel_ingot"}
		},
	})

	-- Other

	--[[minetest.register_craftitem("grenades_basic:gun_powder", {
		description = "A dark powder used for crafting some grenades",
		inventory_image = "grenades_gun_powder.png"
	})

	minetest.register_craft({
		type = "shapeless",
		output = "grenades_basic:gun_powder",
		recipe = {"default:coal_lump", "default:coal_lump", "default:coal_lump", "default:coal_lump"},
	})--]]
else
	crafting.register_recipe({
		type   = "inv",
		output = "grenades_basic:regular 1",
		items  = { "default:steel_ingot 5", "default:iron_lump" },
		always_known = true,
		level  = 1,
	})

	crafting.register_recipe({
		type   = "inv",
		output = "grenades_basic:smoke 1",
		items  = { "default:steel_ingot 5", "default:coal_lump 4" },
		always_known = true,
		level  = 1,
	})

	crafting.register_recipe({
		type   = "inv",
		output = "grenades_basic:flashbang 1",
		items  = { "default:steel_ingot 5", "default:torch 5" },
		always_known = true,
		level  = 1,
	})
end

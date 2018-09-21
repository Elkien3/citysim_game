-- opium poppy seeds

minetest.register_node("drug_wars:seed_opiumpoppy", {
	description = "Opium Poppy Seed",
	tiles = {"drugwars_opiumpoppy_seed.png"},
	inventory_image = "drugwars_opiumpoppy_seed.png",
	wield_image = "drugwars_opiumpoppy_seed.png",
	drawtype = "signlike",
	groups = {seed = 1, snappy = 3, attached_node = 1},
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	sunlight_propagates = true,
	selection_box = farming.select,
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "drug_wars:opiumpoppy_1")
	end,
})

for i = 4, 5 do
    local node_name = "default:grass_" .. i

    drug_wars.add_node_drops(node_name, {items = {'drug_wars:seed_opiumpoppy'}, rarity = 50});
end

-- opium poppy drops

minetest.register_craftitem("drug_wars:raw_opium", {
	description = "Raw Opium",
	inventory_image = "drugwars_raw_opium.png",
})

minetest.register_craftitem("drug_wars:poppy_petal", {
	description = "Poppy Petal",
	inventory_image = "drugwars_poppy_petal.png",
})

-- opium refined items

minetest.register_craftitem("drug_wars:opium_ball", {
    description = "Opium Ball",
	inventory_image = "drugwars_opium_ball.png",
	max_stack = 25,
    on_smoke_woodenpipe = function(player)
		if player ~= nil then
			local playername = player:get_player_name()
		    player:set_hp(player:get_hp() + drug_wars.OPIUM_HEAL)

			local speed_changed = drug_wars.speed_debuff(player, drug_wars.OPIUM_SPEED_DEBUFF, drug_wars.OPIUM_SPEED_DEBUFF_THRESHOLD)	
			
			drug_wars.defense_buff(playername, drug_wars.OPIUM_DEFENSE_BUFF)
			drug_wars.increase_addiction(playername, drug_wars.OPIUM_ADDICTION)

			table.insert(drug_wars.aftereffects, {
				countdown = drug_wars.OPIUM_DURATION,
				on_timeout = function() 
					if(speed_changed) then
						drug_wars.speed_buff(player, drug_wars.OPIUM_SPEED_DEBUFF)	
					end						
					drug_wars.drug_damage(player, drug_wars.OPIUM_HEAL)
					drug_wars.defense_buff(playername, -drug_wars.OPIUM_DEFENSE_BUFF)
				end
			})
		end
	end
})

-- craft usages

minetest.register_craft({
	output = "default:paper 2",
	recipe = {
		{"drug_wars:poppy_petal", "drug_wars:poppy_petal", "drug_wars:poppy_petal"},
		{"drug_wars:poppy_petal", "drug_wars:poppy_petal", "drug_wars:poppy_petal"},
		{"drug_wars:poppy_petal", "drug_wars:poppy_petal", "drug_wars:poppy_petal"}
	}
})

minetest.register_craft({
	output = "drug_wars:opium_ball",
	recipe = {
        {"", "drug_wars:raw_opium", ""},
        {"drug_wars:raw_opium", "drug_wars:raw_opium", "drug_wars:raw_opium"},
        {"", "drug_wars:raw_opium", ""},
    }
})

-- plant nodes definition

local crop_def = {
	drawtype = "plantlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	drop = "",
	selection_box = farming.select,
	groups = {
		snappy = 3, flammable = 2, plant = 1, attached_node = 1,
		not_in_creative_inventory = 1, growing = 1
	},
	sounds = default.node_sound_leaves_defaults()
}

for i = 1,5 do
	crop_def.tiles = {"drugwars_opiumpoppy_"..i..".png"}
	crop_def.visual_scale = 0.7 + i / 10.0
	minetest.register_node("drug_wars:opiumpoppy_"..i, table.copy(crop_def))
end

crop_def.drop = {
	items = {
		{items = {'drug_wars:raw_opium'}, rarity = 5},
		{items = {'drug_wars:seed_opiumpoppy'}, rarity = 1}
	}
}

crop_def.tiles = {"drugwars_opiumpoppy_6.png"}
crop_def.visual_scale = 0.7 + 6 / 10.0
minetest.register_node("drug_wars:opiumpoppy_6", table.copy(crop_def))

crop_def.drop = {
	items = {
        {items = {'drug_wars:raw_opium'}, rarity = 2},
        {items = {'drug_wars:poppy_petal'}, rarity = 2},
		{items = {'drug_wars:seed_opiumpoppy'}, rarity = 1}
	}
}

crop_def.tiles = {"drugwars_opiumpoppy_7.png"}
crop_def.visual_scale = 0.7 + 7 / 10.0
minetest.register_node("drug_wars:opiumpoppy_7", table.copy(crop_def))

crop_def.drop = {
	items = {
        {items = {'drug_wars:raw_opium'}, rarity = 10},
        {items = {'drug_wars:poppy_petal'}, rarity = 1},
		{items = {'drug_wars:seed_opiumpoppy'}, rarity = 1}
	}
}

crop_def.tiles = {"drugwars_opiumpoppy_8.png"}
crop_def.visual_scale = 0.7 + 8 / 10.0
minetest.register_node("drug_wars:opiumpoppy_8", table.copy(crop_def))


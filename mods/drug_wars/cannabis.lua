-- cannabis seeds
minetest.register_node("drug_wars:seed_cannabis", {
	description = "Cannabis Seed",
	tiles = {"drugwars_cannabis_seed.png"},
	inventory_image = "drugwars_cannabis_seed.png",
	wield_image = "drugwars_cannabis_seed.png",
	drawtype = "signlike",
	groups = {seed = 1, snappy = 3, attached_node = 1},
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	sunlight_propagates = true,
	selection_box = farming.select,
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "drug_wars:cannabis_1")
	end,
})

for i = 4, 5 do
    local node_name = "default:grass_" .. i

    drug_wars.add_node_drops(node_name, {items = {'drug_wars:seed_cannabis'}, rarity = 35});
end

-- cannabis drops
minetest.register_craftitem("drug_wars:cannabis_leaf", {
	description = "Cannabis Leaf",
	inventory_image = "drugwars_cannabis_leaf.png",
})

minetest.register_craftitem("drug_wars:cannabis_inflorescence", {
	description = "Cannabis Inflorescence",
	inventory_image = "drugwars_cannabis_inflorescence.png",
})

minetest.register_craftitem("drug_wars:cannabis_resin", {
	description = "Cannabis Resin",
	inventory_image = "drugwars_cannabis_resin.png",
})

-- cannabis refined items

minetest.register_craftitem("drug_wars:weed", {
	description = "Weed",
	inventory_image = "drugwars_weed.png",
	stack_max = 20,
	on_smoke_woodenpipe = function(player)
		if player ~= nil then
			local playername = player:get_player_name()
			local newhunger = hbhunger.hunger[playername] - drug_wars.WEED_HUNGER_DEBUFF 

			if(newhunger < 0) then 
				newhunger = 0
				drug_wars.drug_damage(player, drug_wars.WEED_HEAL)
			else 
				hbhunger.hunger[playername] = newhunger
				player:set_hp(player:get_hp() + drug_wars.WEED_HEAL)
			end

			local speed_changed = drug_wars.speed_debuff(player, drug_wars.WEED_SPEED_DEBUFF, drug_wars.WEED_SPEED_DEBUFF_THRESHOLD)	
			
			drug_wars.defense_buff(playername, drug_wars.WEED_DEFENSE_BUFF)

			drug_wars.increase_addiction(playername, drug_wars.WEED_ADDICTION)

			table.insert(drug_wars.aftereffects, {
				countdown = drug_wars.WEED_DURATION,
				on_timeout = function() 
					if(speed_changed) then
						drug_wars.speed_buff(player, drug_wars.WEED_SPEED_DEBUFF)	
					end

					if(drug_wars.get_addiction(playername) > drug_wars.WEED_ADDICTION_THRESHOLD) then							
						drug_wars.drug_damage(player, drug_wars.WEED_HEAL)
					end

					drug_wars.defense_buff(playername, -drug_wars.WEED_DEFENSE_BUFF)
				end
			})
		end
	end
})

minetest.register_craftitem("drug_wars:hashish", {
	description = "Hashish",
	inventory_image = "drugwars_hashish.png",
	stack_max = 20,
	on_smoke_woodenpipe = function(player)
		if player ~= nil then
			local playername = player:get_player_name()
			local newhunger = hbhunger.hunger[playername] - drug_wars.HASHISH_HUNGER_DEBUFF 

			if(newhunger < 0) then 
				newhunger = 0
				drug_wars.drug_damage(player, drug_wars.HASHISH_HEAL)
			else 
				hbhunger.hunger[playername] = newhunger
				player:set_hp(player:get_hp() + drug_wars.HASHISH_HEAL)
			end

			local speed_changed = drug_wars.speed_debuff(player, drug_wars.HASHISH_SPEED_DEBUFF, drug_wars.HASHISH_SPEED_DEBUFF_THRESHOLD)	
			
			drug_wars.defense_buff(playername, drug_wars.HASHISH_DEFENSE_BUFF)

			drug_wars.increase_addiction(playername, drug_wars.HASHISH_ADDICTION)

			table.insert(drug_wars.aftereffects, {
				countdown = drug_wars.HASHISH_DURATION,
				on_timeout = function() 
					if(speed_changed) then
						drug_wars.speed_buff(player, drug_wars.HASHISH_SPEED_DEBUFF)	
					end

					if(drug_wars.get_addiction(playername) > drug_wars.HASHISH_ADDICTION_THRESHOLD) then							
						drug_wars.drug_damage(player, drug_wars.HASHISH_HEAL)
					end

					drug_wars.defense_buff(playername, -drug_wars.HASHISH_DEFENSE_BUFF)
				end
			})
		end
	end
})

-- craft usages

minetest.register_craft({
	output = "farming:cotton",
	recipe = {
		{"drug_wars:cannabis_leaf", "drug_wars:cannabis_leaf"},
		{"drug_wars:cannabis_leaf", "drug_wars:cannabis_leaf"}
	}
})

minetest.register_craft({
	output = "drug_wars:weed",
	recipe = {{"drug_wars:cannabis_inflorescence", "drug_wars:cannabis_inflorescence"}}
})

minetest.register_craft({
	output = "drug_wars:hashish",
	recipe = {{"drug_wars:cannabis_resin", "drug_wars:cannabis_resin", "drug_wars:cannabis_resin"}}
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

-- plant stages 

for i = 1,5 do
	crop_def.tiles = {"drugwars_cannabis_"..i..".png"}
	crop_def.visual_scale = 0.9 + i / 10.0
	minetest.register_node("drug_wars:cannabis_"..i, table.copy(crop_def))
end

crop_def.drop = {
	items = {
		{items = {'drug_wars:cannabis_inflorescence'}, rarity = 3},
		{items = {'drug_wars:seed_cannabis'}, rarity = 1}
	}
}

for i = 6,7 do
	crop_def.tiles = {"drugwars_cannabis_"..i..".png"}
	crop_def.visual_scale = 0.9 + i / 10.0
	minetest.register_node("drug_wars:cannabis_"..i, table.copy(crop_def))
end

crop_def.tiles = {"drugwars_cannabis_8.png"}
crop_def.visual_scale = 2.0
crop_def.drop = {
	items = {
		{items = {'drug_wars:cannabis_leaf 2'}, rarity = 1},
		{items = {'drug_wars:cannabis_inflorescence'}, rarity = 1},
		{items = {'drug_wars:cannabis_inflorescence'}, rarity = 3},
		{items = {'drug_wars:cannabis_resin'}, rarity = 4},
		{items = {'drug_wars:seed_cannabis'}, rarity = 1},
		{items = {'drug_wars:seed_cannabis'}, rarity = 2},
	}
}
minetest.register_node("drug_wars:cannabis_8", table.copy(crop_def))


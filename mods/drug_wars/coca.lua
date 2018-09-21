-- coca seeds
minetest.register_node("drug_wars:seed_coca", {
	description = "Coca Seed",
	tiles = {"drugwars_coca_seed.png"},
	inventory_image = "drugwars_coca_seed.png",
	wield_image = "drugwars_coca_seed.png",
	drawtype = "signlike",
	groups = {seed = 1, snappy = 3, attached_node = 1},
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	sunlight_propagates = true,
	selection_box = farming.select,
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "drug_wars:coca_1")
	end,
})

for i = 4, 5 do
    local node_name = "default:grass_" .. i

    drug_wars.add_node_drops(node_name, {items = {'drug_wars:seed_coca'}, rarity = 45});
end

-- coca drops
minetest.register_craftitem("drug_wars:coca_leaf", {
	description = "Coca Leaf",
	inventory_image = "drugwars_coca_leaf.png",
})


-- coca refined items

minetest.register_craftitem("drug_wars:cocaine", {
    description = "Cocaine",
	inventory_image = "drugwars_cocaine.png",
	max_stack = 20,
    on_use = function(itemstack, player, pointed_thing)
        local playername = player:get_player_name()
        local newhunger = hbhunger.hunger[playername] + drug_wars.COCAINE_HUNGER_BUFF 
        
        if(newhunger <= 30) then
            hbhunger.hunger[playername] = newhunger
        else 
            hbhunger.hunger[playername] = 30
        end

		drug_wars.speed_buff(player, drug_wars.COCAINE_SPEED_BUFF)
		drug_wars.damage_buff(playername, drug_wars.COCAINE_DAMAGE_BUFF)
        drug_wars.increase_addiction(playername, drug_wars.COCAINE_ADDICTION)
        
        table.insert(drug_wars.aftereffects, {
            countdown = drug_wars.COCAINE_DURATION * (1.0 - drug_wars.addictions[playername]),
            on_timeout = function()                
                drug_wars.speed_debuff(player, drug_wars.COCAINE_SPEED_BUFF, drug_wars.COCAINE_SPEED_BUFF)
				drug_wars.damage_buff(playername, -drug_wars.COCAINE_DAMAGE_BUFF)
                drug_wars.drug_damage(player, drug_wars.COCAINE_DAMAGE)
            end
        })

        return itemstack:get_name() .. " " .. (itemstack:get_count() - 1)
    end
})

minetest.register_craftitem("drug_wars:crack", {
	description = "Crack",
	inventory_image = "drugwars_crack.png",
	max_stack = 30,
	on_smoke_glasspipe = function(player)
        local playername = player:get_player_name()
        local newhunger = hbhunger.hunger[playername] + drug_wars.CRACK_HUNGER_BUFF 
        
        if(newhunger <= 30) then
            hbhunger.hunger[playername] = newhunger
        else 
            hbhunger.hunger[playername] = 30
        end

		drug_wars.speed_buff(player, drug_wars.CRACK_SPEED_BUFF)
		drug_wars.damage_buff(playername, drug_wars.CRACK_DAMAGE_BUFF)
        drug_wars.increase_addiction(playername, drug_wars.CRACK_ADDICTION)
        
        table.insert(drug_wars.aftereffects, {
            countdown = drug_wars.CRACK_DURATION * (1.0 - drug_wars.addictions[playername]),
            on_timeout = function()                
                drug_wars.speed_debuff(player, drug_wars.CRACK_SPEED_BUFF, drug_wars.CRACK_SPEED_BUFF)
				drug_wars.damage_buff(playername, -drug_wars.CRACK_DAMAGE_BUFF)
                drug_wars.drug_damage(player, drug_wars.CRACK_DAMAGE)
            end
        })
	end
})

-- craft usages

minetest.register_craft({
	output = "drug_wars:cocaine",
	recipe = {
		{"drug_wars:coca_leaf", "drug_wars:coca_leaf", "drug_wars:coca_leaf"},
		{"drug_wars:coca_leaf", "drug_wars:coca_leaf", "drug_wars:coca_leaf"}
	}
})

minetest.register_craft({
	type = "cooking",
	output = "drug_wars:crack 2",
	recipe = "drug_wars:cocaine",
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

for i = 1,6 do
	crop_def.tiles = {"drugwars_coca_"..i..".png"}
	minetest.register_node("drug_wars:coca_"..i, table.copy(crop_def))
end

crop_def.tiles = {"drugwars_coca_7.png"}
crop_def.visual_scale = 1.1
crop_def.drop = {
	items = {
		{items = {'drug_wars:coca_leaf 1'}, rarity = 1},
		{items = {'drug_wars:seed_coca'}, rarity = 1},
		{items = {'drug_wars:seed_coca'}, rarity = 2},
	}
}
minetest.register_node("drug_wars:coca_7", table.copy(crop_def))

crop_def.tiles = {"drugwars_coca_8.png"}
crop_def.visual_scale = 1.2
crop_def.drop = {
	items = {
		{items = {'drug_wars:coca_leaf 2'}, rarity = 1},
		{items = {'drug_wars:seed_coca'}, rarity = 1},
		{items = {'drug_wars:seed_coca'}, rarity = 2},
	}
}
minetest.register_node("drug_wars:coca_8", table.copy(crop_def))
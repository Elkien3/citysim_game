local modpath, S = ...

--Pet Hairbrush
minetest.register_craftitem("petz:hairbrush", {
	description = S("Hairbrush"),
	inventory_image = "petz_hairbrush.png",
	wield_image = "petz_hairbrush.png"
})

minetest.register_craft({
	type = "shaped",
	output = "petz:hairbrush",
	recipe = {
		{"", "", ""},
		{"", "default:stick", "farming:string"},
		{"default:stick", "", ""},
	}
})

--Pet Bowl
minetest.register_node("petz:pet_bowl", {
    description = S("Pet Bowl"),
    inventory_image = "petz_pet_bowl_inv.png",
    wield_image = "petz_pet_bowl_inv.png",
    tiles = {"petz_pet_bowl.png"},
    groups = {snappy=1, bendy=2, cracky=1, feeder=1},
    sounds = default.node_sound_stone_defaults(),
    paramtype = "light",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.1875, -0.5, -0.1875, 0.1875, -0.4375, 0.1875}, -- bottom
            {-0.1875, -0.4375, -0.1875, 0.1875, -0.375, -0.125}, -- front
            {-0.1875, -0.4375, 0.125, 0.1875, -0.375, 0.1875}, -- back
            {-0.1875, -0.4375, -0.125, -0.125, -0.375, 0.125}, -- left
            {0.125, -0.4375, -0.125, 0.1875, -0.375, 0.125}, -- right
            },
        },
})

minetest.register_craft({
    type = "shaped",
    output = 'petz:pet_bowl',
    recipe = {
        {'group:wood', '', 'group:wood'},
        {'group:wood', 'group:wood', 'group:wood'},
        {'', 'dye:red', ''},
    }
})
local settings = petz.settings["petz_list"]
--Beaver Oil
if settings.beaver then

minetest.register_craftitem("petz:beaver_oil", {
    description = S("Beaver Oil"),
    inventory_image = "petz_beaver_oil.png",
    wield_image = "petz_beaver_oil.png"
})

minetest.register_craft({
    type = "shaped",
    output = "petz:beaver_oil",
    recipe = {
        {"", "", ""},
        {"", "petz:beaver_fur", ""},
        {"", "vessels:glass_bottle", ""},
    }
})

minetest.register_node("petz:beaver_dam_branches", {
    description = S("Beaver Dam Branches"),
    drawtype = "allfaces_optional",
    paramtype = "light",
    walkable = true,
    tiles = {"petz_beaver_dam_branches.png"},
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
    sounds = default.node_sound_wood_defaults(),
})

end
--Whip

minetest.register_craftitem("petz:whip", {
    description = S("Whip"),
    inventory_image = "petz_whip.png",
    wield_image = "petz_whip.png",
    after_use = function(itemstack, user, node, digparams)
        mokapi.make_sound("player", user, "petz_whip", petz.settings.max_hear_distance)
    end,
})

minetest.register_craft({
    type = "shaped",
    output = "petz:whip",
    recipe = {
        {'', '', 'farming:string'},
        {'', 'farming:string', 'dye:brown'},
        {'default:stick', '', ''},
    }
})

--Bucket Milk
minetest.register_craftitem("petz:bucket_milk", {
    description = S("Milk Bucket"),
    stack_max = 1,
    wield_image = "petz_bucket_milk.png",
    inventory_image = "petz_bucket_milk.png",
    groups = {milk_bucket = 1, food = 3, food_milk = 1},
    on_use = function (itemstack, user, pointed_thing)
        return minetest.do_item_eat(3, "bucket:bucket_empty", itemstack, user, pointed_thing)
    end,
})

--minetest.register_alias("petz:bucket_milk", "mobs:bucket_milk")
if settings.turtle then
--Turtle Shell
minetest.register_craftitem("petz:turtle_shell", {
    description = S("Turtle Shell"),
    wield_image = "petz_turtle_shell.png",
    inventory_image = "petz_turtle_shell.png",
    groups = {},
})
end
minetest.register_craftitem("petz:leather", {
    description = S("Leather"),
    inventory_image = "petz_leather.png",
    wield_image = "petz_leather.png",
    groups = {leather = 1, flammable = 2}
})
if settings.beaver then
minetest.register_craftitem("petz:beaver_fur", {
    description = S("Beaver Fur"),
    inventory_image = "petz_beaver_fur.png",
    wield_image = "petz_beaver_fur.png"
})
end
minetest.register_craftitem("petz:ducky_feather", {
    description = S("Feather"),
    inventory_image = "petz_ducky_feather.png",
    wield_image = "petz_ducky_feather.png",
    groups = {feather = 1},
})

-- Wolf Drops

minetest.register_craftitem("petz:wolf_jaw", {
	description = S("Wolf Jaw"),
	inventory_image = "petz_wolf_jaw.png",
})

minetest.register_craftitem("petz:wolf_fur", {
	description = S("Wolf Fur"),
	inventory_image = "petz_wolf_fur.png",
})

--Material for Lion's Cage

minetest.register_node("petz:gray_paving_stone", {
    description = S("Gray Paving Stone"),
    tiles = {"petz_gray_paving_stone.png"},
    is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

---
---Fishtank
---

local function remove_fish(pos)
	local objs = minetest.get_objects_inside_radius(pos, 0.5)
	if not objs then
		return
	end
	for _, obj in pairs(objs) do
		if obj and obj:get_luaentity() and obj:get_luaentity().groups and obj:get_luaentity().groups.fishtank then
			obj:remove()
			break
		end
	end
end

minetest.register_node("petz:fishtank", {
	description = S("Fish Tank"),
	drawtype = "glasslike_framed",
	tiles = {"petz_fishtank_top.png", "petz_fishtank_bottom.png"},
	special_tiles = {"petz_fishtank_bottom.png"},
	inventory_image = "petz_fishtank_inv.png",
	walkable = true,
	groups = {snappy = 2},
	paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
	param2 = 50,
	sunlight_propagates = true,
	use_texture_alpha = true,
	light_source = default.LIGHT_MAX - 1,
	sounds = default.node_sound_glass_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.25, -0.5, -0.25, 0.25, 0.4, 0.25 },
	},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local itemstack_name= itemstack:get_name()
		if itemstack:get_name():sub(1, 5) == "petz:" then
			itemstack_name= itemstack:get_name():sub(1, -5) --remove the "_set" part
		end
        local itemstack_group = minetest.get_item_group(itemstack_name, "spawn_egg")
        --minetest.chat_send_player("singleplayer", itemstack_name)
        local meta = minetest.get_meta(pos)
		local has_fish = meta:get_string("has_fish")
        if (itemstack_group >= 1) or (itemstack_name == "petz:clownfish" or itemstack_name == "petz:tropicalfish") then
			if has_fish == "false" then
				meta:set_string("has_fish", "true")
				meta:set_string("fish_type", itemstack_name)
				local fish_entity = minetest.add_entity({x=pos.x, y=pos.y, z=pos.z}, itemstack_name.."_entity_sprite")
				local itemstack_meta = itemstack:get_meta()
				fish_entity:set_properties({textures=itemstack_meta:get_string("textures").."^[transformFX"})
				fish_entity:set_sprite({x=0, y=0}, 16, 1.0, false)
				itemstack:take_item()
				clicker:set_wielded_item(itemstack)
				return itemstack
			end
		elseif ((itemstack_name == "mobs:net") or (itemstack_name == "fireflies:bug_net")) and (has_fish == "true") then
			local inv = clicker:get_inventory()
			local fish_type = meta:get_string("fish_type")
			if fish_type and inv:room_for_item("main", ItemStack(fish_type)) then
				inv:add_item("main", fish_type.."_set")
				remove_fish(pos)
				meta:set_string("has_fish", "false")
				meta:set_string("fish_texture", nil)
			end
		end
    end,
	after_place_node = function(pos, placer, itemstack)
		minetest.set_node(pos, {name = "petz:fishtank", param2 = 1})
		local meta = minetest.get_meta(pos)
		meta:set_string("has_fish", "false")
	end,
	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local has_fish = meta:get_string("has_fish")
		local fish_type = meta:get_string("fish_type")
		if fish_type and has_fish == "true" then
			remove_fish(pos)
			minetest.add_entity(pos, fish_type)
		end
	end
})

minetest.register_craft({
	type = "shaped",
	output = "petz:fishtank",
	recipe = {
		{"default:glass", "default:glass", "default:glass"},
		{"default:glass", "group:water_bucket", "default:glass"},
		{"default:glass", "default:glass", "default:glass"},
	},
	replacements = {{"group:water_bucket", "bucket:bucket_empty"}}
})

--Metal Syringe
--[[
minetest.register_craftitem("petz:glass_syringe", {
    description = S("Glass Syringe"),
    inventory_image = "petz_glass_syringe.png",
    wield_image = "petz_glass_syringe.png"
})

minetest.register_craftitem("petz:glass_syringe_sperm", {
    description = S("Glass Syringe with seed"),
    inventory_image = "petz_glass_syringe_sperm.png",
    wield_image = "petz_glass_syringe_sperm.png",
    stack_max = 1
})

minetest.register_craft({
    type = "shaped",
    output = "petz:glass_syringe",
    recipe = {
        {"", "", "vessels:glass_fragments"},
        {"", "vessels:glass_fragments", ""},
        {"default:steel_ingot", "", ""},
    }
})

--]]
if petz.settings.shears == "petz:shears" then -- Shears
	minetest.register_tool("petz:shears", {
		description = S("Shears"),
		inventory_image = "petz_shears.png",
		groups = {flammable = 2},
	})

	minetest.register_craft({
		type = "shaped",
		output = 'petz:shears',
		recipe = {
			{'', 'default:steel_ingot', ''},
			{'', 'group:stick', 'default:steel_ingot'},
		}
	})
end

if petz.settings.lasso == "petz:lasso" then
	-- Lasso
	minetest.register_tool("petz:lasso", {
		description = S("Lasso"),
		inventory_image = "petz_lasso.png",
		groups = {flammable = 2, lasso = 1},
	})

	minetest.register_craft({
		output = "petz:lasso",
		recipe = {
			{"farming:string", "farming:string", "farming:string"},
			{"farming:string", "", "farming:string"},
			{"", "farming:string", ""},
		}
	})
end

-- Saddle
if settings.pony then
minetest.register_craftitem("petz:saddle", {
	description = S("Saddle"),
	inventory_image = "petz_saddle.png",
	groups = {flammable = 2},
})

minetest.register_craft({
	type = "shaped",
	output = "petz:saddle",
	recipe = {
		{"petz:leather", "petz:leather", "petz:leather"},
		{"petz:leather", "default:steel_ingot", "petz:leather"},
		{"petz:leather", "default:steel_ingot", "petz:leather"},
	}
})

minetest.register_craftitem("petz:saddlebag", {
	description = S("Saddlebag"),
	inventory_image = "petz_saddlebag.png",
	groups = {flammable = 2},
})

minetest.register_craft({
	type = "shaped",
	output = "petz:saddlebag",
	recipe = {
		{"petz:leather", "petz:leather", "petz:leather"},
		{"petz:leather", "", "petz:leather"},
		{"petz:leather", "petz:leather", "petz:leather"},
	}
})
end
--Bone
minetest.register_craftitem("petz:bone", {
    description = S("Bone"),
    inventory_image = "petz_bone.png",
    wield_image = "petz_bone.png",
    groups = {bone = 1},
})

-- Elephant Tusk
if settings.elephant or settings.elephant_female then
minetest.register_craftitem("petz:elephant_tusk", {
	description = S("Elephant Tusk"),
	inventory_image = "petz_elephant_tusk.png",
	groups = {},
})
end
for i=1, 2 do
	if i == 1 then
		bottled_mob = "moth"
	else
		bottled_mob = "butterfly"
	end
	minetest.register_node("petz:bottle_"..bottled_mob, {
		description = S("Bottle with "..petz.first_to_upper(bottled_mob)),
		drawtype = "plantlike",
		tiles = {"petz_bottle_"..bottled_mob..".png"},
		inventory_image = "petz_bottle_"..bottled_mob.."_inv.png",
		stack_max = 1,
		drop = "",
		walkable = false,
		groups = {oddly_breakable_by_hand = 1},
		paramtype = "light",
		paramtype2 = "glasslikeliquidlevel",
		param2 = 50,
		sunlight_propagates = true,
		use_texture_alpha = true,
		light_source = default.LIGHT_MAX - 1,
		sounds = default.node_sound_glass_defaults(),
		selection_box = {
			type = "fixed",
			fixed = { -0.25, -0.5, -0.25, 0.25, 0.4, 0.25 },
		},
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local meta_itemstack = itemstack:get_meta()
			local meta = minetest.get_meta(pos)
			--meta = meta_itemstack
			local placer_name = ""
			if placer:is_player() then
				placer_name = placer:get_player_name()
			end
			meta:set_string("owner", placer_name)
			--minetest.chat_send_all("texture= "..tostring(meta_itemstack:get_int("petz:texture_no")))
			meta:set_int("petz:texture_no", meta_itemstack:get_int("petz:texture_no"))
		end,
		on_destruct = function(pos)
			local meta = minetest.get_meta(pos)
			local ent = minetest.add_entity(pos, "petz:"..bottled_mob, '{owner ='.. meta:get_string("owner")..', tamed = true}')
			local texture_no = meta:get_int("petz:texture_no")
			--minetest.chat_send_all("texture= "..tostring(meta:get_int("petz:texture_no")))
			if texture_no then
				local ent_ref = ent:get_luaentity()
				if texture_no == 0 then
					texture_no = math.random(1, #ent_ref.textures)
				end
				local props = {}
				props.textures = {ent_ref.textures[texture_no]}
				ent:set_properties(props)
			end
			--petz.after_tame(moth)
		end,
	})
end

--
--Honey Stuff
--
if settings.bee then
minetest.register_craftitem("petz:honey_bottle", {
	description = S("Honey Bottle"),
	inventory_image = "petz_honey_bottle.png",
	on_use = function (itemstack, user, pointed_thing)
        return minetest.do_item_eat(7, "vessels:glass_bottle", itemstack, user, pointed_thing)
    end,
})

minetest.register_craftitem("petz:honeycomb", {
	description = S("Honeycomb"),
	inventory_image = "petz_honeycomb.png",
})

minetest.register_craftitem("petz:pollen", {
	description = S("Pollen"),
	inventory_image = "petz_pollen.png",
})

minetest.register_craftitem("petz:bee_sting", {
	description = S("Bee Sting"),
	inventory_image = "petz_bee_sting.png",
})

minetest.register_craftitem("petz:beeswax", {
	description = S("Beeswax"),
	inventory_image = "petz_beeswax.png",
})

minetest.register_craft({
	type = "cooking",
	output = "petz:beeswax 3",
	recipe = "petz:honeycomb",
	cooktime = 1,
})

-- Candle from Wax and String/Cotton
minetest.register_node("petz:beeswax_candle", {
	description = S("Beeswax Candle"),
	drawtype = "plantlike",
	inventory_image = "petz_beeswax_candle_static.png",
	wield_image = "petz_beeswax_candle_static.png",
	visual_scale = 0.5,
	tiles = {
		{
			name = "petz_beeswax_candle.png",
			animation={
				type="vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1.0
			}
		},
	},
	paramtype = "light",
	light_source = 11,
	sunlight_propagates = true,
	walkable = false,
	groups = {dig_immediate = 3, attached_node = 1},
	sounds = default.node_sound_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0, 0.15 }
	},
})

minetest.register_craft({
	output = "petz:beeswax_candle 2",
	type = "shaped",
		recipe = {
		{"", "farming:string", ""},
		{"", "petz:beeswax", ""},
		{"", "petz:beeswax", ""},
	}
})
end
--Parchment

minetest.register_craftitem("petz:parchment", {
	description = S("Parchment"),
	inventory_image = "petz_parchment.png",
})

minetest.register_craft({
	type = "shaped",
	output = "petz:parchment",
	recipe = {
		{"", "", ""},
		{"", "", ""},
		{"petz:leather", "petz:leather", "petz:leather"},
	}
})

minetest.register_craft({
	type = "shaped",
	output = "default:book",
	recipe = {
		{"petz:parchment", "", ""},
		{"petz:parchment", "", ""},
		{"petz:parchment", "", ""},
	}
})

--Horseshoe
if settings.pony then
minetest.register_craftitem("petz:horseshoe", {
	description = S("Horseshoe"),
	inventory_image = "petz_horseshoe.png",
})

minetest.register_craft({
	type = "shaped",
	output = "petz:horseshoe",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "", "default:steel_ingot"},
	}
})

minetest.register_alias("petz:horseshoe", "mobs:horseshoe_steel")
end
--Spider Eye
if settings.tarantula then
minetest.register_craftitem("petz:spider_eye", {
	description = S("Spider Eye"),
	inventory_image = "petz_spider_eye.png",
})
end
--Leopard Drop
minetest.register_craftitem("petz:leopard_skin", {
	description = S("Leopard Skin"),
	inventory_image = "petz_leopard_skin.png",
})

minetest.register_craftitem("petz:snow_leopard_skin", {
	description = S("Snow Leopard Skin"),
	inventory_image = "petz_snow_leopard_skin.png",
})

--minetest.register_node("petz:squirrel_cage", {
	--description = S("Squirrel Cage"),
	--drawtype = "glasslike_framed",
	--tiles = {"petz_squirrel_cage.png", "petz_squirrel_cage.png"},
	--special_tiles = {"petz_squirrel_cage.png"},
	--inventory_image = "petz_squirrel_cage.png",
	--walkable = true,
	--groups = {snappy = 2},
	--paramtype = "light",
	--paramtype2 = "glasslikeliquidlevel",
	--param2 = 50,
	--sunlight_propagates = true,
	--use_texture_alpha = true,
	--light_source = default.LIGHT_MAX - 1,
	--sounds = default.node_sound_glass_defaults(),
	--selection_box = {
		--type = "fixed",
		--fixed = { -0.25, -0.5, -0.25, 0.25, 0.4, 0.25 },
	--},
--})

screwdriver = screwdriver or {}

function xdecor.register_pane(name, desc, def)
	xpanes.register_pane(name, {
		description = desc,
		tiles = {"xdecor_"..name..".png"},
		drawtype = "airlike",
		paramtype = "light",
		textures = {"xdecor_"..name..".png", "xdecor_"..name..".png", "xpanes_space.png"},
		inventory_image = "xdecor_"..name..".png",
		wield_image = "xdecor_"..name..".png",
		groups = def.groups,
		sounds = def.sounds or default.node_sound_defaults(),
		recipe = def.recipe
	})
end

xdecor.register_pane("bamboo_frame", "Bamboo Frame", {
	groups = {choppy=3, oddly_breakable_by_hand=2, pane=1, flammable=2},
	recipe = {{"default:papyrus", "default:papyrus", "default:papyrus"},
		  {"default:papyrus", "farming:cotton",  "default:papyrus"},
		  {"default:papyrus", "default:papyrus", "default:papyrus"}}
})
--[[
xdecor.register_pane("chainlink", "Chainlink", {
	groups = {cracky=3, oddly_breakable_by_hand=2, pane=1},
	recipe = {{"default:steel_ingot", "", "default:steel_ingot"},
		  {"", "default:steel_ingot", ""},
		  {"default:steel_ingot", "", "default:steel_ingot"}}
})
--]]
xdecor.register_pane("rusty_bar", "Rusty Iron Bars", {
	sounds = default.node_sound_stone_defaults(),
	groups = {cracky=2, pane=1},
	recipe = {{"", "default:dirt", ""},
		  {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		  {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}}
})

xdecor.register_pane("wood_frame", "Wood Frame", {
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy=2, pane=1, flammable=2},
	recipe = {{"group:wood", "group:stick", "group:wood"},
		  {"group:stick", "group:stick", "group:stick"},
		  {"group:wood", "group:stick", "group:wood"}}
})

xdecor.register("baricade", {
	description = "Baricade",
	drawtype = "plantlike",
	walkable = false,
	inventory_image = "xdecor_baricade.png",
	tiles = {"xdecor_baricade.png"},
	groups = {choppy=2, oddly_breakable_by_hand=1, flammable=2},
	damage_per_second = 4,
	selection_box = xdecor.nodebox.slab_y(0.3)
})

function xdecor.register_storage(name, desc, def)
	xdecor.register(name, {
		description = desc,
		inventory = {size=def.inv_size or 24},
		infotext = desc,
		tiles = def.tiles,
		node_box = def.node_box,
		on_rotate = def.on_rotate,
		on_place = def.on_place,
		groups = def.groups or {choppy=2, oddly_breakable_by_hand=1, flammable=2},
		sounds = default.node_sound_wood_defaults()
	})
end

xdecor.register_storage("barrel", "Barrel", {
	tiles = {"xdecor_barrel_top.png", "xdecor_barrel_sides.png"},
	on_place = minetest.rotate_node
})

xdecor.register_storage("cabinet", "Wooden Cabinet", {
	on_rotate = screwdriver.rotate_simple,
	tiles = {"xdecor_cabinet_sides.png", "xdecor_cabinet_sides.png",
		 "xdecor_cabinet_sides.png", "xdecor_cabinet_sides.png",
		 "xdecor_cabinet_sides.png", "xdecor_cabinet_front.png"}
})

xdecor.register_storage("cabinet_half", "Half Wooden Cabinet", {
	inv_size = 8,
	node_box = xdecor.nodebox.slab_y(0.5, 0.5),
	on_rotate = screwdriver.rotate_simple,
	tiles = {"xdecor_cabinet_sides.png", "xdecor_cabinet_sides.png",
		 "xdecor_half_cabinet_sides.png", "xdecor_half_cabinet_sides.png",
		 "xdecor_half_cabinet_sides.png", "xdecor_half_cabinet_front.png"}
})

xdecor.register_storage("empty_shelf", "Empty Shelf", {
	on_rotate = screwdriver.rotate_simple,
	tiles = {"default_wood.png", "default_wood.png^xdecor_empty_shelf.png"}
})

xdecor.register_storage("multishelf", "Multi Shelf", {
	on_rotate = screwdriver.rotate_simple,
	tiles = {"default_wood.png", "default_wood.png^xdecor_multishelf.png"},
})

xdecor.register("candle", {
	description = "Candle",
	light_source = 12,
	drawtype = "torchlike",
	inventory_image = "xdecor_candle_inv.png",
	wield_image = "xdecor_candle_wield.png",
	paramtype2 = "wallmounted",
	walkable = false,
	groups = {dig_immediate=3, attached_node=1},
	tiles = {{name = "xdecor_candle_floor.png",
			animation = {type="vertical_frames", length=1.5}},
		{name = "xdecor_candle_floor.png",
			animation = {type="vertical_frames", length=1.5}},
		{name = "xdecor_candle_wall.png",
			animation = {type="vertical_frames", length=1.5}}
	},
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.25, -0.5, -0.25, 0.25, 0.1, 0.25},
		wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.1, 0.25},
		wall_side = {-0.5, -0.35, -0.15, -0.15, 0.4, 0.15}
	}
})

xdecor.register("chair", {
	description = "Chair",
	tiles = {"default_wood.png"},
	sounds = default.node_sound_wood_defaults(),
        climbable = true,
        walkable = false,
	groups = {choppy=3, oddly_breakable_by_hand=2, flammable=2},
	on_rotate = screwdriver.rotate_simple,
	node_box = xdecor.pixelbox(16, {
		{3,  0, 11,   2, 16, 2}, {11, 0, 11,  2, 16, 2},
		{5,  9, 11.5, 6,  6, 1}, {3,  0,  3,  2,  6, 2},
		{11, 0,  3,   2,  6, 2}, {3,  6,  3, 10, 2, 8}
	}),
	can_dig = xdecor.sit_dig,
	--[[on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		pos.y = pos.y + 0  -- Sitting position.
		xdecor.sit(pos, node, clicker, pointed_thing)
	end--]]
})

xdecor.register("chair_aspen", {
	description = "Aspen Chair",
	tiles = {"default_aspen_wood.png"},
	sounds = default.node_sound_wood_defaults(),
        climbable = true,
        walkable = false,
	groups = {choppy=3, oddly_breakable_by_hand=2, flammable=2},
	on_rotate = screwdriver.rotate_simple,
	node_box = xdecor.pixelbox(16, {
		{3,  0, 11,   2, 16, 2}, {11, 0, 11,  2, 16, 2},
		{5,  9, 11.5, 6,  6, 1}, {3,  0,  3,  2,  6, 2},
		{11, 0,  3,   2,  6, 2}, {3,  6,  3, 10, 2, 8}
	}),
	can_dig = xdecor.sit_dig,
})

xdecor.register("chair_acacia", {
	description = "Acacia Chair",
	tiles = {"default_acacia_wood.png"},
	sounds = default.node_sound_wood_defaults(),
        climbable = true,
        walkable = false,
	groups = {choppy=3, oddly_breakable_by_hand=2, flammable=2},
	on_rotate = screwdriver.rotate_simple,
	node_box = xdecor.pixelbox(16, {
		{3,  0, 11,   2, 16, 2}, {11, 0, 11,  2, 16, 2},
		{5,  9, 11.5, 6,  6, 1}, {3,  0,  3,  2,  6, 2},
		{11, 0,  3,   2,  6, 2}, {3,  6,  3, 10, 2, 8}
	}),
	can_dig = xdecor.sit_dig,
})

xdecor.register("chair_jungle", {
	description = "Junglewood Chair",
	tiles = {"default_junglewood.png"},
	sounds = default.node_sound_wood_defaults(),
        climbable = true,
        walkable = false,
	groups = {choppy=3, oddly_breakable_by_hand=2, flammable=2},
	on_rotate = screwdriver.rotate_simple,
	node_box = xdecor.pixelbox(16, {
		{3,  0, 11,   2, 16, 2}, {11, 0, 11,  2, 16, 2},
		{5,  9, 11.5, 6,  6, 1}, {3,  0,  3,  2,  6, 2},
		{11, 0,  3,   2,  6, 2}, {3,  6,  3, 10, 2, 8}
	}),
	can_dig = xdecor.sit_dig,
})
xdecor.register("chair_pine", {
	description = "Pine Chair",
	tiles = {"default_pine_wood.png"},
	sounds = default.node_sound_wood_defaults(),
        climbable = true,
        walkable = false,
	groups = {choppy=3, oddly_breakable_by_hand=2, flammable=2},
	on_rotate = screwdriver.rotate_simple,
	node_box = xdecor.pixelbox(16, {
		{3,  0, 11,   2, 16, 2}, {11, 0, 11,  2, 16, 2},
		{5,  9, 11.5, 6,  6, 1}, {3,  0,  3,  2,  6, 2},
		{11, 0,  3,   2,  6, 2}, {3,  6,  3, 10, 2, 8}
	}),
	can_dig = xdecor.sit_dig,
})

xdecor.register("cobweb", {
	description = "Cobweb",
	drawtype = "plantlike",
	tiles = {"xdecor_cobweb.png"},
	inventory_image = "xdecor_cobweb.png",
	move_resistance = 6,
	walkable = false,
	selection_box = {type = "regular"},
	groups = {dig_immediate=3, liquid=3, flammable=3},
	sounds = default.node_sound_leaves_defaults()
})
--[[
for _, c in pairs({"red"}) do  -- Add more curtains colors simply here.
	xdecor.register("curtain_"..c, {
		description = c:gsub("^%l", string.upper).." Curtain",
		walkable = false,
		tiles = {"wool_white.png^[colorize:"..c..":170"},
		inventory_image = "wool_white.png^[colorize:"..c..":170^xdecor_curtain_open_overlay.png^[makealpha:255,126,126",
		wield_image = "wool_white.png^[colorize:"..c..":170",
		drawtype = "signlike",
		paramtype2 = "wallmounted",
		groups = {dig_immediate=3, flammable=3},
		selection_box = {type="wallmounted"},
		on_rightclick = function(pos, node)
			minetest.set_node(pos, {name="xdecor:curtain_open_"..c, param2=node.param2})
		end
	})

	xdecor.register("curtain_open_"..c, {
		tiles = {"wool_white.png^[colorize:"..c..":170^xdecor_curtain_open_overlay.png^[makealpha:255,126,126"},
		drawtype = "signlike",
		paramtype2 = "wallmounted",
		walkable = false,
		groups = {dig_immediate=3, flammable=3, not_in_creative_inventory=1},
		selection_box = {type="wallmounted"},
		drop = "xdecor:curtain_"..c,
		on_rightclick = function(pos, node)
			minetest.set_node(pos, {name="xdecor:curtain_"..c, param2=node.param2})
		end
	})

	minetest.register_craft({
		output = "xdecor:curtain_"..c.." 4",
		recipe = { {"", "wool:"..c, ""},
			   {"", "wool:"..c, ""} }
	})
end

xdecor.register("cushion", {
	description = "Cushion",
	tiles = {"xdecor_cushion.png"},
	groups = {snappy=3, flammable=3, fall_damage_add_percent=-50},
	on_place = minetest.rotate_node,
	node_box = xdecor.nodebox.slab_y(0.5),
	can_dig = xdecor.sit_dig,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		pos.y = pos.y + 0
		xdecor.sit(pos, node, clicker, pointed_thing)

		local wield_item = clicker:get_wielded_item():get_name()
		if wield_item == "xdecor:cushion" and clicker:get_player_control().sneak then
			local player_name = clicker:get_player_name()
			if minetest.is_protected(pos, player_name) then
				minetest.record_protection_violation(pos, player_name) return
			end

			minetest.set_node(pos, {name="xdecor:cushion_block", param2=node.param2})

			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end
			return itemstack
		end
	end
})

xdecor.register("cushion_block", {
	tiles = {"xdecor_cushion.png"},
	groups = {snappy=3, flammable=3, fall_damage_add_percent=-75, not_in_creative_inventory=1}
})
--]]
--local function door_access(name) return name:find("prison") end
local xdecor_doors = {
	japanese = {
		{"group:wood", "default:paper"},
		{"default:paper", "group:wood"},
		{"group:wood", "default:paper"} },
	prison = {
		{"xpanes:bar_flat", "xpanes:bar_flat"},
		{"xpanes:bar_flat", "xpanes:bar_flat"},
		{"xpanes:bar_flat", "xpanes:bar_flat"} },
	rusty_prison = {
		{"xpanes:rusty_bar_flat", "xpanes:rusty_bar_flat"},
		{"xpanes:rusty_bar_flat", "xpanes:rusty_bar_flat"},
		{"xpanes:rusty_bar_flat", "xpanes:rusty_bar_flat"} },
	--screen = {
	--	{"group:wood", "group:wood"},
	--	{"xpanes:chainlink", "xpanes:chainlink"},
-- 	--	{"group:wood", "group:wood"} },
	slide = {
		{"default:paper", "default:paper"},
		{"default:paper", "default:paper"},
		{"group:wood", "group:wood"} },
	woodglass = {
		{"default:glass", "default:glass"},
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"} }
}

for name, recipe in pairs(xdecor_doors) do
	if not doors.register then break end
	doors.register(name.."_door", {
		tiles = {{name = "xdecor_"..name.."_door.png", backface_culling=true}},
		description = name:gsub("%f[%w]%l", string.upper):gsub("_", " ").." Door",
		inventory_image = "xdecor_"..name.."_door_inv.png",
		--protected = door_access(name),
		groups = {choppy=2, cracky=2, oddly_breakable_by_hand=1, door=1},
		recipe = recipe
	})
	minetest.register_alias("xdecor:"..name.."_door", "doors:"..name.."_door")
	minetest.register_alias("xdecor:"..name.."_door_t_1", "air")
	minetest.register_alias("xdecor:"..name.."_door_t_2", "air")
	minetest.register_alias("xdecor:"..name.."_door_b_1", "doors:"..name.."_door_a")
	minetest.register_alias("xdecor:"..name.."_door_b_2", "doors:"..name.."_door_b")
end
minetest.register_alias("xdecor:prison_rust_door", "doors:rusty_prison_door")
minetest.register_alias("xdecor:prison_rust_door_t_1", "air")
minetest.register_alias("xdecor:prison_rust_door_t_2", "air")
minetest.register_alias("xdecor:prison_rust_door_b_1", "doors:rusty_prison_door_a")
minetest.register_alias("xdecor:prison_rust_door_b_2", "doors:rusty_prison_door_b")

xdecor.register("ivy", {
	description = "Ivy",
	drawtype = "signlike",
	walkable = false,
	climbable = true,
	groups = {dig_immediate=3, flammable=3, plant=1},
	paramtype2 = "wallmounted",
	selection_box = {type="wallmounted"},
	tiles = {"xdecor_ivy.png"},
	inventory_image = "xdecor_ivy.png",
	wield_image = "xdecor_ivy.png",
	sounds = default.node_sound_leaves_defaults()
})

xdecor.register("lantern", {
	description = "Lantern",
	light_source = 13,
	drawtype = "plantlike",
	inventory_image = "xdecor_lantern_inv.png",
	wield_image = "xdecor_lantern_inv.png",
	paramtype2 = "wallmounted",
	walkable = false,
	groups = {dig_immediate=3, attached_node=1},
	tiles = {{name = "xdecor_lantern.png", animation = {type="vertical_frames", length=1.5}}},
	selection_box = xdecor.pixelbox(16, {{4, 0, 4, 8, 16, 8}})
})

for _, l in pairs({"iron", "wooden"}) do
	xdecor.register(l.."_lightbox", {
		description = l:gsub("^%l", string.upper).." Light Box",
		tiles = {"xdecor_"..l.."_lightbox.png"},
		groups = {cracky=3, choppy=3, oddly_breakable_by_hand=2},
		light_source = 13,
		sounds = default.node_sound_glass_defaults()
	})
end

for _, f in pairs({"dandelion_white", "dandelion_yellow", "geranium",
		"rose", "tulip", "viola"}) do
	xdecor.register("potted_"..f, {
		description = "Potted "..f:gsub("%f[%w]%l", string.upper):gsub("_", " "),
		walkable = false,
		groups = {dig_immediate=3, flammable=3, plant=1, flower=1},
		tiles = {"xdecor_"..f.."_pot.png"},
		inventory_image = "xdecor_"..f.."_pot.png",
		drawtype = "plantlike",
		sounds = default.node_sound_leaves_defaults(),
		selection_box = xdecor.nodebox.slab_y(0.3)
	})

	minetest.register_craft({
		output = "xdecor:potted_"..f,
		recipe = { {"default:clay_brick", "flowers:"..f, "default:clay_brick"},
			   {"", "default:clay_brick", ""} }
	})
end

local painting_box = {
	type = "wallmounted",
	wall_top = {-0.4375, 0.4375, -0.3125, 0.4375, 0.5, 0.3125},
	wall_bottom = {-0.4375, -0.5, -0.3125, 0.4375, -0.4375, 0.3125},
	wall_side = {-0.5, -0.3125, -0.4375, -0.4375, 0.3125, 0.4375}
}

xdecor.register("painting_1", {
	description = "Painting",
	tiles = {"xdecor_painting_1.png"},
	inventory_image = "xdecor_painting_empty.png",
	wield_image = "xdecor_painting_empty.png",
	paramtype2 = "wallmounted",
	wield_image = "xdecor_painting_empty.png",
	sunlight_propagates = true,
	groups = {choppy=3, oddly_breakable_by_hand=2, flammable=2, attached_node=1},
	sounds = default.node_sound_wood_defaults(),
	node_box = painting_box,
	on_construct = function(pos)
		local node = minetest.get_node(pos)
		local random = math.random(4)
		if random == 1 then return end
		minetest.set_node(pos, {name="xdecor:painting_"..random, param2=node.param2})
	end
})

for i = 2, 4 do
	xdecor.register("painting_"..i, {
		tiles = {"xdecor_painting_"..i..".png"},
		paramtype2 = "wallmounted",
		drop = "xdecor:painting_1",
		sunlight_propagates = true,
		groups = {choppy=3, oddly_breakable_by_hand=2, flammable=2, attached_node=1, not_in_creative_inventory=1},
		sounds = default.node_sound_wood_defaults(),
		node_box = painting_box
	})
end

xdecor.register("stonepath", {
	description = "Garden Stone Path",
	tiles = {"default_stone.png"},
	groups = {snappy=3},
	on_rotate = screwdriver.rotate_simple,
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	node_box = xdecor.pixelbox(16, {
		{8, 0,  8, 6, .5, 6}, {1,  0, 1, 6, .5, 6},
		{1, 0, 10, 5, .5, 5}, {10, 0, 2, 4, .5, 4}
	}),
	selection_box = xdecor.nodebox.slab_y(0.05)
})

function xdecor.register_hard_node(name, desc, def)
	xdecor.register(name, {
		description = desc,
		tiles = {"xdecor_"..name..".png"},
		groups = def.groups or {cracky=2},
		sounds = def.sounds or default.node_sound_stone_defaults()
	})
end

--xdecor.register_hard_node("cactusbrick", "Cactus Brick", {})
xdecor.register_hard_node("coalstone_tile", "Coal Stone Tile", {})
xdecor.register_hard_node("desertstone_tile", "Desert Stone Tile", {})
xdecor.register_hard_node("hard_clay", "Hardened Clay", {})
xdecor.register_hard_node("smallbrick", "Small Stone Bricks", {})
xdecor.register_hard_node("stone_tile", "Stone Tile", {})
xdecor.register_hard_node("stone_rune", "Runestone", {})
xdecor.register_hard_node("packed_ice", "Packed Ice", {
	groups = {cracky=1, puts_out_fire=1},
	sounds = default.node_sound_glass_defaults()
})
xdecor.register_hard_node("wood_tile", "Wooden Tile", {
	groups = {choppy=1, wood=1, flammable=2},
	sounds = default.node_sound_wood_defaults()
})

xdecor.register("table", {
	description = "Table",
	tiles = {"default_wood.png"},
	groups = {choppy=2, oddly_breakable_by_hand=1, flammable=2},
	sounds = default.node_sound_wood_defaults(),
	node_box = xdecor.pixelbox(16, {
		{0, 14, 0, 16, 2, 16}, {5.5, 0, 5.5, 5, 14, 6}
	})
})

xdecor.register("table_jungle", {
	description = "Junglewood Table",
	tiles = {"default_junglewood.png"},
	groups = {choppy=2, oddly_breakable_by_hand=1, flammable=2},
	sounds = default.node_sound_wood_defaults(),
	node_box = xdecor.pixelbox(16, {
		{0, 14, 0, 16, 2, 16}, {5.5, 0, 5.5, 5, 14, 6}
	})
})

xdecor.register("table_pine", {
	description = "Pine Table",
	tiles = {"default_pine_wood.png"},
	groups = {choppy=2, oddly_breakable_by_hand=1, flammable=2},
	sounds = default.node_sound_wood_defaults(),
	node_box = xdecor.pixelbox(16, {
		{0, 14, 0, 16, 2, 16}, {5.5, 0, 5.5, 5, 14, 6}
	})
})

xdecor.register("table_acacia", {
	description = "Acacia Table",
	tiles = {"default_acacia_wood.png"},
	groups = {choppy=2, oddly_breakable_by_hand=1, flammable=2},
	sounds = default.node_sound_wood_defaults(),
	node_box = xdecor.pixelbox(16, {
		{0, 14, 0, 16, 2, 16}, {5.5, 0, 5.5, 5, 14, 6}
	})
})

xdecor.register("table_aspen", {
	description = "Aspen Table",
	tiles = {"default_aspen_wood.png"},
	groups = {choppy=2, oddly_breakable_by_hand=1, flammable=2},
	sounds = default.node_sound_wood_defaults(),
	node_box = xdecor.pixelbox(16, {
		{0, 14, 0, 16, 2, 16}, {5.5, 0, 5.5, 5, 14, 6}
	})
})

xdecor.register("tatami", {
	description = "Tatami",
	tiles = {"xdecor_tatami.png"},
	wield_image = "xdecor_tatami.png",
	groups = {snappy=3, flammable=3},
	node_box = xdecor.nodebox.slab_y(0.0625)
})
--[[
xdecor.register("tv", {
	description = "Television",
	light_source = 11,
	groups = {snappy=3},
	on_rotate = screwdriver.rotate_simple,
	tiles = {"xdecor_television_left.png^[transformR270",
		 "xdecor_television_left.png^[transformR90",
		 "xdecor_television_left.png^[transformFX",
		 "xdecor_television_left.png", "xdecor_television_back.png",
		{name="xdecor_television_front_animated.png",
		 animation = {type="vertical_frames", length=80.0}} }
})

for _, n in pairs({"c0", "c1", "c2", "c3", "c4", "ln"}) do
	minetest.register_alias("xdecor:cobble_wall_"..n, "walls:cobble")
	minetest.register_alias("xdecor:mossycobble_wall_"..n, "walls:cobble")
end--]]

xdecor.register("woodframed_glass", {
	description = "Wood Framed Glass",
	drawtype = "glasslike_framed",
	tiles = {"xdecor_woodframed_glass.png", "xdecor_woodframed_glass_detail.png"},
	groups = {cracky=2, oddly_breakable_by_hand=1},
	sounds = default.node_sound_glass_defaults()
})


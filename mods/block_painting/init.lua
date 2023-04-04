force_paintable_nodes = {
"default:wood",
"default:junglewood",
"default:pine_wood",
"default:acacia_wood",
"default:aspen_wood",
"default:desert_stonebrick",
"default:stonebrick",
"default:sandstonebrick",
"default:desert_sandstone_brick",
"default:silver_sandstone_brick",
"default:silver_sandstone_brick",
"default:brick",
}	

local BP_colors = {
	["block_painting:paint_stripper"] = 0,
	["block_painting:non_existent_paint"] = 1,
	["block_painting:red_paint"] = 2,
	["block_painting:blue_paint"] = 3,
	["block_painting:grey_paint"] = 4,
	["block_painting:black_paint"] = 5,
	["block_painting:yellow_paint"] = 6,
	["block_painting:orange_paint"] = 7,
	["block_painting:pink_paint"] = 8,
	["block_painting:cyan_paint"] = 9,
	["block_painting:magenta_paint"] = 10,
	["block_painting:violet_paint"] = 11,
	["block_painting:brown_paint"] = 12,
	["block_painting:salad_paint"] = 13,
	["block_painting:lightblue_paint"] = 14,
	["block_painting:green_paint"] = 15,
	["block_painting:dark_red_paint"] = 16,
	["block_painting:dark_blue_paint"] = 17,
	["block_painting:dark_yellow_paint"] = 18,
	["block_painting:dark_orange_paint"] = 19,
	["block_painting:dark_pink_paint"] = 20,
	["block_painting:dark_cyan_paint"] = 21,
	["block_painting:dark_magenta_paint"] = 22,
	["block_painting:dark_violet_paint"] = 23,
	["block_painting:dark_brown_paint"] = 24,
	["block_painting:dark_salad_paint"] = 25,
	["block_painting:dark_lightblue_paint"] = 26,
	["block_painting:dark_green_paint"] = 27,
	["block_painting:light_red_paint"] = 28,
	["block_painting:light_blue_paint"] = 29,
	["block_painting:light_yellow_paint"] = 30,
	["block_painting:light_orange_paint"] = 31,
	["block_painting:light_pink_paint"] = 32,
	["block_painting:light_cyan_paint"] = 33,
	["block_painting:light_magenta_paint"] = 34,
	["block_painting:light_violet_paint"] = 35,
	["block_painting:light_brown_paint"] = 36,
	["block_painting:light_salad_paint"] = 37,
	["block_painting:light_lightblue_paint"] = 38,
	["block_painting:light_green_paint"] = 39,
	["block_painting:shadow_paint"] = 40,
}

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
local painter = puncher and puncher:get_player_name() or ""
local wielded_item = puncher:get_wielded_item():get_name()
if wielded_item == "block_painting:paintbrush" or
   wielded_item == "block_painting:magic_paintbrush"
 then
if not minetest.is_protected(pos, painter) then
	if minetest.registered_nodes[node.name] ~= nil and
	minetest.registered_nodes[node.name].palette == "block_painting_pallete.png" 	 
then
local paint = 
puncher:get_inventory():get_stack("main", puncher:get_wield_index()+1):get_name() 
		local color = BP_colors[paint] or false 
		if color ~= false then
if node.param2 ~= color then
puncher:get_inventory():remove_item("main", paint)
end
	node.param2 = color
	minetest.set_node(pos,node)
	end end end end end)

--items

minetest.register_tool("block_painting:paintbrush", {
		description = "".. core.colorize("#fff000", "Paintbrush\n")..core.colorize("#FFFFFF", "Use it on a block, while having paint in your next inventory slot, to paint it\n")..core.colorize("#ff1200", "Might not work on some blocks."),
	range = 5,
	inventory_image = "block_painting_paintbrush.png",
tool_capabilities = {
	full_punch_interval = 1.2,
	max_drop_level=0,
	groupcaps={
		dig_immediate = {times={[3]=2.0,[2]=2.0,[1]=2.0}, uses=0, maxlevel=1},
		},
	damage_groups = {fleshy=0},
},
})

minetest.register_tool("block_painting:magic_paintbrush", {
		description = "".. core.colorize("#fff000", "Magic Paintbrush\n") ..core.colorize("#FFFFFF", "Use it on a block, while having paint in your next inventory slot, to paint it\n")..core.colorize("#00fcff", "capable of painting some liquids and has more range\n")  ..core.colorize("#ff1200", "Might not work on some blocks."),
	liquids_pointable = true,
	range = 8,
	inventory_image = "block_painting_magic_paintbrush.png",
tool_capabilities = {
	full_punch_interval = 1.2,
	max_drop_level=0,
	groupcaps={
		dig_immediate = {times={[3]=2.0,[2]=2.0,[1]=2.0}, uses=0, maxlevel=1},
		},
	damage_groups = {fleshy=0},
},
})

minetest.register_craftitem("block_painting:paint_stripper", {
		description = "".. core.colorize("#fff000", "Paint stripper\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to remove paint from blocks"),
	inventory_image = "block_painting_paintbucket.png^block_painting_paint.png",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:green_paint", {
		description = "".. core.colorize("#fff000", "Green paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#2c9e1b)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:red_paint", {
		description = "".. core.colorize("#fff000", "Red paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#d11b1f)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:blue_paint", {
		description = "".. core.colorize("#fff000", "Blue paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#2c37c7)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:grey_paint", {
		description = "".. core.colorize("#fff000", "Grey paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#5d5d5d)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:black_paint", {
		description = "".. core.colorize("#fff000", "Black paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#171717)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:yellow_paint", {
		description = "".. core.colorize("#fff000", "Yellow paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#e6da00)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:orange_paint", {
		description = "".. core.colorize("#fff000", "Orange paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#f06600)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:pink_paint", {
		description = "".. core.colorize("#fff000", "Pink paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#ff79a5)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:cyan_paint", {
		description = "".. core.colorize("#fff000", "Cyan paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#1bc5a3)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:magenta_paint", {
		description = "".. core.colorize("#fff000", "Magenta paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#f523e6)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:violet_paint", {
		description = "".. core.colorize("#fff000", "Violet paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#7a37b7)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:brown_paint", {
		description = "".. core.colorize("#fff000", "Brown paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#865139)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:salad_paint", {
		description = "".. core.colorize("#fff000", "Salad paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#c1dc27)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:lightblue_paint", {
		description = "".. core.colorize("#fff000", "Light blue paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#57a3ee)",
	stack_max = 999,
})


minetest.register_craftitem("block_painting:dark_green_paint", {
		description = "".. core.colorize("#fff000", "Darker Green paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#123f0b)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:dark_red_paint", {
		description = "".. core.colorize("#fff000", "Darker Red paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#540b0c)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:dark_blue_paint", {
		description = "".. core.colorize("#fff000", "Darker Blue paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#121650)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:dark_yellow_paint", {
		description = "".. core.colorize("#fff000", "Darker Yellow paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#5c5700)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:dark_orange_paint", {
		description = "".. core.colorize("#fff000", "Darker Orange paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#602900)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:dark_pink_paint", {
		description = "".. core.colorize("#fff000", "Darker Pink paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#663042)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:dark_cyan_paint", {
		description = "".. core.colorize("#fff000", "Darker Cyan paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#0b4f41)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:dark_magenta_paint", {
		description = "".. core.colorize("#fff000", "Darker Magenta paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#620e5c)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:dark_violet_paint", {
		description = "".. core.colorize("#fff000", "Darker Violet paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#311649)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:dark_brown_paint", {
		description = "".. core.colorize("#fff000", "Darker Brown paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#362017)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:dark_salad_paint", {
		description = "".. core.colorize("#fff000", "Darker Salad paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#4d5810)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:dark_lightblue_paint", {
		description = "".. core.colorize("#fff000", "Darker Light blue paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#23415f)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:shadow_paint", {
		description = "".. core.colorize("#fff000", "Shadow paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#000000)",
	stack_max = 999,
})


minetest.register_craftitem("block_painting:light_green_paint", {
		description = "".. core.colorize("#fff000", "lighter Green paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#95ce8d)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:light_red_paint", {
		description = "".. core.colorize("#fff000", "lighter Red paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#ffbcd2)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:light_blue_paint", {
		description = "".. core.colorize("#fff000", "lighter Blue paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#959be3)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:light_yellow_paint", {
		description = "".. core.colorize("#fff000", "lighter Yellow paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#f2ec7f)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:light_orange_paint", {
		description = "".. core.colorize("#fff000", "lighter Orange paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#f7b27f)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:light_pink_paint", {
		description = "".. core.colorize("#fff000", "lighter Pink paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#ffbcd2)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:light_cyan_paint", {
		description = "".. core.colorize("#fff000", "lighter Cyan paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#8de2d1)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:light_magenta_paint", {
		description = "".. core.colorize("#fff000", "lighter Magenta paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#fa91f2)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:light_violet_paint", {
		description = "".. core.colorize("#fff000", "lighter Violet paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#bc9bdb)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:light_brown_paint", {
		description = "".. core.colorize("#fff000", "lighter Brown paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#c2a89c)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:light_salad_paint", {
		description = "".. core.colorize("#fff000", "lighter Salad paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#e0ed93)",
	stack_max = 999,
})
minetest.register_craftitem("block_painting:light_lightblue_paint", {
		description = "".. core.colorize("#fff000", "lighter Light blue paint\n")..core.colorize("#FFFFFF", "Use it along with a paintbrush, to paint blocks"),
	inventory_image = "block_painting_paintbucket.png^(block_painting_paint.png^[multiply:#abd1f6)",
	stack_max = 999,
})

---crafts---

minetest.register_craft({
	output = "block_painting:paintbrush 1",
	recipe = {
		{"","farming:cotton","farming:cotton"},
		{"","default:steel_ingot","farming:cotton"},
		{"group:stick","",""},
	}
})
minetest.register_craft({
	output = "block_painting:paint_stripper 30",
	recipe = {
	{"default:junglegrass","default:junglegrass","default:junglegrass"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:green_paint 30",
	recipe = {
	{"dye:green","dye:green","dye:green"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:blue_paint 30",
	recipe = {
	{"dye:blue","dye:blue","dye:blue"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:red_paint 30",
	recipe = {
	{"dye:red","dye:red","dye:red"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:grey_paint 30",
	recipe = {
	{"dye:grey","dye:grey","dye:grey"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:black_paint 30",
	recipe = {
	{"dye:black","dye:black","dye:black"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:yellow_paint 30",
	recipe = {
	{"dye:yellow","dye:yellow","dye:yellow"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:orange_paint 30",
	recipe = {
	{"dye:orange","dye:orange","dye:orange"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:pink_paint 30",
	recipe = {
	{"dye:pink","dye:pink","dye:pink"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:cyan_paint 30",
	recipe = {
	{"dye:cyan","dye:cyan","dye:cyan"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:violet_paint 30",
	recipe = {
	{"dye:violet","dye:violet","dye:violet"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:magenta_paint 30",
	recipe = {
	{"dye:magenta","dye:magenta","dye:magenta"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:brown_paint 30",
	recipe = {
	{"dye:brown","dye:brown","dye:brown"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:lightblue_paint 30",
	recipe = {
	{"dye:blue","dye:white","dye:blue"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:salad_paint 30",
	recipe = {
	{"dye:green","dye:yellow","dye:green"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})


minetest.register_craft({
	output = "block_painting:dark_green_paint 30",
	recipe = {
	{"","dye:black",""},
	{"dye:green","dye:green","dye:green"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:dark_blue_paint 30",
	recipe = {
	{"","dye:black",""},
	{"dye:blue","dye:blue","dye:blue"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:dark_red_paint 30",
	recipe = {
	{"","dye:black",""},
	{"dye:red","dye:red","dye:red"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:shadow_paint 30",
	recipe = {
	{"","dye:black",""},
	{"dye:black","dye:black","dye:black"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:dark_yellow_paint 30",
	recipe = {
	{"","dye:black",""},
	{"dye:yellow","dye:yellow","dye:yellow"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:dark_orange_paint 30",
	recipe = {
	{"","dye:black",""},
	{"dye:orange","dye:orange","dye:orange"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:dark_pink_paint 30",
	recipe = {
	{"","dye:black",""},
	{"dye:pink","dye:pink","dye:pink"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:dark_cyan_paint 30",
	recipe = {
	{"","dye:black",""},
	{"dye:cyan","dye:cyan","dye:cyan"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:dark_violet_paint 30",
	recipe = {
	{"","dye:black",""},
	{"dye:violet","dye:violet","dye:violet"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:dark_magenta_paint 30",
	recipe = {
	{"","dye:black",""},
	{"dye:magenta","dye:magenta","dye:magenta"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:dark_brown_paint 30",
	recipe = {
	{"","dye:black",""},
	{"dye:brown","dye:brown","dye:brown"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:dark_lightblue_paint 30",
	recipe = {
	{"","dye:black",""},
	{"dye:blue","dye:white","dye:blue"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:dark_salad_paint 30",
	recipe = {
	{"","dye:black",""},
	{"dye:green","dye:yellow","dye:green"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})


minetest.register_craft({
	output = "block_painting:light_green_paint 30",
	recipe = {
	{"","dye:white",""},
	{"dye:green","dye:green","dye:green"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:light_blue_paint 30",
	recipe = {
	{"","dye:white",""},
	{"dye:blue","dye:blue","dye:blue"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:light_red_paint 30",
	recipe = {
	{"","dye:white",""},
	{"dye:red","dye:red","dye:red"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:light_yellow_paint 30",
	recipe = {
	{"","dye:white",""},
	{"dye:yellow","dye:yellow","dye:yellow"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:light_orange_paint 30",
	recipe = {
	{"","dye:white",""},
	{"dye:orange","dye:orange","dye:orange"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:light_pink_paint 30",
	recipe = {
	{"","dye:white",""},
	{"dye:pink","dye:pink","dye:pink"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:light_cyan_paint 30",
	recipe = {
	{"","dye:white",""},
	{"dye:cyan","dye:cyan","dye:cyan"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:light_violet_paint 30",
	recipe = {
	{"","dye:white",""},
	{"dye:violet","dye:violet","dye:violet"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:light_magenta_paint 30",
	recipe = {
	{"","dye:white",""},
	{"dye:magenta","dye:magenta","dye:magenta"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:light_brown_paint 30",
	recipe = {
	{"","dye:white",""},
	{"dye:brown","dye:brown","dye:brown"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:light_lightblue_paint 30",
	recipe = {
	{"","dye:white",""},
	{"dye:blue","dye:white","dye:blue"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})
minetest.register_craft({
	output = "block_painting:light_salad_paint 30",
	recipe = {
	{"","dye:white",""},
	{"dye:green","dye:yellow","dye:green"},
	{"basic_materials:oil_extract","default:steel_ingot","mesecons_materials:glue"},
	}
})

local orig_func = minetest.handle_node_drops
minetest.handle_node_drops = function(pos, drops, digger)
	for i, itemstring in pairs(drops) do
		local itemstack = ItemStack(itemstring)
		local metatbl = itemstack:to_table()
		if metatbl and metatbl.meta and metatbl.meta.palette_index and metatbl.meta.palette_index == "0" then
			metatbl.meta.palette_index = nil
			itemstack:get_meta():from_table(metatbl)
		end
		drops[i] = itemstack:to_string()
	end
	return orig_func(pos, drops, digger)
end

function OverrideDyeableNodes()
	for _, paintable_node in pairs(minetest.registered_nodes) do
		local def = minetest.registered_nodes[paintable_node.name]
		if def.paramtype2 == "none" and (not def.drawtype or def.drawtype == "normal") then
			minetest.override_item(paintable_node.name, {
				paramtype2 = "color",
				palette = "block_painting_pallete.png",
			})
		end
	end
	for _, f_paintable_node in pairs(force_paintable_nodes) do
		if minetest.registered_nodes[f_paintable_node] ~= nil then
		minetest.override_item(f_paintable_node, {
			paramtype2 = "color",
			palette = "block_painting_pallete.png",
		})
		end
	end
end

minetest.register_on_mods_loaded(OverrideDyeableNodes)
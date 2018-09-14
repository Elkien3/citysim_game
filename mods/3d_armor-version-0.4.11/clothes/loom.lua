local clothes_table = {}
local clothes_buttons = ""
local function make_buttons()
	local h = 0
	local v = .5
	for itemstring, def in pairs(minetest.registered_items) do
		if def.groups.clothing then
			if h > 6 then
				h = 0
				v = v + 1
			end
			clothes_buttons = clothes_buttons.."item_image_button["..h..","..v..";1,1;"..itemstring..";"..itemstring.."; ]"
			table.insert(clothes_table, itemstring)
			h = h + 1
		end
	end
end
minetest.after(0, make_buttons)
--[[ LOOM FROM CLOTHING MOD
Source Code: Stuart Jones - LGPL v2.1
Textures: Stuart Jones - CC-BY-SA 3.0
Edited by Elkien3
]]--
minetest.register_node("clothes:loom", {
	description = "Loom",
	tiles = {
		"clothing_loom_top.png",
		"clothing_loom_bottom.png",
		"clothing_loom_side2.png",
		"clothing_loom_side1.png",
		"clothing_loom_front.png",
		"clothing_loom_front.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy=2, oddly_breakable_by_hand=1},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.125, -0.375, 0.5, 0.1875}, -- NodeBox1
			{0.375, -0.5, -0.125, 0.5, 0.5, 0.1875}, -- NodeBox3
			{-0.375, -0.5, -0.5, 0.375, -0.4375, 0.5}, -- NodeBox4
			{-0.5, 0, -0.125, 0.5, 0.0625, 0.1875}, -- NodeBox5
			{-0.5, 0.3125, 0.1875, 0.5, 0.5, 0.25}, -- NodeBox6
			{-0.5, 0.3125, -0.1875, 0.5, 0.5, -0.125}, -- NodeBox7
			{-0.375, -0.1875, -0.5, -0.3125, -0.125, 0.5}, -- NodeBox8
			{0.3125, -0.1875, -0.5, 0.375, -0.125, 0.5}, -- NodeBox9
			{-0.4375, -0.1875, -0.5, 0.4375, -0.125, -0.4375}, -- NodeBox10
			{-0.4375, -0.1875, 0.4375, 0.4375, -0.125, 0.5}, -- NodeBox11
			{-0.375, -0.5, 0.375, -0.3125, -0.125, 0.4375}, -- NodeBox12
			{0.3125, -0.5, 0.375, 0.375, -0.125, 0.4375}, -- NodeBox13
			{-0.375, -0.5, -0.4375, -0.3125, -0.125, -0.375}, -- NodeBox14
			{0.3125, -0.5, -0.4375, 0.375, -0.125, -0.375}, -- NodeBox15
			{-0.3125, -0.4375, -0.25, 0.3125, 0, 0.25}, -- NodeBox16
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5,-0.5,-0.5,0.5,0.5,0.5}
		},
	},
	after_place_node = function(pos, placer)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("infotext", "Loom")
	end,
	can_dig = function(pos,player)
		local meta = minetest.env:get_meta(pos)
		local inv = meta:get_inventory()
		if not inv:is_empty("input") or not inv:is_empty("output") then
			return false
		end
		return true
	end,
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("formspec", "invsize[10,11;]"..
			"background[-0.15,-0.25;10.40,11.75;clothing_loom_background.png]"..
			"list[current_name;input;7,2;1,1;]"..
			"list[current_name;output;7,4;1,1;]"..
			"label[7,1.5;Input Wool:]"..
			"label[7,3.5;Output:]"..
			"label[0,0;Clothing Loom:]"..
			clothes_buttons..
			"list[current_player;main;1,7;8,4;]")
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("output", 1)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.env:get_meta(pos)
		local inv = meta:get_inventory()
		if inv:is_empty("input") then
			return
		end
		local output = nil
		for id, item in pairs(clothes_table) do
			minetest.chat_send_all(dump(item))
			if fields[item] then
				output = item
			end
		end

		if output then
			local inputstack = inv:get_stack("input", 1)
			local outputstack = inv:get_stack("output", 1)
			if minetest.registered_items[output] and inv:room_for_item("output", output) then
				inv:add_item("output", output)
				inputstack:take_item()
				inv:set_stack("input", 1, inputstack)
			end
		end
	end,
})

--Craft

minetest.register_craft({
	output = 'clothes:loom',
	recipe = {
		{'group:stick', 'default:pinewood', 'group:stick'},
		{'group:stick', 'default:pinewood', 'group:stick'},
		{'default:pinewood', "default:pinewood", 'default:pinewood'},
	},
})--]]

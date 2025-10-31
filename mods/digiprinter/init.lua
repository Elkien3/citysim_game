
-- Created by jogag
-- Part of the Digiline Stuff pack
-- Mod: Digiprinter - a digiline-controlled printer
-- It prints paper via the Writable Paper (memorandum) mod
-- then it sends "OK" or "ERR_PAPER" or "ERR_SPACE"

local OK_MSG = "OK"
local NO_PAPER_MSG = "ERR_PAPER"
local NO_SPACE_MSG = "ERR_SPACE"

local PRINT_DELAY = 3

-- taken from pipeworks mod
local function facedir_to_dir(facedir)
	--a table of possible dirs
	return ({{x=0, y=0, z=1},
		{x=1, y=0, z=0},
		{x=0, y=0, z=-1},
		{x=-1, y=0, z=0},
		{x=0, y=-1, z=0},
		{x=0, y=1, z=0}})
		
			--indexed into by a table of correlating facedirs
			[({[0]=1, 2, 3, 4, 
				5, 2, 6, 4,
				6, 2, 5, 4,
				1, 5, 3, 6,
				1, 6, 3, 5,
				1, 4, 3, 2})
				
				--indexed into by the facedir in question
				[facedir]]
end

local print_paper = function(pos, node, msg)
	local inv = minetest.get_meta(pos):get_inventory()
	
	local vel = facedir_to_dir(node.param2)
	local front = { x = pos.x - vel.x, y = pos.y - vel.y, z = pos.z - vel.z }
	if minetest.get_node(front).name ~= "air" then
		-- search for the next block
		vel = { x = vel.x * 2, y = vel.y * 2, z = vel.z * 2 }
		front = { x = pos.x - vel.x, y = pos.y - vel.y, z = pos.z - vel.z }
	end
	
	if inv:is_empty("paper") then digiline:receptor_send(pos, digiline.rules.default, channel, NO_PAPER_MSG)
	elseif minetest.get_node(front).name ~= "air" then digiline:receptor_send(pos, digiline.rules.default, channel, NO_SPACE_MSG)
	else
		local paper = inv:get_stack("paper", 1)
		paper:take_item()
		inv:set_stack("paper", 1, paper)
		
		minetest.add_node(front, {
			name = (msg == "" and "memorandum:letter_empty" or "memorandum:letter_written"),
			param2 = node.param2
		})
		
		local meta = minetest.get_meta(front)
		meta:set_string("text", msg)
		meta:set_string("signed", "Digiprinter")
		meta:set_string("infotext", '"'..msg..'" Printed with Digiprinter') -- xD
		
		digiline:receptor_send(pos, digiline.rules.default, channel, OK_MSG)
	end
	minetest.get_meta(pos):set_string("infotext", "Digiline Printer Idle")
end

local on_digiline_receive = function(pos, node, channel, msg)
	local meta = minetest.get_meta(pos)
	if channel == meta:get_string("channel") and not meta:get_string("infotext"):find("Busy") then
		meta:set_string("infotext", "Digiline Printer Busy")
		minetest.after(PRINT_DELAY, print_paper, pos, node, msg)
	end
end

-- taken from computer mod xD
minetest.register_node("digiprinter:printer", {
	description = "Digiline Printer",
	tiles = {"digiprinter_t.png","digiprinter_bt.png","digiprinter_l.png",
			"digiprinter_r.png","digiprinter_b.png","digiprinter_f.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = true,
	groups = {snappy=3},
	sound = default.node_sound_wood_defaults(),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.3125, -0.125, 0.4375, -0.0625, 0.375},
			{-0.4375, -0.5, -0.125, 0.4375, -0.4375, 0.375},
			{-0.4375, -0.5, -0.125, -0.25, -0.0625, 0.375},
			{0.25, -0.5, -0.125, 0.4375, -0.0625, 0.375},
			{-0.4375, -0.5, -0.0625, 0.4375, -0.0625, 0.375},
			{-0.375, -0.4375, 0.25, 0.375, -0.0625, 0.4375},
			{-0.25, -0.25, 0.4375, 0.25, 0.0625, 0.5},
			{-0.25, -0.481132, -0.3125, 0.25, -0.4375, 0}
		},
	},
	digiline = {
		receptor = {},
		effector = {
			action = on_digiline_receive
		},
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("channel", "")
		meta:set_string("infotext", "Digiline Printer Idle")
		meta:set_string("formspec", "size[8,10]"..
			((default and default.gui_bg) or "")..
			((default and default.gui_bg_img) or "")..
			((default and default.gui_slots) or "")..
			"label[0,0;Digiline Printer]"..
			"label[3.5,2;Paper]"..
			"list[current_name;paper;3.5,2.5;1,1;]"..
			"field[2,3.5;5,5;channel;Channel;${channel}]"..
			((default and default.get_hotbar_bg) and default.get_hotbar_bg(0,6) or "")..
			"list[current_player;main;0,6;8,4;]")
		local inv = meta:get_inventory()
		inv:set_size("paper", 1)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.channel then minetest.get_meta(pos):set_string("channel", fields.channel) end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then return 0 end
		return (stack:get_name() == "default:paper" and stack:get_count() or 0)
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		return (minetest.get_meta(pos):get_string("infotext"):find("Busy") and stack:get_count() or 0)
	end,
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("paper")
	end,
})

-- printer crafting:
-- +-------+
-- | ? P ? |
-- | ? M ? |
-- | ? D ? |
-- +-------+
minetest.register_craft({
	output = "digiprinter:printer",
	recipe = {
		{ "homedecor:plastic_sheeting", "", "" },
		{ "digilines:wire_std_00000000", "default:mese_crystal", "homedecor:plastic_sheeting" },
		{ "homedecor:plastic_sheeting", "homedecor:plastic_sheeting", "homedecor:plastic_sheeting" },
	},
})


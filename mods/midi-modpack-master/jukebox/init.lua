local function stop_music(pos, removetbl)
	if removetbl ~= false then removetbl = true end
	midi.stop_midi(minetest.pos_to_string(pos), removetbl)
end

minetest.register_node("jukebox:record_player", {
	description = "Record Player",
	drawtype = "mesh",
	mesh = "jukebox.b3d",
	paramtype2 = "facedir",
	tiles = {"jukebox.png"},
	groups = {oddly_breakable_by_hand = 3},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "size[9,7.5]" ..
		"list[context;main;4,0.3;1,1;0]" ..
		"button[3.5,1.5;1,1;playpause;>]" ..
		"button[4.5,1.5;1,1;stop;\\[   \\]]" ..
		"button[5.5,1.5;1,1;skipforward;>>]" ..
		"button[2.5,1.5;1,1;skipback;<<]" ..
		"list[current_player;main;0.5,3;8,4;0]")
		meta:set_string("infotext", "Record Player")
		local inv = meta:get_inventory()
		inv:set_size("main", 1)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local posname = minetest.pos_to_string(pos)
		local playingsong = midi.playingsongs[posname]
		if fields.playpause then
			if not playingsong then
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				local stack = inv:get_stack("main", 1)				
				local name = "{x="..(pos.x)..",y="..(pos.y)..",z="..(pos.z).."}"
				--name = sender:get_player_name()
				local songdata = stack:get_meta():get_string("data")
				
				if songdata == "" then
					return false, "no data"
				end

				local flag, ret = pcall(function()
					return midi.load_midi(songdata)
				end)

				if not flag then
					return false, ret
				end

				midi.play_midi(name, ret, 1, posname)
			else
				stop_music(pos, false)
				playingsong.playing = not playingsong.playing
			end
		elseif playingsong and fields.stop then
			stop_music(pos)
		elseif playingsong and fields.skipforward then
			stop_music(pos, false)
			playingsong.playhead = playingsong.playhead + 10
		elseif playingsong and fields.skipback then
			stop_music(pos, false)
			playingsong.playhead = playingsong.playhead - 10
		end		
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("main") and default.can_interact_with_node(player, pos)
	end,
	on_destruct = stop_music,
	on_metadata_inventory_move = stop_music,
	on_metadata_inventory_put = stop_music,
	on_metadata_inventory_take = stop_music,
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.3125, 0.375, -0.125, 0.3125}, -- NodeBox1
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.3125, 0.375, -0.125, 0.3125}, -- NodeBox1
		}
	}
})

minetest.register_craft({
	output = "jukebox:record_player",
	recipe = {
		{"", "default:mese_crystal_fragment", "default:stick"},
		{"group:wood", "group:wood", "group:wood"},
	}
})

local function get_stamper_form(errormsg)
	local form = "size[9,6.5]" ..
	"list[context;main;4,0.3;1,1;0]" ..
	"list[current_player;main;0.5,2;8,4;0]" ..
	"field[0.75,0.7;3.25,1;data;Paste song data here;]" ..
	"button[7,0.35;2,1;stamp;Stamp Record]" ..
	"field[5.5,0.7;1.75,1;description;Label;]"..
	"label[0.5,1.25;See mod readme for directions]"
	if errormsg then
		form = form.."label[5.25,1.25;"..minetest.formspec_escape(errormsg).."]"
	end
	return form
end

minetest.register_node("jukebox:record_stamp", {
	description = "Record Stamper",
	drawtype = "mesh",
	mesh = "record_stamp.b3d",
	paramtype2 = "facedir",
	tiles = {"record_stamp.png"},
	groups = {oddly_breakable_by_hand = 3},
	sounds = default.node_sound_stone_defaults(),
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.3125, 0.375, -0.125, 0.3125}, -- NodeBox1
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.3125, 0.375, -0.125, 0.3125}, -- NodeBox1
		}
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_stamper_form())
		meta:set_string("infotext", "Record Stamper")
		local inv = meta:get_inventory()
		inv:set_size("main", 1)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.stamp then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local stack = inv:get_stack("main", 1)	
			if stack:get_name() ~= "jukebox:record" then
				meta:set_string("formspec", get_stamper_form("Error: Invalid Item"))
				return
			end
			if fields.description == "" then
				meta:set_string("formspec", get_stamper_form("Error: No Description"))
				return
			end
			if fields.data == "" then
				meta:set_string("formspec", get_stamper_form("Error: No Song Data"))
				return
			end
			if #fields.data > 20000 then--twice as big as max book text
				meta:set_string("formspec", get_stamper_form("Error: Song is too large"))
				return
			end
			local flag, ret = pcall(function()
				return midi.load_midi(fields.data)
			end)

			if not flag then
				meta:set_string("formspec", get_stamper_form("Error: Invalid Song Data"))
				return
			end
			
			stack:get_meta():set_string("description", "'"..fields.description.."'")
			stack:get_meta():set_string("data", fields.data)
			inv:set_stack("main", 1, stack)
			meta:set_string("formspec", get_stamper_form())
		end
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("main") and default.can_interact_with_node(player, pos)
	end,
})

minetest.register_craft({
	output = "jukebox:record_stamp",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:stick"},
		{"", "", ""},
		{"default:steel_ingot", "default:steel_ingot", ""},
	}
})

minetest.register_craftitem("jukebox:record", {
    description = "Vinyl Record",
    inventory_image = "jukebox_disc.png",
	stack_max = 1,
})
local center = "dye:black"
if minetest.get_modpath("basic_materials") then
	center = "basic_materials:plastic_sheet"
end
minetest.register_craft({
	output = "jukebox:record",
	recipe = {
		{"", "dye:black", ""},
		{"dye:black", center, "dye:black"},
		{"", "dye:black", ""},
	}
})
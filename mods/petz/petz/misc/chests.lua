local modpath, S = ...

petz.chest = {}
petz.chest.open_chests = {}

function petz.chest.get_chest_formspec(pos)
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
	local meta = minetest.get_meta(pos)
	local christmas_msg = meta:get_string("christmas_msg")
	if not(christmas_msg) or christmas_msg == "" then
		christmas_msg = S("Merry Christmas")
	end
	local formspec =
		"size[8,7]" ..
		"image[0,0;1,1;petz_christmas_chest_inv.png]"..
		"label[1,0;"..christmas_msg.."]"..
		"list[nodemeta:" .. spos .. ";main;2,1.3;4,1;]" ..
		"list[current_player;main;0,2.85;8,1;]" ..
		"list[current_player;main;0,4.08;8,3;8]" ..
		"listring[nodemeta:" .. spos .. ";main]" ..
		"listring[current_player;main]" ..
		default.get_hotbar_bg(0,2.85)
	return formspec
end

function petz.chest.chest_lid_close(pn)
	local chest_open_info = petz.chest.open_chests[pn]
	local pos = chest_open_info.pos
	local sound = chest_open_info.sound
	local swap = chest_open_info.swap

	petz.chest.open_chests[pn] = nil
	for k, v in pairs(petz.chest.open_chests) do
		if v.pos.x == pos.x and v.pos.y == pos.y and v.pos.z == pos.z then
			return true
		end
	end

	local node = minetest.get_node(pos)
	minetest.after(0.2, minetest.swap_node, pos, { name = "petz:" .. swap,
			param2 = node.param2 })
	minetest.sound_play(sound, {gain = 0.3, pos = pos, max_hear_distance = 10})
end

minetest.register_on_leaveplayer(function(player)
	local pn = player:get_player_name()
	if petz.chest.open_chests[pn] then
		petz.chest.chest_lid_close(pn)
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "petz:chest" then
		return
	end
	if not player or not fields.quit then
		return
	end
	local pn = player:get_player_name()

	if not petz.chest.open_chests[pn] then
		return
	end

	petz.chest.chest_lid_close(pn)
	return true
end)

petz.christmas_cards = {}

minetest.register_on_leaveplayer(function(player)
    petz.christmas_cards[player:get_player_name()] = nil
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "petz:present_msg" then
		return
	end
	if not player or not fields.quit then
		return
	end

	local pos = petz.christmas_cards[player:get_player_name()]

	if pos and fields.christmas_msg then
		local meta = minetest.get_meta(pos)
		meta:set_string("christmas_msg", fields.christmas_msg)
	end

	return true
end)

function petz.register_chest(name, d)
	local def = table.copy(d)
	def.drawtype = "mesh"
	def.visual = "mesh"
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.legacy_facedir_simple = true
	def.is_ground_content = false

	def.on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", d.description)
		local inv = meta:get_inventory()
		inv:set_size("main", 4*1)
	end
	def.after_place_node = function(pos, placer, itemstack, pointed_thing)
		if placer:is_player() then
			local player_name = placer:get_player_name()
			local formspec =
				"size[6,4]"..
				"image[1,0;1,1;petz_christmas_card.png]"..
				"label[2,0;"..S("Christmas Card").."]"..
				"field[1,2;5,1;christmas_msg;"..S("Compose a message")..":;]"..
				"button_exit[2,3;2,1;write;"..S("Write").."]"
			petz.christmas_cards[player_name] = pos
			minetest.show_formspec(placer:get_player_name(), "petz:present_msg", formspec)
		end
	end
	def.can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end
	def.on_rightclick = function(pos, node, clicker)
		minetest.sound_play(def.sound_open, {gain = 0.3, pos = pos,
				max_hear_distance = 10})
		if not default.chest.chest_lid_obstructed(pos) then
			minetest.swap_node(pos, {
					name = "petz:" .. name .. "_open",
					param2 = node.param2 })
		end
		minetest.after(0.2, minetest.show_formspec,
				clicker:get_player_name(),
				"petz:chest", petz.chest.get_chest_formspec(pos))
		petz.chest.open_chests[clicker:get_player_name()] = { pos = pos, sound = def.sound_close, swap = name }
	end
	def.on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "main", drops)
		drops[#drops+1] = "petz:" .. name
		minetest.remove_node(pos)
		return drops
	end

	def.on_metadata_inventory_move = function(pos, from_list, from_index,
			to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in chest at " .. minetest.pos_to_string(pos))
	end
	def.on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" moves " .. stack:get_name() ..
			" to chest at " .. minetest.pos_to_string(pos))
	end
	def.on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes " .. stack:get_name() ..
			" from chest at " .. minetest.pos_to_string(pos))
	end

	local def_opened = table.copy(def)
	local def_closed = table.copy(def)

	def_opened.mesh = "chest_open.obj"
	for i = 1, #def_opened.tiles do
		if type(def_opened.tiles[i]) == "string" then
			def_opened.tiles[i] = {name = def_opened.tiles[i], backface_culling = true}
		elseif def_opened.tiles[i].backface_culling == nil then
			def_opened.tiles[i].backface_culling = true
		end
	end
	def_opened.drop = "petz:" .. name
	def_opened.groups.not_in_creative_inventory = 1
	def_opened.selection_box = {
		type = "fixed",
		fixed = { -1/2, -1/2, -1/2, 1/2, 3/16, 1/2 },
	}
	def_opened.can_dig = function()
		return false
	end
	def_opened.on_blast = function() end

	def_closed.mesh = nil
	def_closed.drawtype = nil
	def_closed.tiles[6] = def.tiles[5] -- swap textures around for "normal"
	def_closed.tiles[5] = def.tiles[3] -- drawtype to make them match the mesh
	def_closed.tiles[3] = def.tiles[3].."^[transformFX"

	minetest.register_node("petz:" .. name, def_closed)
	minetest.register_node("petz:" .. name .. "_open", def_opened)

end

petz.register_chest("christmas_present", {
	description = S("Christmas Present"),
	tiles = {
		"petz_christmas_chest_top.png",
		"petz_christmas_chest_top.png",
		"petz_christmas_chest_side.png",
		"petz_christmas_chest_side.png",
		"petz_christmas_chest_front.png",
		"petz_christmas_chest_inside.png"
	},
	stack_max = 1,
	sounds = default.node_sound_wood_defaults(),
	sound_open = "default_chest_open",
	sound_close = "default_chest_close",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
})

minetest.register_craft({
	type = "shaped",
	output = "petz:christmas_present",
	recipe = {
		{"default:paper", "default:paper", "default:paper"},
		{"dye:red", "default:chest", "dye:yellow"},
		{"default:paper", "default:paper", "default:paper"},
	}
})

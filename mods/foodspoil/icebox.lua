local TIME_SPEED = minetest.settings:get("time_speed") or 72
local DAY_LENGTH = 86400/TIME_SPEED

--chests edited from minetest_game CC BY-SA 3.0

function icebox_chest_lid_close(pn)
	local chest_open_info = icebox_open_chests[pn]
	local pos = chest_open_info.pos
	local sound = chest_open_info.sound
	local swap = chest_open_info.swap

	icebox_open_chests[pn] = nil
	for k, v in pairs(icebox_open_chests) do
		if v.pos.x == pos.x and v.pos.y == pos.y and v.pos.z == pos.z then
			return true
		end
	end

	local node = minetest.get_node(pos)
	minetest.after(0.2, minetest.swap_node, pos, { name = swap,
			param2 = node.param2 })
	minetest.sound_play(sound, {gain = 0.3, pos = pos,
		max_hear_distance = 10}, true)
end

icebox_open_chests = {}

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "icebox:chest" then
		return
	end
	if not player or not fields.quit then
		return
	end
	local pn = player:get_player_name()

	if not icebox_open_chests[pn] then
		return
	end

	icebox_chest_lid_close(pn)
	return true
end)

local function icebox_register_chest(prefixed_name, d)
	local name = prefixed_name
	local def = table.copy(d)
	def.drawtype = "mesh"
	def.visual = "mesh"
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.legacy_facedir_simple = true
	def.is_ground_content = false
	def.on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Icebox \n(0 ice)")
		meta:set_int("day", minetest.get_day_count())
		local inv = meta:get_inventory()
		inv:set_size("main", 8*2)
	end
	def.can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end
	def.on_rightclick = function(pos, node, clicker)
		minetest.sound_play(def.sound_open, {gain = 0.3, pos = pos,
				max_hear_distance = 10}, true)
		if not default.chest.chest_lid_obstructed(pos) then
			minetest.swap_node(pos, {
					name = name .. "_open",
					param2 = node.param2 })
		end
		minetest.after(0.2, minetest.show_formspec,
				clicker:get_player_name(),
				"icebox:chest", default.chest.get_chest_formspec(pos))
		icebox_open_chests[clicker:get_player_name()] = { pos = pos,
				sound = def.sound_close, swap = name }
	end
	def.on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "main", drops)
		drops[#drops+1] = name
		minetest.remove_node(pos)
		return drops
	end

	def.on_metadata_inventory_move = function(pos, from_list, from_index,
			to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in chest at " .. minetest.pos_to_string(pos))
	end
	def.on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "main" and stack:get_name() == "default:ice" then
			local icecount = 0
			local inv = minetest.get_inventory({type="node", pos=pos})
			local meta = minetest.get_meta(pos)
			for index = 1, inv:get_size("main") do
				local loopstack = inv:get_stack("main", index)
				if loopstack:get_name() == "default:ice" then
					icecount = icecount + loopstack:get_count()
				end
			end
			meta:set_string("infotext", "Icebox \n("..tostring(icecount).." ice)")
			if icecount == stack:get_count() then--if the only ice in the inv is what you jut put in start the "timer"
				meta:set_int("day", minetest.get_day_count())
			end
		end
		minetest.log("action", player:get_player_name() ..
			" moves " .. stack:get_name() ..
			" to chest at " .. minetest.pos_to_string(pos))
	end
	def.on_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname == "main" and stack:get_name() == "default:ice" then
			local icecount = 0
			local inv = minetest.get_inventory({type="node", pos=pos})
			local meta = minetest.get_meta(pos)
			for index = 1, inv:get_size("main") do
				local loopstack = inv:get_stack("main", index)
				if loopstack:get_name() == "default:ice" then
					icecount = icecount + loopstack:get_count()
				end
			end
			meta:set_string("infotext", "Icebox \n("..tostring(icecount).." ice)")
			if icecount == 0 then--all out of ice :(
				meta:set_int("day", minetest.get_day_count())
			end
		end
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
	def_opened.drop = name
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

	minetest.register_node(prefixed_name, def_closed)
	minetest.register_node(prefixed_name .. "_open", def_opened)
end

icebox_register_chest("foodspoil:icebox", {
	description = "Icebox",
	tiles = {
		"technic_silver_chest_top.png",
		"technic_silver_chest_top.png",
		"technic_silver_chest_side.png",
		"technic_silver_chest_side.png",
		"technic_silver_chest_front.png",
		"technic_silver_chest_inside.png"
	},
	sounds = default.node_sound_wood_defaults(),
	sound_open = "default_chest_open",
	sound_close = "default_chest_close",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		--local timer = minetest.get_node_timer(pos)
		--timer:start(ice_consume_time)
	end,
	on_timer = function(pos, elapsed)
		
	end,
})

local function handle_icebox(pos, node)
	local meta = minetest.get_meta(pos)
	local day = minetest.get_day_count()
	local metaday = meta:get_int("day")
	local icecount = 0
	if metaday == 0 then meta:set_int("day", day) return end--todo change behavior when there is no ice
	if day-metaday < 2 then return end--two days have not passed
	local inv = minetest.get_inventory({type="node", pos=pos})
	if not inv or inv.type == "undefined" then return end
	for i = 1, math.floor((day-metaday)/2) do
		if inv:contains_item("main", "default:ice") then
			inv:remove_item("main", "default:ice")
			for index = 1, inv:get_size("main") do
				local stack = inv:get_stack("main", index)
				local name = stack:get_name()
				if name == "default:ice" then
					icecount = icecount + stack:get_count()
				end
				local stackmeta = stack:get_meta()
				local expire = stackmeta:get_int("ed")
				if expire ~= 0 then
					stackmeta:set_int("ed", expire+1)
					stackmeta:set_string("description", minetest.registered_items[name].description.." ed: "..expire+1)
					inv:set_stack("main", index, stack)
				end
			end
		else
			break
		end
	end
	meta:set_int("day", day)
	meta:set_string("infotext", "Icebox \n("..tostring(icecount).." ice)")
end

minetest.register_craft{
        output = 'foodspoil:icebox',
        recipe = {
            {'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
            {'default:steel_ingot', 'group:wool', 'default:steel_ingot'},
            {'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},  -- Also groups; e.g. 'group:crumbly'
        },
    }


minetest.register_abm({
	label = "Icebox ABM",
	nodenames = {"foodspoil:icebox", "foodspoil:icebox_open"},
	interval = DAY_LENGTH/4,
	chance = 1,
	catch_up = false,
	action = handle_icebox
})

minetest.register_lbm({
	label = "Icebox LBM",
	name = "foodspoil:icehandler",
	nodenames = {"foodspoil:icebox", "foodspoil:icebox_open"},
	run_at_every_load = true,
	action = handle_icebox
})
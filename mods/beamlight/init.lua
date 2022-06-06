local players = {}
local player_positions = {}
local last_wielded = {}
local ticktime = .075
local serverstep = tonumber(minetest.settings:get("dedicated_server_step")) or 0.09
if ticktime < serverstep then ticktime = serverstep*1.1 end
local range = 12

local function placelight(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		local timer = minetest.get_node_timer(pos)
		timer:start(ticktime*3)
		--minetest.chat_send_all("restarted")
	elseif node.name == "air" or string.find(node.name, 'beamlight:light_') or minetest.get_item_group(node.name, "light_replaceable") > 0 then
		minetest.set_node(pos, {name=name})
		--minetest.chat_send_all("placed")
	end
end

local function make_beam(pos, dir, length)
	--placelight(pos, "beamlight:light_3")
	if not length then length = 1 end
	if length > 4 then length = 4 end
	for i=1, length do
		if length == 1 then
			placelight(pos, "beamlight:light_"..i)
			return
		end
		local p1
		local p2
		if i == 1 then 
			p1 = pos
			p2 = vector.add(p1, vector.multiply(dir, (range/4)*i))
		else
			p1 = vector.add(pos, vector.multiply(dir, (range/4)*(i-1)))
			p2 = vector.add(pos, vector.multiply(dir, (range/4)*(i)))
		end
		local ray = minetest.raycast(p1, p2, false, true)
		local hit = false
		for pointed in ray do
			if pointed and pointed.ref and pointed.ref == player then
				goto next
			end
			if pointed.intersection_point and pointed.type == "node" then
				local node = minetest.get_node(pointed.under)
				if minetest.registered_nodes[node.name].sunlight_propagates == true then
					goto next
				end
			end
			hit = true
			if pointed.intersection_point then
				placelight(pointed.above, "beamlight:light_"..i)
				break
			end
			::next::
		end
		if not hit then
			placelight(p2, "beamlight:light_"..i)
		else
			break
		end
	end
end
beamlight = {}
beamlight.beams = {}

local i = 0
minetest.register_globalstep(function(dtime)
	i = i + dtime
	if i > ticktime then
		i = 0
	else
		return
	end
	--[[for i,player in ipairs(minetest.get_connected_players()) do
		local wielded_item = player:get_wielded_item():get_name()
		if wielded_item == "default:torch" or wielded_item == "xdecor:candle" or wielded_item == "xdecor:lantern" then
			beamlight.beams[player:get_player_name()] = {player = player}
		else
			beamlight.beams[player:get_player_name()] = nil
		end
	end--]]
	for name, data in pairs (beamlight.beams) do
		if data.player then
			if data.player:is_player() then
				local dir = data.player:get_look_dir()
				local eye_offset = {x = 0, y = 1.45, z = 0}
				local eyepos = vector.add(data.player:get_pos(), eye_offset)
				make_beam(eyepos, dir, data.length)
			else
				beamlight.beams[name] = nil
			end
		elseif data.object then
			local dir = data.object:get_yaw()
			if dir then
				dir = minetest.yaw_to_dir(dir)
				local pos = vector.add(data.object:get_pos(), {x=0,y=data.y or .5,z=0})
				if data.x then
					pos = vector.add(pos, vector.multiply(dir, data.x))
				end
				make_beam(pos, dir, data.length)
			else
				beamlight[name] = nil
			end
		elseif data.pos and data.dir then
			make_beam(data.pos, vector.normalize(data.dir), data.length)
		else
			beamlight.beams[name] = nil
		end
	end
end)

--[[minetest.register_on_leaveplayer(function(player, timed_out)
	beamlight.beams[player:get_player_name()] = nil
end)--]]

minetest.register_node("beamlight:light_1", {
	drawtype = "glasslike",
	tile_images = {"beamlight.png"},
	 --tile_images = {"beamlight_debug.png"},
	inventory_image = minetest.inventorycube("beamlight.png"),
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	light_propagates = true,
	sunlight_propagates = true,
	buildable_to = true,
	light_source = 13,
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		if not timer:is_started() then
			timer:start(ticktime*3)
		end
	end,
	on_timer = function(pos, elapsed)
		local node = minetest.get_node(pos)
		if node.name == "beamlight:light_1" then
			minetest.remove_node(pos)
		end
	end,
	selection_box = {
        type = "fixed",
        fixed = {0, 0, 0, 0, 0, 0},
    },
})

minetest.register_node("beamlight:light_2", {
	drawtype = "glasslike",
	tile_images = {"beamlight.png"},
	 --tile_images = {"beamlight_debug.png"},
	inventory_image = minetest.inventorycube("beamlight.png"),
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	light_propagates = true,
	sunlight_propagates = true,
	buildable_to = true,
	light_source = 9,
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		if not timer:is_started() then
			timer:start(ticktime*3)
		end
	end,
	on_timer = function(pos, elapsed)
		local node = minetest.get_node(pos)
		if node.name == "beamlight:light_2" then
			minetest.remove_node(pos)
		end
	end,
	selection_box = {
        type = "fixed",
        fixed = {0, 0, 0, 0, 0, 0},
    },
})

minetest.register_node("beamlight:light_3", {
	drawtype = "glasslike",
	tile_images = {"beamlight.png"},
	 --tile_images = {"beamlight_debug.png"},
	inventory_image = minetest.inventorycube("beamlight.png"),
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	light_propagates = true,
	sunlight_propagates = true,
	buildable_to = true,
	light_source = 7,
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		if not timer:is_started() then
			timer:start(ticktime*3)
		end
	end,
	on_timer = function(pos, elapsed)
		local node = minetest.get_node(pos)
		if node.name == "beamlight:light_3" then
			minetest.remove_node(pos)
		end
	end,
	selection_box = {
        type = "fixed",
        fixed = {0, 0, 0, 0, 0, 0},
    },
})

minetest.register_node("beamlight:light_4", {
	drawtype = "glasslike",
	tile_images = {"beamlight.png"},
	 --tile_images = {"beamlight_debug.png"},
	inventory_image = minetest.inventorycube("beamlight.png"),
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	light_propagates = true,
	sunlight_propagates = true,
	buildable_to = true,
	light_source = 5,
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		if not timer:is_started() then
			timer:start(ticktime*3)
		end
	end,
	on_timer = function(pos, elapsed)
		local node = minetest.get_node(pos)
		if node.name == "beamlight:light_4" then
			minetest.remove_node(pos)
		end
	end,
	selection_box = {
        type = "fixed",
        fixed = {0, 0, 0, 0, 0, 0},
    },
})

minetest.register_abm({
	nodenames = {"beamlight:light_1", "beamlight:light_2", "beamlight:light_3", "beamlight:light_4"},
	interval = 10,
	chance = 1,
	catch_up = false,
	action = function(pos, node, _, _)
		local timer = minetest.get_node_timer(pos)
		if not timer:is_started() or timer:get_elapsed() > ticktime*3 then
			minetest.remove_node(pos)
		end
	end,
})

minetest.register_lbm({
	name = "beamlight:remove",
	nodenames = {"beamlight:light_1", "beamlight:light_2", "beamlight:light_3", "beamlight:light_4"},
	run_at_every_load = true,
	action = function(pos, node, _, _)
		local timer = minetest.get_node_timer(pos)
		if not timer:is_started() or timer:get_elapsed() > ticktime*3 then
			minetest.remove_node(pos)
		end
	end,
})
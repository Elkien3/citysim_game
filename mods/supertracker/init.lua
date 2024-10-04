local storage = minetest.get_mod_storage()
local settings = minetest.settings
local active_chunks = minetest.deserialize(storage:get_string("active")) or {}
local last_track = minetest.deserialize(storage:get_string("last_track")) or {}

local track_distance = settings:get("supertracker.track_distance") or 16 --distance between virtual tracks laid by players
local detect_range = settings:get("supertracker.detect_range") or 32 --distance the tracker can find tracks.
local chunk_size = settings:get("supertracker.chunk_size") or 100 --changing this after data is already written will have unexpected results
local load_interval = settings:get("supertracker.load_interval") or 2 --time in seconds to check for new chunks that need to be loaded or unloaded
local track_interval = settings:get("supertracker.track_interval") or .5 --time in seconds to check if a player should put down a new track
local track_expire = settings:get("supertracker.track_expire") or 7*86400 --time in seconds for a track to expire and be deleted
local last_known_accuracy = settings:get("supertracker.last_known_accuracy") or 0 --approxamate accuracy of the "last known chunk" tracker function, set to <1 to disable entirely
local car_last_known_accuracy = settings:get("supertracker.car_last_known_accuracy") or 100 --same as above, but for cars
local car_last_known_accuracy_mode = 6
if not cars then
	car_last_known_accuracy = 0
elseif last_known_accuracy < 1 then
	car_last_known_accuracy_mode = 5
end
local chestlist = {"default:chest", "default:chest_open", "default:chest_locked", "default:chest_locked_open", "digilines:chest", "currency:safe", "currency:shop", "xdecor:cabinet", "xdecor:cabinet_half", "xdecor:barrel", "inbox:empty", "inbox:full", "package:package", "foodspoil:icebox", "foodspoil:icebox_open", "foodspoil:icebox_locked", ""foodspoil:icebox_locked_open"}

local function is_table_empty(tbl)
	for _ in pairs(tbl) do
		return false
	end
	return true
end

local function get_table_size(tbl)
	i = 0
	for _ in pairs(tbl) do
		i = i + 1
	end
	return i
end

local function save_active()
	storage:set_string("active", minetest.serialize(active_chunks))
end

local function cull_chunk(chunkpos, time)
	local time = time or os.time()
	if not chunkpos or not active_chunks[chunkpos] then return end
	for name, tracktbl in pairs(active_chunks[chunkpos]) do
		local lastindex
		for i, tbl in pairs(tracktbl) do
			if time - tbl[2] < track_expire then
				lastindex = i
				break
			end
		end
		if not lastindex then--all tracks for this player are expired, remove the name from the chunk
			active_chunks[chunkpos][name] = nil
			--minetest.chat_send_all("yeet")
		else
			local newtbl = {}
			table.move(tracktbl, lastindex, get_table_size(tracktbl), 1, newtbl)--new table, starting from the first track that isnt expired
			--minetest.chat_send_all(dump(tracktbl))
			--minetest.chat_send_all(dump(newtbl))
			--minetest.chat_send_all(lastindex)
			active_chunks[chunkpos][name] = newtbl
		end
	end
end

local function load_chunk(chunkpos)
	if not chunkpos or active_chunks[chunkpos] then return end-- if no chunk given or if its already loaded then return
	active_chunks[chunkpos] = minetest.deserialize(storage:get_string(chunkpos)) or {}
	save_active()
	--minetest.chat_send_all("loaded chunk "..chunkpos)
end

local function unload_chunk(chunkpos, write, time)
	if not chunkpos or not active_chunks[chunkpos] then return end --if no chunk given or is not loaded then return
	cull_chunk(chunkpos, time)
	
	if is_table_empty(active_chunks[chunkpos]) then
		storage:set_string(chunkpos, "")
		--minetest.chat_send_all("is empty")
	else
		storage:set_string(chunkpos, minetest.serialize(active_chunks[chunkpos]))
	end
	
	active_chunks[chunkpos] = nil
	if write ~= false then
		save_active()
	end
	--minetest.chat_send_all("unloaded chunk "..chunkpos)
end

local function unload_chunks(chunklist)
	if not chunklist or type(chunklist) ~= "table" then return end
	local time = os.time()
	for chunk, _ in pairs(chunklist) do
		unload_chunk(chunk, false, time)
	end
	save_active()
end

local function get_chunk(pos)
	return minetest.pos_to_string(vector.floor(vector.divide(pos, chunk_size)))
end

local function get_chunk_pos(chunkpos)
	return vector.multiply(minetest.string_to_pos(chunkpos), chunk_size)
end

local function get_chunks_in_range(pos, range)
	local r = range or detect_range
	local nearby_chunks = {}
	for i, checkpos in pairs({{x=0,y=0,z=0}, {x=r, y=r, z=0}, {x=-r, y=r, z=0}, {x=0, y=r, z=r}, {x=0, y=r, z=-r}, {x=r, y=-r, z=0}, {x=-r, y=-r, z=0}, {x=0, y=-r, z=r}, {x=0, y=-r, z=-r} }) do
		local chunk = get_chunk(vector.add(pos, checkpos))
		nearby_chunks[chunk] = true
	end
	return nearby_chunks
end

local function cull_tracks()
	local time = os.time()
	local storagetbl = storage:to_table()
	for chunk, chunktbl in pairs(storagetbl.fields) do
		local deserialized = minetest.deserialize(chunktbl)
		if chunk ~= "active" and chunk ~= "last_track" and deserialized then
			for name, tracktbl in pairs(deserialized) do
				for i, tbl in pairs(tracktbl) do
					if time-tbl[2] > track_expire then
						tracktbl[i] = nil
					end
				end
				if is_table_empty(tracktbl) then
					deserialized[name] = nil
				end
			end
			if is_table_empty(deserialized) then
				storagetbl.fields[chunk] = nil
			end
		end
	end
	storage:from_table(storagetbl)
end

local function delete_all_tracks()
	storage:from_table({})
	active_chunks = {}
	last_track = {}
end

local function get_closest_track(pos, name)
	local dist
	local closesttbl
	local time = os.time()
	local nearby_chunks = get_chunks_in_range(pos)
	for chunk, _ in pairs(nearby_chunks) do
		if active_chunks[chunk] and active_chunks[chunk][name] then
			for i, tbl in pairs(active_chunks[chunk][name]) do
				if time-tbl[2] < track_expire and vector.distance(tbl[1], pos) <= detect_range then
					local newdist = vector.distance(tbl[1], pos)
					if not dist or newdist < dist then
						dist = newdist
						closesttbl = tbl
					end
				end
			end
		end
	end
	return closesttbl
end

local function get_oldest_track(pos, name)
	local oldest
	local oldesttbl
	local time = os.time()
	local nearby_chunks = get_chunks_in_range(pos)
	for chunk, _ in pairs(nearby_chunks) do
		if active_chunks[chunk] and active_chunks[chunk][name] then
			for i, tbl in pairs(active_chunks[chunk][name]) do
				if time-tbl[2] < track_expire and vector.distance(tbl[1], pos) <= detect_range then
					if not oldest or tbl[2] < oldest then
						oldest = tbl[2]
						oldesttbl = tbl
						break--we can break since following indexes will always be newer
					end
				end
			end
		end
	end
	return oldesttbl
end

local function get_newest_track(pos, name)
	local newest
	local newesttbl
	local time = os.time()
	local nearby_chunks = get_chunks_in_range(pos)
	for chunk, _ in pairs(nearby_chunks) do
		if active_chunks[chunk] and active_chunks[chunk][name] then
			for i, tbl in pairs(active_chunks[chunk][name]) do
				if time-tbl[2] < track_expire and vector.distance(tbl[1], pos) <= detect_range then
					if not newest or tbl[2] > newest then
						newest = tbl[2]
						newesttbl = tbl--todo reverse the search order so i can break here
					end
				end
			end
		end
	end
	return newesttbl
end

local function load_tick() --this timed function will handle automatic loading and unloading of chunks. todo: maybe make people that arent tracking just load the chunk they are in.
	local nearby_chunks = {}
	for i, player in pairs(minetest.get_connected_players()) do
		local pos = vector.round(player:get_pos())
		local name = player:get_player_name()
		for chunk, _ in pairs(get_chunks_in_range(pos, math.min(detect_range*1.5, chunk_size/2))) do
			nearby_chunks[chunk] = true
			load_chunk(chunk)
		end
	end
	
	local chunks_to_unload = {} --unload active chunks that are now out of range
	for chunk, _ in pairs(active_chunks) do
		if not nearby_chunks[chunk] then
			chunks_to_unload[chunk] = true
		end
	end
	unload_chunks(chunks_to_unload)
	minetest.after(load_interval, load_tick)
end
load_tick()

local function track_tick()
	local update = false
	local time = os.time()
	for i, player in pairs(minetest.get_connected_players()) do
		local pos = vector.round(player:get_pos())
		local name = player:get_player_name()
		if not last_track[name] or vector.distance(last_track[name], pos) > track_distance then
			update = true
			last_track[name] = pos
			local chunk = get_chunk(pos)
			load_chunk(chunk)
			if not active_chunks[chunk][name] then
				active_chunks[chunk][name] = {}
			end
			local trackinfo = {pos, time}
			table.insert(active_chunks[chunk][name], trackinfo)
		end
	end
	if update then
		storage:set_string("last_track", minetest.serialize(last_track))
		save_active()
	end
	minetest.after(track_interval, track_tick)
end
track_tick()

minetest.register_on_shutdown(function()
	unload_chunks(active_chunks)
end)

minetest.register_chatcommand("cull_tracks", {
    params = "",
    description = "checks all old tracks",
    privs = {server = true},
    func = function(name, param)
		cull_tracks()
		return true, "Culled all old tracks"
    end
})

minetest.register_chatcommand("delete_all_tracks", {
    params = "",
    description = "deletes all tracks",
    privs = {server = true},
    func = function(name, param)
		delete_all_tracks()
		return true, "deleted all tracks"
    end
})

local function generate_tracker_form(target_default, mode_selected_item)

    local form = "size[4,4]" ..
    "field[0.5,0.7;3.7,1;target;Target;"..minetest.formspec_escape(target_default).."]" ..
    "label[0.2,1.2;Tracking Mode]" ..
    "dropdown[0.21,1.6;3.79,1;mode;Chest,Newest,Oldest,Closest"
	if last_known_accuracy > 0 then
		form = form..",Last known"
	end
	if car_last_known_accuracy > 0 then
		form = form..",Car last known"
	end
	form = form..";"..tostring(mode_selected_item)..";true]" ..
    "button_exit[2.5,2.9;1.5,1;accept;Accept]"

    return form
end

local hudlist = {}
local hudtimers = {}

local function add_hud(player, pos, name)
	local playername = player:get_player_name()
	local marker = player:hud_add({
		hud_elem_type = "waypoint",
		name = name,
		number = 0xFF0000,
		world_pos = pos
	})
	if not hudlist[playername] then hudlist[playername] = {} end
	table.insert(hudlist[playername], marker)
	hudtimers[playername] = 10
end

local function remove_huds(player)
	local name = player and player:get_player_name()
	if not name or not hudlist[name] then return end
	for key, val in pairs(hudlist[name]) do
		player:hud_remove(val)
	end
	hudlist[name] = nil
end

minetest.register_globalstep(function(dtime)
	for name, timer in pairs(hudtimers) do
		hudtimers[name] = timer - dtime
		if timer <= 0 then
			remove_huds(minetest.get_player_by_name(name))
			hudtimers[name] = nil
			hudlist[name] = nil
		end
	end
end)

local function on_tracker_use(itemstack, player, pointed_thing, place)
	local meta = itemstack:get_meta()
	local mode = meta:get_int("mode")
	if mode == 0 then mode = 1 end
	if (last_known_accuracy < 1 and car_last_known_accuracy < 0 and mode == 5) or (car_last_known_accuracy < 1 and mode == 6) then
		mode = 1
	end
	local target = meta:get_string("target") or ""
	if place then
		minetest.show_formspec(player:get_player_name(), "supertracker:tracker", generate_tracker_form(target, mode))
	else
		remove_huds(player)
		local pos = vector.round(player:get_pos())
		if mode == 1 then--chest mode
			local chests = minetest.find_nodes_in_area(vector.subtract(pos, detect_range), vector.add(pos, detect_range), chestlist)
			if chests then
				for _, chestpos in pairs(chests) do
					if vector.distance(pos, chestpos) <= detect_range then
						add_hud(player, chestpos, "")
					end
				end
			end
		elseif mode == car_last_known_accuracy_mode then
			local carpos = cars.get_car_pos(target)
			if carpos then
				carpos = vector.add(vector.multiply(vector.floor(vector.divide(carpos, car_last_known_accuracy)), car_last_known_accuracy), car_last_known_accuracy/2)
				add_hud(player, carpos, "Car last known (within "..car_last_known_accuracy..")")
			end
		elseif mode == 5 then--last know position mode
			if last_track[target] then
				local lastchunk = vector.add(vector.multiply(vector.floor(vector.divide(last_track[target], last_known_accuracy)), last_known_accuracy), last_known_accuracy/2)
				add_hud(player, lastchunk, "Last known (within "..last_known_accuracy..")")
			end
		else
			local tbl
			local string
			if mode == 2 then
				string = "newest"
				tbl = get_newest_track(pos, target)
			elseif mode == 3 then
				string = "oldest"
				tbl = get_oldest_track(pos, target)
			elseif mode == 4 then
				string = "closest"
				tbl = get_closest_track(pos, target)
			end
			if string and tbl then
				local timeago = os.time()-tbl[2]
				add_hud(player, tbl[1], string.." ("..timeago.." seconds ago)")
			end
		end
	end
end

minetest.register_craftitem("supertracker:tracker", {
    description = "Super Tracker 7800",
    inventory_image = "tracker_gps_variant.png",
    stack_max = 1,
    on_place = function(itemstack, player, pointed_thing)
		on_tracker_use(itemstack, player, pointed_thing, true)
	end,
    on_secondary_use = function(itemstack, player, pointed_thing)
		on_tracker_use(itemstack, player, pointed_thing, true)
	end,
    on_use = function(itemstack, player, pointed_thing)
		on_tracker_use(itemstack, player, pointed_thing, false)
	end,
})

if minetest.get_modpath("mesecons_detector") and minetest.get_modpath("default") and minetest.get_modpath("technic") and minetest.get_modpath("digilines") and minetest.get_modpath("mesecons_button") then
	minetest.register_craft({
		output = "supertracker:tracker",
		recipe = {
			{"mesecons_detector:node_detector_off", "default:mese_crystal", "mesecons_detector:object_detector_off"},
			{"technic:control_logic_unit", "digilines:lcd", "technic:battery"},
			{"default:steel_ingot", "mesecons_button:button_off", "default:steel_ingot"},
		}
	})
elseif minetest.get_modpath("default") then
	minetest.register_craft({
		output = "supertracker:tracker",
		recipe = {
			{"default:mese_crystal", "default:diamond", "default:mese_crystal"},
			{"default:diamond", "default:obsidian_glass", "default:diamond"},
			{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		}
	})
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "supertracker:tracker" then return end
	if not fields.quit then return end
	if not minetest.check_player_privs(player, {interact = true}) then return end
	local wielditem = player:get_wielded_item()
	if wielditem:get_name() ~= "supertracker:tracker" then return end
	local meta = wielditem:get_meta()
	--minetest.chat_send_all(dump(fields))
	if fields.target then
		meta:set_string("target", fields.target)
	end
	if fields.mode then
		meta:set_int("mode", tonumber(fields.mode) or 1)
	end
	player:set_wielded_item(wielditem)
end)
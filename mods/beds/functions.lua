local pi = math.pi
local is_sp = minetest.is_singleplayer()
local enable_respawn = minetest.settings:get_bool("enable_bed_respawn")
if enable_respawn == nil then
	enable_respawn = true
end

-- support for MT game translation.
local S = beds.get_translator

-- Helper functions

local function get_look_yaw(pos)
	local rotation = minetest.get_node(pos).param2
	if rotation > 3 then
		rotation = rotation % 4 -- Mask colorfacedir values
	end
	if rotation == 1 then
		return pi / 2, rotation
	elseif rotation == 3 then
		return -pi / 2, rotation
	elseif rotation == 0 then
		return pi, rotation
	else
		return 0, rotation
	end
end

local function is_night_skip_enabled()
	local enable_night_skip = minetest.settings:get_bool("enable_bed_night_skip")
	if enable_night_skip == nil then
		enable_night_skip = true
	end
	local tod = minetest.get_timeofday()
	if tod > 0.2 and tod < 0.805 then
		enable_night_skip = false
	end
	return enable_night_skip
end

local function check_in_beds(players)
	local in_bed = beds.player
	if not players then
		players = minetest.get_connected_players()
	end

	for n, player in ipairs(players) do
		local name = player:get_player_name()
		if not in_bed[name] then
			return false
		end
	end

	return #players > 0
end

local function lay_down(player, pos, bed_pos, state, skip)
	local name = player:get_player_name()
	local hud_flags = player:hud_get_flags()

	if not player or not name then
		return
	end

	-- stand up
	if state ~= nil and not state then
		local p = beds.pos[name] or nil
		beds.player[name] = nil
		beds.bed_position[name] = nil
		-- skip here to prevent sending player specific changes (used for leaving players)
		if skip then
			return
		end
		if p then
			player:set_pos(p)
		end

		-- physics, eye_offset, etc
		player:set_eye_offset({x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
		player:set_look_horizontal(math.random(1, 180) / 100)
		player_api.player_attached[name] = false
		if playercontrol then
			playercontrol.set_effect(name, "speed", 1, "beds", true)
		else
			player:set_physics_override({speed = 1, gravity = 1, jump = 1})
		end
		hud_flags.wielditem = true
		player_api.set_animation(player, "stand" , 30)

	-- lay down
	else
		beds.pos[name] = pos
		beds.bed_position[name] = bed_pos
		beds.player[name] = 1

		-- physics, eye_offset, etc
		player:set_eye_offset({x = 0, y = -13, z = 0}, {x = 0, y = 0, z = 0})
		local yaw, param2 = get_look_yaw(bed_pos)
		player:set_look_horizontal(yaw)
		local dir = minetest.facedir_to_dir(param2)
		-- p.y is just above the nodebox height of the 'Simple Bed' (the highest bed),
		-- to avoid sinking down through the bed.
		local p = {
			x = bed_pos.x + dir.x / 2,
			y = bed_pos.y + 0.07,
			z = bed_pos.z + dir.z / 2
		}
		if playercontrol then
			playercontrol.set_effect(name, "speed", 0, "beds", true)
		else
			player:set_physics_override({speed = 0, gravity = 0, jump = 0})
		end
		player:set_pos(p)
		player_api.player_attached[name] = true
		hud_flags.wielditem = false
		player_api.set_animation(player, "lay" , 0)
	end

	player:hud_set_flags(hud_flags)
end

local function get_player_in_bed_count()
	local c = 0
	for _, _ in pairs(beds.player) do
		c = c + 1
	end
	return c
end

local function update_formspecs(finished)
	local ges = #minetest.get_connected_players()
	local player_in_bed = get_player_in_bed_count()
	local is_majority = (ges / 2) < player_in_bed

	local form_n
	local esc = minetest.formspec_escape
	if finished then
		form_n = beds.formspec .. "label[2.7,9;" .. esc(S("Good morning.")) .. "]"
	else
		form_n = beds.formspec .. "label[2.2,9;" ..
			esc(S("@1 of @2 players are in bed", player_in_bed, ges)) .. "]"
		if is_majority and is_night_skip_enabled() then
			form_n = form_n .. "button_exit[2,6;4,0.75;force;" ..
				esc(S("Force night skip")) .. "]"
		end
	end

	for name,_ in pairs(beds.player) do
		minetest.show_formspec(name, "beds_form", form_n)
	end
end


-- Public functions

function beds.kick_players()
	for name, _ in pairs(beds.player) do
		local player = minetest.get_player_by_name(name)
		lay_down(player, nil, nil, false)
	end
end

function beds.skip_night()
	minetest.set_timeofday(0.23)
end

function beds.on_rightclick(pos, player)
	local name = player:get_player_name()
	local ppos = player:get_pos()
	local tod = minetest.get_timeofday()

	--[[if tod > 0.2 and tod < 0.805 then
		if beds.player[name] then
			lay_down(player, nil, nil, false)
		end
		minetest.chat_send_player(name, S("You can only sleep at night."))
		return
	end--]]

	-- move to bed
	if not beds.player[name] then
		lay_down(player, ppos, pos)
		beds.set_spawns() -- save respawn positions when entering bed
	else
		lay_down(player, nil, nil, false)
	end

	if not is_sp then
		update_formspecs(false)
	end

	-- skip the night and let all players stand up
	if check_in_beds() then
		minetest.after(2, function()
			if not is_sp then
				update_formspecs(is_night_skip_enabled())
			end
			if is_night_skip_enabled() then
				beds.skip_night()
				beds.kick_players()
			end
		end)
	end
end

function beds.can_dig(bed_pos)
	-- Check all players in bed which one is at the expected position
	for _, player_bed_pos in pairs(beds.bed_position) do
		if vector.equals(bed_pos, player_bed_pos) then
			return false
		end
	end
	return true
end

-- Callbacks
-- Only register respawn callback if respawn enabled
if enable_respawn then
	-- respawn player at bed if enabled and valid position is found
	minetest.register_on_respawnplayer(function(player)
		local name = player:get_player_name()
		local pos = beds.spawn[name]
		if pos then
			player:set_pos(pos)
			return true
		end
	end)
end

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	lay_down(player, nil, nil, false, true)
	beds.player[name] = nil
	if check_in_beds() then
		minetest.after(2, function()
			update_formspecs(is_night_skip_enabled())
			if is_night_skip_enabled() then
				beds.skip_night()
				beds.kick_players()
			end
		end)
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "beds_form" then
		return
	end

	-- Because "Force night skip" button is a button_exit, it will set fields.quit
	-- and lay_down call will change value of player_in_bed, so it must be taken
	-- earlier.
	local last_player_in_bed = get_player_in_bed_count()

	if fields.quit or fields.leave then
		lay_down(player, nil, nil, false)
		update_formspecs(false)
	end

	if fields.force then
		local is_majority = (#minetest.get_connected_players() / 2) < last_player_in_bed
		if is_majority and is_night_skip_enabled() then
			update_formspecs(true)
			beds.skip_night()
			beds.kick_players()
		else
			update_formspecs(false)
		end
	end
end)


local enable_crash = true
local crash_threshold = 6.5		-- ignored if enable_crash=false

------------------------------------------------------------------------------

local mobs_redo = false
if minetest.get_modpath("mobs") then
	if mobs.mod and mobs.mod == "redo" then
		mobs_redo = true
	end
end

--
-- Helper functions
--

--local function is_group(pos, group)
--	local nn = minetest.get_node(pos).name
--	return minetest.get_item_group(nn, group) ~= 0
--end

local function node_is(pos)
	local node = minetest.get_node(pos)
	if node.name == "air" then
		return "air"
	end
	if minetest.get_item_group(node.name, "liquid") ~= 0 then
		return "liquid"
	end
	if minetest.get_item_group(node.name, "walkable") ~= 0 then
		return "walkable"
	end
	return "other"
end

local function get_sign(i)
	i = i or 0
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
end

local function get_velocity(v, yaw, y)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x = x, y = y, z = z}
end

local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

local function force_detach(player)
	local attached_to = player:get_attach()
	if attached_to then
		local entity = attached_to:get_luaentity()
		if entity.driver and entity.driver == player then
			entity.driver = nil
		elseif entity.passenger and entity.passenger == player then
			entity.passenger = nil
		end
		player:set_detach()
		default.player_attached[player:get_player_name()] = false
		player:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
	end
end

-------------------------------------------------------------------------------


minetest.register_on_leaveplayer(function(player)
	force_detach(player)
end)

minetest.register_on_shutdown(function()
    local players = minetest.get_connected_players()
	for i = 1,#players do
		force_detach(players[i])
	end
end)

minetest.register_on_dieplayer(function(player)
	force_detach(player)
	return true
end)

-------------------------------------------------------------------------------


lib_mount = {}

function lib_mount.attach(entity, player, is_passenger)
	local attach_at, eye_offset = {}, {}
	
	if not entity.player_rotation then
		entity.player_rotation = {x=0, y=0, z=0}
	end
	
	local rot_view = 0
	if entity.player_rotation.y == 90 then
		rot_view = math.pi/2
	end

	if is_passenger == true then
		if not entity.passenger_attach_at then
			entity.passenger_attach_at = {x=0, y=0, z=0}
		end
		if not entity.passenger_eye_offset then
			entity.passenger_eye_offset = {x=0, y=0, z=0}
		end 
		attach_at = entity.passenger_attach_at
		eye_offset = entity.passenger_eye_offset
		entity.passenger = player
	else
		if not entity.driver_attach_at then
			entity.driver_attach_at = {x=0, y=0, z=0}
		end
		if not entity.driver_eye_offset then
			entity.driver_eye_offset = {x=0, y=0, z=0}
		end 
		attach_at = entity.driver_attach_at
		eye_offset = entity.driver_eye_offset
		entity.driver = player
	end

	force_detach(player)

	player:set_attach(entity.object, "", attach_at, entity.player_rotation)
	default.player_attached[player:get_player_name()] = true
	player:set_eye_offset(eye_offset, {x=0, y=0, z=0})
	minetest.after(0.2, function()
		default.player_set_animation(player, "sit" , 30)
	end)
	player:set_look_yaw(entity.object:getyaw() - rot_view)
end

function lib_mount.detach(player, offset)
	force_detach(player)
	default.player_set_animation(player, "stand" , 30)
	local pos = player:getpos()
	pos = {x = pos.x + offset.x, y = pos.y + 0.2 + offset.y, z = pos.z + offset.z}
	minetest.after(0.1, function()
		player:setpos(pos)
	end)
end

local aux_timer = 0

function lib_mount.drive(entity, dtime, is_mob, moving_anim, stand_anim, jump_height, can_fly)
	aux_timer = aux_timer + dtime
	
	if can_fly and can_fly == true then
		jump_height = 0
	end

	local rot_steer, rot_view = math.pi/2, 0
	if entity.player_rotation.y == 90 then
		rot_steer, rot_view = 0, math.pi/2
	end

	local acce_y = 0

	local velo = entity.object:getvelocity()
	entity.v = get_v(velo) * get_sign(entity.v)

	-- process controls
	if entity.driver then
		local ctrl = entity.driver:get_player_control()
		if ctrl.aux1 then
			if aux_timer >= 0.2 then
				entity.mouselook = not entity.mouselook
				aux_timer = 0
			end
		end
		if ctrl.up then
			if get_sign(entity.v) >= 0 then
				entity.v = entity.v + entity.accel/10
			else
				entity.v = entity.v + entity.braking/10
			end
		elseif ctrl.down then
			if entity.max_speed_reverse == 0 and entity.v == 0 then return end
			if get_sign(entity.v) < 0 then
				entity.v = entity.v - entity.accel/10
			else
				entity.v = entity.v - entity.braking/10
			end
		end
		if entity.mouselook then
			if ctrl.left then
				entity.object:setyaw(entity.object:getyaw()+get_sign(entity.v)*math.rad(1+dtime)*entity.turn_spd)
			elseif ctrl.right then
				entity.object:setyaw(entity.object:getyaw()-get_sign(entity.v)*math.rad(1+dtime)*entity.turn_spd)
			end
		else
			entity.object:setyaw(entity.driver:get_look_yaw() - rot_steer)
		end
		if ctrl.jump then
			if jump_height > 0 and velo.y == 0 then
				velo.y = velo.y + (jump_height * 3) + 1
				acce_y = acce_y + (acce_y * 3) + 1
			end
			if can_fly and can_fly == true then
				velo.y = velo.y + 1
				acce_y = acce_y + 1
			end
		end
		if ctrl.sneak then
			if can_fly and can_fly == true then
				velo.y = velo.y - 1
				acce_y = acce_y - 1
			end
		end
	end

	-- if not moving then set animation and return
	if entity.v == 0 and velo.x == 0 and velo.y == 0 and velo.z == 0 then
		if is_mob and mobs_redo == true then
			if stand_anim and stand_anim ~= nil then
				set_animation(entity, stand_anim)
			end
		end
		return
	end
	
	-- set animation
	if is_mob and mobs_redo == true then
		if moving_anim and moving_anim ~= nil then
			set_animation(entity, moving_anim)
		end
	end

	-- Stop!
	local s = get_sign(entity.v)
	entity.v = entity.v - 0.02 * s
	if s ~= get_sign(entity.v) then
		entity.object:setvelocity({x=0, y=0, z=0})
		entity.v = 0
		return
	end

	-- enforce speed limit forward and reverse
	local max_spd = entity.max_speed_reverse
	if get_sign(entity.v) >= 0 then
		max_spd = entity.max_speed_forward
	end
	if math.abs(entity.v) > max_spd then
		entity.v = entity.v - get_sign(entity.v)
	end

	-- Set position, velocity and acceleration	
	local p = entity.object:getpos()
	local new_velo = {x=0, y=0, z=0}
	local new_acce = {x=0, y=-9.8, z=0}

	p.y = p.y - 0.5
	local ni = node_is(p)
	local v = entity.v
	if ni == "air" then
		if can_fly == true then
			new_acce.y = 0
		end
	elseif ni == "liquid" then
		if entity.terrain_type == 2 or entity.terrain_type == 3 then
			new_acce.y = 0
			p.y = p.y + 1
			if node_is(p) == "liquid" then
				if velo.y >= 5 then
					velo.y = 5
				elseif velo.y < 0 then
					new_acce.y = 20
				else
					new_acce.y = 5
				end
			else
				if math.abs(velo.y) < 1 then
					local pos = entity.object:getpos()
					pos.y = math.floor(pos.y) + 0.5
					entity.object:setpos(pos)
					velo.y = 0
				end
			end
		else
			v = v*0.25
		end
--	elseif ni == "walkable" then
--		v = 0
--		new_acce.y = 1
	end

	new_velo = get_velocity(v, entity.object:getyaw() - rot_view, velo.y)
	new_acce.y = new_acce.y + acce_y

	entity.object:setvelocity(new_velo)
	entity.object:setacceleration(new_acce)

	-- CRASH!
	if enable_crash then
		local intensity = entity.v2 - v
		if intensity >= crash_threshold then
			if is_mob then
				entity.object:set_hp(entity.object:get_hp() - intensity)
			else
				if entity.driver then
					local drvr = entity.driver
					lib_mount.detach(drvr, {x=0, y=0, z=0})
					drvr:setvelocity(new_velo)
					drvr:set_hp(drvr:get_hp() - intensity)
				end
				if entity.passenger then
					local pass = entity.passenger
					lib_mount.detach(pass, {x=0, y=0, z=0})
					pass:setvelocity(new_velo)
					pass:set_hp(pass:get_hp() - intensity)
				end
				local pos = entity.object:getpos()
				minetest.add_item(pos, entity.drop_on_destroy)
				entity.removed = true
				-- delay remove to ensure player is detached
				minetest.after(0.1, function()
					entity.object:remove()
				end)
			end
		end
	end

	entity.v2 = v
end

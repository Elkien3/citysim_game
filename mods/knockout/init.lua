local path = minetest.get_modpath(minetest.get_current_modname())
dofile(path .. "/overrides.lua")

-- Create globals
knockout = {}
knockout.knocked_out = {}
knockout.carrying = {}
knockout.tools = {}

-- Create mod storage
knockout.storage = minetest.get_mod_storage()

-- Created locals
local knockout_huds = {}

-- Register entity
   
minetest.register_entity("knockout:entity", {
	hp_max = 1000,
	physical = true,
	weight = 5,
	collisionbox = {-0.35, 0, -0.35, 0.35, 1.8, 0.35},
	visual = "cube",
	textures = {"invisible.png", "invisible.png", "invisible.png", "invisible.png", "invisible.png", "invisible.png"},
	is_visible = true,
	makes_footstep_sound = false,
    automatic_rotate = false,
    on_activate = function(e, sdata, dtime)
		e.grabbed_name = sdata
		e.object:set_armor_groups({immortal = 1})
		local p = minetest.get_player_by_name(e.grabbed_name)
		if p ~= nil then
			e.object:set_yaw(p:get_look_horizontal())
		end
    end,
    on_punch = function(e, puncher, time_from_last_punch, tool_capabilities, dir)
		-- The player can't punch themselves
		if puncher:get_player_name() == e.grabbed_name then return end
		-- If punched with a water bucket revive
		local tool = puncher:get_wielded_item():get_name()
		if tool == "bucket:bucket_water" then
			knockout.wake_up(e.grabbed_name)
			return
		end
		-- Otherwise hurt the player
		local p = minetest.get_player_by_name(e.grabbed_name)
		if p == nil then
			e.object:remove()
		else
			p:set_detach()
			p:punch(puncher, time_from_last_punch, tool_capabilities, dir)
			p:set_attach(e.object, "", {x = 0, y = 10, z = 0}, {x = 0, y = 0, z = 0})
		end
    end,
    on_rightclick = function(e, clicker)
		local cName = clicker:get_player_name()
		if cName == e.grabbed_name then return end
		for carryer, carried in pairs(knockout.carrying) do
			if carryer == cName or carried == e.grabbed_name then return end
		end
		victim = minetest.get_player_by_name(e.grabbed_name)
		if victim then
			victim:set_attach(clicker, "", {x = 0, y = 0, z = -15}, {x = 0, y = 0, z = 0})
			knockout.carrying[cName] = e.grabbed_name
			e.object:remove()
		end
    end,
    on_step = function(e, dtime)
		if knockout.knocked_out[e.grabbed_name] == nil or minetest.get_player_by_name(e.grabbed_name) == nil then
			e.object:remove()
		end
    end
})

-- Load knocked out players
knockout.load = function()
	local ko = knockout.storage:get_string("knocked_out")
	if ko ~= "" then
		knockout.knocked_out = minetest.deserialize(ko)
	end
end

-- Save knocked out players
knockout.save = function()
	knockout.storage:set_string("knocked_out", minetest.serialize(knockout.knocked_out))
end

-- Drop a player
knockout.carrier_drop = function(pName) -- pname = name of carrier
	if knockout.carrying[pName] then
		local cName = knockout.carrying[pName]
		local carried = minetest.get_player_by_name(cName)
		if carried then
			carried:set_detach()
			knockout.knockout(cName)
		end
		knockout.carrying[pName] = nil
	end
end

-- Knock out player
knockout.knockout = function(pName, duration)
	local p = minetest.get_player_by_name(pName)
	if not p then return end
	if duration == nil then
		if knockout.knocked_out[pName] == nil then return end
	else
		knockout.knocked_out[pName] = duration
	end
	-- Incase player is riding a horse or something
	p:set_detach()
	-- If the player is carrying another player, fix that
	knockout.carrier_drop(pName)
	-- Freeze player using entites
	local pos = p:get_pos()
	local e = minetest.add_entity(pos, "knockout:entity", pName)
	p:set_attach(e, "", {x = 0, y = 10, z = 0}, {x = 0, y = 0, z = 0})
	-- Make player lay down
	default.player_attached[pName] = true
	default.player_set_animation(p, "lay")
	-- Black screen
	if knockout_huds[pName] == nil then
		knockout_huds[pName] = p:hud_add({
			hud_elem_type = "image",
			text = "knockout_black.png",
			name = "knockedout",
			position = {x = 0.5, y = 0.5},
			scale = {x= -110, y= -110},
			alignment = {x = 0, y = 0},
		
		})
	end
	-- No interacting for you, player
	local privs = minetest.get_player_privs(pName)
	privs.shout = nil
	privs.interact = nil
	minetest.set_player_privs(pName, privs)
	-- Save
	knockout.save()
end

-- Wake up player
knockout.wake_up = function(pName)
	local p = minetest.get_player_by_name(pName)
	knockout.knocked_out[pName] = nil
	-- Un-freeze player
	local e = p:get_attach()
	if e ~= nil then
		local pos = e:get_pos()
		e:remove()
		p:set_detach()
		p:set_pos(pos)
	end
	-- Make player stand back up
	default.player_attached[pName] = false
	default.player_set_animation(p, "stand")
	p:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
	-- If the player was being carried, remove that
	for name, carried in pairs(knockout.carrying) do
		if carried == pName then
			knockout.carrying[name] = nil
			break
		end
	end
	-- Give the whiny player their privs back already
	local privs = minetest.get_player_privs(pName)
	privs.shout = true
	privs.interact = true
	minetest.set_player_privs(pName, privs)
	-- Hide formspec
	if p:get_hp() > 0 then
		minetest.close_formspec(pName, "knockout:fs")
	end
	-- Un-black screen
	if knockout_huds[pName] ~= nil then
		p:hud_remove(knockout_huds[pName])
		knockout_huds[pName] = nil
	end
	-- Save
	knockout.save()
end

-- Decrease knockout time
knockout.decrease_knockout_time = function(pName, by)
	knockout.knocked_out[pName] = knockout.knocked_out[pName] - by
	if knockout.knocked_out[pName] <= 0 then
		knockout.wake_up(pName)
	end
end

-- Init
knockout.load()
dofile(path .. "/api.lua")
dofile(path .. "/handlers.lua")
dofile(path .. "/tools.lua")

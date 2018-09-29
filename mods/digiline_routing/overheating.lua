-- © 2017 numberZero
-- License: GNU Lesser General Public License, version 2 (or any later version)

local COOLDOWN_STEP = 0.5
local DEFAULT_MAX_RATE = 20.0
local hot_objects = {}
local timer = 0.0

digiline_routing.overheat = {}

digiline_routing.overheat.heat = function(pos, heat)
	local id = minetest.hash_node_position(pos)
	local temperature = (hot_objects[id] or 0) + (heat or 1)
	hot_objects[id] = temperature
	return temperature
end

digiline_routing.overheat.forget = function(pos)
	local id = minetest.hash_node_position(pos)
	hot_objects[id] = nil
end

local global_cooldown = function(dtime)
	timer = timer + dtime
	if timer < COOLDOWN_STEP then -- don't overload the CPU
		return
	end
	local cooldown = DEFAULT_MAX_RATE * timer
	timer = 0
	for id, temperature in pairs(hot_objects) do
		temperature = temperature - cooldown
		if temperature <= 0 then
			hot_objects[id] = nil
		else
			hot_objects[id] = temperature
		end
	end
end

minetest.register_globalstep(global_cooldown)

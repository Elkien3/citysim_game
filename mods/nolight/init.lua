local max_light = 3
local whitelist = {}
local blacklist = {}
local torchtime = 30*60

local torchlist = {"default:torch_ceiling", "default:torch_wall", "default:torch"}
local mp = minetest.get_modpath("nolight")

minetest.register_lbm{
	label = "Ensure torch burn timer",
	name = "nolight:torch",
	nodenames = torchlist,
	run_at_every_load = true,
	action = function(pos, node)
	local timer = minetest.get_node_timer(pos)
	if not timer:is_started() then timer:start(torchtime) end
end}

dofile(mp.."/lantern.lua")
dofile(mp.."/technic.lua")
dofile(mp.."/handheld.lua")

local electric_light_list = {}
electric_light_list["mesecons_lightstone:lightstone_white_off"] = "mesecons_lightstone:lightstone_white_on"
electric_light_list["mesecons_lamp:lamp_off"] = "mesecons_lamp:lamp_on"
electric_light_list["streets:light_vertical_off"] = "streets:light_vertical_on"
electric_light_list["streets:light_horizontal_off"] = "streets:light_horizontal_on"
electric_light_list["streets:light_hanging_off"] = "streets:light_hanging_on"

minetest.register_on_mods_loaded(function()
	local str
	for id, torch in pairs(torchlist) do
		local def = minetest.registered_nodes[torch]
		local origfunc = def.on_construct
		local torchconstruct = function(pos)
			local funcval
			if origfunc then
				funcval = origfunc(pos)
			end
			minetest.get_node_timer(pos):start(torchtime)
			return funcval
		end
		origfunc = def.on_timer
		local torchtimer = function(pos, elapsed)
			local funcval
			if origfunc then
				funcval = origfunc(pos)
			end
			if minetest.get_node(pos).name == torch then
				minetest.remove_node(pos)
				if math.random(4) == 1 then
					minetest.add_item(pos, "default:stick")
				end
			end
			return funcval
		end
		minetest.override_item(torch, {
			drop = {
				max_items = 1,
				items = {
					{items = {"default:stick"}, rarity = 4},
				}
			},
			on_timer = torchtimer,
			on_construct = torchconstruct
		})
	end
	minetest.register_alias_force("fire:permanent_flame","fire:basic_flame")--no permanent_flame allowed
	for name, node_on in pairs(electric_light_list) do
		if minetest.registered_nodes[name] and (not node_on or minetest.registered_nodes[node_on]) then
			register_electrical_light(name, node_on)
		end
	end
	for name, def in pairs(minetest.registered_nodes) do
		if def.light_source <= max_light then goto skip end
		if def.groups and def.groups.eletric_light then goto skip end
		if name == "default:torch" then goto skip end
		if string.find(name, "tnt") then goto skip end
		if string.find(name, "furnace") then goto skip end
		if string.find(name, "fire:") then goto skip end
		if string.find(name, "technic:") then goto skip end
		if string.find(name, "lava") or string.find(name, "fireflies") or string.find(name, "mesecon_torch") or string.find(name, "mesecons_powerplant") or string.find(name, "candle") or string.find(name, "streets:roadwork") then
			minetest.override_item(name, {light_source = max_light})
			goto skip
		end
		if minetest.get_craft_recipe(name).items == nil then goto skip end
		if not str then str = name else str = str..","..name end
		register_electrical_light(name)
		::skip::
	end
	--minetest.after(4,minetest.chat_send_all, str)
end)
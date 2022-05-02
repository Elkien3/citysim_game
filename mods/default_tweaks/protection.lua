local list = {
	"beds:bed_bottom", "beds:fancy_bed_bottom", "xdecor:baricade", "streets:roadwork_delineator_bottom", "streets:roadwork_delineator_light_bottom",
	"streets:roadwork_blinking_light_on", "streets:roadwork_blinking_light_off", "streets:roadwork_pylon", "realchess:chessboard", "default:glass",
	"xpanes:glass_pane", "xpanes:glass_pane_flat", "xpanes:pane", "xpanes:pane_flat", "doors:door_glass_a", "doors:door_glass_b", "default:water_source"
}
local blacklist = {}
for i = 1, 4 do
	table.insert(list, "xdecor:painting_"..i)
end
minetest.register_on_mods_loaded(function()
	local nodelist = minetest.registered_nodes
	local grouplist = {"leaves", "dig_immediate", "liquid", "falling_node"}--
	for name, def in pairs(nodelist) do
		for index, group in pairs(grouplist) do
			if def.groups and def.groups[group] and def.groups[group] > 0 then
				if group == "falling_node" and def.groups[group] == 2 then goto skip end
				if string.match(name, "signs") then goto skip end
				--if group == "liquid" then minetest.after(10, function() minetest.chat_send_all(name) end) end
				table.insert(list, name)
				::skip::
			end
		end
	end
	for index, name in pairs(list) do
		if type(index) == "number" and type(name) == "string" then
			list[name] = true
			list[index] = nil
		end
	end
	for index, name in pairs(blacklist) do
		if list[name] then
			list[name] = nil
		end
	end
end)

minetest.register_privilege("griefing", {
    description = "Has chance to break some protected blocks",
    give_to_singleplayer = false
})

local tempprotect = {}
minetest.register_node("default_tweaks:protect", {
	description = "Protection Block, works against all players.",
	drawtype = "nodebox",
	tiles = {
		"default_stone.png^protector_overlay.png",
		"default_stone.png^protector_overlay.png",
		"default_stone.png^protector_overlay.png^protector_logo.png"
	},
	sounds = default.node_sound_stone_defaults(),
	groups = {dig_immediate = 2, unbreakable = 1},
	is_ground_content = false,
	paramtype = "light",
	light_source = 3,

	node_box = {
		type = "fixed",
		fixed = {
			{-0.5 ,-0.5, -0.5, 0.5, 0.5, 0.5}
		}
	},
	on_construct = function(pos)
		tempprotect[minetest.pos_to_string(pos)] = true
		local meta = minetest.get_meta(pos)
		meta:set_int("exp", 15)
		meta:set_string("infotext", "Protection (expires in 15 minutes)")
		local timer = minetest.get_node_timer(pos)
		timer:start(60)
	end,
	
	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local expire = meta:get_int("exp")
		expire = expire - 1
		if expire <= 0 then
			minetest.dig_node(pos)
			return false
		end
		meta:set_int("exp", expire)
		meta:set_string("infotext", "Protection (expires in "..tostring(expire).." minutes)")
		return true
	end,

	on_rightclick = function(pos, node, clicker, itemstack)
		local meta = minetest.get_meta(pos)
		meta:set_int("exp", 15)
		meta:set_string("infotext", "Protection (expires in 15 minutes)")
		local timer = minetest.get_node_timer(pos)
		timer:start(60)
	end,

	on_punch = function(pos, node, puncher)
		local meta = minetest.get_meta(pos)
		meta:set_int("exp", 15)
		meta:set_string("infotext", "Protection (expires in 15 minutes)")
		local timer = minetest.get_node_timer(pos)
		timer:start(60)
	end,

	can_dig = function(pos, player)
		return true
	end,
	after_destruct = function(pos, oldnode)
		tempprotect[minetest.pos_to_string(pos)] = nil
	end
})

minetest.register_craft({
	output = "default_tweaks:protect",
	recipe = {
		{"default:stone", "default:stone", "default:stone"},
		{"default:stone", "default:gold_ingot", "default:stone"},
		{"default:stone", "default:stone", "default:stone"}
	}
})

minetest.register_lbm({
	label = "Add Temp Protect",
	name = "default_tweaks:protectadd",
	nodenames = {"default_tweaks:protect"},
	run_at_every_load = true,
	action = function(pos, node)
		local timer = minetest.get_node_timer(pos)
		if not timer:is_started() then
			timer:start(60)
		end
		tempprotect[minetest.pos_to_string(pos)] = true
	end,
})

local function is_tempprotected(pos, range)
	if not range then range = 16 end
	for posstring, _ in pairs(tempprotect) do
		local pos2 = minetest.string_to_pos(posstring)
		local diff = vector.subtract(pos, pos2)
		if diff.x <= range and diff.y <= range and diff.z <= range then
			return true
		end
	end
	return false
end

local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
	if not minetest.check_player_privs(name, {griefing=true}) then
		if is_tempprotected(pos) then return true else
			return old_is_protected(pos, name)
		end
	end
	local nodename = minetest.get_node(pos).name
	local player = minetest.get_player_by_name(name)
	if player and player:is_player() then
		local stack = player:get_wielded_item()
		--minetest.chat_send_all(nodename.." "..tostring(list[nodename]))
		if string.match(stack:get_name(), "bucket:") and (nodename == "air" or list[nodename]) then return false end
		if nodename == "air" then
			local def = stack:get_definition()
			if def.type == "node" then
				nodename = stack:get_name()
			else
				if is_tempprotected(pos) then return true else
					return old_is_protected(pos, name)
				end
			end
		end
	end
	--minetest.chat_send_all(nodename.." "..tostring(list[nodename]))
	if list[nodename] then
		return false
	else
		return old_is_protected(pos, name)
	end
end
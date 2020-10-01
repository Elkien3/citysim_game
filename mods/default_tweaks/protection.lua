local list = {
	"beds:bed_bottom", "beds:fancy_bed_bottom", "xdecor:barricade", "streets:roadwork_delineator_bottom", "streets:roadwork_delineator_light_bottom",
	"streets:roadwork_blinking_light_on", "streets:roadwork_blinking_light_off", "streets:roadwork_pylon", "realchess:chessboard", "default:glass",
	"xpanes:glass_pane", "xpanes:glass_pane_flat", "doors:door_glass_a", "doors:door_glass_b"
}
local blacklist = {"signs:label_small"}
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

local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
	local nodename = minetest.get_node(pos).name
	if nodename == "air" then
		local stack = minetest.get_player_by_name(name):get_wielded_item()
		local def = stack:get_definition()
		if def.type == "node" then
			nodename = stack:get_name()
		else
			return old_is_protected(pos, name)
		end
	end
	--minetest.chat_send_all(nodename.." "..tostring(list[nodename]))
	if list[nodename] then
		return false
	else
		return old_is_protected(pos, name)
	end
end
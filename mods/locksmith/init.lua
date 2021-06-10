local function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

local orig_func = default.can_interact_with_node
default.can_interact_with_node = function(player, pos)
	local orig_val = orig_func(player, pos)
	if orig_val == true then return true end
	local name = player:get_player_name()
	local meta = minetest.get_meta(pos)
	if meta:get_string("owner") == "" then return true end
	if meta:get_int("protected") == 1 and not minetest.is_protected(pos, name) then return true end
	if jobs and jobs.permissionstring(name, meta:get_string("owner")) then return true end
	if meta:get_string("shared") ~= "" then
		local names = split(meta:get_string("shared"), "%s,")
		for i, shared_name in pairs(names) do
			if name == shared_name or (jobs and jobs.permissionstring(name, shared_name)) then return true end
		end
	end
	return false
end

function locksmith_form(pos)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	local shared = meta:get_string("shared")
	local protected = meta:get_int("protected") == 1
    local form = 
    "size[3,3.5]" ..
    "field[0.5,0.75;2.75,1;owner;Change Owner;"..minetest.formspec_escape(owner).."]" ..
    "field[0.5,2;2.75,1;shared;Shared Players;"..minetest.formspec_escape(shared).."]" ..
    "checkbox[0.5,2.5;protected;Protected;"..tostring(protected).."]"
     return form
end

local shared_nodes = {}
shared_nodes["default:chest_locked"] = true
shared_nodes["doors:door_steel_a"] = true
shared_nodes["doors:door_steel_b"] = true
shared_nodes["doors:door_steel_c"] = true
shared_nodes["doors:door_steel_d"] = true
shared_nodes["doors:trapdoor_steel"] = true
shared_nodes["doors:trapdoor_steel_open"] = true
shared_nodes["xpanes:door_steel_bar_a"] = true
shared_nodes["xpanes:door_steel_bar_b"] = true
shared_nodes["xpanes:door_steel_bar_c"] = true
shared_nodes["xpanes:door_steel_bar_d"] = true
shared_nodes["streets:fence_chainlink_door_open"] = true
shared_nodes["streets:fence_chainlink_door_closed"] = true
shared_nodes["doors:prison_door_a"] = true
shared_nodes["doors:prison_door_b"] = true
shared_nodes["doors:prison_door_c"] = true
shared_nodes["doors:prison_door_d"] = true
shared_nodes["doors:rusty_prison_door_a"] = true
shared_nodes["doors:rusty_prison_door_b"] = true
shared_nodes["doors:rusty_prison_door_c"] = true
shared_nodes["doors:rusty_prison_door_d"] = true
shared_nodes["currency:safe"] = true
shared_nodes["3d_armor_stand:locked_armor_stand"] = true
shared_nodes["xdecor:mailbox"] = true

local locksmith_forms = {}

minetest.register_craftitem("locksmith:tool", {
	description = "Locksmith Kit",
	inventory_image = "locksmith_tool.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then return end
		local name = user:get_player_name()
		local nodename = minetest.get_node(pointed_thing.under).name
		if not shared_nodes[nodename] then return end
		local meta = minetest.get_meta(pointed_thing.under)
		local owner = meta:get_string("owner")
		if not minetest.check_player_privs(user, "protection_bypass") and owner ~= "" and name ~= owner and (not jobs or not jobs.permissionstring(name, owner)) then return end
		locksmith_forms[name] = pointed_thing.under
		minetest.show_formspec(name, "locksmith:form", locksmith_form(pointed_thing.under))
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "locksmith:form" then return end
	local name = player:get_player_name()
	if not locksmith_forms[name] then return end
	local meta = minetest.get_meta(locksmith_forms[name])
	if not meta then return end
	local owner = meta:get_string("owner")
	if not minetest.check_player_privs(player, "protection_bypass") and owner ~= "" and name ~= owner and (not jobs or not jobs.permissionstring(name, owner)) then return end
	if fields.owner and (minetest.player_exists(fields.owner) or (jobs and jobs.is_job_string(fields.owner))) then
		meta:set_string("owner", fields.owner)
		local info = meta:get_string("infotext")
		meta:set_string("infotext", string.gsub(info, owner, fields.owner))
	end
	if fields.shared then
		meta:set_string("shared", fields.shared)
	end
	if fields.protected == "true" then
		meta:set_int("protected", 1)
	elseif fields.protected == "false" then
		meta:set_int("protected", 0)
	end
	if fields.quit then
		locksmith_forms[name] = nil
	end
end)
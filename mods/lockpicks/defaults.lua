function make_pickable(nodename, itemname, lockedgroup, newinfotext)
	local groupies = minetest.registered_nodes[nodename].groups
	groupies.locked = lockedgroup
	minetest.override_item(nodename, {
	groups = groupies,
	on_dig = function(pos, node, digger)		
		local meta = minetest.get_meta(pos)
		local name = digger:get_player_name()
		local can_pick = false
		local tool_group = digger:get_wielded_item():get_tool_capabilities()
		if meta:get_string("owner") ~= "" then
			if tool_group.groupcaps.locked then
				if tool_group.groupcaps.locked.maxlevel >= lockedgroup then
					can_pick = true
				end
			end
		end
		if minetest.get_modpath("ctf_protect") ~= nil then
			if minetest.is_protected(pos, name) then
				can_pick = false
			end
		end
		if not minetest.check_player_privs(name, {lockpick=true}) then
			can_pick = false
			minetest.chat_send_player(name, "Your do not have the lockpick priv.")
		end
		if can_pick then
			local wielditem = digger:get_wielded_item()
			local wieldlevel = tool_group.max_drop_level
			local rand = math.random(1,10)
			if rand == 1 or meta:get_string("owner") == name then
				meta:set_string("owner", "")
				meta:set_string("infotext", newinfotext)
				minetest.chat_send_player(name, "You picked the lock!")
				minetest.log("action", name.." picked "..minetest.get_node(pos).name.." with "..digger:get_wielded_item():get_name().." at ("..pos.x..","..pos.y..","..pos.z..")")
				if playercontrol_set_timer then
					local privs = minetest.get_player_privs(name)
					privs.lockpick = nil
					minetest.set_player_privs(name, privs)
					playercontrol_set_timer(name, "lockpick", 2*60)
				end
			elseif rand == 2 then
				wielditem:clear()
				digger:set_wielded_item(wieldeditem)
				minetest.chat_send_player(name, "Your lockpick broke!")
			else
				minetest.chat_send_player(name, "You failed to pick the lock.")
			end
			return false
		else
			return true
		end
	end
	})
end

make_pickable("default:chest_locked", nil, 2, "Lockpicked Chest")

if minetest.get_modpath("doors") ~= nil then
	make_pickable("doors:door_steel_a", "doors:door_steel", 1, "Lockpicked Door")
	make_pickable("doors:door_steel_b", "doors:door_steel", 1, "Lockpicked Door")
	make_pickable("doors:trapdoor_steel", nil, 1, "Lockpicked Trapdoor")
	make_pickable("doors:trapdoor_steel_open", "doors:trapdoor_steel", 1, "Lockpicked Trapdoor")
end
if minetest.get_modpath("inbox") ~= nil then
	make_pickable("inbox:empty", nil, 2, "Lockpicked Mailbox")
	make_pickable("inbox:full", "inbox:empty", 2, "Lockpicked Mailbox")
end
if minetest.get_modpath("itemframes") ~= nil then
	make_pickable("itemframes:frame", nil, 1, "Lockpicked Itemframe")
	make_pickable("itemframes:pedestal", nil, 1, "Lockpicked Pedestal")
end
if minetest.get_modpath("currency") ~= nil then
	make_pickable("currency:shop", nil, 2, "Lockpicked Shop")
	make_pickable("currency:safe", nil, 3, "Lockpicked Safe")
end
if minetest.get_modpath("3d_armor_stand") ~= nil then
	make_pickable("3d_armor_stand:locked_armor_stand", nil, 1, "Lockpicked Armor Stand")
end
if minetest.get_modpath("signs") ~= nil and not minetest.get_modpath("font_api") then
	make_pickable("default:sign_wall_steel", nil, 1, "Lockpicked Sign")
	make_pickable("signs:sign_yard_steel", "default:sign_wall_steel", 1, "Lockpicked Sign")
end

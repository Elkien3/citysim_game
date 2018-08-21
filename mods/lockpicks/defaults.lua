function make_pickable(nodename, itemname, lockedgroup, newinfotext)
	local groupies = minetest.registered_nodes[nodename].groups
	groupies.locked = lockedgroup
	minetest.override_item(nodename, {
	groups = groupies,
	on_dig = function(pos, node, digger)		
		local meta = minetest.get_meta(pos)
		local can_pick = false
		if meta:get_string("owner") ~= "" then
			if digger:get_wielded_item():get_tool_capabilities().groupcaps.locked then
				if digger:get_wielded_item():get_tool_capabilities().groupcaps.locked.maxlevel <= lockedgroup then
					can_pick = true
				end
			end
		end
		if minetest.get_modpath("ctf_protect") ~= nil then
			if minetest.is_protected(pos, digger:get_player_name()) then
				can_pick = false
			end
		end
		if can_pick then
			local wielditem = digger:get_wielded_item()
			local wieldlevel = digger:get_wielded_item():get_tool_capabilities().max_drop_level
			if math.random() > math.pow(.66, wieldlevel) then
				meta:set_string("owner", "")
				meta:set_string("infotext", newinfotext)
				minetest.chat_send_player(digger:get_player_name(), "You picked the lock!")
			else
				wielditem:clear()
				digger:set_wielded_item(wieldeditem)
				minetest.chat_send_player(digger:get_player_name(), "Your lockpick broke!")
			end
			return false
		else
			local inv = meta:get_inventory()
			if inv:is_empty("main") and default.can_interact_with_node(digger, pos) then
				minetest.remove_node(pos)
				digger:get_inventory():add_item('main', itemname or nodename)
			end
		end
	end
	})
end

make_pickable("default:chest_locked", nil, 2, "Lockpicked Chest")

if minetest.get_modpath("doors") ~= nil then
	make_pickable("doors:door_steel_a", "doors:door_steel", 2, "Lockpicked Door")
	make_pickable("doors:door_steel_b", "doors:door_steel", 2, "Lockpicked Door")
	make_pickable("doors:trapdoor_steel", nil, 2, "Lockpicked Trapdoor")
	make_pickable("doors:trapdoor_steel_open", "doors:trapdoor_steel", 2, "Lockpicked Trapdoor")
end
if minetest.get_modpath("inbox") ~= nil then
	make_pickable("inbox:empty", nil, 2, "Lockpicked Mailbox")
	make_pickable("inbox:full", "inbox:empty", 2, "Lockpicked Mailbox")
end
if minetest.get_modpath("itemframes") ~= nil then
	make_pickable("itemframes:frame", nil, 2, "Lockpicked Itemframe")
	make_pickable("itemframes:pedestal", nil, 2, "Lockpicked Pedestal")
end
if minetest.get_modpath("currency") ~= nil then
	make_pickable("currency:shop", nil, 2, "Lockpicked Shop")
	make_pickable("currency:safe", nil, 1, "Lockpicked Safe")
end
if minetest.get_modpath("3d_armor_stand") ~= nil then
	make_pickable("3d_armor_stand:locked_armor_stand", nil, 2, "Lockpicked Armor Stand")
end
if minetest.get_modpath("signs") ~= nil then
	make_pickable("default:sign_wall_steel", nil, 2, "Lockpicked Sign")
	make_pickable("signs:sign_yard_steel", "default:sign_wall_steel", 2, "Lockpicked Sign")
end

local storage = minetest.get_mod_storage()
local classtbl = minetest.deserialize(storage:get_string("classtbl")) or {}
local classes = {
	["unclassed"] = "Slows hunger rate. Good for jobs that dont fit in the class system.",
	["farmer"] = "Is able to plant and harvest crops and breed livestock.",
	["miner"] = "Is able to dig stonelike blocks under -30 y",
	["machinist"] = "Is able to place and use mv and hv technic machines, and create/repair cars.",
	["cook"] = "Is able to complete cooking recipes.",
	["snooper"] = "Can peek in chests with lockpicks, and use the /grief_check command.",
}
class_switch_time = 3*24*60*60--3 days
class_switch_cost = 15

function class_get(name, class)
	if not name then return end
	local pclass = (classtbl[name] and classtbl[name].name) or "unclassed"
	if class then
		return class == pclass
	else
		return pclass
	end
end

for name, ctbl in pairs(classtbl) do
	if ctbl.name == "unclassed" and os.time() - ctbl.time > class_switch_time then--cull list of unclassed people
		classtbl[name] = nil
	end
end
storage:set_string("classtbl", minetest.serialize(classtbl))

minetest.register_chatcommand("class", {
	params = "<name>",
	description = "Check the class of yourself or another player",
	func = function(name, param)
		if param == "" then param = name end
		return true, param.." is "..class_get(param)
	end
})

minetest.register_chatcommand("classes", {
	params = "<class>",
	description = "Lists all classes or gives you info on a specific class.",
	func = function(name, param)
		if param == "" then
			local str
			for classname, classdesc in pairs(classes) do
				if not str then
					str = "Available classes: "..classname
				else
					str = str..", "..classname
				end
			end
			return true, str
		elseif classes[param] then
			return true, param..": "..classes[param]
		else
			return false, "Invalid input."
		end
	end
})

local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

minetest.register_chatcommand("class_set", {
	params = "<class>",
	description = "Set your class",
	func = function(name, param)
		local oldclass = classtbl[name]
		if oldclass and os.time() - oldclass.time < class_switch_time then
			local timeleft = class_switch_time - (os.time() - oldclass.time)
			timeleft = round(timeleft/(60*60), 2)
			return false, "You must wait "..(timeleft).." hours before changing class again."
		end
		if param == "" then
			return false, "do '/class_set unclassed' to go to unclassed"
		elseif classes[param] then
			local paidtext = ""
			if oldclass and money3 then--only charge money if you've changed class before
				if money3.dec(name, class_switch_cost) then
					return false, "You need to pay "..tostring(class_switch_cost).."cr to change class."
				end
				if taxes and taxes.add then taxes.add(class_switch_cost) end
				paidtext = " (paid "..tostring(class_switch_cost).."cr)"
			end
			classtbl[name] = {name = param, time = os.time()}
			storage:set_string("classtbl", minetest.serialize(classtbl))
			return true, "You are now "..param..paidtext
		else
			return false, "Invalid Input. do ./classes to see class list."
		end
	end
})

--class behavior (most need to be supported in the mod)

--Miner
local orig_node_dig = minetest.node_dig
minetest.node_dig = function(pos, node, digger)
	local name = digger and digger:get_player_name()
	if name and pos and pos.y and pos.y <= -30 and not class_get(name, "miner") and string.find(node.name, "stone") then
		return false
	end
	return orig_node_dig(pos, node, digger)
end

--Farmer
local orig_handle_drop = minetest.handle_node_drops
minetest.handle_node_drops = function(pos, drops, digger)
	local node = minetest.get_node(pos)
	if digger and node and node.name then
		local plantname = string.sub(node.name, 1, -3)
		local name = digger:get_player_name()
		local plantdef = farming.registered_plants[plantname]
		if plantdef and name and not class_get(name, "farmer") then
			drops = {plantdef.seed}
		end
	end
	return orig_handle_drop(pos, drops, digger)
end

--Machinist
if minetest.get_modpath("technic") then
	for nodename, def in pairs(minetest.registered_nodes) do
		local groups = def.groups or {}
		if groups.technic_machine and (groups.technic_mv or groups.technic_hv) then
			local orig_receive = def.on_receive_fields
			local new_receive
			if orig_receive then
				new_receive = function(pos, formname, fields, sender)
					local name = sender:get_player_name()
					if class_get(name, "machinist") then
						return orig_receive(pos, formname, fields, sender)
					end
				end
			end
			local oldput = def.allow_metadata_inventory_put
			local newput = function(pos, listname, index, stack, player)
				if not class_get(player:get_player_name(), "machinist") then return 0 end
				if oldput then
					return oldput(pos, listname, index, stack, player)
				else
					return stack:get_count()
				end
			end
			local oldtake = def.allow_metadata_inventory_take
			local newtake = function(pos, listname, index, stack, player)
				if not class_get(player:get_player_name(), "machinist") then return 0 end
				if oldput then
					return oldtake(pos, listname, index, stack, player)
				else
					return stack:get_count()
				end
			end
			local oldmove = def.allow_metadata_inventory_move
			local newmove = function(pos, from_list, from_index, to_list, to_index, count, player)
				if not class_get(player:get_player_name(), "machinist") then return 0 end
				if oldmove then
					return oldmove(pos, from_list, from_index, to_list, to_index, count, player)
				else
					return count
				end
			end
			local orig_place = def.on_place
			minetest.override_item(nodename, {on_place = function(itemstack, placer, pointed_thing)
					local name = placer and placer:get_player_name()
					if not name or class_get(name, "machinist") then
						if orig_place then
							return orig_place(itemstack, placer, pointed_thing)
						else
							return minetest.item_place(itemstack, placer, pointed_thing)
						end
					end
				end,
				on_receive_fields = new_receive,
				allow_metadata_inventory_put = newput,
				allow_metadata_inventory_take = newtake,
				allow_metadata_inventory_move = newmove
			})
		end
	end
end

if minetest.get_modpath("default") then
	--allow snoopers to rightclick chests to peek into them.
	--self-explanatory - taken from original locked chest code
	function has_locked_chest_privilege(meta, player)
		if player:get_player_name() ~= meta:get_string("owner") then
			return false
		end
		return true
	end

	function get_chest_formspec(pos)
		local spos = pos.x .. "," .. pos.y .. "," .. pos.z
		local formspec =
			"size[8,9]" ..
			default.gui_bg ..
			default.gui_bg_img ..
			default.gui_slots ..
			"list[nodemeta:" .. spos .. ";main;0,0.3;8,4;]" ..
			"list[current_player;main;0,4.85;8,1;]" ..
			"list[current_player;main;0,6.08;8,3;8]" ..
			"listring[nodemeta:" .. spos .. ";main]" ..
			"listring[current_player;main]" ..
			default.get_hotbar_bg(0,4.85)
		return formspec
	end
			
	local newchestrightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local wield = clicker:get_wielded_item():get_name()
		local def = minetest.registered_tools[wield]
		if not default.can_interact_with_node(clicker, pos) and not class_get(clicker:get_player_name(), "snooper") then
			return itemstack
		end
		name = "default:chest_locked"
		sound_open = "default_chest_open"
		sound_close = "default_chest_close"
		minetest.sound_play(sound_open, {gain = 0.3,
				pos = pos, max_hear_distance = 10}, true)
		if not default.chest.chest_lid_obstructed(pos) then
			minetest.swap_node(pos,
					{ name = name .. "_open",
					param2 = node.param2 })
		end
		minetest.after(0.2, minetest.show_formspec,
				clicker:get_player_name(),
				"default:chest", default.chest.get_chest_formspec(pos))
		default.chest.open_chests[clicker:get_player_name()] = { pos = pos,
				sound = sound_close, swap = name }
	end
	minetest.override_item("default:chest_locked", {on_rightclick = newchestrightclick})
	minetest.override_item("default:chest_locked_open", {on_rightclick = newchestrightclick})
end
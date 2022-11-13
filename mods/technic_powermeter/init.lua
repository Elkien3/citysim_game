-- yes, the power meter is technically a bed

local recipe = {}
if minetest.get_modpath("currency") then
	recipe = {
		{"", "technic:control_logic_unit", ""},
		{"technic:lv_cable", "currency:shop", "technic:lv_cable"},
	}
else
	recipe = {
		{"", "technic:control_logic_unit", ""},
		{"technic:lv_cable", "default:chest", "technic:lv_cable"},
	}
end

beds.register_bed("technic_powermeter:meter", {
	description = "Power Meter",
	--inventory_image = "power_meter_lock.png",
	--wield_image = "power_meter_lock.png",
	tiles = {
		bottom = {
			"power_meter_top.png",
			"power_meter_bottom.png",
			"power_meter_lock.png",
			"power_meter_plain.png",
			"power_meter_plain.png",
			"power_meter_plain.png"
		},
		top = {
			"power_meter_top.png",
			"power_meter_bottom.png",
			"power_meter_plain.png",
			"power_meter_plain.png",
			"power_meter_plain.png",
			"power_meter_plain.png",
		}
	},
	nodebox = {
		bottom = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		top = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	},
	selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 1.5},
	recipe = recipe
})

local function form_meter(pos, owner)
	local meta = minetest.get_meta(pos)
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
	local price = meta:get_string("price")
	if price == "" then price = "0" end
	local form = "size[8,7]" ..
		"list[current_player;main;0,3;8,4;0]" ..
		"list[nodemeta:"..spos..";input;6,0.9;1,1.1;0]" ..
		"label[5.7,0.4;Bought: "..technic.EU_string(meta:get_int("bought")).."]" ..
		"button_exit[6,1.8;1,1;buy;Buy]"..
		"label[5.7,-.2;Price: "..price.." minegeld/kEU]"
		if owner then
			form = form..
				"label[0.5,0;Customers gave:]" ..
				"list[nodemeta:" .. spos .. ";output;0.5,0.5;2.5,2;0]"..
				"field[3,0.6;2.5,1;price;Price (minegeld/kEU);"..price.."]"
		else
			
		end
	return form
end

local form_table = {}

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "technic_powermeter:form" then return end
	if not player then return end
	local name = player:get_player_name()
	local pos = form_table[name]
	if not pos then return end
	local meta = minetest.get_meta(pos)
	if fields.buy then
		local inv = meta:get_inventory()
		local price = (tonumber(meta:get_string("price")) or 0)/1000
		local input = inv:get_stack("input", 1)
		local moneys = {minegeld = 1, minegeld_5 = 5, minegeld_10 = 10}
		local amount = (moneys[string.gsub(input:get_name(), "currency:", "")] or 0) * input:get_count()
		if amount > 0 and price > 0 and (amount >= price or meta:get_int("bought") > 0) then
			local bought = math.floor(amount/price)
			local change = math.floor(amount-bought*price)
			local output = ItemStack({name = "currency:minegeld", count = amount-change})
			local changestack = ItemStack({name = "currency:minegeld", count = change})
			if inv:room_for_item("output", output) then
				if change > 0 then
					inv:set_stack("input", 1, changestack)
				else
					inv:set_stack("input", 1, ItemStack())
				end
				inv:add_item("output", output)
				bought = bought+meta:get_int("bought")
				meta:set_int("bought", bought)
			else
				minetest.chat_send_player(name, "Meter is full and cannot fit payment, contact meter owner.")
			end
		end
	end
	if fields.key_enter_field == "price" then
		if default.can_interact_with_node(player, pos) then
			if tonumber(fields.price) then
				meta:set_string("price", fields.price)
			end
		end
	end
	if fields.quit then
		form_table[name] = nil
		return true
	end
end)

local S = technic.getter

local run = function(pos1, node)
	-- Machine information
	local machine_name  = S("Power Meter")
	local meta1          = minetest.get_meta(pos1)
	local enabled       = meta1:get_string("enabled")
	local bought		 = meta1:get_int("bought")
	--enabled = enabled == "1"
	--if not enabled or (meta1:get_int("mesecon_mode") == 1 and meta1:get_int("mesecon_effect") == 0) then return end
	
	local dir = minetest.facedir_to_dir(node.param2)
	local pos2 = vector.add(pos1, dir)
	local node2 = minetest.get_node_or_nil(pos2)
	if not node2 or node2.name ~= "technic_powermeter:meter_top" or node.param2 ~= node2.param2 then
		return
	end
	--pos1 is bottom/recieving pos2 is top/producing
	local meta2 = minetest.get_meta(pos2)

	local name_bottom	 = minetest.get_node(vector.subtract(pos1, dir)).name
	local name_top		 = minetest.get_node(vector.add(pos2, dir)).name

	local from = technic.get_cable_tier(name_bottom)
	local to   = technic.get_cable_tier(name_top)
	meta1:set_int("LV_EU_timeout", 2)
	meta1:set_int("MV_EU_timeout", 2)
	meta1:set_int("HV_EU_timeout", 2)
	meta2:set_int("LV_EU_timeout", 2)
	meta2:set_int("MV_EU_timeout", 2)
	meta2:set_int("HV_EU_timeout", 2)
	
	if bought == 0 then
		meta1:set_string("infotext", S("@1 (owned by @2) (@3)", machine_name, meta1:get_string("owner"), technic.EU_string(bought)))
		if from then
			meta1:set_int(from.."_EU_demand", 0)
			meta1:set_int(from.."_EU_supply", 0)
		end
		if to then
			meta2:set_int(to.."_EU_demand", 0)
			meta2:set_int(to.."_EU_supply", 0)
		end
		return
	end
	
	local network_hash = technic.cables[minetest.hash_node_position(pos2)]
	local network = network_hash and minetest.get_position_from_hash(network_hash)
	local sw_pos = network and {x=network.x,y=network.y+1,z=network.z}
	if not sw_pos or not minetest.get_node(sw_pos).name == "technic:switching_station" then
		if to then
			meta2:set_int(to.."_EU_supply", 0)
		end
		if from then
			meta1:set_int(from.."_EU_demand", 0)
		end
		return
	end
	local sw_meta = minetest.get_meta(sw_pos)
	local demand = sw_meta:get_int("demand")
	local supply = sw_meta:get_int("supply")
	
	network_hash = technic.cables[minetest.hash_node_position(pos1)]
	network = network_hash and minetest.get_position_from_hash(network_hash)
	local sw_pos2 = network and {x=network.x,y=network.y+1,z=network.z}
	if not sw_pos2 or not minetest.get_node(sw_pos2).name == "technic:switching_station" then
		if to then
			meta2:set_int(to.."_EU_supply", 0)
		end
		if from then
			meta1:set_int(from.."_EU_demand", 0)
		end
		return
	end

	if from and to and from==to and not vector.equals(sw_pos, sw_pos2) then
		local input = meta1:get_int(from.."_EU_input")
		if supply > 0 then
			demand = math.max(demand - (supply-meta2:get_int(to.."_EU_supply")), 0)
		end
		if input > bought then
			demand = bought
		else
			bought = bought - input
		end
		meta1:set_int(from.."_EU_demand", demand)
		meta1:set_int(from.."_EU_supply", 0)
		meta2:set_int(to.."_EU_demand", 0)
		meta2:set_int(to.."_EU_supply", input)
		meta1:set_int("bought", bought)
		meta1:set_string("infotext", S("@1 (owned by @2) (@3)", machine_name, meta1:get_string("owner"), technic.EU_string(bought)))
	else
		meta1:set_string("infotext", S("@1 (owned by @2) Has Bad Cabling (@3)", machine_name, meta1:get_string("owner"), technic.EU_string(bought)))
		if to then
			meta2:set_int(to.."_EU_supply", 0)
		end
		if from then
			meta1:set_int(from.."_EU_demand", 0)
		end
		return
	end
end

local old_func = minetest.registered_nodes["technic_powermeter:meter_bottom"].on_place

--bottom is the one with the selectionbox
minetest.override_item("technic_powermeter:meter_bottom",{
	groups = {bed = 1, snappy=2, choppy=2, oddly_breakable_by_hand=2,
		technic_machine=1, technic_all_tiers=1},
	connect_sides = {"front"},
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("input") and
			inv:is_empty("output") and
			default.can_interact_with_node(player, pos)
	end,
	on_rightclick = function(pos, node, clicker)
		if not clicker then return end
		local name = clicker:get_player_name()
		if not name then return end
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		minetest.show_formspec(name,"technic_powermeter:form", form_meter(pos, default.can_interact_with_node(clicker, pos)))
		form_table[name] = pos
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local udef = minetest.registered_nodes[node.name]
		local pos
		if udef and udef.buildable_to then
			pos = under
		else
			pos = pointed_thing.above
		end
		itemstack = old_func(itemstack, placer, pointed_thing)
		if minetest.get_node(pos).name == "technic_powermeter:meter_bottom" then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			inv:set_size("input", 1)
			inv:set_size("output", 4)
			meta:set_string("owner", placer:get_player_name() or "")
			meta:set_string("infotext", "Power Meter (owned by "..meta:get_string("owner")..")")
			--meta:set_int("LV_EU_timeout", 2)
			--meta:set_int("MV_EU_timeout", 2)
			--meta:set_int("HV_EU_timeout", 2)
			technic.clear_networks(pos)
		end	
		return itemstack
	end,
	technic_run = run,
	--technic_on_disable = run,
})
minetest.override_item("technic_powermeter:meter_top",{
	groups = {bed = 2, snappy=2, choppy=2, oddly_breakable_by_hand=2,
		technic_machine=1, technic_all_tiers=1, not_on_creative_inventory = 1},
	connect_sides = {"back"}
})

for tier, machines in pairs(technic.machines) do
	technic.register_machine(tier, "technic_powermeter:meter_bottom", technic.receiver)
	technic.register_machine(tier, "technic_powermeter:meter_top", technic.producer)
end
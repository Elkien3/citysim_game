-- The supply converter is a generic device which can convert from
-- LV to MV and back, and HV to MV and back.
-- The machine is configured by the wiring below and above it.
--
-- It works like this:
--   The top side is setup as the receiver side, the bottom as the producer side.
--   Once the receiver side is powered it will deliver power to the other side.
--   Unused power is wasted just like any other producer!

local digilines_path = minetest.get_modpath("digilines")

local S = technic.getter

local cable_entry = "^technic_cable_connection_overlay.png"

local function set_supply_converter_formspec(meta)
	local formspec = "size[5,3]"..
		"field[0.3,0.5;2,1;power;"..S("Input Power")..";"..meta:get_int("power").."]"
	if digilines_path then
		formspec = formspec..
			"field[2.3,0.5;3,1;channel;Digiline Channel;"..meta:get_string("channel").."]"
	end
	-- The names for these toggle buttons are explicit about which
	-- state they'll switch to, so that multiple presses (arising
	-- from the ambiguity between lag and a missed press) only make
	-- the single change that the user expects.
	if meta:get_int("mesecon_mode") == 0 then
		formspec = formspec.."button[0,1;5,1;mesecon_mode_1;"..S("Ignoring Mesecon Signal").."]"
	else
		formspec = formspec.."button[0,1;5,1;mesecon_mode_0;"..S("Controlled by Mesecon Signal").."]"
	end
	if meta:get_int("enabled") == 0 then
		formspec = formspec.."button[0,1.75;5,1;enable;"..S("%s Disabled"):format(S("Supply Converter")).."]"
	else
		formspec = formspec.."button[0,1.75;5,1;disable;"..S("%s Enabled"):format(S("Supply Converter")).."]"
	end
	if meta:get_int("autoenabled") == 0 then
		formspec = formspec.."button[0,2.5;5,1;autoenable;"..S("%s Disabled"):format(S("Automatic mode")).."]"
	else
		formspec = formspec.."button[0,2.5;5,1;autodisable;"..S("%s Enabled"):format(S("Automatic mode")).."]"
	end
	meta:set_string("formspec", formspec)
end

local supply_converter_receive_fields = function(pos, formname, fields, sender)
	if not sender or minetest.is_protected(pos, sender:get_player_name()) then
		return
	end
	local meta = minetest.get_meta(pos)
	local power = nil
	if fields.power then
		power = tonumber(fields.power) or 0
		power = math.max(power, 0)
		power = math.min(power, 10000)
		power = 100 * math.floor(power / 100)
		if power == meta:get_int("power") then power = nil end
		meta:set_int("autoenabled", 0)
	end
	if power then meta:set_int("power", power) end
	if fields.channel then meta:set_string("channel", fields.channel) end
	if fields.enable  then meta:set_int("enabled", 1) end
	if fields.disable then meta:set_int("enabled", 0) end
	if fields.mesecon_mode_0 then meta:set_int("mesecon_mode", 0) end
	if fields.mesecon_mode_1 then meta:set_int("mesecon_mode", 1) end
	if fields.autoenable then meta:set_int("autoenabled", 1) end
	if fields.autodisable then meta:set_int("autoenabled", 0) end
	set_supply_converter_formspec(meta)
end

local mesecons = {
	effector = {
		action_on = function(pos, node)
			minetest.get_meta(pos):set_int("mesecon_effect", 1)
		end,
		action_off = function(pos, node)
			minetest.get_meta(pos):set_int("mesecon_effect", 0)
		end
	}
}


local digiline_def = {
	receptor = {
		rules = technic.digilines.rules,
		action = function() end
	},
	effector = {
		rules = technic.digilines.rules,
		action = function(pos, node, channel, msg)
			if type(msg) ~= "string" then
				return
			end
			local meta = minetest.get_meta(pos)
			if channel ~= meta:get_string("channel") then
				return
			end
			msg = msg:lower()
			if msg == "get" then
				digilines.receptor_send(pos, technic.digilines.rules, channel, {
					enabled      = meta:get_int("enabled"),
					power        = meta:get_int("power"),
					mesecon_mode = meta:get_int("mesecon_mode")
				})
				return
			elseif msg == "off" then
				meta:set_int("enabled", 0)
			elseif msg == "on" then
				meta:set_int("enabled", 1)
			elseif msg == "toggle" then
				local onn = meta:get_int("enabled")
				onn = 1-onn -- Mirror onn with pivot 0.5, so switch between 1 and 0.
				meta:set_int("enabled", onn)
			elseif msg:sub(1, 5) == "power" then
				local power = tonumber(msg:sub(7))
				if not power then
					return
				end
				power = math.max(power, 0)
				power = math.min(power, 10000)
				power = 100 * math.floor(power / 100)
				meta:set_int("power", power)
				meta:set_int("autoenabled", 0)
			elseif msg:sub(1, 12) == "mesecon_mode" then
				meta:set_int("mesecon_mode", tonumber(msg:sub(14)))
			elseif msg == "autoenable" then
				meta:set_int("autoenabled", 1)
			elseif msg == "autodisable" then
				meta:set_int("autoenabled", 0)
			elseif msg == "autotoggle" then
				local onn = meta:get_int("autoenabled")
				onn = 1-onn -- Mirror onn with pivot 0.5, so switch between 1 and 0.
				meta:set_int("autoenabled", onn)
			else
				return
			end
			set_supply_converter_formspec(meta)
		end
	},
}

local run = function(pos, node, run_stage)
	-- run only in producer stage.
	if run_stage == technic.receiver then
		return
	end

	local remain = 0.9
	-- Machine information
	local machine_name  = S("Supply Converter")
	local meta          = minetest.get_meta(pos)
	local enabled       = meta:get_int("enabled") == 1 and
		(meta:get_int("mesecon_mode") == 0 or meta:get_int("mesecon_effect") ~= 0)

	local pos_up        = {x=pos.x, y=pos.y+1, z=pos.z}
	local pos_down      = {x=pos.x, y=pos.y-1, z=pos.z}
	local name_up       = minetest.get_node(pos_up).name
	local name_down     = minetest.get_node(pos_down).name

	local from = technic.get_cable_tier(name_up)
	local to   = technic.get_cable_tier(name_down)
	
	if enabled and meta:get_int("autoenabled") == 1 then
		local lowdemand = 0
		local lowsupply = 0
		local network_hash = technic.cables[minetest.hash_node_position(pos_down)]
		local network = network_hash and minetest.get_position_from_hash(network_hash)
		local sw_pos = network and vector.offset(network, 0, 1, 0)
		if sw_pos and minetest.get_node(sw_pos).name == "technic:switching_station" then
			local sw_meta = minetest.get_meta(sw_pos)
			lowdemand = sw_meta:get_int("demand")
			lowsupply = sw_meta:get_int("supply")
			if technic.sw_pos2network then
				local network_id = technic.sw_pos2network(sw_pos)
				local network2 = network_id and technic.networks[network_id]
				lowdemand = network2.demand
				lowsupply = network2.supply
			end
			if lowsupply > 0 then
				lowdemand = math.max(lowdemand - (lowsupply-meta:get_int(to.."_EU_supply")), 0)
			end
		end
		meta:set_int("power", math.ceil(lowdemand/remain))
	end
	
	local demand = enabled and meta:get_int("power") or 0
	
	if from and to then
		local input = meta:get_int(from.."_EU_input")
		if (technic.get_timeout(from, pos) <= 0) or (technic.get_timeout(to, pos) <= 0) then
			-- Supply converter timed out, either RE or PR network is not running anymore
			input = 0
		end
		meta:set_int(from.."_EU_demand", demand)
		meta:set_int(from.."_EU_supply", 0)
		meta:set_int(to.."_EU_demand", 0)
		meta:set_int(to.."_EU_supply", input * remain)
		meta:set_string("infotext", S("@1 (@2 @3 -> @4 @5)", machine_name,
			technic.EU_string(input), from,
			technic.EU_string(input * remain), to))
	else
		meta:set_string("infotext", S("%s Has Bad Cabling"):format(machine_name))
		if to then
			meta:set_int(to.."_EU_supply", 0)
		end
		if from then
			meta:set_int(from.."_EU_demand", 0)
		end
		return
	end

end

minetest.register_node("technic:supply_converter", {
	description = S("Supply Converter"),
	tiles  = {
		"technic_supply_converter_tb.png"..cable_entry,
		"technic_supply_converter_tb.png"..cable_entry,
		"technic_supply_converter_side.png",
		"technic_supply_converter_side.png",
		"technic_supply_converter_side.png",
		"technic_supply_converter_side.png"
		},
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2,
		technic_machine=1, technic_all_tiers=1},
	connect_sides = {"top", "bottom"},
	sounds = default.node_sound_wood_defaults(),
	on_receive_fields = supply_converter_receive_fields,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Supply Converter"))
		if digilines_path then
			meta:set_string("channel", "supply_converter"..minetest.pos_to_string(pos))
		end
		meta:set_int("power", 10000)
		meta:set_int("enabled", 1)
		meta:set_int("mesecon_mode", 0)
		meta:set_int("mesecon_effect", 0)
		set_supply_converter_formspec(meta)
	end,
	mesecons = mesecons,
	digiline = digiline_def,
	technic_run = run,
	technic_on_disable = run,
})

minetest.register_craft({
	output = 'technic:supply_converter 1',
	recipe = {
		{'basic_materials:gold_wire', 'technic:rubber',         'technic:doped_silicon_wafer'},
		{'technic:mv_transformer', 'technic:machine_casing', 'technic:lv_transformer'},
		{'technic:mv_cable',       'technic:rubber',         'technic:lv_cable'},
	},
	replacements = { {"basic_materials:gold_wire", "basic_materials:empty_spool"}, },
})

for tier, machines in pairs(technic.machines) do
	technic.register_machine(tier, "technic:supply_converter", technic.producer_receiver)
end


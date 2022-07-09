--[[IMPORTANT you need to change your builtin/game/item.lua usage of is_protected from its original to
if core.is_protected(place_to, playername, true, def.name) then
if core.is_protected(pos, diggername, false, node.name) then
for place and dig respectively, or protected blocks not in exception list will only be diggable with drill vehicle
--]]
if minetest.settings:get_bool("default_tweaks.overwrite_item", false) then
	dofile(minetest.get_modpath("default_tweaks").."/builtin-item.lua")--this will overwrite the default item.lua. copied from 5.5.0-dev
end

local list = {
	"beds:bed_bottom", "beds:fancy_bed_bottom", "xdecor:baricade", "streets:roadwork_delineator_bottom", "streets:roadwork_delineator_light_bottom",
	"streets:roadwork_blinking_light_on", "streets:roadwork_blinking_light_off", "streets:roadwork_pylon", "realchess:chessboard", "default:glass",
	"xpanes:glass_pane", "xpanes:glass_pane_flat", "xpanes:pane", "xpanes:pane_flat", "doors:door_glass_a", "doors:door_glass_b", "default:water_source", "default_tweaks:protect"
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
	description = "Protection Block, temporary, works against all players.",
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
			minetest.remove_node(pos)
			minetest.add_item(pos, "default_tweaks:protect")
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

local grieftbl = {}

minetest.register_globalstep(function(dtime)
	for posstring, tbl in pairs(grieftbl) do
		tbl.timeout = tbl.timeout + dtime
		if tbl.timer then--one place action by player cannot count for more than .5 seconds of build time.
			tbl.timer = tbl.timer + dtime
			if tbl.timer > .5 then tbl.timer = .5 end
		end
		if tbl.timeout > 60 then--actions interrupted for more than a minute are cancelled
			grieftbl[posstring] = nil
		end
	end
end)

local function make_strong_block(nodename, strength)
	if not strength then strength = 60 end-- 1 minute default drill time
	local def = minetest.registered_nodes[nodename]
	if not def then return end
	local groups = table.copy(def.groups or {})
	groups.strong = strength
	minetest.override_item(nodename, {groups = groups, node_dig_prediction = ""})
	local nomodname = string.gsub(nodename, ".*:", "")
	if minetest.registered_nodes["stairs:slab_"..nomodname] then--automatically add stairs at lowered strength if available
		make_strong_block("stairs:slab_"..nomodname, math.floor(strength*.5))
		make_strong_block("stairs:stair_"..nomodname, math.floor(strength*.75))
		make_strong_block("stairs:stair_outer_"..nomodname, math.floor(strength*.666))
		make_strong_block("stairs:stair_inner_"..nomodname, math.floor(strength*.857))
	end
end

function make_strong_door(doorname, strength)
	local suffixtbl = {"_a", "_b", "_c", "_d", "_open"}
	for i, suffix in pairs(suffixtbl) do
		make_strong_block(doorname..suffix, strength)
	end
end

minetest.register_on_mods_loaded(function()
	local strongblocklist = {["default:steelblock"] = 60*10, ["default:bronzeblock"] = 60*8, ["default:goldblock"] = 60*10,
	["default:copperblock"] = 60*6, ["default:tinblock"] = 60*4, ["default:obsidian"] = 60*15, ["default:obsidian_block"] = 60*15,
	["default:obsidianbrick"] = 60*15, ["default:obsidian_glass"] = 90, ["xpanes:obsidian_pane"] = 30,
	["xpanes:obsidian_pane_flat"] = 30, ["default:sign_wall_steel"] = 30, ["default:diamondblock"] = 60*20, ["default:mese"] = 60*20,
	["basic_materials:brass_block"] = 60*10, ["basic_materials:concrete_block"] = 60*2, ["moreores:mithril_block"] = 60*25,
	["moreores:silver_block"] = 60*10, ["technic:blast_resistant_concrete"] = 60*4, ["technic:carbon_steel_block"] = 60*12,
	["technic:cast_iron_block"] = 60*14, ["technic:chromium_block"] = 60*16, ["technic:lead_block"] = 60*10,
	["technic:stainless_steel_block"] = 60*20, ["technic:zinc_block"] = 60*20, ["vote_block:poll"] = 30, ["army:chainlink"] = 60,
	["streets:fence_chainlink"] = 30, ["streets:fence_chainlink_door_closed"] = 60, ["streets:fence_chainlink_door_open"] = 60,
	["3d_armor_stand:locked_armor_stand"] = 30, ["areas:shop"] = 30, ["currency:shop"] = 30, ["currency:safe"] = 60*10,
	["bed_metal:bed_bottom"] = 30, ["bed_metal:bed_top"] = 30, ["oil:pump"] = 30, ["elevator:elevator_off"] = 30,
	["elevator:elevator_on"] = 30, ["elevator:motor"] = 60*4, ["frisk:metal_detector"] = 60*4, ["locksmith:mesecon_switch_off"] = 30,
	["locksmith:mesecon_switch_on"] = 30, ["mesecons_switch:mesecon_switch_off"] = 30, ["mesecons_switch:mesecon_switch_on"] = 30,
	["inbox:empty"] = 30, ["inbox:full"] = 30, ["mesecons_random:ghoststone"] = 60, ["streets:steel_support"] = 60,
	["technic:steel_strut_with_insulator_clip"] = 60, ["technic:granite"] = 60, ["streets:concrete_wall"] = 60,
	["streets:roadwork_traffic_barrier"] = 60, ["streets:bigpole"] = 30, ["streets:bigpole_corner"] = 30, ["streets:bigpole_cross"] = 30,
	["streets:bigpole_edge"] = 30, ["streets:bigpole_short"] = 30, ["streets:bigpole_tjunction"] = 30}
	
	local strongdoorlist = {["doors:door_steel"] = 60*1,["doors:trapdoor_steel"] = 60*1, ["xpanes:door_steel_bar"] = 60*1,
	["xpanes:trapdoor_steel_bar"] = 60*1, ["doors:prison_door"] = 60*1, ["doors:rusty_prison_door"] = 60*1}
	for nodename, strength in pairs(strongblocklist) do
		make_strong_block(nodename, strength)
	end
	for doorname, strength in pairs(strongdoorlist) do
		make_strong_door(doorname, strength)
	end
	for nodename, def in pairs(minetest.registered_nodes) do
		if def.groups and def.groups.technic_machine then
			make_strong_block(nodename, 60)
		elseif string.find(nodename, "streets:sign_") and nodename ~= "streets:sign_blank" and nodename ~= "streets:sign_blank_polemount" and nodename ~= "streets:sign_workshop" then
			make_strong_block(nodename, 3)
		end
	end
end)

local old_is_protected = minetest.is_protected
local function handle_griefing(pos, name, placing, nodename)
	if placing == nil then return true end
	if minetest.get_node_group(nodename, "strong") > 0 then return true end
	if not minetest.check_player_privs(name, {griefing=true}) then return true end
	local posstring = minetest.pos_to_string(pos)
	local tbl = grieftbl[posstring]
	if tbl == nil or tbl.placing ~= placing or tbl.nodename ~= nodename then
		if placing then
			tbl = {placing = placing, nodename = nodename, timeout = 0, progress = 0, timer = 0}
		else
			tbl = {placing = placing, nodename = nodename, timeout = 0, progress = 0}
		end
		grieftbl[posstring] = tbl
	end
	tbl.timeout = 0
	if placing then
		tbl.progress = tbl.progress + tbl.timer--placing is done in 10 seconds
		tbl.timer = 0
	else
		tbl.progress = tbl.progress + 1--digging is done in 10 digs
	end
	--minetest.chat_send_all(tbl.progress)
	if tbl.progress >= 10 then
		return false
	else
		local def = core.registered_nodes[nodename]
		if def and def.sounds and name ~= "" then
			if placing and def.sounds.place then
				core.sound_play(def.sounds.place, {
					pos = pos,
					exclude_player = name,
				}, true)
			elseif def.sounds.dug then
				core.sound_play(def.sounds.dug, {
					pos = pos,
					exclude_player = name,
				}, true)
			end
		end
		grieftbl[posstring] = nil
		return true
	end
end
function minetest.is_protected(pos, name, placing, nodename)
	if name == "cars:drill" then return false end
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
				if is_tempprotected(pos) or old_is_protected(pos, name) then
					return handle_griefing(pos, name, placing, nodename)
				end
			end
		end
	end
	--minetest.chat_send_all(nodename.." "..tostring(list[nodename]))
	if list[nodename] then
		return false
	else
		if is_tempprotected(pos) or old_is_protected(pos, name) then
			return handle_griefing(pos, name, placing, nodename)
		end
	end
end
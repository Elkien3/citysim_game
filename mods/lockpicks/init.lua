--lockpicks v0.8 by HeroOfTheWinds
--Adds a variety of lockpicks and redefines most locked objects to allow them to be 'picked' and unlocked.

local breakexp = .66 --exponent for tools to determine 

local has_moreores = false
if minetest.get_modpath("moreores") ~= nil then
	has_moreores = true
end

--lockpick definitions
--[[minetest.register_tool("lockpicks:lockpick_wood", {
	description="Wooden Lockpick",
	inventory_image = "wooden_lockpick.png",
	tool_capabilities = {
		max_drop_level = 1,
		groupcaps = {locked={maxlevel=1, uses=10, times={[3]=5.00}}}
	}
})--]]
minetest.register_tool("lockpicks:lockpick_steel", {
	description="Steel Lockpick",
	inventory_image = "steel_lockpick.png",
	tool_capabilities = {
		max_drop_level = 2,
		groupcaps = {locked={maxlevel=1, uses=20, times={[1]=6.00}}}
	}
})
minetest.register_tool("lockpicks:lockpick_copper", {
	description="Copper Lockpick",
	inventory_image = "copper_lockpick.png",
	tool_capabilities = {
		max_drop_level = 3,
		groupcaps = {locked={maxlevel=1, uses=30, times={[1]=5.50}}}
	}
})
if has_moreores then
minetest.register_tool("lockpicks:lockpick_silver", {
	description="Silver Lockpick",
	inventory_image = "silver_lockpick.png",
	tool_capabilities = {
		max_drop_level = 4,
		groupcaps = {locked={maxlevel=1, uses=40, times={[1]=3.00}}}
	}
})
end
minetest.register_tool("lockpicks:lockpick_gold", {
	description="Gold Lockpick",
	inventory_image = "gold_lockpick.png",
	tool_capabilities = {
		max_drop_level = 5,
		groupcaps = {locked={maxlevel=2, uses=50, times={[2]=12.00,[1]=2.00}}}
	}
})
if has_moreores then
minetest.register_tool("lockpicks:lockpick_mithril", {
	description="Mithril Lockpick",
	inventory_image = "mithril_lockpick.png",
	tool_capabilities = {
		max_drop_level = 6,
		groupcaps = {locked={maxlevel=3, uses=50, times={[3]=20.00,[2]=8.00,[1]=1.00}}}
	}
})
end

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


--locked node definitions

--load technic chests
modpath=minetest.get_modpath("lockpicks")

dofile(modpath.."/defaults.lua")

--pick recipe definitions
minetest.register_craft({
	output = "lockpicks:lockpick_wood",
	recipe = {
		{"", "default:stick", "default:stick"},
		{"", "default:stick", ""},
		{"", "default:wood", ""}
	}
})
minetest.register_craft({
	output = "lockpicks:lockpick_steel",
	recipe = {
		{"", "default:steel_ingot", "default:steel_ingot"},
		{"", "default:steel_ingot", ""},
		{"", "default:wood", ""}
	}
})
minetest.register_craft({
	output = "lockpicks:lockpick_copper",
	recipe = {
		{"", "default:copper_ingot", "default:copper_ingot"},
		{"", "default:copper_ingot", ""},
		{"", "default:steel_ingot", ""}
	}
})
if has_moreores then
minetest.register_craft({
	output = "lockpicks:lockpick_silver",
	recipe = {
		{"", "moreores:silver_ingot", "moreores:silver_ingot"},
		{"", "moreores:silver_ingot", ""},
		{"", "default:steel_ingot", ""}
	}
})
end
minetest.register_craft({
	output = "lockpicks:lockpick_gold",
	recipe = {
		{"", "default:gold_ingot", "default:gold_ingot"},
		{"", "default:gold_ingot", ""},
		{"", "default:steel_ingot", ""}
	}
})
if has_moreores then
minetest.register_craft({
	output = "lockpicks:lockpick_mithril",
	recipe = {
		{"", "moreores:mithril_ingot", "moreores:mithril_ingot"},
		{"", "moreores:mithril_ingot", ""},
		{"", "default:steel_ingot", ""}
	}
})
end
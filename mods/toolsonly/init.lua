local toolsonly = false
local shortrange = true
local lowstack = false
local maxstack = 20
local smallinv = true
local invsize = 16

local function add_toolsonly()
	for itemstring, def in pairs(minetest.registered_nodes) do
			if def.groups.oddly_breakable_by_hand then def.groups.oddly_breakable_by_hand = nil end
			if not def.groups.level and not def.groups.dig_immediate then def.groups.level = 2 end
			minetest.override_item(itemstring, {groups = def.groups })
	end
end

local function add_shortrange()
	minetest.override_item("", {range = 3,})
end

local function add_lowstack()
	for itemstring, def in pairs(minetest.registered_items) do
		minetest.override_item(itemstring, {stack_max = maxstack})
	end
end

if toolsonly then
	minetest.after(0, add_toolsonly)
end
if shortrange then
	minetest.after(0, add_shortrange)
end
if lowstack then
	minetest.after(0, add_lowstack)
end
if smallinv then
	minetest.register_on_joinplayer(function(player)
		local player_inv = player:get_inventory()
		player_inv:set_size("main", invsize)
	end)
end
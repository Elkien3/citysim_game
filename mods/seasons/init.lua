local mod_storage = minetest.get_mod_storage()
seasons = minetest.deserialize(mod_storage:get_string("seasons")) or {}

local months = {}
table.insert(months, {name = "January", days = 31})
table.insert(months, {name = "February", days = 28})
table.insert(months, {name = "March", days = 31})
table.insert(months, {name = "April", days = 30})
table.insert(months, {name = "May", days = 31})
table.insert(months, {name = "June", days = 30})
table.insert(months, {name = "July", days = 31})
table.insert(months, {name = "August", days = 31})
table.insert(months, {name = "September", days = 30})
table.insert(months, {name = "October", days = 31})
table.insert(months, {name = "November", days = 30})
table.insert(months, {name = "December", days = 31})

function seasons_getyear(days)
	local i = 0
	local totaldays = days or minetest.get_day_count()
	if not totaldays then return end
	while true do
		if totaldays - (i*365) > 365 then
			i = i + 1
		else
			return i
		end
	end
end
function seasons_getmonth(days)
	local totaldays = days or minetest.get_day_count()
	if not totaldays then return end
	if totaldays > 365 then
		totaldays = totaldays - (seasons_getyear(totaldays)*365)
	end
	for id, month in pairs(months) do
		if totaldays - month.days < 1 then
			return id, month.name, totaldays
		else
			totaldays = totaldays - month.days
		end
	end
end

function seasons_getseason(days)
	local id = seasons_getmonth(days)
	if id == 12 or id == 1 or id == 2 then
		return "Winter"
	elseif id >= 3 and id <= 5 then
		return "Spring"
	elseif id >= 6 and id <= 8 then
		return "Summer"
	elseif id >= 9 and id <= 11 then
		return "Fall"
	else
		return false
	end
end

minetest.register_chatcommand("date", {
	params = "<none>",
	description = "Get current date",
	privs = {shout = true},
	func = function( _ , _)
		local days = minetest.get_day_count()
		local year = seasons_getyear(days)
		days = days-(year*365)
		local id, month, day = seasons_getmonth(days)
		if year and month and day then
			return true, "Date is "..month.." "..tostring(day).." "..tostring(year+2000).." ("..seasons_getseason(days)..")"
		else
			return false, "Unable to get date."
		end
	end,
})

local function changeflowertextures(revert)
	local flowers = {}
	table.insert(flowers, "rose")
	table.insert(flowers, "tulip")
	table.insert(flowers, "dandelion_yellow")
	table.insert(flowers, "chrysanthemum_green")
	table.insert(flowers, "geranium")
	table.insert(flowers, "viola")
	table.insert(flowers, "dandelion_white")
	table.insert(flowers, "tulip_black")
	for id, name in pairs (flowers) do
		if revert then
			minetest.override_item("flowers:" .. name, {
				tiles = {"flowers_" .. name .. ".png"},
				inventory_image = "flowers_" .. name .. ".png",
				wield_image = "flowers_" .. name .. ".png",		
			})
		else
			minetest.override_item("flowers:" .. name, {
				tiles = {"flowers_" .. name .. ".png^[colorize:#cdcdcd:150"},
				inventory_image = "flowers_" .. name .. ".png^[colorize:#cdcdcd:150",
				wield_image = "flowers_" .. name .. ".png^[colorize:#cdcdcd:150",		
			})
		end
	end
end

local function slowtreegrowth()
	local trees = {}
	table.insert(trees, "sapling")
	table.insert(trees, "junglesapling")
	table.insert(trees, "pine_sapling")
	table.insert(trees, "acacia_sapling")
	table.insert(trees, "aspen_sapling")
	for id, name in pairs (trees) do
		minetest.override_item("default:" .. name, {
			on_construct = function(pos)
				minetest.get_node_timer(pos):start(math.random(2*60*60, 3*60*60))
			end,
		})
	end
end
slowtreegrowth()

minetest.register_lbm({
	name = "seasons:ensuresaplingtimer",
	nodenames = {":moretrees:rubber_tree_sapling", "default:sapling", "default:junglesapling", "default:pine_sapling", "default:acacia_sapling", "default:aspen_sapling"},
	run_at_every_load = true,
	action = function(pos, node)
		local timer = minetest.get_node_timer(pos)
		if not timer:is_started() then
			timer:start(math.random(2*60*60, 3*60*60))
		end
	end,
})

local originalflowerspread = flowers.flower_spread
flowers.flower_spread = function(pos, node)
	if node.name ~= "flowers:mushroom_red" and node.name ~= "flowers:mushroom_brown" and seasons_getseason == "Winter" then
		return
	else
		originalflowerspread(pos, node)
	end
end

local originalgrowsapling = default.grow_sapling
default.grow_sapling = function(pos)
	if seasons_getseason == "Winter" then
		minetest.get_node_timer(pos):start(math.random(2*60*60, 3*60*60))
	else
		originalgrowsapling(pos)
	end
end

local function handleseasons()
	if seasons.current == "Winter" then
		changeflowertextures()
		minetest.override_item('default:dirt_with_grass', {
			tiles = {"default_snow.png", "default_dirt.png",
			{name = "default_dirt.png^default_snow_side.png",
				tileable_vertical = false}},
		})
		minetest.override_item('default:apple', {
			tiles = {"default_apple.png^[colorize:#cdcdcd:100"},
			inventory_image = "default_apple.png^[colorize:#cdcdcd:100",
		})
		minetest.override_item('default:leaves', {
			tiles = {"invisible.png"},
			special_tiles = {"invisible.png"},
			walkable = false,
			pointable = false,
			sunlight_propagates = true,
			buildable_to = true,
			on_place = function(itemstack, placer, pointed_thing) return nil end
		})
		minetest.override_item('default:bush_leaves', {
			tiles = {"invisible.png"},
			walkable = false,
			pointable = false,
			sunlight_propagates = true,
			buildable_to = true,
			on_place = function(itemstack, placer, pointed_thing) return nil end
		})
		minetest.override_item('default:aspen_leaves', {
			tiles = {"invisible.png"},
			walkable = false,
			pointable = false,
			sunlight_propagates = true,
			buildable_to = true,
			on_place = function(itemstack, placer, pointed_thing) return nil end
		})
		minetest.override_item('default:blueberry_bush_leaves_with_berries', {
			tiles = {"invisible.png"},
			walkable = false,
			pointable = false,
			sunlight_propagates = true,
			buildable_to = true,
			on_place = function(itemstack, placer, pointed_thing) return nil end
		})
		minetest.override_item('default:blueberry_bush_leaves', {
			tiles = {"invisible.png"},
			walkable = false,
			pointable = false,
			sunlight_propagates = true,
			buildable_to = true,
			on_place = function(itemstack, placer, pointed_thing) return nil end
		})
		add_suffocation()
		local i = 1
		while i <= 5 do
			minetest.override_item("default:grass_"..tostring(i), {
				tiles = {"default_grass_"..tostring(i)..".png^[colorize:#cdcdcd:200"},
				inventory_image = "default_grass_"..tostring(i)..".png^[colorize:#cdcdcd:200",
				wield_image = "default_grass_"..tostring(i)..".png^[colorize:#cdcdcd:200",
			})
			i = i + 1
		end
	elseif seasons.current == "Spring" then
		changeflowertextures(true)
		farming_setspeed(2)
		minetest.override_item('default:dirt_with_grass', {
			tiles = {"default_dry_grass.png",
			"default_dirt.png",
			{name = "default_dirt.png^default_dry_grass_side.png",
				tileable_vertical = false}},
		})
		minetest.override_item('default:apple', {
			tiles = {"default_apple.png"},
			inventory_image = "default_apple.png",
		})
		local i = 1
		while i <= 5 do
			minetest.override_item("default:grass_"..tostring(i), {
				tiles = {"default_dry_grass_"..tostring(i)..".png^[colorize:#9cb93e:40"},
				inventory_image = "default_dry_grass_"..tostring(i)..".png^[colorize:#9cb93e:40",
				wield_image = "default_dry_grass_"..tostring(i)..".png^[colorize:#9cb93e:40",
			})
			i = i + 1
		end
	elseif seasons.current == "Summer" then
		changeflowertextures(true)
		farming_setspeed(1)
		minetest.override_item('default:dirt_with_grass', {
			tiles = {"default_grass.png", "default_dirt.png",
			{name = "default_dirt.png^default_grass_side.png",
				tileable_vertical = false}},
		})
		minetest.override_item('default:apple', {
			tiles = {"default_apple.png"},
			inventory_image = "default_apple.png",
		})
		minetest.override_item('default:leaves', {
			tiles = {"default_leaves.png"},
			special_tiles = {"default_leaves_simple.png"},
			walkable = true,
			pointable = true,
			sunlight_propagates = false,
			buildable_to = false,
			on_place = function(itemstack, placer, pointed_thing) return itemstack end
		})
		minetest.override_item('default:bush_leaves', {
			tiles = {"default_leaves_simple.png"},
			walkable = true,
			pointable = true,
			sunlight_propagates = false,
			buildable_to = false,
			on_place = function(itemstack, placer, pointed_thing) return itemstack end
		})
		minetest.override_item('default:aspen_leaves', {
			tiles = {"default_aspen_leaves.png"},
			walkable = true,
			pointable = true,
			sunlight_propagates = false,
			buildable_to = false,
			on_place = function(itemstack, placer, pointed_thing) return itemstack end
		})
		minetest.override_item('default:blueberry_bush_leaves_with_berries', {
			tiles = {"default_blueberry_bush_leaves.png^default_blueberry_overlay.png"},
			walkable = true,
			pointable = true,
			sunlight_propagates = false,
			buildable_to = false,
			on_place = function(itemstack, placer, pointed_thing) return itemstack end
		})
		minetest.override_item('default:blueberry_bush_leaves', {
			tiles = {"default_blueberry_bush_leaves.png"},
			walkable = true,
			pointable = true,
			sunlight_propagates = false,
			buildable_to = false,
			on_place = function(itemstack, placer, pointed_thing) return itemstack end
		})
		local i = 1
		while i <= 5 do
			minetest.override_item("default:grass_"..tostring(i), {
				tiles = {"default_grass_"..tostring(i)..".png"},
				inventory_image = "default_grass_"..tostring(i)..".png",
				wield_image = "default_grass_"..tostring(i)..".png",
			})
			i = i + 1
		end
	elseif seasons.current == "Fall" then
		changeflowertextures(true)
		farming_setspeed(2)
		minetest.override_item('default:dirt_with_grass', {
			tiles = {"default_dry_grass.png",
			"default_dirt.png",
			{name = "default_dirt.png^default_dry_grass_side.png",
				tileable_vertical = false}},
		})
		minetest.override_item('default:apple', {
			tiles = {"default_apple.png"},
			inventory_image = "default_apple.png",
		})
		minetest.override_item('default:leaves', {
			tiles = {"default_leaves_fall.png"},
			special_tiles = {"default_leaves_fall_simple.png"},
			walkable = true,
			pointable = true,
			sunlight_propagates = false,
			buildable_to = false,
			on_place = function(itemstack, placer, pointed_thing) return itemstack end
		})
		minetest.override_item('default:bush_leaves', {
			tiles = {"default_leaves_fall_simple.png"},
			walkable = true,
			pointable = true,
			sunlight_propagates = false,
			buildable_to = false,
			on_place = function(itemstack, placer, pointed_thing) return itemstack end
		})
		minetest.override_item('default:aspen_leaves', {
			tiles = {"default_aspen_leaves_fall.png"},
			walkable = true,
			pointable = true,
			sunlight_propagates = false,
			buildable_to = false,
			on_place = function(itemstack, placer, pointed_thing) return itemstack end
		})
		minetest.override_item('default:blueberry_bush_leaves_with_berries', {
			tiles = {"default_blueberry_bush_leaves_fall.png^default_blueberry_overlay.png"},
			walkable = true,
			pointable = true,
			sunlight_propagates = false,
			buildable_to = false,
			on_place = function(itemstack, placer, pointed_thing) return itemstack end
		})
		minetest.override_item('default:blueberry_bush_leaves', {
			tiles = {"default_blueberry_bush_leaves_fall.png"},
			walkable = true,
			pointable = true,
			sunlight_propagates = false,
			buildable_to = false,
			on_place = function(itemstack, placer, pointed_thing) return itemstack end
		})
		local i = 1
		while i <= 5 do
			minetest.override_item("default:grass_"..tostring(i), {
				tiles = {"default_dry_grass_"..tostring(i)..".png^[colorize:#9cb93e:40"},
				inventory_image = "default_dry_grass_"..tostring(i)..".png^[colorize:#9cb93e:40",
				wield_image = "default_dry_grass_"..tostring(i)..".png^[colorize:#9cb93e:40",
			})
			i = i + 1
		end
	else
		return
	end
	minetest.log("info", "Seasons: Handled textures")
end
handleseasons()

local needsChange = false
local function tick(timed)
	local days = minetest.get_day_count()
	if days then
		local season = seasons_getseason(days)
		if seasons.current ~= season then
			if #minetest.get_connected_players() == 0 then
				handleseasons()
			else
				needsChange = true
			end
		end
		seasons.current = season
		mod_storage:set_string("seasons", minetest.serialize(seasons))
	else
		minetest.after(1, tick)
	end
	if timed then
		minetest.after(60, tick, true)
	end
end
minetest.after(1, tick, true)

minetest.register_on_leaveplayer(function(player)
	if needsChange and #minetest.get_connected_players() == 0 then
		handleseasons()
		needsChange = false
	end
end)
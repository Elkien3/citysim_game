--add more stages to digging mapgen stone
--skip stages for players that have "fresh" arms

local storage = minetest.get_mod_storage()

local stonestagetbl = minetest.deserialize(storage:get_string("stonestagetbl")) or {}
local lastupdated = storage:get_int("stonestagelastupdated")
if lastupdated == 0 then lastupdated = os.time() end

local twostage = 600--at or below this you dig in two stages (in seconds of dig time)
local threestage = 800--at or below this you dig in three stages
local capstage = 1000--you dont wear your arm out past this
local ticktime = 86.4--you recover from digging one second every ticktime seconds

local function updatestonestage()
	local currenttime = os.time()
	local addtime = math.floor((currenttime-lastupdated)/ticktime)
	local update = false
	for name, amount in pairs(stonestagetbl) do
		update = true
		amount = amount - addtime
		if amount <= 0 then
			stonestagetbl[name] = nil
		else
			stonestagetbl[name] = amount
		end
		--minetest.chat_send_all(stonestagetbl[name] or 0)
	end
	if update then
		storage:set_string("stonestagetbl", minetest.serialize(stonestagetbl))
	end
	lastupdated = currenttime
	storage:set_int("stonestagelastupdated", lastupdated)
	minetest.after(ticktime, updatestonestage)
end
updatestonestage()

local stonedef = table.copy(minetest.registered_nodes["default:stone"])
local stone_after_dig = function(pos, oldnode, oldmetadata, digger)
	local newnodename
	if not digger then return end
	local name = digger:get_player_name()
	if not name then return end
	--minetest.chat_send_all((stonestagetbl[name] or 0))
	if not stonestagetbl[name] or stonestagetbl[name] <= twostage then
		local stagetbl = {
			["default:stone"] = "default_tweaks:stone_3",
			["default_tweaks:stone_1"] = "default_tweaks:stone_3",
		}
		newnodename = stagetbl[oldnode.name]
	elseif stonestagetbl[name] <= threestage then
		local stagetbl = {
			["default:stone"] = "default_tweaks:stone_1",
			["default_tweaks:stone_1"] = "default_tweaks:stone_3",
		}
		newnodename = stagetbl[oldnode.name]
	else
		local stagetbl = {
			["default:stone"] = "default_tweaks:stone_1",
			["default_tweaks:stone_1"] = "default_tweaks:stone_2",
			["default_tweaks:stone_2"] = "default_tweaks:stone_3",
		}
		newnodename = stagetbl[oldnode.name]
	end
	if newnodename then
		minetest.set_node(pos, {name = newnodename})
	else--node was dug
		local wielditem = digger:get_wielded_item()
		local nodedef = minetest.registered_nodes[oldnode.name]
		local digtime
		if wielditem and nodedef then
			digtime = minetest.get_dig_params(nodedef.groups, wielditem:get_tool_capabilities()).time
		end
		--minetest.chat_send_all(dump(digtime))
		stonestagetbl[name] = (stonestagetbl[name] or 0) + (digtime or 1)
		if stonestagetbl[name] > capstage then
			stonestagetbl[name] = capstage
		else
			--storage:set_string("stonestagetbl", minetest.serialize(stonestagetbl))--commented out to save resources
		end
	end
end

stonedef.drop = "default:cobble"
minetest.register_node("default_tweaks:stone", table.copy(stonedef))

stonedef.after_dig_node = stone_after_dig
stonedef.tiles[1] = "default_stone.png^[crack:1:1"
stonedef.drop = ""
stonedef.node_dig_prediction = "default_tweaks:stone_2"
minetest.register_node("default_tweaks:stone_1", table.copy(stonedef))

stonedef.node_dig_prediction = "default_tweaks:stone_3"
stonedef.tiles[1] = "default_stone.png^[crack:1:2"
minetest.register_node("default_tweaks:stone_2", table.copy(stonedef))

stonedef.node_dig_prediction = "air"
stonedef.tiles[1] = "default_stone.png^[crack:1:3"
stonedef.drop = "default:cobble"
minetest.register_node("default_tweaks:stone_3", table.copy(stonedef))

minetest.override_item("default:stone", {
	node_placement_prediction = "default_tweaks:stone",
	on_place = function(itemstack, placer, pointed_thing)
		itemstack:set_name("default_tweaks:stone")
		itemstack = minetest.item_place(itemstack, placer, pointed_thing)
		if itemstack:get_count() > 0 then
			itemstack:set_name("default:stone")
		end
		return itemstack
	end,
	node_dig_prediction = "default_tweaks:stone_1",
	after_dig_node = stone_after_dig,
	drop = ""
})
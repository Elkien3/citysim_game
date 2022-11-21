--add more stages to digging mapgen stone
--skip stages for players that have "fresh" arms

local storage = minetest.get_mod_storage()

local stonestagetbl = minetest.deserialize(storage:get_string("stonestagetbl")) or {}
local lastupdated = storage:get_int("stonestagelastupdated")
if lastupdated == 0 then lastupdated = os.time() end

local twostage = 240--at or below this you dig in two stages
local threestage = 360--at or below this you dig in three stages
local capstage = 480--you dont wear your arm out past this
local ticktime = 180--you recover from digging one block every ticktime seconds

local function updatestonestage()
	local currenttime = os.time()
	local addblocks = math.floor((currenttime-lastupdated)/ticktime)
	local update = false
	for name, amount in pairs(stonestagetbl) do
		update = true
		amount = amount - addblocks
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
			["default_tweaks:stone"] = "default_tweaks:stone_3",
			["default_tweaks:stone_1"] = "default_tweaks:stone_3",
		}
		newnodename = stagetbl[oldnode.name]
	elseif stonestagetbl[name] <= threestage then
		local stagetbl = {
			["default_tweaks:stone"] = "default_tweaks:stone_1",
			["default_tweaks:stone_1"] = "default_tweaks:stone_3",
		}
		newnodename = stagetbl[oldnode.name]
	else
		local stagetbl = {
			["default_tweaks:stone"] = "default_tweaks:stone_1",
			["default_tweaks:stone_1"] = "default_tweaks:stone_2",
			["default_tweaks:stone_2"] = "default_tweaks:stone_3",
		}
		newnodename = stagetbl[oldnode.name]
	end
	if newnodename then
		minetest.set_node(pos, {name = newnodename})
	else--node was dug
		stonestagetbl[name] = (stonestagetbl[name] or 0) + 1
		if stonestagetbl[name] > capstage then
			stonestagetbl[name] = capstage
		else
			--storage:set_string("stonestagetbl", minetest.serialize(stonestagetbl))--commented out to save resources
		end
	end
end

stonedef.node_dig_prediction = "default_tweaks:stone_1"
stonedef.after_dig_node = stone_after_dig
stonedef.drop = ""
minetest.register_node("default_tweaks:stone", table.copy(stonedef))

minetest.register_alias_force("mapgen_stone", "default_tweaks:stone")

stonedef.tiles[1] = "default_stone.png^[crack:1:1"
stonedef.node_dig_prediction = "default_tweaks:stone_2"
minetest.register_node("default_tweaks:stone_1", table.copy(stonedef))

stonedef.node_dig_prediction = "default_tweaks:stone_3"
stonedef.tiles[1] = "default_stone.png^[crack:1:2"
minetest.register_node("default_tweaks:stone_2", table.copy(stonedef))

stonedef.node_dig_prediction = "air"
stonedef.tiles[1] = "default_stone.png^[crack:1:3"
stonedef.drop = "default:cobble"
minetest.register_node("default_tweaks:stone_3", table.copy(stonedef))
local playerlocs = {}
local income_per_hour
local incometime
local function income()
	income_per_hour = tonumber(minetest.settings:get("money3.income_amount") or "0")
	if income_per_hour > 0 then
		incometime = 3600/income_per_hour
		for _,player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			local givetoplayer = true
			local giveextra = false
			if minetest.get_modpath("mumblereward") ~= nil then
				if mumblereward_players[name] then
					giveextra = true
				end
			end
			if playerlocs[name] and vector.equals(playerlocs[name], player:get_pos()) then
				givetoplayer = false
			end
			playerlocs[name] = player:get_pos()
			if givetoplayer then
				local inv = player:get_inventory()
				inv:add_item("main", "currency:minegeld")
				if giveextra and math.random(2) == 1 then--average 1.5 income for mumble users
					inv:add_item("main", "currency:minegeld")
				end
				minetest.log("info", "[Currency] basic income for "..name.."")
			end
		end
	else
		incometime = 1800--refresh every 30 minutes if disabled
	end
	minetest.after(incometime, income)
end
income()

minetest.register_on_joinplayer(function(player)
	playerlocs[player:get_player_name()] = player:get_pos()
end)
minetest.register_on_leaveplayer(function(player)
	playerlocs[player:get_player_name()] = nil
end)

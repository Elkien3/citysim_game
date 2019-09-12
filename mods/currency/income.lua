players_income = {}
local playerlocs = {}
local timer = 0
local function income()
    for _,player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
		local givetoplayer = true
		if minetest.get_modpath("mumblereward") ~= nil then
			if not mumblereward_players[name] then
				givetoplayer = false 
			end
		end
		if playerlocs[name] and vector.equals(playerlocs[name], player:get_pos()) then
			givetoplayer = false
		end
		playerlocs[name] = player:get_pos()
		if givetoplayer then
			local inv = player:get_inventory()
			inv:add_item("main", "currency:minegeld")
			minetest.log("info", "[Currency] basic income for "..name.."")
		end
    end
	minetest.after(1200, income)
	
end
minetest.after(1200, income)

minetest.register_on_joinplayer(function(player)
	playerlocs[player:get_player_name()] = player:get_pos()
end)
minetest.register_on_leaveplayer(function(player)
	playerlocs[player:get_player_name()] = nil
end)

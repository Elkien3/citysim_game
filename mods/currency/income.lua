players_income = {}

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
		if givetoplayer then
			local inv = player:get_inventory()
			inv:add_item("main", "currency:minegeld")
			minetest.log("info", "[Currency] basic income for "..name.."")
		end
    end
	minetest.after(600, income)
end
minetest.after(600, income)
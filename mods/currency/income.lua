players_income = {}

local timer = 0
local function income()
    for _,player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
		local inv = player:get_inventory()
        inv:add_item("main", "currency:minegeld")
        minetest.log("info", "[Currency] basic income for "..name.."")
    end
	minetest.after(600, income)
end
minetest.after(600, income)
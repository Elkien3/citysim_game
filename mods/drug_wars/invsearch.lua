drug_wars.current_searchers = {}

minetest.create_detached_inventory("searchinv_main", {
        allow_move = function() return 0 end,
        allow_put = function() return 0 end,
        allow_take = function() return 0 end
})

minetest.create_detached_inventory("searchinv_craft", {
    allow_move = function() return 0 end,
    allow_put = function() return 0 end,
    allow_take = function() return 0 end
})

function drug_wars.is_searchable(player, searcher) 
    local player_pos = player:get_pos()
    local searcher_pos = searcher:get_pos()

    local x_diff = (player_pos.x - searcher_pos.x) 
    local y_diff = (player_pos.y - searcher_pos.y) 
    local z_diff = (player_pos.z - searcher_pos.z) 

    return (x_diff * x_diff) + (y_diff * y_diff) + (z_diff * z_diff) < drug_wars.INV_SEARCH_MAX_DISTANCE
end

minetest.register_chatcommand("inv_search", {
    params = "<playername>",
    description = "Request <playername> to show all items in its inventory",
    func = function(searchername, playername)
        local searcher = minetest.get_player_by_name(searchername)
        local player = minetest.get_player_by_name(playername)

        if searcher ~= nil then
            if player ~= nil then
                if drug_wars.is_searchable(player, searcher) then
                    minetest.chat_send_player(playername, searchername .. " asked you to search your inventory (accept with /inv_search_accept)")
                    drug_wars.current_searchers[playername] = searchername 
                else 
                    minetest.chat_send_player(searchername, "inv_search: Player is too far")
                end
            else
                minetest.chat_send_player(searchername, "inv_search: Invalid player name")
            end
        end
    end
})

minetest.register_chatcommand("inv_search_accept", {
    description = "Shows your inventory to your current searcher",
    func = function(playername)
        local player = minetest.get_player_by_name(playername)
        local searchername = drug_wars.current_searchers[playername]

        if searchername ~= nil then
            local searcher = minetest.get_player_by_name(searchername)            
            if player ~= nil then
                if searcher ~= nil then
                    if drug_wars.is_searchable(player, searcher) then
                        local player_maininv = minetest.get_inventory({type="detached", name="searchinv_main"})
                        player_maininv:set_list(playername, player:get_inventory():get_list("main"))

                        local player_craftinv = minetest.get_inventory({type="detached", name="searchinv_craft"})
                        player_craftinv:set_list(playername, player:get_inventory():get_list("craft"))

                        local search_formspec =
                            "size[8, 9]" ..
                            "list[detached:searchinv_craft;"..playername..";2.5,0.5;3,3;]" ..
                            "list[detached:searchinv_main;"..playername..";0,5;8,4;]"

                        minetest.show_formspec(searchername, "drug_wars:inv_search", search_formspec)
                        --minetest.show_formspec(playername, "drug_wars:inv_search", search_formspec)
                        drug_wars.current_searchers[playername] = nil
                    else 
                        minetest.chat_send_player(playername, "inv_show: Searcher is too far")
                    end
                else
                    minetest.chat_send_player(playername, "inv_show: Invalid searcher")
                end
            end
        else
            minetest.chat_send_player(playername, "inv_show: Nobody asked to search your inventory")
        end
    end
})
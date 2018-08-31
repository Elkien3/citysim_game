drug_wars.damage_buffs = {}
drug_wars.defense_buffs = {}

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if(hp_change < 0) then
        if(drug_wars.defense_buffs[player:get_player_name()] ~= nil) then
            hp_change = hp_change * (1.0 - drug_wars.defense_buffs[player:get_player_name()])
        end

        if(reason ~= nil and reason.type == 'punch' and reason.object ~= nil and minetest.is_player(reason.object)) then
            local punchername = reason.object:get_player_name()
        
            if(drug_wars.damage_buffs[punchername] ~= nil) then
                hp_change = hp_change * (1.0 + drug_wars.damage_buffs[punchername])
            end
        end
    end

    return hp_change
end, true)
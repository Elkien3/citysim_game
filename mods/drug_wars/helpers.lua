function drug_wars.add_node_drops(node_name, drop)
    local new_drops = { drop }
    local current_max_items, current_drops

    if minetest.registered_nodes[node_name].drop == nil then
        current_max_items = 1
    else
        current_max_items = minetest.registered_nodes[node_name].drop.max_items
        current_drops = minetest.registered_nodes[node_name].drop.items

        for k, v in pairs(current_drops) do
            table.insert(new_drops, v)
        end
    end

	minetest.override_item(node_name, {
		drop = {
			max_items = current_max_items,
		    items = new_drops
		},
    })
end

function drug_wars.increase_addiction(playername, value) 
    if(drug_wars.addictions[playername] ~= nil) then
        drug_wars.addictions[playername] = drug_wars.addictions[playername] + value
    else
        drug_wars.addictions[playername] = value
    end
end

function drug_wars.get_addiction(playername)
    if(drug_wars.addictions[playername] ~= nil) then
        return drug_wars.addictions[playername]
    else 
        return 0.0
    end
end

function drug_wars.drug_damage(player, value)
    if(player ~= nil) then
        local changetable = {}
        changetable["type"] = "punch"

        local addiction = drug_wars.addictions[player:get_player_name()]
        if(addiction ~= nil) then
            player:set_hp(player:get_hp() - (value * (1 + addiction)), changetable)
        else
            player:set_hp(player:get_hp() - value, changetable)
        end
    end
end

function drug_wars.defense_buff(playername, value)
    if(drug_wars.defense_buffs[playername] ~= nil) then
        drug_wars.defense_buffs[playername] = drug_wars.defense_buffs[playername] + value
        if(drug_wars.defense_buffs[playername] > drug_wars.DEFENSE_BUFF_CEILING) then
            drug_wars.defense_buffs[playername] = drug_wars.DEFENSE_BUFF_CEILING
        end
    else
        drug_wars.defense_buffs[playername] = value
    end
end

function drug_wars.damage_buff(playername, value)
    if(drug_wars.damage_buffs[playername] ~= nil) then
        drug_wars.damage_buffs[playername] = drug_wars.damage_buffs[playername] + value
        if(drug_wars.damage_buffs[playername] > drug_wars.DAMAGE_BUFF_CEILING) then
            drug_wars.damage_buffs[playername] = drug_wars.DAMAGE_BUFF_CEILING
        end
    else
        drug_wars.damage_buffs[playername] = value
    end
end

function drug_wars.speed_buff(player, value)
    if(player ~= nil) then
        local current_phy = player:get_physics_override()
        local new_phy = current_phy
        new_phy.speed = new_phy.speed + value
        player:set_physics_override(new_phy)
    end
end

function drug_wars.speed_debuff(player, value, threshold)
    if(player ~= nil) then
        local current_phy = player:get_physics_override()
        if(current_phy ~= nil) then 
            local change_speed = current_phy.speed > threshold 
            if(change_speed) then
                local new_phy = current_phy
                new_phy.speed = new_phy.speed - value
                player:set_physics_override(new_phy)
            end

            return change_speed
        else
            return nil
        end
    else
        return nil
    end
end

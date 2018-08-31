minetest.register_globalstep(function(dtime) 
    for k, aftereffect in pairs(drug_wars.aftereffects) do
        aftereffect.countdown = aftereffect.countdown - dtime
        if(aftereffect.countdown <= 0) then 
            aftereffect.on_timeout()
            table.remove(drug_wars.aftereffects, k)
        end
    end
end)

drug_wars.addiction_timer = drug_wars.ADDICTION_TICK 

minetest.register_globalstep(function(dtime)
    drug_wars.addiction_timer = drug_wars.addiction_timer - dtime

    if(drug_wars.addiction_timer <= 0) then
        for k, addiction in pairs(drug_wars.addictions) do
            if(drug_wars.addictions[k] >= drug_wars.ADDICTION_REDUCTION_THRESHOLD) then
                local new_addiction = addiction - drug_wars.ADDICTION_REDUCTION
                drug_wars.addictions[k] = new_addiction
                if(drug_wars.addictions[k] < 0) then
                    drug_wars.addictions[k] = 0
                end
                    
                minetest.chat_send_player(k, "Your drug addiction has been reduced") -- to " .. drug_wars.addictions[k])

                if(new_addiction <= drug_wars.ADDICTION_REDUCTION_THRESHOLD) then 
                    drug_wars.addictions[k] = nil
                    minetest.chat_send_player(k, "You detoxed yourself, congratulations!")
                else
                    if(drug_wars.addictions[k] >= drug_wars.ADDICTION_DAMAGE_THRESHOLD) then
                        drug_wars.drug_damage(minetest.get_player_by_name(k), drug_wars.ADDICTION_DAMAGE)
                        minetest.chat_send_player(k, "You are intoxicated by drugs, you should stop with that crap")
                    end
                end
            end

            
        end
        drug_wars.addiction_timer = drug_wars.ADDICTION_TICK
    end
end)
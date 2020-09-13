local modpath, S = ...

petz.brush = function(self, wielded_item_name, pet_name)
    if petz.settings.tamagochi_mode == true then
        if wielded_item_name == "petz:hairbrush" then
            if self.brushed == false then
                petz.set_affinity(self, petz.settings.tamagochi_brush_rate)
                self.brushed = true
                mobkit.remember(self, "brushed", self.brushed)
            else
                minetest.chat_send_player(self.owner, S("Your").." "..S(pet_name).." "..S("had already been brushed."))
            end
        else --it's beaver_oil
            if self.beaver_oil_applied == false then
                petz.set_affinity(self, petz.settings.tamagochi_beaver_oil_rate)
                self.beaver_oil_applied = true
                mobkit.remember(self, "beaver_oil_applied", self.beaver_oil_applied)
            else
                minetest.chat_send_player(self.owner, S("Your").." "..S(pet_name).." "..S("had already been spreaded with beaver oil."))
            end
        end
    end
    mokapi.make_sound("object", self.object, "petz_brushing", petz.settings.max_hear_distance)
    petz.do_particles_effect(self.object, self.object:get_pos(), "star")
end

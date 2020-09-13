local modpath, S = ...

petz.on_step = function(self, dtime)
	local on_step_time = 1
	if mobkit.timer(self, on_step_time) and not(self.dead) then --Only check every 1 sec, not every step!
		if self.init_tamagochi_timer == true then
			petz.init_tamagochi_timer(self)
		end
		if self.is_pregnant == true then
			petz.pregnant_timer(self, on_step_time)
		elseif self.is_baby == true then
			petz.growth_timer(self, on_step_time)
		end
		if self.gallop == true then
			petz.gallop(self, on_step_time)
		end
		if self.dreamcatcher then
			petz.dreamcatcher_save_metadata(self)
		end
		local lifetime = petz.check_lifetime(self)
		if lifetime then
			petz.lifetime_timer(self, lifetime, on_step_time)
		end
		--Tamagochi
		--Check the hungry
		if petz.settings.tamagochi_mode == true and self.is_pet and petz.settings.tamagochi_hungry_warning > 0 and not(self.status=="sleep") then
			if not(self.tmp_follow_texture) then
				local items = string.split(petz.settings[self.type.."_follow"], ',')
				local item = petz.str_remove_spaces(items[1]) --the first one
				local follow_texture
				if string.sub(item, 1, 5) == "group" then
					follow_texture = "petz_pet_bowl_inv.png"
				else
					follow_texture = minetest.registered_items[item].inventory_image
				end
				self.tmp_follow_texture = follow_texture --temporary property
			end
			if mobkit.timer(self, 2) then
				if (self.hp / self.max_hp) <= petz.settings.tamagochi_hungry_warning then
					petz.do_particles_effect(self.object, self.object:get_pos(), "hungry", self.tmp_follow_texture)
				end
			end
		end
	end
end

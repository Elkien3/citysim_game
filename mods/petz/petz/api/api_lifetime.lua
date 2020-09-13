local modpath, S = ...

petz.check_lifetime = function(self)
	local pet_lifetime = petz.settings[self.type.."_lifetime"]
	--minetest.chat_send_all("test")
	if self.dreamcatcher or (petz.settings.lifetime_only_non_tamed and self.tamed) or (petz.settings.lifetime_avoid_non_breedable and self.breed) then
		return false
	elseif petz.settings.lifetime > 0 and not(pet_lifetime and pet_lifetime < 0) then
		--minetest.chat_send_all("test1")
		return petz.settings.lifetime
	elseif pet_lifetime and pet_lifetime > 0 then
		--minetest.chat_send_all("test2")
		return pet_lifetime
	else
		--minetest.chat_send_all("test3")
		return false
	end
end

petz.lifetime_timer = function(self, lifetime, on_step_time)
	if not(self.lifetime) then
		--Firstly apply the variability
		local variability = lifetime * (math.random(0, petz.settings.lifetime_variability*100) / 100)
		if math.random(1, 2) == 1 then
			variability = -variability
		end
		lifetime = mokapi.round(lifetime - variability)
		self.lifetime = mobkit.remember(self, "lifetime", lifetime)
	end
	--minetest.chat_send_all(tostring(self.lifetime))
	self.lifetime = mobkit.remember(self, "lifetime", self.lifetime - on_step_time)
	if self.lifetime <= 0 then
		petz.on_die(self)
	end
end

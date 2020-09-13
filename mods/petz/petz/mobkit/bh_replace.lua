local modpath, S = ...

--
-- Replace Behaviour
--

function petz.bh_replace(self)
	if mokapi.replace(self, "petz_replace", petz.settings.max_hear_distance) then
		petz.refill(self) --Refill wool, milk or nothing
	end
	if self.lay_eggs then
		petz.lay_egg(self)
	end
end

local modpath, S = ...

---
--- Aquatic Behaviours
---

function mobkit.hq_aqua_jump(self, prty)
	local func = function(self)
		local vel_impulse = 2.5
		local velocity = {
			x = self.max_speed * (vel_impulse/3),
			y = self.max_speed * vel_impulse,
			z = self.max_speed * (vel_impulse/3),
		}
		petz.set_velocity(self, velocity)
		self.object:set_acceleration({x=1.0, y=vel_impulse, z=1.0})
		self.status = "jump"
		mokapi.make_sound("object", self.object, "petz_splash", petz.settings.max_hear_distance)
		minetest.after(0.5, function(self, velocity)
			if mobkit.is_alive(self.object) then
				self.status = nil
				mobkit.clear_queue_high(self)
			end
		end, self, velocity)
		return true
	end
	mobkit.queue_high(self, func, prty)
end

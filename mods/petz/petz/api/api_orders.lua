local modpath, S = ...

petz.ownthing = function(self)
	self.status = mobkit.remember(self, "status", nil)
	if self.can_fly then
		mobkit.hq_wanderfly(self, 0)
	elseif self.can_swin and self.isinliquid then
		mobkit.hq_aqua_roam(self, 0, self.max_speed)
	else
		mobkit.hq_roam(self, 0)
	end
	mobkit.clear_queue_low(self)
	mobkit.clear_queue_high(self)
end

petz.stand = function(self)
	self.object:set_velocity({ x = 0, y = 0, z = 0 })
	self.object:set_acceleration({ x = 0, y = 0, z = 0 })
end

petz.standhere = function(self)
	mobkit.clear_queue_high(self)
	mobkit.clear_queue_low(self)
	if self.can_fly == true then
		if mobkit.node_name_in(self, "below") == "air" then
			mobkit.animate(self, "fly")
		else
			mobkit.animate(self, "stand")
		end
	elseif self.can_swin and petz.isinliquid(self) then
		mobkit.animate(self, "def")
	else
		if self.animation["sit"] and not(petz.isinliquid(self)) then
			mobkit.animate(self, "sit")
		else
			mobkit.animate(self, "stand")
		end
	end
	self.status = mobkit.remember(self, "status", "stand")
	--mobkit.lq_idle(self, 2400)
	petz.stand(self)
end

petz.guard = function(self)
	self.status = mobkit.remember(self, "status", "guard")
	mobkit.clear_queue_high(self)
	petz.stand(self)
end

petz.follow = function(self, player)
	mobkit.clear_queue_low(self)
	mobkit.clear_queue_high(self)
	self.status = mobkit.remember(self, "status", "follow")
	if self.can_fly then
		mobkit.animate(self, "fly")
		mobkit.hq_followliquidair(self, 100, player)
	elseif self.can_swin and self.isinliquid then
		mobkit.animate(self, "def")
		mobkit.hq_followliquidair(self, 100, player)
	else
		mobkit.hq_follow(self, 100, player)
	end
end

petz.alight = function(self)
	mobkit.clear_queue_low(self)
	mobkit.clear_queue_high(self)
	if not(mobkit.node_name_in(self, "below") == "air") then
		mobkit.animate(self, "fly")
	end
	mobkit.hq_alight(self, 0)
end

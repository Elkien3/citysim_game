local modpath, S = ...

--
-- Approach Torch Behaviour
-- for moths (not finished!!!)
--

function mobkit.hq_approach_torch(self, prty, tpos)
	local func=function(self)
		local pos = self.object:get_pos()
		if pos and tpos then
			local distance = vector.distance(pos, tpos)
			if distance < self.view_range and (distance >= self.view_range) then
				--if mobkit.is_queue_empty_low(self) then
					--mobkit.lq_followliquidair(self, target)
				--end
			elseif distance >= self.view_range then
				petz.ownthing(self)
				return true
			end
		else
			return true
		end
	end
	mobkit.queue_high(self, func, prty)
end







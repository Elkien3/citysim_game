local carlist = {"black", "blue", "brown", "cyan", 
"dark_green", "dark_grey", "green", "grey", "magenta", 
"orange", "pink", "red", "violet", "white", "yellow"}

for id, color in pairs (carlist) do
	minetest.register_entity("vehicle_mash:car_"..color, {
		on_activate = function(self, staticdata, dtime_s)
			local pos = self.object:getpos()
			ent = minetest.add_entity(pos, "cars:car_"..color)
			if ent then
				ent:setyaw(self.object:getyaw() - math.pi/2)
				self.object:remove()
			end
		end,
	})
end
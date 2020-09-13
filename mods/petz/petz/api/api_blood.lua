local modpath, S = ...

function petz.blood(self)
	if not(petz.settings.blood) or self.no_blood then
		return
	end
	local pos = self.object:get_pos()
	local texture
	if self.blood_texture then
		texture = self.blood_texture
	else
		texture = "petz_blood.png"
	end
	local gravity = -9.8
	minetest.add_particlespawner({
		amount = 5,
		time = 0.25,
		minpos = pos,
		maxpos = pos,
		minvel = {x = -1, y = -1, z = -1},
		maxvel = {x = 1, y = 1, z = 1},
		minacc = {x = 0, y = gravity, z = 0},
		maxacc = {x = 0, y = gravity, z = 0},
		minexptime = 0.1,
		maxexptime = 1,
		minsize = 0.5,
		maxsize = 1,
		texture = texture,
		glow = 0
	})
end

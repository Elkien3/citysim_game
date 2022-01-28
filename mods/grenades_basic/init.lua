local function remove_flora(pos, radius)
	local pos1 = vector.subtract(pos, radius)
	local pos2 = vector.add(pos, radius)

	for _, p in ipairs(minetest.find_nodes_in_area(pos1, pos2, "group:flora")) do
		if vector.distance(pos, p) <= radius then
			minetest.remove_node(p)
		end
	end
end

grenades.register_grenade("grenades_basic:frag", {
	description = "Frag grenade",
	image = "grenades_frag.png",
	on_explode = function(pos, name)
		if not name or not pos then
			return
		end

		local player = minetest.get_player_by_name(name)

		local radius = 6

		minetest.add_particlespawner({
			amount = 20,
			time = 0.5,
			minpos = vector.subtract(pos, radius),
			maxpos = vector.add(pos, radius),
			minvel = {x = 0, y = 5, z = 0},
			maxvel = {x = 0, y = 7, z = 0},
			minacc = {x = 0, y = 1, z = 0},
			maxacc = {x = 0, y = 1, z = 0},
			minexptime = 0.3,
			maxexptime = 0.6,
			minsize = 7,
			maxsize = 10,
			collisiondetection = true,
			collision_removal = false,
			vertical = false,
			texture = "grenades_smoke.png",
		})

		minetest.add_particle({
			pos = pos,
			velocity = {x=0, y=0, z=0},
			acceleration = {x=0, y=0, z=0},
			expirationtime = 0.3,
			size = 15,
			collisiondetection = false,
			collision_removal = false,
			object_collision = false,
			vertical = false,
			texture = "grenades_boom.png",
			glow = 10
		})

		minetest.sound_play("grenades_explode", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 64,
		})

		remove_flora(pos, radius/2)

		for _, v in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
			local hit = minetest.raycast(pos, v:get_pos(), true, true):next()

			if hit and v:is_player() and v:get_hp() > 0 and hit.type == "object" and hit.ref:is_player() and
			hit.ref:get_player_name() == v:get_player_name() then
				v:punch(player, 2, {damage_groups = {grenade = 1, fleshy = 90 * 0.707106 ^ vector.distance(pos, v:get_pos())}}, nil)
			end
		end
	end,
})

-- Flashbang Grenade

local flash_sounds = {}
local flash_spawners = {}

local function add_flashparticlespawner(player, name, step)
	if not flash_spawners[name] then flash_spawners[name] = {} end
	local distance = 20
	flash_spawners[name][step] = minetest.add_particlespawner({
		amount = 320,
		-- Number of particles spawned over the time period `time`.
		time = .1,
		-- Lifespan of spawner in seconds.
		-- If time is 0 spawner has infinite lifespan and spawns the `amount` on
		-- a per-second basis.
		minpos = {x=-distance, y=1.5-distance, z=-distance},
		maxpos = {x=distance, y=1.5+distance, z=distance},
		--minvel = {x=-speed/4, y=-speed/4, z=-speed/4},
		--maxvel = {x=speed/4, y=speed/4, z=speed/4},
		minexptime = 2,
		maxexptime = 2.2,
		minsize = 500,
		maxsize = 500,
		attached = player,
		glow = 14,
		texture = "flash"..tostring(step)..".png",
		playername = name,
	})
	return flash_spawners[name][step]
end

grenades.register_grenade("grenades_basic:flashbang", {
	description = "Flashbang grenade (Blinds all who look at blast)",
	image = "grenades_flashbang.png",
	clock = 1,
	on_explode = function(pos)
		minetest.sound_play("grenades_glasslike_break", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 32,
		})
		minetest.sound_play("grenades_explode", {
			pos = pos,
			gain = .2,
			pitch = 3,
			max_hear_distance = 32,
		})
		for _, v in ipairs(minetest.get_objects_inside_radius(pos, 20)) do
			local hit = minetest.raycast(pos, v:get_pos(), true, true):next()

			if hit and v:is_player() and v:get_hp() > 0 and hit.type == "object" and
			hit.ref:is_player() and hit.ref:get_player_name() == v:get_player_name() then
				local playerdir = vector.round(v:get_look_dir())
				local grenadedir = vector.round(vector.direction(v:get_pos(), pos))
				local pname = v:get_player_name()

				if math.acos(playerdir.x*grenadedir.x + playerdir.y*grenadedir.y + playerdir.z*grenadedir.z) <= math.pi/4 or vector.distance(v:get_pos(), pos) < 3 then
					if flash_sounds[pname] then
						minetest.sound_stop(flash_sounds[pname])
						flash_sounds[pname] = nil
					end
					flash_sounds[pname] = minetest.sound_play("grenades_tinnitus", {
						to_player = pname,
						gain = 1.0,
					})
					if flash_spawners[pname] then
						for i, spawner in pairs(flash_spawners[pname]) do
							minetest.delete_particlespawner(spawner, pname)
						end
					end
					flash_spawners[pname] = {}
					for i = 0, 5, 1 do
						minetest.after(i*2, add_flashparticlespawner, v, pname, i)
					end
				end
			end
		end
	end,
})

grenades.register_grenade("grenades_basic:smoke", {
	description = "Smoke grenade",
	image = "grenades_smoke_grenade.png",
	on_explode = function(pos)
		minetest.sound_play("grenades_glasslike_break", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 32,
		})

		local hiss = minetest.sound_play("grenades_hiss", {
			pos = pos,
			gain = 1.0,
			loop = true,
			max_hear_distance = 32,
		})

		minetest.after(40, minetest.sound_stop, hiss)

		for i = 0, 5, 1 do
			minetest.add_particlespawner({
				amount = 40,
				time = 45,
				minpos = vector.subtract(pos, 2),
				maxpos = vector.add(pos, 2),
				minvel = {x = 0, y = 2, z = 0},
				maxvel = {x = 0, y = 3, z = 0},
				minacc = {x = 1, y = 0.2, z = 1},
				maxacc = {x = 1, y = 0.2, z = 1},
				minexptime = 1,
				maxexptime = 1,
				minsize = 125,
				maxsize = 140,
				collisiondetection = false,
				collision_removal = false,
				vertical = false,
				texture = "grenades_smoke.png",
			})
		end
	end,
	particle = {
		image = "grenades_smoke.png",
		life = 1,
		size = 4,
		glow = 0,
		interval = 5,
	}
})

local teargastbl = {}
local gas_lifetime = 10
local gas_timer = 0
local gaseffecttbl = {}

local gas_entity = {
	initial_properties = {
		physical = true,
		pointable = false,
		visual = "sprite",
		collide_with_objects = false,
		textures = {"grenades_smoke.png"},
		visual_size = {x=1.2, y=1.2},
		collisionbox = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25}
	},
	on_step = function(self, dtime, moveresult)
		self.lifetime = self.lifetime - dtime
		if self.lifetime <= 0 then
			self.object:remove()
			return
		end
		for i, player in pairs(minetest.get_connected_players()) do
			local pos = player:get_pos()
			local selfpos = self.object:get_pos()
			if vector.distance(pos, selfpos) < 20 then--cull anyone farther than 20 blocks
				pos = player:get_pos()
				pos.y = pos.y + 1.45
				local offset = player:get_eye_offset()
				offset = vector.rotate(offset, {x=0,y=player:get_look_horizontal(), z=0})
				pos = vector.add(pos, offset)
				if vector.distance(pos, selfpos) < 1.5 then
					gaseffecttbl[player:get_player_name()] = 20
					if playercontrol then
						playercontrol.set_effect(player:get_player_name(), "speed", .9, "teargas", true)
					else
						player:set_physics_override({speed = .9})
					end
				end
			end
		end
		if moveresult.collisions then
			local newvel
			for i, col in pairs(moveresult.collisions) do
				local vel = col.old_velocity
				if vel[col.axis] > 0 then
					if not newvel then newvel = table.copy(vel) end
					newvel[col.axis] = -vel[col.axis]
				end
			end
			if newvel then
				self.object:set_velocity(newvel)
			end
		end
		if math.random(30) == 1 then--some random movement
			local vel = self.object:get_velocity()
			local randvel = vector.normalize({x=math.random(-100,100),y=0,z=math.random(-100,100)})
			randvel = vector.multiply(randvel, (math.random(10,20)/100))
			self.object:set_velocity(vector.add(vel, randvel))
		end
	end,
	on_activate = function(self, staticdata)
		if not staticdata or staticdata == "" then
			self.object:remove()
		else
			self.lifetime = tonumber(staticdata)
		end
	end
}
minetest.register_entity("grenades_basic:gas_entity", gas_entity)
local gashuds = {}
minetest.register_globalstep(function(dtime)
	gas_timer = gas_timer + dtime
	if gas_timer >= .5 then
		gas_timer = 0
		for name, timer in pairs(gaseffecttbl) do
			local player = minetest.get_player_by_name(name)
			if not player then gaseffecttbl[name] = nil gashuds[name] = nil return end
			if not gashuds[name] then
				gashuds[name] = player:hud_add({
					hud_elem_type = "image",
					position = {x = 0.5, y = 0.5},
					scale = {
						x = -100,
						y = -100
					},
					text = "overlay.png"
				})
			end
			gaseffecttbl[name] = timer - .5
			if gaseffecttbl[name] <= 0 then
				if gashuds[name] then
					player:hud_remove(gashuds[name])
					gashuds[name] = nil
				end
				if playercontrol then
					playercontrol.set_effect(name, "gunwag", nil, "teargas", true)
					local fov = playercontrol.set_effect(name, "fov", nil, "teargas", false)
					if fov then player:set_fov(fov, false, 1) end
					playercontrol.set_effect(player:get_player_name(), "speed", nil, "teargas", true)
				else
					player:set_fov(0, false, 1)
					player:set_physics_override({speed = .9})
				end
				gaseffecttbl[name] = nil
				return
			end
			--[[if math.random(4) == 1 then
				local vert = math.random(-100,100)/100
				local hori = math.random(-100,100)/100
				local total = (math.abs(vert) + math.abs(hori))*math.random(8, 12)
				vert = vert/total
				hori = hori/total
				player:set_look_vertical(player:get_look_vertical()+vert)
				player:set_look_horizontal(player:get_look_horizontal()+hori)
			end--]]
			if math.random(4) == 1 then
				local randvel = vector.normalize({x=math.random(-100,100),y=0,z=math.random(-100,100)})
				randvel = vector.multiply(randvel, (math.random(30,40)/10))
				player:add_velocity(randvel)
			end
			if playercontrol then
				playercontrol.set_effect(name, "gunwag", 20, "teargas", true)
				local fov = playercontrol.set_effect(name, "fov", math.random(60, 80), "teargas", false)
				if fov then player:set_fov(fov, false, 1) end
			else
				player:set_fov(math.random(60, 80), false, 1)
			end
			if math.random(3) == 1 then
				local hp = player:get_hp()
				player:set_hp(hp-1)
				player:set_hp(hp)
			end
		end
		for i, tbl in pairs(teargastbl) do
			tbl.lifetime = tbl.lifetime - .5
			if tbl.lifetime <= 0 then
				table.remove(teargastbl, i)
			else
				local obj = minetest.add_entity(tbl.pos, "grenades_basic:gas_entity", gas_lifetime+math.random(-2,2))
				local randvel = vector.normalize({x=math.random(-100,100),y=math.random(-100,100),z=math.random(-100,100)})
				randvel = vector.multiply(randvel, (math.random(10,20)/20))
				obj:set_velocity(randvel)
			end
		end
	end
end)

grenades.register_grenade("grenades_basic:tear_gas", {
	description = "Tear Gas grenade",
	image = "grenades_tear_gas.png",
	on_explode = function(pos)
		minetest.sound_play("grenades_glasslike_break", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 32,
		})

		local hiss = minetest.sound_play("grenades_hiss", {
			pos = pos,
			gain = 1.0,
			loop = true,
			max_hear_distance = 32,
		})

		minetest.after(40, minetest.sound_stop, hiss)

		table.insert(teargastbl, {pos = pos, lifetime = 40})
	end,
	particle = {
		image = "grenades_smoke.png",
		life = 1,
		size = 4,
		glow = 0,
		interval = 5,
	}
})

dofile(minetest.get_modpath("grenades_basic").."/crafts.lua")
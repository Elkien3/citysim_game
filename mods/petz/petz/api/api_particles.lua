local modpath, S = ...

--
--Particle Effects
--

petz.do_particles_effect = function(obj, pos, particle_type, texture_name)
    local minpos
    minpos = {
        x = pos.x,
        y = pos.y,
        z = pos.z
    }
    local maxpos
    maxpos = {
        x = minpos.x + 0.4,
        y = minpos.y - 0.5,
        z = minpos.z + 0.4
    }
    local time
    local particles_amount
    local min_size
    local max_size
    if particle_type == "star" then
        texture_name = "petz_star_particle.png"
        time = 1.5
        particles_amount = 20
		min_size = 1.0
		max_size = 1.5
    elseif particle_type == "heart" then
        texture_name = "petz_affinity_heart.png"
        time = 1.5
        particles_amount = 10
		min_size = 1.0
		max_size = 1.5
    elseif particle_type == "pregnant_pony" then
        texture_name = "petz_pony_pregnant_icon.png"
        time = 1.5
        particles_amount = 10
        min_size = 5.0
		max_size = 6.0
	elseif particle_type == "pregnant_lamb" then
        texture_name = "petz_lamb_pregnant_icon.png"
        time = 1.5
        particles_amount = 10
        min_size = 5.0
		max_size = 6.0
	elseif particle_type == "pregnant_camel" then
        texture_name = "petz_camel_pregnant_icon.png"
        time = 1.5
        particles_amount = 10
        min_size = 5.0
		max_size = 6.0
	elseif particle_type == "dreamcatcher" then
        texture_name = "petz_dreamcatcher_particle.png"
        time = 1.5
        particles_amount = 15
        min_size = 1.0
		max_size = 2.0
	elseif particle_type == "pollen" then
        texture_name = "petz_pollen.png"
        time = 1.5
        particles_amount = 15
        min_size = 0.5
		max_size = 1.0
	elseif particle_type == "pumpkin" then
        texture_name = "petz_pumpkin_particle.png"
        time = 1.5
        particles_amount = 10
        min_size = 2.0
		max_size = 4.0
	elseif particle_type == "fire" then
        texture_name = "petz_fire_particle.png"
        time = 1.5
        particles_amount = 50
        min_size = 2.0
		max_size = 4.0
	elseif particle_type == "sleep" then
        texture_name = "petz_sleep_particle.png"
        time = 1.5
        particles_amount = 3
        min_size = 1.0
		max_size = 2.0
	elseif particle_type == "hungry" then
        time = 1.5
        particles_amount = 3
        min_size = 1.0
		max_size = 2.0
    end

    minetest.add_particlespawner({
        --attached = objw,
        amount = particles_amount,
        time = time,
        minpos = minpos,
        maxpos = maxpos,
        --minvel = {x=1, y=0, z=1},
        --maxvel = {x=1, y=0, z=1},
        --minacc = {x=1, y=0, z=1},
        --maxacc = {x=1, y=0, z=1},
        minexptime = 1,
        maxexptime = 1,
        minsize = min_size,
        maxsize =max_size,
        collisiondetection = false,
        vertical = false,
        texture = texture_name,
        glow = 14
    })
end

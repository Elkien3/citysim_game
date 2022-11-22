local timer = 0

local function start_unconscious(player)
	local name = player:get_player_name()
	if not medical.data[name] then medical.data[name] = {} end
	if not medical.data[name].unconscious then
		medical.data[name].unconscious = {yaw = player:get_look_horizontal()}
	elseif medical.data[name].unconscious.spawner then
		minetest.delete_particlespawner(medical.data[name].unconscious.spawner)
	end
	interacthandler.revoke(name)
	medical.data[name].unconscious.spawner = minetest.add_particlespawner({
        amount = 100,
        time = 0,
        minpos = {x=0, y=0, z=0},
        maxpos = {x=0, y=0, z=0},
        minvel = {x=-10, y=-10, z=-10},
        maxvel = {x=10, y=10, z=10},
        minacc = {x=0, y=0, z=0},
        maxacc = {x=0, y=0, z=0},
        minexptime = 1,
        maxexptime = 1,
        minsize = 100,
        maxsize = 100,
        attached = player,
        texture = "black.png",
        playername = name,
        glow = 14
    })
	medical.effect_handle(player)
	if not default.player_attached[name] then
		minetest.add_entity(player:get_pos(), "medical:unconsciousattach", name)
	end
	minetest.after(0, function() player_api.set_animation(player, "lay") end)
	--player:set_eye_offset({x=0, y=-13, z=0}, {x=0, y=0, z=0})
end

local function end_unconscious(player)
	local name = player:get_player_name()
	if not medical.data[name] or not medical.data[name].unconscious then return end
	if medical.data[name].unconscious.spawner then
		minetest.delete_particlespawner(medical.data[name].unconscious.spawner)
	end
	interacthandler.grant(name)
	medical.data[name].unconscious = nil
	medical.data[name].hp = nil
	if player:get_attach() and player:get_attach():get_luaentity().name == "medical:unconsciousattach" then
		player:set_detach()
	else
		medical.detach(name)
	end
	player_api.set_animation(player, "stand")
	--player:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
	medical.effect_handle(player)
end

local function add_puddle(player, puddletype, volume)
	local puddleent
	local anim_range = player:get_animation()
	for i, obj in pairs(minetest.get_objects_inside_radius(player:get_pos(), 1)) do
		if obj:get_luaentity() and obj:get_luaentity().name == puddletype then
			puddleent = obj:get_luaentity()
			break
		end
	end
	if not puddleent then
		local puddlepos = player:get_pos()
		if anim_range.x >= 223 and anim_range.x <= 226 then--different offset if recumbant. use parent object yaw if applicable
			puddlepos = vector.add(puddlepos, vector.rotate({x=0,y=0,z=-.55}, {x=0,y=player:get_look_horizontal(),z=0}))
		else
			puddlepos = vector.add(puddlepos, vector.rotate({x=0,y=0,z=.3}, {x=0,y=player:get_look_horizontal(),z=0}))
		end
		local puddleobj = minetest.add_entity(puddlepos, puddletype, minetest.serialize({volume = volume, update = os.time()}))
		if puddleobj then
			puddleent = puddleobj:get_luaentity()
		end
	else
		puddleent.volume = (puddleent.volume or 0) + volume
		puddleent.update = os.time()
		puddlesize = math.sqrt(puddleent.volume)/10
		puddleent.object:set_properties({visual_size = {x=puddlesize, y = puddlepuddlesize}})
	end
end

local hptable = {}
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer > 1 then
		timer = 0
		for i, player in pairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			local md = medical.data[name]
			local totalhpgain = 4--default 4 hp gain per minute
			
			--if airway is obstructed then hunger/thirst/bed/blanket dosnt matter
			if md.obstructed then
				--fix obstructions if patient is not supine
				local anim_range = player:get_animation()
				if (anim_range.x < 162 or anim_range.x > 167) and player:get_breath() > 0 then
					minetest.after(.9, function()
						if not player then return end
						md.obstructed = nil
						add_puddle(player, "medical:puddle_water", 200)
						minetest.sound_play("cough", {
							object = player,
							max_hear_distance = 16,
						}, true)
					end)
				else
					totalhpgain = -20
				end
			else
				--hunger/thirst
				if (hbhunger and hbhunger.get_hunger_raw(player) <= 0) or (thirsty and thirsty.get_hydro(player) <= 0) then
					totalhpgain = 0
					if hbhunger and hbhunger.get_hunger_raw(player) <= 0 then
						totalhpgain = totalhpgain-2
					end
					if thirsty and thirsty.get_hydro(player) <= 0 then
						totalhpgain = totalhpgain-2
					end
				end
				
				--bed and blanket
				for i, obj in pairs(player:get_children()) do
					if obj and obj:get_luaentity() and obj:get_luaentity().name == "medical:blanket" then
						totalhpgain = totalhpgain + 2
						break
					end
				end
				if beds and beds.player[name] then--todo hospital bed
					totalhpgain = totalhpgain + 2
				end
			end
				
			--injury
			if md.injuries then
				local injuryloss = 0
				for index, injury in pairs (md.injuries) do
					injury.healtime = (injury.healtime or 60) - 1
					if beds and beds.player[name] then--heal injuries twice as fast in a bed
						injury.healtime = (injury.healtime or 60) - 1
					end
					if injury.healtime < 1 then
						local ent = medical.entities[name]
						if ent then
							ent = ent[index]
						end
						if ent then
							ent:remove()
						end
						medical.data[name].injuries[index] = nil
						medical.save()
					else
						if not injury.severity then injury.severity = 1 end
						local injurydef = medical.injuries[injury.name]
						local severity = math.max(injury.severity, .05)--treated wounds still are a detriment until they time out
						injuryloss = injuryloss + (injurydef.hploss*severity)
					end
				end
				totalhpgain = totalhpgain - injuryloss
				if math.random(5) == 1 then
					add_puddle(player, "medical:puddle_blood", injuryloss)
				end
			end
			
			if totalhpgain < -30 then--cap hp loss at 30 hp per minute (1 hp per 2 seconds)
				totalhpgain = -30
			end
			
			hptable[name] = hptable[name] + (totalhpgain/60)
			if hptable[name] >= 1 then
				player:set_hp(player:get_hp()+1, {type = "set_hp", source = "medical"})
				hptable[name] = hptable[name] - 1
			elseif hptable[name] <= -1 then
				player:set_hp(player:get_hp()-1, {type = "set_hp", source = "medical"})
				hptable[name] = hptable[name] + 1
			end
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if medical.data[name] and medical.data[name].unconscious then
		start_unconscious(player)
	end
	if not medical.data[name] then
		medical.data[name] = {}
	end
	hptable[name] = 0
end)

minetest.register_on_respawnplayer(function(player)
	player:set_hp(20)
	local name = player:get_player_name()
	end_unconscious(player)
	medical.data[name] = {}
	if medical.entities[name] then
		for bone, obj in pairs(medical.entities[name]) do
			obj:remove()
		end
		medical.entities[name] = nil
	end
	medical.save()
end)
minetest.register_on_shutdown(medical.save)

minetest.register_on_leaveplayer(function(player, timed_out)
	local name = player:get_player_name()
	if medical.data[name] and medical.data[name].unconscious and medical.data[name].unconscious.spawner then
		minetest.delete_particlespawner(medical.data[name].unconscious.spawner)
		medical.data[name].unconscious.spawner = nil
	end
	hptable[name] = nil
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)
	local hp = player:get_hp()
	local hittype = reason.type or "unknown"
	--minetest.chat_send_all(hittype)
	local name = player:get_player_name()
	local md = medical.data[name]
	if md.hp and hittype == "drown" then
		md.obstructed = true
	end
	if md.hp and reason.source and reason.source == "medical" then
		md.hp = md.hp + hp_change
		--minetest.chat_send_all(md.hp)
		if md.hp < -50 then
			return -hp, true
		end
		if md.hp >= 1 then
			end_unconscious(player)
		else
			return -hp+1, true
		end
	elseif not md.hp and hp + hp_change <= 0 then--player would have died
		md.hp = -5-math.random(10)
		start_unconscious(player)
		if hittype == "drown" then
			md.obstructed = true
		end
		return -hp+1, true
	end
	return hp_change
end, true)


minetest.register_entity("medical:puddle_blood", {
    hp_max = 1,
    physical = true,
	collide_with_objects = false,
	pointable = false,
	use_texture_alpha = true,
    collisionbox = {-0.1,-0.01,-0.1, 0.1,0.1,0.1},
    visual = "mesh",
	mesh = "plane.b3d",
    textures = {"puddle_blood.png"}, -- number of required textures depends on visual -- number of required textures depends on visual
    is_visible = true,
    makes_footstep_sound = false,
	on_activate = function(self, staticdata, dtime_s)
		staticdata = minetest.deserialize(staticdata)
		if not staticdata then return end
		self.volume = staticdata.volume
		self.update = staticdata.update
		bloodsize = math.sqrt(self.volume or 0)/16
		self.object:set_properties({visual_size = {x=bloodsize, y = bloodsize}})
		self.object:set_acceleration({x=0, y=-10, z=0})
	end,
	on_step = function(self, dtime)
		if os.time() - self.update > 300 then--5 minutes
			for i = 1, math.floor((os.time() - self.update)/300) do
				self.volume = (self.volume*.9) - 10
			end
			if self.volume <= 0 then
				self.object:remove()
				return
			end
			bloodsize = math.sqrt(self.volume or 0)/16
			self.object:set_properties({visual_size = {x=bloodsize, y = bloodsize}})
			self.update = os.time()
		end
	end,
	get_staticdata = function(self)
		return minetest.serialize({volume = self.volume, update = self.update})
	end
})
minetest.register_entity("medical:puddle_water", {
    hp_max = 1,
    physical = true,
	collide_with_objects = false,
	pointable = false,
	use_texture_alpha = true,
    collisionbox = {-0.1,-0.02,-0.1, 0.1,0.1,0.1},
    visual = "mesh",
	mesh = "plane.b3d",
    textures = {"puddle_water.png"}, -- number of required textures depends on visual -- number of required textures depends on visual
    is_visible = true,
    makes_footstep_sound = false,
	on_activate = function(self, staticdata, dtime_s)
		staticdata = minetest.deserialize(staticdata)
		if not staticdata then return end
		self.volume = staticdata.volume
		self.update = staticdata.update
		puddlesize = math.sqrt(self.volume or 0)/12
		self.object:set_properties({visual_size = {x=puddlesize, y = puddlesize}})
		self.object:set_acceleration({x=0, y=-10, z=0})
	end,
	on_step = function(self, dtime)
		if os.time() - self.update > 300 then--5 minutes
			for i = 1, math.floor((os.time() - self.update)/300) do
				self.volume = (self.volume*.9) - 10
			end
			if self.volume <= 0 then
				self.object:remove()
				return
			end
			bloodsize = math.sqrt(self.volume or 0)/16
			self.object:set_properties({visual_size = {x=bloodsize, y = bloodsize}})
			self.update = os.time()
		end
	end,
	get_staticdata = function(self)
		return minetest.serialize({volume = self.volume, update = self.update})
	end
})

minetest.register_entity("medical:unconsciousattach", {
    hp_max = 1,
    physical = true,
	collide_with_objects = false,
	pointable = false,--this should be false after testing
	use_texture_alpha = true,
    collisionbox = {-0.2,0,-0.2, 0.2,0.4,0.2},
    visual = "sprite",
	textures = {"invis.png"},
	--textures = {"default_dirt.png"},
    is_visible = true,
    makes_footstep_sound = false,
	on_activate = function(self, staticdata, dtime_s)
		if not staticdata or staticdata == "" then self.object:remove() return end
		self.object:set_acceleration({x=0, y=-10, z=0})
		local player = minetest.get_player_by_name(staticdata)
		if not player then self.object:remove() return end
		player:set_attach(self.object)
		default.player_attached[staticdata] = true
		self.object:set_yaw(player:get_look_horizontal())
		self.object:set_properties({collisionbox = player:get_properties().collisionbox})
	end,
	on_detach_child = function(self, child)
		if child:is_player() then
			local name = child:get_player_name()
			if default.player_attached[name] == self.object then
				default.player_attached[name] = nil
			end
		end
		self.object:remove()
	end
})
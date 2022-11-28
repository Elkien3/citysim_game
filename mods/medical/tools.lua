medical.hud = {}
--medical.feeling = {}

medical.usedtools[""] = function(player, clicker, wielditem, hitloc, local_hitloc)
	local playerpos = player:get_pos()
	local cname = clicker:get_player_name()
	local sname = player:get_player_name()
	local vitalpoints = {}
	vitalpoints.laying = {}
	vitalpoints.standing = {}
	vitalpoints.sitting = {}
	vitalpoints.recumbant = {}
	vitalpoints.laying.cartoid =  {x=0,y=.1,z=-.425}
	vitalpoints.laying.breath =  {x=0,y=.1,z=-.6}
	vitalpoints.laying.Arm_Right = {x=.5,y=.1,z=-.05}
	vitalpoints.laying.Arm_Left = {x=-.5,y=.1,z=-.05}
	vitalpoints.laying.Leg_Right = {x=.20,y=.1,z=.7}
	vitalpoints.laying.Leg_Left = {x=-.20,y=.1,z=.7}
	vitalpoints.standing.cartoid =  {x=0,y=1.2,z=.3}
	vitalpoints.standing.breath =  {x=0,y=1.32,z=.2}
	vitalpoints.sitting.cartoid =  {x=0,y=0.67,z=.3}
	vitalpoints.sitting.breath =   {x=0,y=0.79,z=.2}
	vitalpoints.recumbant.cartoid =  {x=0,y=0.25,z=-.4}
	vitalpoints.recumbant.breath =  {x=0,y=0.25,z=-.52}
	local newtbl, anim = medical.get_limb_locations(player, vitalpoints)
	vitalpoints = newtbl
	local distance, hitpart = medical.getclosest(vitalpoints, local_hitloc)
	if distance > .15 then return false end
	local hp = medical.data[sname].hp or player:get_hp()
	--medical.feeling[cname] = {name = sname, hitpart = hitpart, hitloc = hitloc}
	if hitpart == "breath" then
		if medical.hud[cname] then clicker:hud_remove(medical.hud[cname]) medical.hud[cname] = nil end
		medical.hud[cname] = clicker:hud_add({
			hud_elem_type = "image",
			position  = {x = 0.5, y = 0.55},
			offset    = {x = 0, y = 0},
			text      = "nopulse.png",
			scale     = { x = 10, y = 10},
			alignment = { x = 0, y = 0 },
		})
		clicker:hud_set_flags({wielditem=false})
		local respiratory = 48-((hp+100)/3.333)--12 to 48 from a 20 to -100
		--minetest.chat_send_all(respiratory)
		medical.start_timer(cname.."breathcheck", 60/respiratory, true, sname,
			function(arg)
				if medical.data[sname].obstructed then
					return
				elseif respiratory < 20 then
					minetest.sound_play("breathsoft", {
						pos = hitloc,
						to_player = cname,
					})
				elseif  respiratory < 35 then
					minetest.sound_play("breathdeep", {
						pos = hitloc,
						to_player = cname,
					})
				else
					minetest.sound_play("breathrapid", {
						pos = hitloc,
						to_player = cname,
					})
				end
				local circle = clicker:hud_add({
					hud_elem_type = "image",
					position  = {x = 0.5, y = 0.55},
					offset    = {x = 0, y = 0},
					text      = "foundpulse.png",
					scale     = { x = 10, y = 10},
					alignment = { x = 0, y = 0 },
				})
				minetest.after(.15, function()
					local hitter = minetest.get_player_by_name(cname)
					if hitter then
						hitter:hud_remove(circle)
					end
				end)
			end,
			cname,
			function(stoparg)
				local player = minetest.get_player_by_name(stoparg)
				if medical.hud[stoparg] then
					player:hud_remove(medical.hud[stoparg])
					medical.hud[stoparg] = nil
					player:hud_set_flags({wielditem=true})
					--medical.feeling[cname] = nil
				end
			end, "RMB", cname, sname
		)
	else
		local temptex = "temp_normal.png"
		if hp < -60 then
			temptex = "temp_cold.png"
		end
		if medical.hud[cname] then clicker:hud_remove(medical.hud[cname]) medical.hud[cname] = nil end
		medical.hud[cname] = clicker:hud_add({
			hud_elem_type = "image",
			position  = {x = 0.5, y = 0.55},
			offset    = {x = 0, y = 0},
			text      = "nopulse.png^"..temptex,
			scale     = { x = 10, y = 10},
			alignment = { x = 0, y = 0 },
		})
		clicker:hud_set_flags({wielditem=false})
		local pulse = 140-((hp+100)/2)--80 to 140 from a 20 to -100
		--minetest.chat_send_all(pulse)
		medical.start_timer(cname.."pulsecheck", 60/pulse, true, sname,
			function(arg)
				minetest.sound_play("human-heartbeat-daniel_simon", {
					pos = hitloc,
					to_player = cname,
					gain = (hp+100)/120
				})
				local circle = clicker:hud_add({
					hud_elem_type = "image",
					position  = {x = 0.5, y = 0.55},
					offset    = {x = 0, y = 0},
					text      = "foundpulse.png^[opacity:"..(((hp+100)/120)*255),
					scale     = { x = 10, y = 10},
					alignment = { x = 0, y = 0 },
				})
				minetest.after(.15, function()
					local hitter = minetest.get_player_by_name(cname)
					if hitter then
						hitter:hud_remove(circle)
					end
				end)
			end,
			cname,
			function(stoparg)
				local player = minetest.get_player_by_name(stoparg)
				if medical.hud[stoparg] then
					player:hud_remove(medical.hud[stoparg])
					medical.hud[stoparg] = nil
					player:hud_set_flags({wielditem=true})
					--medical.feeling[cname] = nil
				end
			end, "RMB", cname, sname
		)
	end
	return true
end

local function rotateVector(x, y, a)
  local c = math.cos(a)
  local s = math.sin(a)
  return c*x - s*y, s*x + c*y
end

medical.attachedtools[""] = function(player, clicker, wielditem, hitloc, local_hitloc)
	--local limb = medical.getlimb(self.object, clicker, nil, nil, hitloc)
	local cname = clicker:get_player_name()
		if not player then return end
	local name = player:get_player_name()
	local grabpoints = {}
	grabpoints.laying = {}
	grabpoints.laying.logrollleft = {x=-.21, y = .11, z = -.085}
	grabpoints.laying.logrollright = {x=.21, y = .11, z = -.085}
	grabpoints.laying.breath = {x=0, y = .2, z = -.505}
	grabpoints.laying.compression = {x=0, y = .14, z = -.223}
	grabpoints.recumbant = {}
	grabpoints.recumbant.logrollback = {x=0, y = .11, z = -.085}
	local newtbl, anim = medical.get_limb_locations(player, grabpoints)
	grabpoints = newtbl
	local distance, hitpart = medical.getclosest(grabpoints, local_hitloc)
	--minetest.chat_send_all(dump(distance))
	--minetest.chat_send_all(dump(hitpart))
	if hitpart == "logrollleft" or hitpart == "logrollright" and distance <= .15 then
		local recumbantanim = {}
		local side = "left"
		if hitpart == "logrollleft" then
			side = "right"
		end
		--player:set_properties({mesh = "medical_character.b3d"})
		--minetest.chat_send_all("recimbantboi")
		player_api.set_animation(player, "recumbant"..side)
		return
	elseif hitpart == "logrollback" and distance <= .15 then
		player_api.set_animation(player, "lay")
		return
	--[[elseif hitpart == "compression" and distance <= .15 then
		if medical.hud[cname] then
			clicker:hud_remove(medical.hud[cname])
		end
		medical.hud[cname] = medical.add_anim_hud(clicker, {
			hud_elem_type = "image",
			position  = {x = 0.5, y = 0.55},
			offset    = {x = 0, y = 0},
			scale     = { x = 10, y = 10},
			alignment = { x = 0, y = 0 },
			text = "compressionnew.png",
			frame_amount = 3,
			frame_duration = .1,
			keep_at_end = true,
		})
		clicker:hud_set_flags({wielditem=false})
		local stoparg = {cname = cname, name = name}
		local func = function(player)
			medical.pulse(player, true)
			--minetest.chat_send_all(math.random(10))
			medical.timers[cname].func = function() medical.refill_heart(player) end--no pulse when heart is compressed
		end
		local stopfunc = function(stoparg)
			medical.refill_heart(player)
			if medical.hud[cname] then
				medical.remove_anim_hud(clicker, medical.hud[cname])
				medical.hud[cname] = medical.add_anim_hud(clicker, {
					hud_elem_type = "image",
					position  = {x = 0.5, y = 0.55},
					offset    = {x = 0, y = 0},
					scale     = { x = 10, y = 10},
					alignment = { x = 0, y = 0 },
					text = "compressionreverse.png",
					frame_amount = 5,
					frame_duration = .1,
					keep_at_end = false,
				})
			end
		end
		medical.start_timer(cname, .25, true, player, func, stoparg, stopfunc, "LMB", cname)
		return
	elseif hitpart == "breath" and distance <= .15 then
		if medical.hud[cname] then
			clicker:hud_remove(medical.hud[cname])
		end
		local tex = "breath.png"
		if medical.data[name].obstructed then
			tex = "breathfail.png"
		end
		medical.hud[cname] = medical.add_anim_hud(clicker, {
			hud_elem_type = "image",
			position  = {x = 0.5, y = 0.55},
			offset    = {x = 0, y = 0},
			scale     = { x = 10, y = 10},
			alignment = { x = 0, y = 0 },
			text = tex,
			frame_amount = 4,
			frame_duration = .25,
			keep_at_end = true,
		})
		clicker:hud_set_flags({wielditem=false})
		local stoparg = {cname = cname, name = name}
		local func = function(player)
			medical.breathe(player, true)
			--minetest.chat_send_all(math.random(10))
			medical.timers[cname].func = function() if math.random(3) == 1 then medical.data[name].obstructed = true end end
			medical.timers[cname].length = 1
		end
		local stopfunc = function(stoparg)
			if medical.hud[cname] then
				medical.remove_anim_hud(clicker, medical.hud[cname])
				medical.hud[cname] = medical.add_anim_hud(clicker, {
					hud_elem_type = "image",
					position  = {x = 0.5, y = 0.55},
					offset    = {x = 0, y = 0},
					scale     = { x = 10, y = 10},
					alignment = { x = 0, y = 0 },
					text = "breathreverse.png",
					frame_amount = 6,
					frame_duration = .25,
					keep_at_end = false,
				})
			end
		end
		medical.start_timer(cname, .5, true, player, func, stoparg, stopfunc, "LMB", cname)
		return--]]
	end
	local all_objects = minetest.get_objects_inside_radius(hitloc, 10)
	local cname = clicker:get_player_name()
	for _,obj in ipairs(all_objects) do
		local pos = obj:get_pos()
		local marker = clicker:hud_add({
			hud_elem_type = "waypoint",
			name = obj:get_entity_name(),
			number = 0xFF0000,
			world_pos = obj:get_pos()
		})
			minetest.after(5, function()
				local hitter = minetest.get_player_by_name(cname)
				if hitter then
					hitter:hud_remove(marker)
				end
			end)
	end
end

minetest.register_craftitem("medical:blanket", {
	description = "Blanket",
	inventory_image = "medical_blanket.png",
	tool_capabilities = {
		full_punch_interval = 1,
		damage_groups = {fleshy=0},
	},
})
minetest.register_craft({
	output = "medical:blanket",
	recipe = {
		{"farming:cotton","farming:cotton","farming:cotton"},
		{"farming:cotton","farming:cotton","farming:cotton"},
	},
})

medical.attachedtools["medical:blanket"] = function(player, clicker, wielditem, hitloc, local_hitloc)
	local loctbl, anim = medical.get_limb_locations(player)
	if anim == "standing" or anim == "sitting" then return end
	for i, obj in pairs(player:get_children()) do
		if obj:get_luaentity().name == "medical:blanket" then--no double blanketing
			return
		end
	end
	if not minetest.is_creative_enabled(clicker:get_player_name()) then
		wielditem:take_item()
		clicker:set_wielded_item(wielditem)
	end
	local obj = minetest.add_entity(player:get_pos(), "medical:blanket", "spawn")
	obj:set_attach(player)
	obj:set_properties({mesh = "blanket-"..anim..".b3d"})
end

minetest.register_entity("medical:blanket", {
    hp_max = 1,
    physical = false,
	pointable = true,
	--use_texture_alpha = false,
    collisionbox = {-0.4,.2,-0.4, 0.4,0.4,0.4},
    visual = "mesh",
	mesh = "blanket-laying.b3d",
    textures = {"wool_white.png"},
    is_visible = true,
    makes_footstep_sound = false,
	on_activate = function(self, staticdata, dtime_s)
		if not staticdata or staticdata == "" then self.object:remove() return end
		self.object:set_armor_groups({fleshy = 0})
	end,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if not puncher:is_player() then return end
		local inv = puncher:get_inventory()
		if not minetest.is_creative_enabled(puncher:get_player_name()) then
			minetest.add_item(self.object:get_pos(), inv:add_item("main", "medical:blanket"))
		end
		self.object:remove()
	end,
})
orig_func = player_api.set_animation
player_api.set_animation = function(player, anim_name, speed)
	for i, obj in pairs(player:get_children()) do
		if obj:get_luaentity() and obj:get_luaentity().name == "medical:blanket" then
			minetest.add_item(obj:get_pos(), "medical:blanket")
			obj:remove()
		end
	end
	orig_func(player, anim_name, speed)
end
	
--[[
minetest.register_tool("medical:bpcuff", {
    description = "Blood Pressure Cuff",
    inventory_image = "bpcuff.png",
})

minetest.register_tool("medical:bpbladder", {
    description = "Blood Pressure Cuff",
    inventory_image = "bpcuffbladder.png",
	on_use = function(itemstack, player, pointed_thing)
		--inflate bp cuff
	end
})

minetest.register_entity("medical:bpcuff", {
    hp_max = 1,
    physical = false,
    weight = 5,
    collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
    visual = "cube",
    visual_size = {x=.25, y=.25},--{x=.211, y=.211},
    textures = {"default_coal_block.png", "default_coal_block.png", "default_coal_block.png", "default_coal_block.png", "default_coal_block.png", "default_coal_block.png"}, -- number of required textures depends on visual
    colors = {}, -- number of required colors depends on visual
    spritediv = {x=1, y=1},
    initial_sprite_basepos = {x=0, y=0},
    is_visible = true,
    makes_footstep_sound = false,
    automatic_rotate = false,
	on_activate = function(self, staticdata, dtime_s)
		if not staticdata or staticdata == "" then self.object:remove() end
		self.owner = staticdata
	end
})

minetest.register_entity("medical:line", {
    hp_max = 1,
    physical = false,
    weight = 5,
    collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
    visual = "cube",
    visual_size = {x=.05, y=.1},
    textures = {"blackline.png", "blackline.png", "blackline.png", "blackline.png", "blackline.png", "blackline.png"}, -- number of required textures depends on visual
    colors = {}, -- number of required colors depends on visual
    spritediv = {x=1, y=1},
    initial_sprite_basepos = {x=0, y=0},
    is_visible = true,
    makes_footstep_sound = false,
    automatic_rotate = false,
	on_step = function(self, dtime)
		if not self.target or not self.owner then self.object:remove() return end
		local player = minetest.get_player_by_name(self.owner)
		local op = player:get_pos()
		op.y = op.y + 1
		op = vector.add(op, vector.multiply(player:get_player_velocity(), .1))
		if self.lastpos and vector.equals(self.lastpos, op) then return end
		local tp = self.target
		
		if vector.distance(op, tp) > 1.5 then
			local inv = player:get_inventory()
			local list = "main"
			return
		end
		
		local delta = vector.subtract(op, tp)
		local yaw = math.atan2(delta.z, delta.x) - math.pi / 2
		local pitch = math.atan2(delta.y,  math.sqrt(delta.z*delta.z + delta.x*delta.x))
		pitch = pitch + math.pi/2
		
		self.object:move_to({x=(op.x+tp.x)/2, y=(op.y+tp.y)/2, z=(op.z+tp.z)/2, })
		self.object:set_rotation({x=pitch, y=yaw, z=0})
		self.object:set_properties({visual_size = {x=.05, y=vector.distance(tp, op)}})
		self.lastpos = op
	end,
	on_activate = function(self, staticdata, dtime_s)
		if not staticdata or staticdata == "" then self.object:remove() end
		self.owner = staticdata
		self.target = self.object:get_pos()
	end
})

medical.attachedtools["medical:bpcuff"] = function(self, clicker, wielditem, hitloc, local_hitloc)
	local limb = medical.getlimb(self.object, clicker, nil, nil, hitloc)
	local bone
	if limb == "rightarm" then bone = "Arm_Right" elseif limb == "leftarm" then bone = "Arm_Left" else return end
	local pos = self.object:get_pos()
	local obj = minetest.add_entity(pos, "medical:bpcuff", clicker:get_player_name())
	minetest.after(0, function()
		local marker = clicker:hud_add({
			hud_elem_type = "waypoint",
			name = "hit",
			number = 0xFF0000,
			world_pos = obj:get_pos()
		}) end)
	obj:set_attach(self.object, bone, {x=0,y=.5,z=0}, {x=0,y=0,z=0})
	--local obj = minetest.add_entity(hitloc, "medical:line", clicker:get_player_name())
	minetest.after(0, function() clicker:set_wielded_item({name = ""})end)
end--]]
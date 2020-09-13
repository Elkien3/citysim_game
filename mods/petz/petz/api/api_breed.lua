local modpath, S = ...

petz.breed = function(self, clicker, wielded_item, wielded_item_name)
	if self.is_rut == false and self.is_pregnant == false then
		wielded_item:take_item()
		clicker:set_wielded_item(wielded_item)
		self.is_rut = true
		mobkit.remember(self, "is_rut", self.is_rut)
		petz.do_particles_effect(self.object, self.object:get_pos(), "heart")
		mokapi.make_sound("object", self.object, "petz_"..self.type.."_moaning", petz.settings.max_hear_distance)
	else
		if self.is_rut then
			minetest.chat_send_player(clicker:get_player_name(), S("This animal is already rut."))
		else
			minetest.chat_send_player(clicker:get_player_name(), S("This animal is already pregnant."))
		end
	end
end

petz.pony_breed = function(self, clicker, wielded_item, wielded_item_name)
	if wielded_item_name == "petz:glass_syringe" and self.is_male== true then
		local new_wielded_item = ItemStack("petz:glass_syringe_sperm")
		local meta = new_wielded_item:get_meta()
		local speedup = (self.horseshoes or 0) * petz.settings.horseshoe_speedup
		meta:set_string("petz_type", self.type)
		meta:set_int("max_speed_forward", (self.max_speed_forward - speedup))
		meta:set_int("max_speed_reverse", (self.max_speed_reverse - speedup))
		meta:set_int("accel", (self.accel - speedup))
		if wielded_item:get_count() > 1 then
			local inv = clicker:get_inventory()
			if not inv:room_for_item("main", new_wielded_item) then
				minetest.chat_send_player(clicker:get_player_name(), S("No room in your inventory for a Glass Syringe with seed."))
				return
			end
			wielded_item:take_item(1)
			clicker:set_wielded_item(wielded_item)
			inv:add_item("main", new_wielded_item)
		else
			clicker:set_wielded_item(new_wielded_item)
		end
	elseif wielded_item_name == "petz:glass_syringe_sperm" and self.is_male== false then
		local meta = wielded_item:get_meta()
		local petz_type = meta:get_string("petz_type")
		if self.is_pregnant == false and self.pregnant_count > 0 and self.type == petz_type then
			self.is_pregnant = mobkit.remember(self, "is_pregnant", true)
			local pregnant_count = self.pregnant_count - 1
			mobkit.remember(self, "pregnant_count", pregnant_count)
			local max_speed_forward = meta:get_int("max_speed_forward")
			local max_speed_reverse = meta:get_int("max_speed_reverse")
			local accel = meta:get_int("accel")
			local father_veloc_stats = {}
			father_veloc_stats["max_speed_forward"] = max_speed_forward
			father_veloc_stats["max_speed_reverse"] = max_speed_reverse
			father_veloc_stats["accel"] = accel
			self.father_veloc_stats = mobkit.remember(self, "father_veloc_stats", father_veloc_stats)
			petz.do_particles_effect(self.object, self.object:get_pos(), "pregnant".."_"..self.type)
			clicker:set_wielded_item("petz:glass_syringe")
		end
	end
end

petz.childbirth = function(self)
	local pos = self.object:get_pos()
	self.is_pregnant = mobkit.remember(self, "is_pregnant", false)
	self.pregnant_time = mobkit.remember(self, "pregnant_time", 0.0)
	local baby_properties = {}
	baby_properties["baby_born"] = true
	if self.father_genes then
		baby_properties["gen1_father"] = self.father_genes["gen1"]
		baby_properties["gen2_father"] = self.father_genes["gen2"]
	else
		baby_properties["gen1_father"] = math.random(1, #self.skin_colors-1)
		baby_properties["gen2_father"] = math.random(1, #self.skin_colors-1)
	end
	if self and self.genes then
		baby_properties["gen1_mother"] = self.genes["gen1"]
		baby_properties["gen2_mother"] = self.genes["gen2"]
	else
		baby_properties["gen1_mother"] = math.random(1, #self.skin_colors-1)
		baby_properties["gen2_mother"] = math.random(1, #self.skin_colors-1)
	end
	local baby_type = "petz:"..self.type
	if self.type == "elephant" then -- female elephants have "elephant" as type
		if math.random(1, 2) == 1 then
			baby_type = "petz:elephant_female" --could be a female baby elephant
		end
	end
	pos.y = pos.y + 1.01 -- birth a litte up
	local baby = minetest.add_entity(pos, baby_type, minetest.serialize(baby_properties))
	mokapi.make_sound("object", baby, "petz_pop_sound", petz.settings.max_hear_distance)
	local baby_entity = baby:get_luaentity()
	baby_entity.is_baby = true
	mobkit.remember(baby_entity, "is_baby", baby_entity.is_baby)
	if not(self.owner== nil) and not(self.owner== "") then
		baby_entity.tamed = true
		mobkit.remember(baby_entity, "tamed", baby_entity.tamed)
		baby_entity.owner = self.owner
		mobkit.remember(baby_entity, "owner", baby_entity.owner)
	end
	return baby_entity
end

petz.pregnant_timer = function(self, dtime)
	self.pregnant_time = mobkit.remember(self, "pregnant_time", self.pregnant_time + dtime)
	if self.pregnant_time >= petz.settings.pregnancy_time then
		local baby_entity = petz.childbirth(self)
		if self.is_mountable == true then
			--Set the genetics accordingly the father and the mother
			local speedup = (self.horseshoes or 0) * petz.settings.horseshoe_speedup
			local random_number = math.random(-1, 1)
			local new_max_speed_forward = petz.round(((self.father_veloc_stats["max_speed_forward"] or 1) + (self.max_speed_forward-speedup))/2) + random_number
			if new_max_speed_forward <= 0 then
				new_max_speed_forward = 0
			elseif new_max_speed_forward > 10 then
				new_max_speed_forward = 10
			end
			random_number = math.random(-1, 1)
			local new_max_speed_reverse = petz.round(((self.father_veloc_stats["max_speed_reverse"] or 1) + (self.max_speed_reverse-speedup))/2) + random_number
			if new_max_speed_reverse <= 0 then
				new_max_speed_reverse = 0
			elseif new_max_speed_reverse > 10 then
				new_max_speed_reverse = 10
			end
			random_number = math.random(-1, 1)
			local new_accel  = petz.round(((self.father_veloc_stats["accel"] or 1) + (self.accel-speedup))/2) + random_number
			if new_accel <= 0 then
				new_accel = 0
			elseif new_accel > 10 then
				new_accel = 10
			end
			baby_entity.max_speed_forward = new_max_speed_forward
			mobkit.remember(baby_entity, "max_speed_forward", baby_entity.max_speed_forward)
			baby_entity.max_speed_reverse = new_max_speed_reverse
			mobkit.remember(baby_entity, "max_speed_reverse", baby_entity.max_speed_reverse)
			baby_entity.accel = new_accel
			mobkit.remember(baby_entity, "accel", baby_entity.accel)
		end
	end
end

petz.growth_timer = function(self, dtime)
	self.growth_time = mobkit.remember(self, "growth_time", (self.growth_time or 0) + dtime)
	if self.growth_time >= petz.settings.growth_time then
		self.is_baby = mobkit.remember(self, "is_baby", false)
		local pos = self.object:get_pos()
		pos.y = pos.y + 1.01 -- grows a litte up
		self.object:set_pos(pos)
		local vel = self.object:get_velocity()
		vel.y=vel.y + 4.0
		self.object:set_velocity(vel)
		petz.set_properties(self, {
			jump = false,
			is_baby = false,
			visual_size = self.visual_size,
			collisionbox = self.collisionbox
		})
		mokapi.make_sound("object", self.object, "petz_pop_sound", petz.settings.max_hear_distance)
	end
end

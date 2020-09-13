local modpath, S = ...

--
--'set_initial_properties' is call by 'on_activate' for each pet
--

petz.dyn_prop = {
	accel = {type= "int", default = 1},
	affinity = {type= "int", default = 100},
	beaver_oil_applied = {type= "boolean", default = false},
	behive = {type= "pos", default = false},
	brushed = {type= "boolean", default = false},
	child = {type= "boolean", default = false},
	colorized = {type= "string", default = nil},
	convert_count = {type= "int", default = 5},
	dreamcatcher = {type= "boolean", default = false},
	dead = {type= "boolean", default = false},
	driver = {type= "player", default = nil},
	eggs_count = {type= "int", default = 0},
	exchange_item_index = {type= "int", default = 1},
	exchange_item_amount = {type= "int", default = 1},
	father_genes = {type= "table", default = {}},
	father_veloc_stats = {type= "table", default = {}},
	fed = {type= "boolean", default = true},
	food_count = {type= "int", default = 0},
	food_count_wool = {type= "int", default = 0},
	for_sale = {type= "boolean", default = false},
	gallop = {type= "boolean", default = false},
	gallop_time = {type= "int", default = 0},
	gallop_exhausted = {type= "boolean", default = false},
	gallop_recover_time = {type= "int", default = petz.settings.gallop_recover_time},
	genes = {type= "table", default = {}},
	growth_time = {type= "int", default = 0},
	herding = {type= "boolean", default = false},
	horseshoes = {type= "int", default = 0},
	is_baby = {type= "boolean", default = false},
	is_male = {type= "boolean", default = false},
	is_pregnant = {type= "boolean", default = false},
	is_rut = {type= "boolean", default = false},
	lashed = {type= "boolean", default = false},
	lashing_count = {type= "int", default = 0},
	lifetime = {type= "int", default = nil},
	max_speed_forward = {type= "int", default = 1},
	max_speed_reverse = {type= "int", default = 1},
	milked = {type= "boolean", default = false},
	muted = {type= "boolean", default = false},
	owner = {type= "string", default = nil},
	pregnant_count = {type= "int", default = petz.settings.pregnant_count},
	pregnant_time = {type= "int", default = 0},
	saddle = {type= "boolean", default = false},
	saddlebag = {type= "boolean", default = false},
	saddlebag_inventory = {type= "table", default = nil},
	set_vars = {type= "boolean", default = false},
	shaved = {type= "boolean", default = false},
	show_tag = {type= "boolean", default = false},
	sleep_start_time = {type= "int", default = nil},
	sleep_end_time = {type= "int", default = nil},
	square_ball_attached = {type= "boolean", default = false},
	status = {type= "string", default = ""},
	tag = {type= "string", default = ""},
	tamed = {type= "boolean", default = false},
	--texture_no = {type= "int", default = 1}, --do not use!!! OR MISSING TEXTURE
	warn_attack = {type= "boolean", default = false},
	was_killed_by_player = {type= "boolean", default = false},
}

petz.cleanup_prop= function(self)
	self.warn_attack = false --reset the warn attack
	self.driver = nil --no driver
	self.was_killed_by_player = false --reset the warn attack
end

petz.genetics_random_texture = function(self, textures_count)
	local array = {}
	for row=1, textures_count do
		array[row] = {}
		for col=1, textures_count do
			array[row][col] = math.min(row, col)
		end
	end
	return array[math.random(1, textures_count)][math.random(1, textures_count)]
	-- Accessing the array to calculate the rates
	--local rates = {}
	--for row=1, textures_count do
		--for col=1, textures_count do
			--rates[array[row][col]] = (rates[array[row][col]] or 0) + 1
		--end
	--end

	--for row=1, textures_count do
		--minetest.chat_send_player("singleplayer", tostring(rates[row]))
	--end
end

petz.set_random_gender = function()
	if math.random(1, 2) == 1 then
		return true
	else
		return false
	end
end

petz.get_gen = function(self)
	local textures_count
	if self.mutation and (self.mutation > 0) then
		textures_count = #self.skin_colors - self.mutation
	else
		textures_count = #self.skin_colors
	end
	return math.random(1, textures_count)
end

petz.genetics_texture  = function(self, textures_count)
	for i = 1, textures_count do
		if self.genes["gen1"] == i or self.genes["gen2"] == i then
			return i
		end
	end
end

petz.load_vars = function(self)
	for key, value in pairs(petz.dyn_prop) do
		self[key] = mobkit.recall(self, key) or value["default"]
	end
	if not(self.sleep_start_time) or not(self.sleep_end_time) then
		petz.calculate_sleep_times(self)
	end
	petz.insert_tamed_by_owner(self)
	petz.cleanup_prop(self)	 --Reset some vars
end

function petz.set_initial_properties(self, staticdata, dtime_s)
	local static_data_table = minetest.deserialize(staticdata)
	local captured_mob = false
	local baby_born = false
	--minetest.chat_send_player("singleplayer", staticdata)
	if static_data_table and static_data_table["fields"] and static_data_table["fields"]["captured"] then
		captured_mob = true
	elseif static_data_table and static_data_table["baby_born"] and static_data_table["baby_born"] == true then
		baby_born = true
	end
	--
	--1. NEW MOBS
	--
	--dtime_s == 0 differenciates between loaded and new created mobs
	if dtime_s == 0 and captured_mob == false then	--set some vars
		--Mob Specific
		--Lamb
		if self.type == "lamb" then --set a random color
			self.food_count_wool = mobkit.remember(self, "food_count_wool", 0)
			self.shaved = mobkit.remember(self, "shaved", false)
		elseif self.type == "puppy" then
			self.square_ball_attached = mobkit.remember(self, "square_ball_attached", false)
		elseif self.is_mountable == true then
			if baby_born == false then
				self.max_speed_forward= mobkit.remember(self, "max_speed_forward", math.random(2, 4)) --set a random velocity for walk and run
				self.max_speed_reverse= 	mobkit.remember(self, "max_speed_reverse", math.random(1, 2))
				self.accel= mobkit.remember(self, "accel", math.random(2, 4))
			end
			self.driver = mobkit.remember(self, "driver", nil)
			--Saddlebag
			self.saddle = mobkit.remember(self, "saddle", false)
			if self.has_saddlebag == true then
				self.saddlebag_ref = nil
				self.saddlebag_inventory = mobkit.remember(self, "saddlebag_inventory", {})
			end
			self.gallop = mobkit.remember(self, "gallop", false)
			self.gallop_time = mobkit.remember(self, "gallop_time", 0)
			self.gallop_exhausted = mobkit.remember(self, "gallop_exhausted", false)
			self.gallop_recover_time = mobkit.remember(self, "gallop_recover_time", petz.settings.gallop_recover_time)
		end
		if self.type == "pony" then
			self.horseshoes = mobkit.remember(self, "horseshoes", 0)
		end
		if self.herd then
			self.herding = mobkit.remember(self, "herding", false)
		end
		--Mobs that can have babies
		if self.breed == true then
			if self.is_male == nil then
				self.is_male = petz.set_random_gender() --set a random gender
			end
			mobkit.remember(self, "is_male", self.is_male)
			self.is_rut = mobkit.remember(self, "is_rut", false)
			self.is_pregnant = mobkit.remember(self, "is_pregnant", false)
			self.pregnant_time = mobkit.remember(self, "pregnant_time", 0.0)
			self.father_genes = mobkit.remember(self, "father_genes", {})
			self.father_veloc_stats = mobkit.remember(self, "father_veloc_stats", {})
			self.pregnant_count = mobkit.remember(self, "pregnant_count", petz.settings.pregnant_count)
			self.is_baby = mobkit.remember(self, "is_baby", false)
			self.growth_time = mobkit.remember(self, "growth_time", 0.0)
			--Genetics
			self.genes = {}
			local genes_mutation = false
			if self.mutation and (self.mutation > 0) and math.random(1, 200) == 1 then
				genes_mutation = true
			end
			if genes_mutation == false then
				if baby_born == false then
					self.genes["gen1"] = petz.get_gen(self)
					self.genes["gen2"] = petz.get_gen(self)
					--minetest.chat_send_player("singleplayer", tostring(self.genes["gen1"]))
					--minetest.chat_send_player("singleplayer", tostring(self.genes["gen2"]))
				else
					if math.random(1, 2) == 1 then
						self.genes["gen1"] = static_data_table["gen1_father"]
					else
						self.genes["gen1"] = static_data_table["gen2_father"]
					end
					if math.random(1, 2) == 1 then
						self.genes["gen2"] = static_data_table["gen1_mother"]
					else
						self.genes["gen2"] = static_data_table["gen2_mother"]
					end
				end
				local textures_count
				if self.mutation and (self.mutation > 0) then
					textures_count = #self.skin_colors - self.mutation
				else
					textures_count = #self.skin_colors
				end
				self.texture_no = petz.genetics_texture(self, textures_count)
			else -- mutation
				local mutation_gen = math.random((#self.skin_colors-self.mutation+1), #self.skin_colors) --select the mutation in the last skins
				self.genes["gen1"] = mutation_gen
				self.genes["gen2"] = mutation_gen
				self.texture_no = mutation_gen
			end
			mobkit.remember(self, "genes", self.genes)
		end
		if self.lay_eggs == true then
			self.eggs_count = mobkit.remember(self, "eggs_count", 0)
		end
		--ALL the mobs
		--Get a texture
		if not(self.texture_no) then
			if self.skin_colors then
				local textures_count
				if self.mutation and (self.mutation > 0) then
					textures_count = #self.skin_colors - self.mutation
				else
					textures_count = #self.skin_colors
				end
				self.texture_no = petz.genetics_random_texture(self, textures_count)
			else
				self.texture_no = 1
			end
		end
		self.set_vars = mobkit.remember(self, "set_vars", true)
		self.tag = mobkit.remember(self, "tag", "")
		self.show_tag = mobkit.remember(self, "show_tag", false)
		self.tamed = mobkit.remember(self, "tamed", false)
		self.owner = mobkit.remember(self, "owner", nil)
		self.fed = mobkit.remember(self, "fed", true)
		self.for_sale = mobkit.remember(self, "for_sale", false)
		self.exchange_item_index = mobkit.remember(self, "exchange_item_index", 1)
		self.exchange_item_amount = mobkit.remember(self, "exchange_item_amount", 1)
		self.brushed = mobkit.remember(self, "brushed", false)
		self.food_count = mobkit.remember(self, "food_count", 0)
		self.lifetime = mobkit.remember(self, "lifetime", nil)
		self.was_killed_by_player = mobkit.remember(self, "was_killed_by_player", false)
		self.dreamcatcher = mobkit.remember(self, "dreamcatcher", false)
		self.status = mobkit.remember(self, "status", nil)
		self.warn_attack = mobkit.remember(self, "warn_attack", false)
		self.colorized = mobkit.remember(self, "colorized", nil)
		self.convert = mobkit.remember(self, "convert", nil)
		self.muted = mobkit.remember(self, "muted", false)
		if petz.settings[self.type.."_convert_count"] then
			self.convert_count = mobkit.remember(self, "convert_count", petz.settings[self.type.."_convert_count"])
		end
		if self.init_tamagochi_timer== true then
			petz.init_tamagochi_timer(self)
		end
		if self.has_affinity == true then
			self.affinity = mobkit.remember(self, "affinity", 100)
		end
		if self.is_wild == true then
			self.lashed = mobkit.remember(self, "lashed", false)
			self.lashing_count = mobkit.remember(self, "lashing_count", 0)
		end
		petz.calculate_sleep_times(self) --Sleep behaviour
	--
	--2. ALREADY EXISTING MOBS
	--
	elseif captured_mob == false then
		petz.load_vars(self) --Load memory variables
	--
	--3. CAPTURED MOBS
	--
	else
		for key, value in pairs(petz.dyn_prop) do
			local prop_value
			if value["type"] == "string" then
				prop_value = static_data_table["fields"][key]
			elseif value["type"] == "int" then
				prop_value = tonumber(static_data_table["fields"][key])
			elseif value["type"] == "boolean" then
				prop_value = minetest.is_yes(static_data_table["fields"][key])
			elseif value["type"] == "table" then
				prop_value = minetest.deserialize(static_data_table["fields"][key])
			elseif value["type"] == "player" then
				prop_value = nil
			end
			self[key] = mobkit.remember(self, key, prop_value) or value["default"]
		end
		self.texture_no = tonumber(static_data_table["fields"]["texture_no"])
	end

	--Custom textures
	if captured_mob == true or self.breed == true then
		local texture
		--Mob Specific
		--Lamb
		if self.type == "lamb" then
			local shaved_string = ""
			if self.shaved == true then
				shaved_string = "_shaved"
			end
			texture = "petz_lamb".. shaved_string .."_"..self.skin_colors[self.texture_no]..".png"
		elseif self.is_mountable == true then
			if self.saddle then
				texture = "petz_"..self.type.."_"..self.skin_colors[self.texture_no]..".png" .. "^petz_"..self.type.."_saddle.png"
			else
				texture = "petz_"..self.type.."_"..self.skin_colors[self.texture_no]..".png"
			end
			if self.saddlebag then
				texture = texture .. "^petz_"..self.type.."_saddlebag.png"
			end
		else
			texture = self.textures[self.texture_no]
		end
		mobkit.remember(self, "texture_no", self.texture_no)
		petz.set_properties(self, {textures = {texture}})
	end
	if self.type == "bee" and self.queen then --delay to create beehive
		minetest.after(math.random(120, 150), function(self)
			if mobkit.is_alive(self.object) then
				self.create_beehive = mobkit.remember(self, "create_beehive", true)
			end
		end, self)
	end
	if self.colorized then
		if not(self.shaved) then
			petz.colorize(self, self.colorized)
		end
	end
	if self.horseshoes and captured_mob == false then
		petz.horseshoes_speedup(self)
	end
	if self.breed == true then
		if baby_born == true then
			self.is_baby = mobkit.remember(self, "is_baby", true)
		end
		if self.is_baby == true then
			petz.set_properties(self, {
				visual_size = self.visual_size_baby,
				collisionbox = self.collisionbox_baby
			})
		end
	end
	--self.head_rotation = {x= -90, y= 90, z= 0}
	--self.whead_position = self.object:get_bone_position("parent")
	--self.head_position.y = self.head_position.y + 0.25
	--ALL the mobs
	if self.is_pet and self.tamed then
		petz.update_nametag(self)
	end
	if self.status then
		if self.status == "stand" then
			petz.standhere(self)
		elseif self.status == "guard" then
			petz.guard(self)
		elseif self.status == "sleep" then
			self.status = nil --reset
		else
			self.status = nil
		end
	end
end

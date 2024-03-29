-- support for i18n
local S = armor_i18n.gettext

local skin_previews = {}
local use_player_monoids = minetest.global_exists("player_monoids")
local use_armor_monoid = minetest.global_exists("armor_monoid")
local armor_def = setmetatable({}, {
	__index = function()
		return setmetatable({
			groups = setmetatable({}, {
				__index = function()
					return 0
				end})
			}, {
			__index = function()
				return 0
			end
		})
	end,
})
local armor_textures = setmetatable({}, {
	__index = function()
		return setmetatable({}, {
			__index = function()
				return "blank.png"
			end
		})
	end
})

armor = {
	timer = 0,
	elements = {"head", "torso", "legs", "feet"},
	physics = {"jump", "speed", "gravity"},
	attributes = {"heal", "fire", "water"},
	formspec = "image[2.5,0;2,4;armor_preview]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		default.get_hotbar_bg(0, 4.7)..
		"list[current_player;main;0,4.7;8,1;]"..
		"list[current_player;main;0,5.85;8,3;8]",
	def = armor_def,
	textures = armor_textures,
	default_skin = "character",
	materials = {
		wood = "group:wood",
		cactus = "default:cactus",
		steel = "default:steel_ingot",
		bronze = "default:bronze_ingot",
		diamond = "default:diamond",
		gold = "default:gold_ingot",
		mithril = "moreores:mithril_ingot",
		crystal = "ethereal:crystal_ingot",
	},
	fire_nodes = {
		{"default:lava_source",     5, 8},
		{"default:lava_flowing",    5, 8},
		{"fire:basic_flame",        3, 4},
		{"fire:permanent_flame",    3, 4},
		{"ethereal:crystal_spike",  2, 1},
		{"ethereal:fire_flower",    2, 1},
		--{"default:torch",           1, 1},
		--{"default:torch_ceiling",   1, 1},
		--{"default:torch_wall",      1, 1},
	},
	registered_groups = {["fleshy"]=100},
	registered_callbacks = {
		on_update = {},
		on_equip = {},
		on_unequip = {},
		on_damage = {},
		on_destroy = {},
	},
	migrate_old_inventory = true,
	version = "0.4.11",
}

armor.config = {
	init_delay = 2,
	init_times = 10,
	bones_delay = 1,
	update_time = 1,
	drop = minetest.get_modpath("bones") ~= nil,
	destroy = false,
	level_multiplier = 1,
	heal_multiplier = 1,
	material_wood = true,
	material_cactus = true,
	material_steel = true,
	material_bronze = true,
	material_diamond = true,
	material_gold = true,
	material_mithril = true,
	material_crystal = true,
	water_protect = true,
	fire_protect = minetest.get_modpath("ethereal") ~= nil or minetest.get_modpath("hazmat_suit") ~= nil,
	punch_damage = true,
}

-- Armor Registration

armor.register_armor = function(self, name, def)
	minetest.register_tool(name, def)
end

armor.register_armor_group = function(self, group, base)
	base = base or 100
	self.registered_groups[group] = base
	if use_armor_monoid then
		armor_monoid.register_armor_group(group, base)
	end
end

-- Armor callbacks

armor.register_on_update = function(self, func)
	if type(func) == "function" then
		table.insert(self.registered_callbacks.on_update, func)
	end
end

armor.register_on_equip = function(self, func)
	if type(func) == "function" then
		table.insert(self.registered_callbacks.on_equip, func)
	end
end

armor.register_on_unequip = function(self, func)
	if type(func) == "function" then
		table.insert(self.registered_callbacks.on_unequip, func)
	end
end

armor.register_on_damage = function(self, func)
	if type(func) == "function" then
		table.insert(self.registered_callbacks.on_damage, func)
	end
end

armor.register_on_destroy = function(self, func)
	if type(func) == "function" then
		table.insert(self.registered_callbacks.on_destroy, func)
	end
end

armor.run_callbacks = function(self, callback, player, index, stack)
	if stack then
		local def = stack:get_definition() or {}
		if type(def[callback]) == "function" then
			def[callback](player, index, stack)
		end
	end
	local callbacks = self.registered_callbacks[callback]
	if callbacks then
		for _, func in pairs(callbacks) do
			func(player, index, stack)
		end
	end
end

armor.update_player_visuals = function(self, player)
	if not player then
		return
	end
	local name = player:get_player_name()
	if self.textures[name] then
		default.player_set_textures(player, {
			self.textures[name].skin,
			self.textures[name].armor,
			self.textures[name].wielditem,
		})
	end
	self:run_callbacks("on_update", player)
end

armor.set_player_armor = function(self, player)
	local name, armor_inv = self:get_valid_player(player, "[set_player_armor]")
	if not name then
		return
	end
	local state = 0
	local count = 0
	local material = {count=1}
	local preview = armor:get_preview(name)
	local texture = "3d_armor_trans.png"
	local skintexture = armor:get_player_skin(name)
	local textures = {}
	local physics = {}
	local attributes = {}
	local levels = {}
	local groups = {}
	local change = {}
	local clothes = ""
	local hat = ""
	local abovehair = false
	for _, phys in pairs(self.physics) do
		physics[phys] = 1
	end
	for _, attr in pairs(self.attributes) do
		attributes[attr] = 0
	end
	for group, _ in pairs(self.registered_groups) do
		change[group] = 1
		levels[group] = 0
	end
	local list = armor_inv:get_list("armor")
	if type(list) ~= "table" then
		return
	end
	for i, stack in pairs(list) do
		if stack:get_count() == 1 then
			local def = stack:get_definition()
			for _, element in pairs(self.elements) do
				if def.groups["armor_"..element] then
					if def.armor_groups then
						for group, level in pairs(def.armor_groups) do
							if levels[group] then
								levels[group] = levels[group] + level
							end
						end
					else
						local level = def.groups["armor_"..element]
						levels["fleshy"] = levels["fleshy"] + level
					end
					break
				end
				-- DEPRECATED, use armor_groups instead
				if def.groups["armor_radiation"] and levels["radiation"] then
					levels["radiation"] = def.groups["armor_radiation"]
				end
			end
			local item = stack:get_name()
			local tex = def.texture or item:gsub("%:", "_")
			tex = tex:gsub(".png$", "")
			local texpng = ""
			if not string.find(tex, ".png") then
				texpng = ".png"
			end
			local prev = def.preview or tex.."_preview"
			prev = prev:gsub(".png$", "")
			if def.groups["clothing"] then
				if def.groups["armor_head"] then
					hat = hat.."^"..tex..texpng
				else
					clothes = clothes.."^"..tex..texpng
				end
			else
				texture = texture.."^"..tex..texpng
			end
			preview = preview.."^"..prev
			if not string.find(prev, ".png") then
				preview = preview..".png"
			end
			state = state + stack:get_wear()
			count = count + 1
			for _, phys in pairs(self.physics) do
				local value = def.groups["physics_"..phys] or 0
				physics[phys] = physics[phys] + value
			end
			for _, attr in pairs(self.attributes) do
				local value = def.groups["armor_"..attr] or 0
				attributes[attr] = attributes[attr] + value
			end
			local mat = string.match(item, "%:.+_(.+)$")
			if material.name then
				if material.name == mat then
					material.count = material.count + 1
				end
			else
				material.name = mat
			end
		end
	end
	if self.skin_mod == "charactercreation"  then
		local skindata = charactercreation_getskin(name)
		local face = "(face"..skindata.facetype..".png^[multiply:#"..skindata.facecolor..")"
		local hair = "(hair"..skindata.hairtype..".png^[multiply:#"..skindata.haircolor..")"
		skintexture = skintexture..clothes.."^"..face.."^"..hair..hat
	else
		skintexture = skintexture..clothes..hat
	end
	for group, level in pairs(levels) do
		if level > 0 then
			level = level * armor.config.level_multiplier
			if material.name and material.count == #self.elements then
				level = level * 1.1
			end
		end
		local base = self.registered_groups[group]
		self.def[name].groups[group] = level
		if level > base then
			level = base
		end
		groups[group] = base - level
		change[group] = groups[group] / base
	end
	for _, attr in pairs(self.attributes) do
		self.def[name][attr] = attributes[attr]
	end
	for _, phys in pairs(self.physics) do
		self.def[name][phys] = physics[phys]
	end
	if use_armor_monoid then
		armor_monoid.monoid:add_change(player, change, "3d_armor:armor")
	else
		player:set_armor_groups(groups)
	end
	if use_player_monoids then
		player_monoids.speed:add_change(player, physics.speed,
			"3d_armor:physics")
		player_monoids.jump:add_change(player, physics.jump,
			"3d_armor:physics")
		player_monoids.gravity:add_change(player, physics.gravity,
			"3d_armor:physics")
	else
		player:set_physics_override(physics)
	end
	self.textures[name].armor = texture
	self.textures[name].skin = skintexture
	self.textures[name].preview = preview
	self.def[name].level = self.def[name].groups.fleshy or 0
	self.def[name].state = state
	self.def[name].count = count
	self:update_player_visuals(player)
end

armor.punch = function(self, player, hitter, time_from_last_punch, tool_capabilities)
	local name, armor_inv = self:get_valid_player(player, "[punch]")
	if not name then
		return
	end
	local state = 0
	local count = 0
	local recip = true
	local default_groups = {cracky=3, snappy=3, choppy=3, crumbly=3, level=1}
	local list = armor_inv:get_list("armor")
	for i, stack in pairs(list) do
		if stack:get_count() == 1 then
			local name = stack:get_name()
			local use = minetest.get_item_group(name, "armor_use") or 0
			local damage = use > 0
			local def = stack:get_definition() or {}
			if type(def.on_punched) == "function" then
				damage = def.on_punched(player, hitter, time_from_last_punch,
					tool_capabilities) ~= false and damage == true
			end
			if damage == true and tool_capabilities then
				local damage_groups = def.damage_groups or default_groups
				local level = damage_groups.level or 0
				local groupcaps = tool_capabilities.groupcaps or {}
				local uses = 0
				damage = false
				for group, caps in pairs(groupcaps) do
					local maxlevel = caps.maxlevel or 0
					local diff = maxlevel - level
					if diff == 0 then
						diff = 1
					end
					if diff > 0 and caps.times then
						local group_level = damage_groups[group]
						if group_level then
							local time = caps.times[group_level]
							if time then
								local dt = time_from_last_punch or 0
								if dt > time / diff then
									if caps.uses then
										uses = caps.uses * math.pow(3, diff)
									end
									damage = true
									break
								end
							end
						end
					end
				end
				if damage == true and recip == true and hitter and
						def.reciprocate_damage == true and uses > 0 then
					local item = hitter:get_wielded_item()
					if item and item:get_name() ~= "" then
						item:add_wear(65535 / uses)
						hitter:set_wielded_item(item)
					end
					-- reciprocate tool damage only once
					recip = false
				end
			end
			if damage == true and hitter == "fire" then
				damage = minetest.get_item_group(name, "flammable") > 0
			end
			if damage == true then
				self:damage(player, i, stack, use)
			end
			state = state + stack:get_wear()
			count = count + 1
		end
	end
	self.def[name].state = state
	self.def[name].count = count
end

armor.damage = function(self, player, index, stack, use)
	local old_stack = ItemStack(stack)
	stack:add_wear(use)
	self:run_callbacks("on_damage", player, index, stack)
	self:set_inventory_stack(player, index, stack)
	if stack:get_count() == 0 then
		self:run_callbacks("on_unequip", player, index, old_stack)
		self:run_callbacks("on_destroy", player, index, old_stack)
		self:set_player_armor(player)
	end
end

armor.get_player_skin = function(self, name)
	if (self.skin_mod == "skins" or self.skin_mod == "simple_skins") and skins.skins[name] then
		return skins.skins[name]..".png"
	elseif self.skin_mod == "u_skins" and u_skins.u_skins[name] then
		return u_skins.u_skins[name]..".png"
	elseif self.skin_mod == "wardrobe" and wardrobe.playerSkins and wardrobe.playerSkins[name] then
		return wardrobe.playerSkins[name]
	elseif self.skin_mod == "charactercreation" then
		local skindata = charactercreation_getskin(name)
		local skin
		if spood_get_effect then
			local speed, sideeffect = spood_get_effect(name)
			local opacity = math.min(sideeffect*25, 255)
			skin = "((skin"..skindata.skintype..".png^(spoodcharacteroverlay.png^[opacity:"..opacity.."))^[multiply:#"..skindata.skincolor..")"
		else
			skin = "(skin"..skindata.skintype..".png^[multiply:#"..skindata.skincolor..")"
		end
		local eyes = "(eye"..skindata.eyetype..".png)^(eye"..skindata.eyetype.."color.png^[multiply:#"..skindata.eyecolor..")"
		--local face = "(face"..skindata.facetype..".png^[multiply:#"..skindata.facecolor..")"
		--local hair = "(hair"..skindata.hairtype..".png^[multiply:#"..skindata.haircolor..")"
		return skin.."^"..eyes--.."^"..face.."^"..hair
	end
	return armor.default_skin..".png"
end

armor.add_preview = function(self, preview)
	skin_previews[preview] = true
end

armor.get_preview = function(self, name)
	local preview = string.gsub(armor:get_player_skin(name), ".png", "_preview.png")
	if skin_previews[preview] then
		return preview
	end
	return "character_preview.png"
end

armor.get_armor_formspec = function(self, name, listring)
	if armor.def[name].init_time == 0 then
		return "label[0,0;Armor not initialized!]"
	end
	local formspec = armor.formspec..
		"list[detached:"..name.."_armor;armor;0,0.5;2,3;]"
	if listring == true then
		formspec = formspec.."listring[current_player;main]"..
			"listring[detached:"..name.."_armor;armor]"
	end
	formspec = formspec:gsub("armor_preview", armor.textures[name].preview)
	formspec = formspec:gsub("armor_level", armor.def[name].level)
	for _, attr in pairs(self.attributes) do
		formspec = formspec:gsub("armor_attr_"..attr, armor.def[name][attr])
	end
	for group, _ in pairs(self.registered_groups) do
		formspec = formspec:gsub("armor_group_"..group,
			armor.def[name].groups[group])
	end
	return formspec
end

armor.get_element = function(self, item_name)
	for _, element in pairs(armor.elements) do
		if minetest.get_item_group(item_name, "armor_"..element) > 0 then
			return element..tostring(minetest.get_item_group(item_name, "armor_"..element))
		end
	end
end

armor.serialize_inventory_list = function(self, list)
	local list_table = {}
	for _, stack in ipairs(list) do
		table.insert(list_table, stack:to_string())
	end
	return minetest.serialize(list_table)
end

armor.deserialize_inventory_list = function(self, list_string)
	local list_table = minetest.deserialize(list_string)
	local list = {}
	for _, stack in ipairs(list_table or {}) do
		table.insert(list, ItemStack(stack))
	end
	return list
end

armor.load_armor_inventory = function(self, player)
	local name, inv = self:get_valid_player(player, "[load_armor_inventory]")
	if not name then
		return
	end
	local armor_list_string = player:get_attribute("3d_armor_inventory")
	if armor_list_string then
		inv:set_list("armor",
			self:deserialize_inventory_list(armor_list_string))
		return true
	end
end

armor.save_armor_inventory = function(self, player)
	local name, inv = self:get_valid_player(player, "[save_armor_inventory]")
	if not name then
		return
	end
	local elements = {}
	for i = 1, 6 do
		local stack = inv:get_stack("armor", i)
		local element = self:get_element(stack:get_name())
		if element and not elements[element] then
			elements[element] = true;
		else
			inv:remove_item("armor", stack)
			local player_inv = player:get_inventory()
			if player_inv and player_inv:room_for_item("main", stack) then
				player_inv:add_item("main", stack)
			else
				minetest.item_drop(stack, player, player:get_pos())
			end
		end
	end
	player:set_attribute("3d_armor_inventory",
		self:serialize_inventory_list(inv:get_list("armor")))
end

armor.update_inventory = function(self, player)
	-- DEPRECATED: Legacy inventory support
end

armor.set_inventory_stack = function(self, player, i, stack)
	local name, inv = self:get_valid_player(player, "[set_inventory_stack]")
	if not name then
		return
	end
	inv:set_stack("armor", i, stack)
	self:save_armor_inventory(player)
end

armor.get_valid_player = function(self, player, msg)
	msg = msg or ""
	if not player then
		minetest.log("warning", S("3d_armor: Player reference is nil @1", msg))
		return
	end
	local name = player:get_player_name()
	if not name then
		minetest.log("warning", S("3d_armor: Player name is nil @1", msg))
		return
	end
	local inv = minetest.get_inventory({type="detached", name=name.."_armor"})
	if not inv then
		minetest.log("warning", S("3d_armor: Detached armor inventory is nil @1", msg))
		return
	end
	return name, inv
end

armor.drop_armor = function(pos, stack)
	local node = minetest.get_node_or_nil(pos)
	if node then
		local obj = minetest.add_item(pos, stack)
		if obj then
			obj:setvelocity({x=math.random(-1, 1), y=5, z=math.random(-1, 1)})
		end
	end
end

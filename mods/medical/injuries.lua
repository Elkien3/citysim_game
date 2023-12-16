medical.injuries = {}

function medical.effect_handle(player)
	local wag = 0
	local speed = 1
	local jump = nil
	local name = player:get_player_name()
	if medical.data[name].injuries then
		--handle loss of vital signs due to injuries
		for index, injury in pairs (medical.data[name].injuries) do
			if not injury.severity then injury.severity = 1 end
			local injurydef = medical.injuries[injury.name]
			local treated = injury.severity == 0
			if injurydef.effects then
				local effects = table.copy(injurydef.effects)
				if effects.Limb_Specific then
					effects = effects[index]
				end
				if effects then
					if effects.gunwag then
						if treated then
							wag = wag + (effects.gunwag/2)
						else
							wag = wag + effects.gunwag
						end
					end
					if effects.speed then
						if treated then
							speed = speed*((effects.speed+1)/2)
						else
							speed = speed*effects.speed
						end
					end
				end
			else
				wag = wag + .5
			end
		end
	end
	--if medical.data[name].unconscious then speed = 0.00001 jump = 0.00001 end
	if wag == 0 then wag = nil end
	if speed == 1 then speed = nil end
	playercontrol.set_effect(name, "gunwag", wag, "medical", true)
	playercontrol.set_effect(name, "speed", speed, "medical", true)
	--playercontrol.set_effect(name, "jump", jump, "medical", true)
end

minetest.register_on_joinplayer(medical.effect_handle)
minetest.register_on_joinplayer(medical.init_injuries)

function medical.injury_handle(player, clicker, rightclick, tool, hitlimb, finish)
	local name = player:get_player_name()
	local cname = clicker:get_player_name()
	local wielditem = clicker:get_wielded_item()
	if not medical.data[name].injuries then return false end
	local injury = medical.data[name].injuries[hitlimb]
	local ent = medical.entities[name]
	if ent then
		ent = ent[hitlimb]
	end
	local injurydef = medical.injuries[injury.name]
	if not injury.step then injury.step = 1 end
	local stepdef = injurydef.steps[injury.step]
	if not stepdef then return false end
	if (tool ~= stepdef.tool and minetest.get_item_group(tool, stepdef.tool) == 0) or rightclick ~= stepdef.rightclick then
		return false
	end
	if (wielditem:get_name() ~= stepdef.tool and minetest.get_item_group(wielditem:get_name(), stepdef.tool) == 0) then
		return false
	end
	if finish then
		if stepdef.take_item and not minetest.is_creative_enabled(cname) then
			wielditem:take_item()
			clicker:set_wielded_item(wielditem)
		end
		if stepdef.finishsound then
			minetest.sound_play(stepdef.finishsound, {
				object = ent,
				max_hear_distance = 16,
			}, true)
		end
		if ent and (stepdef.mesh or stepdef.textures) then
			local props = ent:get_properties()
			ent:set_properties({mesh = (stepdef.mesh or props.mesh), textures = (stepdef.textures or props.textures)})
		end
		if stepdef.severity then
			medical.data[name].injuries[hitlimb].severity = (medical.data[name].injuries[hitlimb].severity or 1) * stepdef.severity
		end
		injury.step = injury.step + 1
		if not injurydef.steps[injury.step] then
			if not injurydef.healtime then
				if ent then
					ent:remove()
				end
				medical.data[name].injuries[hitlimb] = nil
			else
				medical.data[name].injuries[hitlimb].severity = 0
			end
			medical.effect_handle(clicker)
		end
		medical.save()
		return true
	end
	--if medical.timers[name] ~= nil then return end
	local stopfunc
	local stoparg
	if stepdef.hud then
		local huddef = {
			hud_elem_type = "image",
			position  = {x = 0.5, y = 0.55},
			offset    = {x = 0, y = 0},
			scale     = { x = 10, y = 10},
			alignment = { x = 0, y = 0 },
		}
		if type(stepdef.hud) == "string" then
			huddef.text = stepdef.hud
			medical.hud[cname] = clicker:hud_add(huddef)
			clicker:hud_set_flags({wielditem=false})
			stoparg = cname
			stopfunc = function(stoparg)
				local clicker = minetest.get_player_by_name(stoparg)
				if medical.hud[stoparg] then
					clicker:hud_remove(medical.hud[stoparg])
					medical.hud[stoparg] = nil
					clicker:hud_set_flags({wielditem=true})
				end
			end
		elseif type(stepdef.hud) == "table" then
			for i, val in pairs(huddef) do
				if not stepdef.hud[i] then
					stepdef.hud[i] = val
				end
			end
			if stepdef.hud.frame_amount then
				medical.hud[cname] = medical.add_anim_hud(clicker, stepdef.hud)
				clicker:hud_set_flags({wielditem=false})
				stoparg = cname
				stopfunc = function(stoparg)
					local clicker = minetest.get_player_by_name(stoparg)
					if medical.hud[stoparg] then
						medical.remove_anim_hud(clicker, medical.hud[cname])
						medical.hud[stoparg] = nil
						clicker:hud_set_flags({wielditem=true})
					end
				end
			else
				medical.hud[cname] = clicker:hud_add(huddef)
				clicker:hud_set_flags({wielditem=false})
				stoparg = cname
				stopfunc = function(stoparg)
					local clicker = minetest.get_player_by_name(stoparg)
					if medical.hud[stoparg] then
						clicker:hud_remove(medical.hud[stoparg])
						medical.hud[stoparg] = nil
						clicker:hud_set_flags({wielditem=true})
					end
				end
			end
		end
	end
	if stepdef.startsound then
		minetest.sound_play(stepdef.startsound, {
			object = ent,
			max_hear_distance = 16,
		}, true)
	end
	local key = "LMB"
	if rightclick then
		key = "RMB"
	end
	if stepdef.time then
		medical.start_timer(cname, stepdef.time, false, {player, clicker, rightclick, tool, hitlimb, true}, medical.injury_handle, stoparg, stopfunc, key, cname, name)
	else
		medical.start_timer(cname, 0, false, {player, clicker, rightclick, tool, hitlimb, true}, medical.injury_handle, stoparg, stopfunc, key, cname, name)
	end
	return true
end

minetest.register_entity("medical:injury", {
    hp_max = 1,
    physical = false,
	pointable = false,
    weight = 5,
	use_texture_alpha = true,
    collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
    visual = "mesh",
	mesh = "flat.b3d",
    textures = {"invis.png"}, -- number of required textures depends on visual -- number of required textures depends on visual
    is_visible = true,
    makes_footstep_sound = false,
	on_activate = function(self, staticdata, dtime_s)
		if not staticdata or staticdata == "" then self.object:remove() return end
		local data = minetest.deserialize(staticdata)
		self.owner = data.owner
		self.bone = data.bone
		self.injury = data.injury
		if not self.injury then self.object:remove() return end
		if not self.injury.step then self.injury.step = 1 end
		local injurydef = medical.injuries[self.injury.name]
		local mesh
		local textures
		for i = (self.injury.step-1), 1, -1 do
			local tempstepdef = injurydef.steps[i]
			if not mesh and tempstepdef.mesh then
				mesh = tempstepdef.mesh
			end
			if not textures and tempstepdef.textures then
				textures = table.copy(tempstepdef.textures)
			end
		end
		if not mesh then mesh = (injurydef.mesh or props.mesh) end
		if not textures then textures = (injurydef.textures or props.textures) end
		self.object:set_armor_groups({fleshy = 0})
		local props = self.object:get_properties()
		self.object:set_properties({mesh = mesh, textures = textures})
	end,
	--[[on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if not puncher:is_player() then return end
		local name = puncher:get_player_name()
		local wielditem = puncher:get_wielded_item()
		local wieldname = wielditem:get_name()
		medical.injury_handle(self.owner, puncher, false, wieldname, self.bone)
	end,
    on_rightclick = function(self, clicker)
		if not clicker:is_player() then return end
		local name = clicker:get_player_name()
		local wielditem = clicker:get_wielded_item()
		local wieldname = wielditem:get_name()
		medical.injury_handle(self.owner, clicker, true, wieldname, self.bone)
	end,--]]
})

minetest.register_craftitem("medical:bandage", {
	description = "Bandage",
	inventory_image = "medical_bandage.png",
	tool_capabilities = {
		full_punch_interval = 1,
		damage_groups = {fleshy=0},
	},
	groups = {medical_dressing = 2}
})
minetest.register_craft({
	output = "medical:bandage 6",
	recipe = {
		{"farming:cotton","farming:cotton","farming:cotton"},
	},
})

minetest.register_craftitem("medical:bandage_cold", {
	description = "Cold Compress",
	inventory_image = "medical_bandage.png^medical_coldicon.png",
	tool_capabilities = {
		full_punch_interval = 1,
		damage_groups = {fleshy=0},
	},
	--groups = {medical_dressing = 2}
})
minetest.register_craft({
	output = "medical:bandage_cold 8",
	recipe = {
		{"medical:bandage","medical:bandage","medical:bandage"},
		{"medical:bandage","default:ice","medical:bandage"},
		{"medical:bandage","medical:bandage","medical:bandage"},
	},
})

minetest.register_craftitem("medical:bandage_moist", {
	description = "Moistened Bandage",
	inventory_image = "medical_bandage.png^medical_moisticon.png",
	tool_capabilities = {
		full_punch_interval = 1,
		damage_groups = {fleshy=0},
	},
	--groups = {medical_dressing = 2}
})
minetest.register_craft({
	output = "medical:bandage_moist 8",
	replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}},
	recipe = {
		{"medical:bandage","medical:bandage","medical:bandage"},
		{"medical:bandage","bucket:bucket_water","medical:bandage"},
		{"medical:bandage","medical:bandage","medical:bandage"},
	},
})

minetest.register_craftitem("medical:tourniquet", {
	description = "Tourniquet",
	inventory_image = "medical_tourniquet.png",
	tool_capabilities = {
		full_punch_interval = 1,
		damage_groups = {fleshy=0},
	},
	--groups = {medical_dressing = 2}
})
minetest.register_craft({
	output = "medical:tourniquet",
	recipe = {
		{"default:stick"},
		{"medical:bandage"},
	},
})

local bandagehud = {text = "bandageanimated.png", frame_amount = 8, frame_duration = .25, keep_at_end = true}
local splinthud = {text = "splintanimated.png", frame_amount = 2, frame_duration = .5, keep_at_end = true}
local tourniquettightenhud = {text = "tourniquettightenanimated.png", frame_amount = 4, frame_duration = .25, loop = true}
local tourniquetapplyhud = {text = "tourniquetapplyanimated.png", frame_amount = 4, frame_duration = .25, loop = false}

medical.injuries["bruise"] = {
	mesh = "flat.b3d",
	textures = {"medical_bruise.png"},
	steps = {
		{tool = "medical:bandage_cold", take_item = true, rightclick = false, time = 2, hud = bandagehud, mesh = "bandagetest.b3d", textures = {"wool_white.png", "invis.png"}, startsound = "bandagestart", finishsound = "bandagefinish"},
	},
	hploss = 1,
	healtime = 600,
	medical_step = nil,
}

medical.injuries["abrasion"] = {
	mesh = "flat.b3d",
	textures = {"medical_abrasion.png"},
	steps = {
		{tool = "medical:bandage", take_item = true, rightclick = false, time = 2, hud = bandagehud, mesh = "bandagetest.b3d", textures = {"wool_white.png", "invis.png"}, startsound = "bandagestart", finishsound = "bandagefinish"},
	},
	hploss = 2.5,
	healtime = 600,
	medical_step = nil,
}

medical.injuries["burn"] = {
	mesh = "flat.b3d",
	textures = {"medical_burn.png"},
	steps = {
		{tool = "medical:bandage_moist", take_item = true, rightclick = false, time = 2, hud = bandagehud, mesh = "bandagetest.b3d", textures = {"wool_white.png", "invis.png"}, startsound = "bandagestart", finishsound = "bandagefinish"},
	},
	hploss = 3,
	healtime = 720,
	medical_step = nil,
}

medical.injuries["wound"] = {
	mesh = "flat.b3d",
	textures = {"medical_wound.png"},
	steps = {
		{tool = "medical:bandage", take_item = true, rightclick = false, time = 2, hud = bandagehud, mesh = "bandagetest.b3d", textures = {"wool_white.png", "medical_wound.png"}, startsound = "bandagestart", finishsound = "bandagefinish"},
		{tool = "", rightclick = true, time = 5, hud = "applypressure.png", textures = {"wool_white.png", "invis.png"}}
	},
	hploss = 5,
	healtime = 1200,
	medical_step = nil,
}

medical.injuries["wound_arterial"] = {
	mesh = "flat.b3d",
	possible_limbs = {Arm_Right = true, Arm_Left = true, Leg_Right = true, Leg_Left = true},
	textures = {"medical_arterial_wound.png"},
	steps = {
		{tool = "medical:tourniquet", take_item = true, rightclick = false, time = 1, hud = tourniquetapplyhud, mesh = "arterial_wound.b3d", textures = {"medical_arterial_wound.png", "wool_black.png", "invis.png"}},
		{tool = "", rightclick = true, time = 2, hud = tourniquettightenhud, severity = .5},
		{tool = "medical:bandage", take_item = true, rightclick = false, time = 2, hud = bandagehud, textures = {"medical_arterial_wound.png", "wool_black.png", "wool_white.png"}, startsound = "bandagestart", finishsound = "bandagefinish"},
		{tool = "", rightclick = true, time = 5, hud = "applypressure.png", textures = {"invis.png", "wool_black.png", "wool_white.png"}}
	},
	hploss = 6,
	healtime = 1200,
	medical_step = nil,
}
--for animated huds do: hud = {text = "default_lava_flowing_animated.png", frame_amount = 16, frame_duration = .25, keep_at_end = true}
medical.injuries["fracture"] = {
	mesh = "bonetest.b3d",
	possible_limbs = {Arm_Right = true, Arm_Left = true, Leg_Right = true, Leg_Left = true},
	textures = {"default_clay.png", "invis.png", "invis.png"},
	steps = {
		{tool = "default:stick", take_item = true, rightclick = false, time = 1, hud = splinthud, textures = {"default_clay.png", "default_stick.png", "invis.png"}},
		{tool = "medical:bandage", take_item = true, rightclick = false, time = 2, hud = bandagehud, textures = {"invis.png", "default_stick.png", "wool_white.png"}, startsound = "bandagestart", finishsound = "bandagefinish"}
	},
	hploss = 6,
	healtime = 1200,
	medical_step = nil,
	effects = {Limb_Specific = true, Arm_Left = {gunwag = 4}, Arm_Right = {gunwag = 4}, Leg_Left = {speed = .5}, Leg_Left = {speed = .5}}
}

local function get_injury_order(injury)
	local injuryorder = {"bruise", "abrasion", "burn", "wound"}
	for i, name in pairs(injuryorder) do
		if injury == name then
			return i
		end
	end
	return 5
end

local function get_injury(name, limb)
	if not medical.data[name] or not medical.data[name].injuries or not medical.data[name].injuries[limb] then return end
	return medical.data[name].injuries[limb].name, medical.data[name].injuries[limb].severity or 1
end

local function get_limbs_with_injury(name, searchinjury)
	local limbtbl = {"Head", "Body", "Back", "Arm_Right", "Arm_Left", "Leg_Right", "Leg_Left"}
	local newlimbtbl
	for i, limbname in pairs(limbtbl) do
		local injury = get_injury(name, limbname)
		if injury and injury == searchinjury then
			if not newlimbtbl then newlimbtbl = {} end
			table.insert(newlimbtbl, limbname)
		end
	end
	return newlimbtbl
end

local function get_random_limb(limbtbl, func)
	if not limbtbl then limbtbl = {"Head", "Body", "Back", "Arm_Right", "Arm_Left", "Leg_Right", "Leg_Left"} end
	if not func then--no function, just wants a random limb
		return limbtbl[math.random(#limbtbl)]
	else--has function to pick and choose the limbs
		for i = #limbtbl, 2, -1 do--shuffle
			local j = math.random(i)
			limbtbl[i], limbtbl[j] = limbtbl[j], limbtbl[i]
		end
		for i, limbname in pairs(limbtbl) do
			if func(limbname) == true then return limbname end
		end
	end
end

local function is_replaceable(name, injuryname, limbname)
	local tempinjury, tempseverity = get_injury(name, limbname)
	if tempinjury then
		if get_injury_order(tempinjury) > get_injury_order(injuryname) or (tempinjury == injuryname and tempseverity == 1) then
			return false
		end
	end
	return true
end

local function is_upgradable(name, injuryname, limbname)
	local tempinjury, tempseverity = get_injury(name, limbname)
	if tempinjury then
		if get_injury_order(tempinjury) ~= 5 and tempseverity == 1 then
			local injuryupgrades = {["bruise"] = "abrasion", ["abrasion"] = "wound", ["burn"] = "wound", ["wound"] = "wound_arterial"}
			if injuryupgrades[tempinjury] == "wound_arterial" and not medical.injuries["wound_arterial"].possible_limbs[limbname] then
				return false
			end
			return true, injuryupgrades[tempinjury]
		end
	end
	return false
end

function medical.add_injury(player, injurytype, hp, limb)--injurytypes are sharp, blunt, burn. if the limb is "full" of injuries already it will try to put it in a random place
	local name = player:get_player_name()
	if not name then return end
	local existinginjury, severity = get_injury(name, limb)
	local severitymulti = .2
	if injurytype == "sharp" then
		if -hp+math.random(5) > 12 then--if high damage do arterial bleed or fracture
			if math.random(2) == 1 then
				injurytype = "wound_arterial"
			else
				injurytype = "fracture"
			end
			if not limb or (existinginjury and not is_replaceable(name, injurytype, limb))
			or not medical.injuries[injurytype].possible_limbs[limb] then
				limb = get_random_limb( {"Arm_Right", "Arm_Left", "Leg_Right", "Leg_Left"}, function(limbname)
					return is_replaceable(name, injurytype, limbname)
				end)
			end
			if not limb then
				injurytype = "wound"
				limb = get_random_limb(nil, function(limbname)
					return is_replaceable(name, injurytype, limbname)
				end)
			end
		else
			if -hp+math.random(3) > 8 then
				injurytype = "wound"
			else
				injurytype = "abrasion"
			end
			if is_upgradable(name, injurytype, limb) then
				local _
				_, injurytype = is_upgradable(name, injurytype, limb)
			end
			if not limb or (existinginjury and not is_replaceable(name, injurytype, limb)) then
				limb = get_random_limb(nil, function(limbname)
					return is_replaceable(name, injurytype, limbname)
				end)
			end
			if not limb then--replace wound with wound_arterial
				injurytype = "wound_arterial"
				limb = get_random_limb( {"Arm_Right", "Arm_Left", "Leg_Right", "Leg_Left"}, function(limbname)
					return is_replaceable(name, injurytype, limbname)
				end)
			end
		end
	elseif injurytype == "blunt" then
		if -hp+math.random(5) > 10 then--if high damage do fracture
			injurytype = "fracture"
			if not limb or (existinginjury and not is_replaceable(name, injurytype, limb))
			or not medical.injuries[injurytype].possible_limbs[limb] then
				limb = get_random_limb( {"Arm_Right", "Arm_Left", "Leg_Right", "Leg_Left"}, function(limbname)
					return is_replaceable(name, injurytype, limbname)
				end)
			end
			if not limb then--replace with wound if nowhere is available for fracture
				injurytype = "wound"
				limb = get_random_limb(nil, function(limbname)
					return is_replaceable(name, injurytype, limbname)
				end)
			end
		else
			if -hp+math.random(3) > 6 then
				injurytype = "abrasion"
			else
				injurytype = "bruise"
			end
			if not limb or (existinginjury and not is_replaceable(name, injurytype, limb)) then
				limb = get_random_limb(nil, function(limbname)
					return is_replaceable(name, injurytype, limbname)
				end)
			end
			if not limb then--replace with wound if nowhere is available bruise or abrasion
				injurytype = "wound"
				limb = get_random_limb(nil, function(limbname)
					return is_replaceable(name, injurytype, limbname)
				end)
			end
		end
	elseif injurytype == "burn" then
		if not limb or (existinginjury and not is_replaceable(name, injurytype, limb)) then
			limb = nil
			if get_limbs_with_injury(name, "burn") then
				limb = get_random_limb(get_limbs_with_injury(name, "burn"),--first try to see if any existing burns can be made more severe
					function(limbname)
						local tempinjury, tempseverity = get_injury(name, limbname)
						if tempseverity == 1 then
							return false
						end
						return true
					end)
				existinginjury, severity = get_injury(name, limb)
			end
			if not limb then
				limb = get_random_limb(nil, function(limbname)
					return is_replaceable(name, injurytype, limbname)
				end)
			end
		end
	end
	if not limb then return end
	local newseverity = ((severity or 0) - (hp*severitymulti))--hp is always negative, so use double negative to make severity be positive
	if newseverity > 1 then newseverity = 1 end
	injurydef = medical.injuries[injurytype]
	if not medical.data[name].injuries then medical.data[name].injuries = {} end
	medical.data[name].injuries[limb] = {name = injurytype, severity = newseverity, healtime = injurydef.healtime}
	medical.add_injury_ent(player, limb, {name = injurytype, severity = newseverity})
	medical.effect_handle(player)
	medical.save()
end

minetest.register_on_mods_loaded(function()
	--if true then return true end
	local sharplist = {}--{"grenades_basic:frag", "spriteguns:coltarmy", "spriteguns:cz527", "spriteguns:mini14", "spriteguns:pardini",  "spriteguns:remington870",  "spriteguns:thompson"} I'll just change the gun and grenade mod to add tool cababilities to punch()
	for name, tool in pairs(minetest.registered_tools) do
		for i, text in pairs({"sword_", "hoe_", "pick_", "axe_", }) do--add all these to sharp group
			if string.find(name, text) then
				table.insert(sharplist, name)
				goto next
			end
		end
		::next::
	end
	for i, itemname in pairs(sharplist) do
		if minetest.registered_items[itemname] then
			local olddef = table.copy(minetest.registered_items[itemname])
			if not olddef.tool_capabilities then olddef.tool_capabilities = {} end
			if not olddef.tool_capabilities.damage_groups then olddef.tool_capabilities.damage_groups = {} end
			olddef.tool_capabilities.damage_groups.sharp = 1
			minetest.override_item(itemname, {tool_capabilities = olddef.tool_capabilities})
		end
	end
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)
	local hittype = reason.type
	--minetest.chat_send_all(dump(reason))
	if not hittype or (hittype == "hp_change" or hittype == "respawn" or hittype == "punch") or hp_change >= 0 then return end
	local name = player:get_player_name()
	if medical.data[name].hp then return end--disallow further injuries when already down
	if hittype == "fall" then --fall: bruise/abrasion/fracture
		local limb
		if math.random((-hp_change)*.25) ~= 1 then--more likely to hurt legs when falling than anything else
			limb = get_random_limb({"Leg_Right", "Leg_Left"})
		end
		medical.add_injury(player, "blunt", hp_change, limb)
	elseif hittype == "node_damage" then--node_damage: burns for lava/fire/smoke/steam, sharp for others
		if reason.node and (string.find(reason.node, "fire") or string.find(reason.node, "lava") or string.find(reason.node, "steam") or string.find(reason.node, "smoke")) then
			medical.add_injury(player, "burn", hp_change)
		else
			medical.add_injury(player, "sharp", hp_change)
		end
	elseif hittype == "radiation" then--support technic radiation (requires technic tweak, dosnt work with master technic)
		medical.add_injury(player, "burn", hp_change)
	else
		--minetest.chat_send_all(hittype)
		minetest.log("warning", "Medical: hp was changed with unknown reason type '"..hittype.."' no injuries added")
	end
end, false)

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	damage = -damage--hpchange does negative so this should too
	if hitter:get_player_name() and playercontrol and playercontrol.can_pvp and not playercontrol.can_pvp(hitter:get_player_name()) then damage = damage/4 end
	if damage >= 0 then return false end
	if damage < -20 then damage = -20 end--cap this at -20
	--minetest.chat_send_all(dump(dir))
	local limb = medical.getlimb(player, hitter, tool_capabilities, dir)
	local name = player:get_player_name()
	if medical.data[name].hp then return true end--disallow further injuries when already down
	--minetest.chat_send_all(limb)
	if tool_capabilities and tool_capabilities.damage_groups and tool_capabilities.damage_groups.sharp and damage < -1 then
		if tool_capabilities.damage_groups.grenade then--multiple wounds from fragmentation grenades, based on how much damage
			for i = 1, math.ceil(-damage*.333) do--one injury for every 3 hp damage, 12 damage = 4 injuries
				medical.add_injury(player, "sharp", damage/i, limb)
			end
		else
			medical.add_injury(player, "sharp", damage, limb)
		end
	else
		medical.add_injury(player, "blunt", damage, limb)
	end
	return false
end)
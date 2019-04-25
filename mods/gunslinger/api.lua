gunslinger = {}

local max_wear = 65534
local lite = minetest.settings:get_bool("gunslinger.lite")

--get the walking speed
local max_speed = minetest.settings:get("movement_speed_walk") or 4
-- account a little bit for jumping and falling
max_speed = max_speed + 2

local guns = {}
local types = {}
local automatic = {}
local scope_overlay = {}
local interval = {}

--
-- Internal API functions
--

local function play_sound(sound, player)
	minetest.sound_play(sound, {
		object = player,
		loop = false,
		max_hear_distance = 200,
		pitch = math.random(90,110)*.01
	})
end

local function add_auto(name, def, stack)
	automatic[name] = {
		def   = def,
		stack = stack
	}
end

--------------------------------

local function show_scope(player, scope, zoom)
	if not player then
		return
	end

	-- Create HUD overlay element
	scope_overlay[player:get_player_name()] = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0.5, y = 0.5},
		alignment = {x = 0, y = 0},
		text = scope
	})
end

local function hide_scope(player)
	if not player then
		return
	end

	local name = player:get_player_name()
	player:hud_remove(scope_overlay[name])
	scope_overlay[name] = nil
end

--------------------------------

local function reload(stack, player, ammo)
	-- Check for ammo
	if not ammo then
		return stack
	end
	local is_mag = minetest.get_item_group(ammo, "gunslinger_magazine") > 0
	local inv = player:get_inventory()
	if inv:contains_item("main", ammo) then
		-- Ammo exists, reload and reset wear
		if is_mag then
			local id
			local magstack
			local magwear = 65534
			for i = 1, inv:get_size("main") do
				if inv:get_stack("main", i):get_name() == ammo then
					if inv:get_stack("main", i):get_wear() <= magwear then
						id = i
						magstack = inv:get_stack("main", i)
						magwear = magstack:get_wear()
					end
				end
			end
			stack:replace({name = string.gsub(stack:get_name(), '_empty', ""), wear = magwear})
			magstack:take_item()
			inv:set_stack("main", id, magstack)
		else
			stack:set_wear(0)
			inv:remove_item("main", ammo)
		end
		minetest.sound_play("gunslinger_loadmag", {
			object = player,
			max_hear_distance = 30,
			pitch = math.random(90,110)*.01
		})
	else
		-- No ammo, play click sound
		play_sound("gunslinger_ooa", player)
	end

	return stack
end

local function fire(stack, player, base_spread, max_spread, pellets)
	-- Workaround to prevent function from running if stack is nil
	if not stack then
		return
	end

	local def = gunslinger.get_def(stack:get_name())
	if not def then
		return stack
	end

	local wear = stack:get_wear()
	if wear == max_wear then
		if def.magazine then
			return stack
		else
			return reload(stack, player, def.ammo)
		end
	end

	-- Play gunshot sound
	play_sound(def.fire_sound, player)

	-- Take aim
	local eye_offset = {x = 0, y = 1.45, z = 0} --player:get_eye_offset().offset_first
	--local first, third = player:get_eye_offset()
	--eye_offset = vector.add(eye_offset, first)
	local dir = player:get_look_dir()
	local p1 = vector.add(player:get_pos(), eye_offset)
	p1 = vector.add(p1, dir)
	
	if def.horizontal_recoil then
		local h = player:get_look_horizontal()
		player:set_look_horizontal(h + (math.random(-1*def.horizontal_recoil, def.horizontal_recoil))*.001)
	end
	if def.vertical_recoil then
		local v = player:get_look_vertical()
		player:set_look_vertical(v - (math.random(def.vertical_recoil/2, def.vertical_recoil))*.001)
	end
	
	--no point in calculating how much you should spread with distance if it's disabled
	if max_spread then
		local speed = vector.length(player:get_player_velocity())
		if speed > max_speed then
			speed = max_speed
		end
		--a little calculation. speed divided by max speed should always be a value between 0 and 1.
		base_spread = base_spread + max_spread*(speed/max_speed)
	end
	if not pellets then pellets = 1 end
	for i = 1, pellets do
		if base_spread then
			dir.x = dir.x + (math.random(-1*base_spread, base_spread))*.001
			dir.y = dir.y + (math.random(-1*base_spread, base_spread))*.001
			dir.z = dir.z + (math.random(-1*base_spread, base_spread))*.001
		end
		local p2 = vector.add(p1, vector.multiply(dir, def.range))
		local ray = minetest.raycast(p1, p2)
		local pointed = ray:next()
		
		if pointed and pointed.ref and pointed.ref == player then
			pointed = ray:next()
		end

		if pointed and pointed.intersection_point and pointed.type == "node" then
			minetest.add_particle({
				pos = vector.subtract(pointed.intersection_point, vector.divide(dir, 50)),
				expirationtime = 10,
				size = 2,
				texture = "gunslinger_decal.png",
				vertical = true
			})
		end
		-- Projectile particle
		minetest.add_particle({
			pos = p1,
			velocity = vector.multiply(dir, 400),
			acceleration = {x = 0, y = 0, z = 0},
			expirationtime = 2,
			size = 1,
			collisiondetection = true,
			collision_removal = true,
			object_collision = true,
			glow = 5,
			texture = "gunslinger_bullet.png"
		})

		-- Fire!
		if pointed and pointed.type == "object" then
			local target = pointed.ref
			local point = pointed.intersection_point
			local dmg = def.base_dmg * def.dmg_mult

			-- Add 50% damage if headshot
			if point.y > target:get_pos().y + 1.5 then
				dmg = dmg * 1.5
			end

			-- Add 20% more damage if player using scope
			if scope_overlay[player:get_player_name()] then
				dmg = dmg * 1.2
			end

			target:punch(player, nil, {damage_groups={fleshy=dmg}})
		end
	end

	-- Update wear
	local wear = stack:get_wear()
	wear = wear + def.unit_wear
	if wear > max_wear then
		wear = max_wear
	end
	stack:set_wear(wear)

	return stack
end

local function burst_fire(stack, player, base_spread, max_spread, pellets)
	local def = gunslinger.get_def(stack:get_name())
	local burst = def.burst or 3
	for i = 1, burst do
		minetest.after(i / def.fire_rate, function(st)
			fire(st, player, base_spread, max_spread, pellets)
		end, stack)
	end
	-- Manually add wear to stack, as functions can't return
	-- values from within minetest.after
	local wear = stack:get_wear()
	wear = wear + def.unit_wear*3
	if wear > max_wear then
		wear = max_wear
	end
	stack:set_wear(wear)

	return stack
end

--------------------------------

local function on_lclick(stack, player)
	if not stack or not player then
		return
	end

	local def = gunslinger.get_def(stack:get_name())
	if not def then
		return
	end

	local name = player:get_player_name()
	if interval[name] and interval[name] < def.unit_time then
		return
	end
	interval[name] = 0

	if def.mode == "automatic" and not automatic[name] then
		add_auto(name, def, stack)
	elseif def.mode == "hybrid"
			and not automatic[name] then
		if scope_overlay[name] then
			stack = burst_fire(stack, player, def.base_spread, def.pellets)
		else
			add_auto(name, def)
		end
	elseif def.mode == "burst" then
		stack = burst_fire(stack, player, def.base_spread, def.pellets)
	elseif def.mode == "semi-automatic" then
		stack = fire(stack, player, def.base_spread, def.max_spread, def.pellets)
	elseif def.mode == "manual" then
		local meta = stack:get_meta()
		if meta:contains("loaded") then
			stack = fire(stack, player, def.base_spread, def.max_spread, def.pellets)
			meta:set_string("loaded", "")
		else
			stack = reload(stack, player, def.ammo)
			meta:set_string("loaded", "true")
		end
	end

	return stack
end

local function on_rclick(stack, player)
	local def = gunslinger.get_def(stack:get_name())
	if scope_overlay[player:get_player_name()] then
		hide_scope(player)
	else
		if def.scope then
			show_scope(player, def.scope, def.scope_overlay)
		end
	end

	return stack
end

local function on_q(itemstack, dropper, pos)
	local name = itemstack:get_name()
	if dropper:get_wielded_item():get_name() ~= name then return end
	local def = gunslinger.get_def(name)
	local inv = dropper:get_inventory()
	if inv:room_for_item("main", {name = def.ammo}) then
		inv:add_item("main", {name = def.ammo, wear = itemstack:get_wear()})
	else
		minetest.add_item(pos, {name = def.ammo, wear = itemstack:get_wear()})
	end
	minetest.sound_play("gunslinger_dropmag", {
		object = dropper,
		max_hear_distance = 30,
		pitch = math.random(90,110)*.01
	})
	dropper:set_wielded_item({name = name.."_empty"})
end

--------------------------------

local function on_step(dtime)
	for name in pairs(interval) do
		interval[name] = interval[name] + dtime
	end
	for name, info in pairs(automatic) do
		local player = minetest.get_player_by_name(name)
		if not player or player:get_hp() <= 0 then
			automatic[name] = nil
			return
		end
		if player:get_wielded_item():get_name() ~= info.stack:get_name() then return end
		if interval[name] < info.def.unit_time then
			return
		end
		if player:get_player_control().LMB then
			-- If LMB pressed, fire
			info.stack = fire(player:get_wielded_item(), player, info.def.base_spread, info.def.max_spread, info.def.pellets)
			player:set_wielded_item(info.stack)
			automatic[name].stack = info.stack
			interval[name] = 0
		else
			-- If LMB not pressed, remove player from list
			automatic[name] = nil
		end
	end
end

if not lite then
	minetest.register_globalstep(on_step)
end

--
-- External API functions
--

function gunslinger.get_def(name)
	return guns[name]
end

function gunslinger.register_type(name, def)
	assert(type(name) == "string" and type(def) == "table",
			   "gunslinger.register_type: Invalid params!")
	assert(not types[name], "gunslinger.register_type:"
			.. " Attempt to register a type with an existing name!")

	types[name] = def
end

function gunslinger.register_gun(name, def)
	assert(type(name) == "string" and type(def) == "table",
			   "gunslinger.register_type: Invalid params!")
	assert(not guns[name], "gunslinger.register_gun:"
			.. " Attempt to register a gun with an existing name!")

	-- Import type defaults if def.type specified
	if def.type then
		assert(types[def.type], "gunslinger.register_gun: Invalid type!")

		for name, val in pairs(types[def.type]) do
			def[name] = val
		end
	end
	-- Abort when making use of unimplemented features
	if def.zoom then
		error("register_gun: Unimplemented feature!")
	end

	if (def.mode == "automatic" or def.mode == "hybrid")
			and lite then
		error("gunslinger.register_gun: Attempt to register gun of " ..
				"type '" .. def.mode .. "' when lite mode is enabled")
	end

	def.itemdef.on_use = on_lclick
	--[[def.itemdef.on_secondary_use = on_rclick
	def.itemdef.on_place = function(stack, player, pointed)
		if pointed.type == "node" then
			local node = minetest.get_node_or_nil(pointed.under)
			local nodedef = minetest.registered_items[node.name]
			return nodedef.on_rightclick or on_rclick(stack, player)
		elseif pointed.type == "object" then
			local entity = pointed.ref:get_luaentity()
			return entity:on_rightclick(player) or on_rclick(stack, player)
		end
	end--]]
	if def.magazine then
		def.itemdef.on_drop = on_q
	end
	if not def.pellets then
		def.pellets = 1
	end
	if not def.dmg_mult then
		def.dmg_mult = 1
	end
	if not def.fire_sound then
		def.fire_sound = (def.pellets == 1)
			and "gunslinger_fire1" or "gunslinger_fire2"
	end

	if def.zoom and not def.scope then
		error("gunslinger.register_gun: zoom requires scope to be defined!")
	end

	def.unit_wear = math.ceil(max_wear / def.clip_size)
	def.unit_time = 1 / def.fire_rate
	
	def.itemdef.wear_represents = "ammunition"

	guns[name] = def
	minetest.register_tool(name, def.itemdef)
	if def.magazine then
		local emtpydef = table.copy(def).itemdef
		emtpydef.description = emtpydef.description.." (Empty)"
		emtpydef.inventory_image = string.gsub(emtpydef.inventory_image, '.png', "").."_empty.png"
		emtpydef.wield_image = string.gsub(emtpydef.wield_image, '.png', "").."_empty.png"
		emtpydef.on_drop = nil
		emtpydef.groups = {not_in_creative_inventory = 1}
		emtpydef.on_use = function(stack, player)
			return reload(stack, player, def.ammo)
		end
		minetest.register_tool(name.."_empty", emtpydef)
	end
end

function gunslinger.register_magazine(magazine, ammunition, size)
	minetest.override_item(magazine, {
    groups = {gunslinger_magazine=1},
	wear_represents = "ammunition"
	})
	minetest.register_craft({
		type = "shapeless",
		output = magazine,
		recipe = {magazine, ammunition},
	})
	minetest.register_craft({
		type = "shapeless",
		output = magazine.." 1 65535",
		recipe = {magazine}
	})

	minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
		local hasbullet
		local hasmag
		local magid
		local other = false
		for id, stack in pairs (old_craft_grid) do
			if stack:get_name() == ammunition then
				hasbullet = stack:get_count()
			elseif stack:get_name() == magazine then
				hasmag = stack:get_wear()
				magid = id
			elseif stack:get_name() ~= "" then
				other = true
			end
		end
		
		if other then return end
		
		if hasmag and not hasbullet then
			local bullets = math.floor((size+.5) - ((hasmag/65534)*size))
			craft_inv:add_item("craft", {name = ammunition, count = bullets})
		end
		
		if hasbullet and hasmag then
			craft_inv:add_item("craft", {name = ammunition})
			local needbullets = math.floor((hasmag/65534)*size+.5)
			if needbullets == 0 then
				return
			end
			if hasbullet >= needbullets then
				itemstack:set_wear(0)
				craft_inv:remove_item("craft", {name = ammunition, count = needbullets})
			else
				itemstack:set_wear(hasmag-(hasbullet*(65534/size)))
				craft_inv:remove_item("craft", {name = ammunition, count = hasbullet})
			end
		end
	end)
end
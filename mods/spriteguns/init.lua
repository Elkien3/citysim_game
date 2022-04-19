spriteguns = {}
spriteguns.registered_guns = {}
local storage = minetest.get_mod_storage()
local scalepref = minetest.deserialize(storage:get_string("scalepref")) or {}
local skipsteppref = minetest.deserialize(storage:get_string("skipsteppref")) or {}
local gun_huds = {}
local max_wear = 65534
local max_speed = (minetest.settings:get("movement_speed_walk") or 4) + 1

shootable_entities = {["creatures:zombie"] = true, ["creatures:ghost"] = true, ["creatures:oerrki"] = true}

minetest.register_chatcommand("spritegunscale",{
	params = "<scale>",  -- Short parameter description
	description = "Set sprite gun scale multiplier",  -- Full description
	func = function(name, param)
		if not param or param == "" or not tonumber(param) then return false, "Invalid Input" end
		scalepref[name] = tonumber(param)
		storage:set_string("scalepref", minetest.serialize(scalepref))
		return true, "Sprite Gun Scale set to "..param
	end
})

spriteguns.is_wielding_gun = function(name)
	return gun_huds[name] ~= nil
end

minetest.register_chatcommand("spritegunskipstep",{
	params = "<scale>",  -- Short parameter description
	description = "Set wether or not to skip every other step's hud update",  -- Full description
	func = function(name, param)
		if not param or (param ~= "false" and param ~= "true") then return false, "Invalid Input, must be 'true' or 'false'" end
		param = param == "true"
		skipsteppref[name] = param
		storage:set_string("skipsteppref", minetest.serialize(skipsteppref))
		return true, "Sprite Gun Skip Step preference set to "..tostring(param)
	end
})

if binoculars then binoculars.update_player_property = function() minetest.unregister_item("binoculars:binoculars") end end--die zoomer
minetest.register_on_joinplayer(function(player)
	player:set_properties({zoom_fov = 0})
end)

local function play_delayed_sound(sound, def, pos, player, selfhear)
	if not sound or not pos or not player then return end
	if not def then def = {} end
	for id, data in pairs({
		object = player,
		loop = false,
		max_hear_distance = 64,
		pitch = math.random(90,110)*.01
		}) do
		if not def[id] then def[id] = data end
	end
	for _,player2 in ipairs(minetest.get_connected_players()) do
		if selfhear or player ~= player2 then
			local distance = vector.distance(pos, player2:get_pos())
			local sounddef = table.copy(def)
			if distance <= (sounddef.max_hear_distance or 32) then
				sounddef.to_player = player2:get_player_name()
				minetest.after(distance/343, minetest.sound_play, sound, sounddef)
			end
		end
	end
end

function math.Clamp(val, lower, upper)
    assert(val and lower and upper, "not very useful error message here")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

-- converted from c#. source: lordofduct https://forum.unity.com/threads/how-do-i-find-the-closest-point-on-a-line.340058/

local function NearestPointOnFiniteLine(lineStart, lineEnd, pnt)
    local line = vector.subtract(lineEnd, lineStart)
    local len = vector.length(line)
    line = vector.normalize(line)
   
    local v = vector.subtract(pnt, lineStart)
    local d = vector.dot(v, line)
    d = math.Clamp(d, 0, len);
    return vector.add(lineStart, vector.multiply(line, d))
end

local function set_physics(player, amount)
	if playercontrol then
		playercontrol.set_effect(player:get_player_name(), "speed", amount, "spriteguns", true)
	else
		player:set_physics_override({speed = amount or 1})
	end
end

local function zoom(name, def, val)
	if not name then return end
	if not gun_huds[name] then add_gun(name, def.gunname) end
	gun_huds[name].offset.y = -.5
	if not gun_huds[name] then return end
	local player = minetest.get_player_by_name(name)
	if not player then return end
	if val == nil then val = not gun_huds[name].zoom end
	gun_huds[name].zoom = val
	if val then
		set_physics(player, (def.zoomspeed or .5))
		if def and def.zoomfov then
			if playercontrol then
				local fov = playercontrol.set_effect(name, "fov", def.zoomfov, "spriteguns", false)
				if fov then player:set_fov(fov, false, .15) end
			else
				player:set_fov(def.zoomfov, false, .15)
			end
		end
	else
		set_physics(player, nil)
		if playercontrol then
			player:set_fov(playercontrol.set_effect(name, "fov", nil, "spriteguns", false) or 0, false, .15)
		else
			player:set_fov(0, false, .15)
		end
	end
end

local function add_gun(name, gunname)
	if not name then return end
	local player = minetest.get_player_by_name(name)
	if not player then return end
	local itemstack = player:get_wielded_item()
	local def = spriteguns.registered_guns[gunname]
	if gun_huds[name] then
		player:hud_remove(gun_huds[name].hud)
		player:hud_remove(gun_huds[name].hotbar)
		gun_huds[name] = nil
	end
	gun_huds[name] = {stack = itemstack, index = player:get_wield_index(), gun = gunname, point = {x=0,y=0,z=0}, zoom = false, target = {x=math.random(-def.targetrecoil,def.targetrecoil)/1000,y= math.random(-def.targetrecoil,def.targetrecoil)/1000, z=0}, offset = {x=0,y=-1,z=0}, t = 0, vel = {}}
	if itemstack:get_wear() ~= max_wear then
		gun_huds[name].anim = "load"
	end
	if addcrosshair then
		if addcrosshair.tbl[name] then
			player:hud_remove(addcrosshair.tbl[name])
		end
	else
		player:hud_set_flags({crosshair=false})
	end
	player:hud_set_flags({wielditem=false})
	player:hud_set_flags({hotbar=false})
	local scale = def.scale or 7.5
	if scalepref[name] then
		scale = scale * scalepref[name]
	end
	gun_huds[name].hud = player:hud_add({
		hud_elem_type = "image_waypoint",
		scale = {x=scale, y=scale},
		text = "invis.png",
		alignment = {x=0,y=0},
		offset = {x=0,y=0},
		world_pos = {x=0,y=0,z=0},
		z_index = -10000
	})
	gun_huds[name].hotbar = player:hud_add({
		hud_elem_type = "inventory",
		text = "main",
		number = 8,
		alignment = {x=0,y=0},
		position  = {x = 0.5, y = 1},
		item = player:get_wield_index(),
		offset = {x=-224,y=-60}
	})
	gun_huds[name].lastlook = player:get_look_dir()
end
local function remove_gun(name)
	if not name then return end
	if not gun_huds[name] then return end
	local player = minetest.get_player_by_name(name)
	if player then
		player:hud_remove(gun_huds[name].hud)
		player:hud_remove(gun_huds[name].hotbar)
		if addcrosshair then
			addcrosshair.setflags(player)
		else
			player:hud_set_flags({crosshair=true})
		end
		player:hud_set_flags({wielditem=true})
		player:hud_set_flags({hotbar=true})
	end
	zoom(name, nil, false)
	gun_huds[name] = nil
end
local function rotateVector(x, y, a)
  local c = math.cos(a)
  local s = math.sin(a)
  return c*x - s*y, s*x + c*y
end
--[[ couldnt figure this out, just some pasted code from stackexhange
local function get_circlepoint(radius)
	local angle = math.random(360)
	local distance = math.random(radius*1000)/1000
	local vector = vector.rotate({x=distance, y=0, z=0}, {x=0, y=angle*math.pi/180, z=0})
	return vector.x, vector.z--]]
	--[[local t = 2*math.pi*(math.random(radius*1000)/1000)
	local u = (math.random(radius*1000)/1000)+(math.random(radius*1000)/1000)
	if u > radius then u = radius end
	return u*math.cos(t), u*math.sin(t)--]]
--end

minetest.register_node("spriteguns:flash", {
	drawtype = "glasslike",
	tile_images = {"invis.png"},
	-- tile_images = {"walking_light_debug.png"},
	inventory_image = minetest.inventorycube("walking_light.png"),
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	light_propagates = true,
	sunlight_propagates = true,
	light_source = 13,
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(.1) -- in seconds
	end,
	on_timer = function(pos, elapsed)
		minetest.remove_node(pos)
	end,
	selection_box = {
        type = "fixed",
        fixed = {0, 0, 0, 0, 0, 0},
    },
})
minetest.register_abm({
	nodenames = {"spriteguns:flash"},
	interval = 10,
	chance = 1,
	catch_up = false,
	action = function(pos, _, _, _)
		if not minetest.get_node_timer(pos):is_started() then
			minetest.remove_node(pos)
		end
	end,
})

local function get_top_parent(obj)
	while true do
		local parent = obj:get_attach()
		if parent then
			obj = parent
		else
			return obj
		end
	end
end
local function find_recursive_player_children(obj, player)
	local tbl = {}
	local children = obj:get_children()
	if children then
		for id, child in pairs(children) do
			if child == player then return {} end
			if child:is_player() then
				table.insert(tbl, child)
			end
			for id2, child2 in pairs(find_recursive_player_children(child, player)) do
				if child2 == player then return {} end
				tbl.insert(tbl, child2)
			end
		end
	end
	return tbl
end

local function fire(player, def, itemstack)
	local name = player:get_player_name()
	local t1 = minetest.get_us_time()/1000000
	if not name then return end
	if not def then return end
	if not gun_huds[name] then return end--add_gun(name, def.gunname) end
	local tbl = gun_huds[name]
	if tbl.firing and t1-tbl.firing < def.firetime then return end
	if tbl.animrepeat then tbl.animcancel = true end
	if tbl.anim then return end
	local stack = itemstack or player:get_wielded_item()
	local wear = stack:get_wear()
	if wear == max_wear then
		tbl.offset.y = tbl.offset.y - .05
		minetest.sound_play("gunslinger_charge", {
			object = player,
			pitch = math.random(90,110)/100
		}, true)
		tbl.firing = nil
		return
	end
	
	tbl.firing = t1
	local eye_offset = {x = 0, y = 1.45, z = 0} --player:get_eye_offset().offset_first
	local first, third = player:get_eye_offset()
	if first then
		first.x, first.z = rotateVector(first.x, first.z, player:get_look_horizontal())
		eye_offset = vector.add(eye_offset, vector.multiply(first, .1))
	end
	
	local bullets = def.size-math.floor((wear/max_wear)*def.size+.5)
	bullets = bullets - 1
	wear = max_wear-(bullets/def.size)*max_wear
	stack:set_wear(wear)
	
	local pellets = def.pellets or 1
	local p1 = vector.add(player:get_pos(), eye_offset)
	local endPoint
	
	for i = 1, pellets do
		local dir = table.copy(tbl.point)
		if def.spread then
			local spread = {}
			spread.x = math.random(-1*1000, 1000)
			spread.y = math.random(-1*1000, 1000)
			spread.z = math.random(-1*1000, 1000)
			
			spread=vector.multiply(vector.normalize(spread), def.spread/1000)
			
			dir = vector.normalize(vector.add(dir, spread))
		end
		--[[local x, y = get_circlepoint(.1) couldnt figure this out
		dir = vector.rotate(dir, {x=x, y=y, z=0})--]]
		
		if not dir then return end
		local p2 = vector.add(p1, vector.multiply(dir, def.range))
		endPoint = p2
		local ray = minetest.raycast(p1, p2)
		local pointed = ray:next()
		
		if pointed and pointed.ref and pointed.ref == player then
			pointed = ray:next()
		end

		if pointed and pointed.intersection_point and pointed.type == "node" then
			endPoint = pointed.intersection_point
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
			local dmg = def.damage
			if not target:is_player() then
				local players = find_recursive_player_children(get_top_parent(target), player)
				local dist
				for id, child in pairs(players) do
					childpos = child:get_pos()
					childpos.y = childpos.y + .5
					local parent, bone, attachpos = child:get_attach()
					attachpos = vector.multiply(vector.rotate(attachpos, parent:get_rotation()), .1)
					childpos = vector.add(childpos, attachpos)
					local closepoint = NearestPointOnFiniteLine(point, endPoint, childpos)
					local tempdist = vector.distance(closepoint, childpos)
					if not dist or dist > tempdist then
						dist = tempdist
						target = child
						if tempdist > 1 then
							dmg=def.damage/2
						end
					end
				end
			end
			endPoint = point
			if target:is_player() or (target:get_entity_name() and shootable_entities[target:get_entity_name()]) then
				local targetpos = target:get_pos()
				-- Add 50% damage if headshot
				if point.y > targetpos.y + 1.5 then
					dmg = dmg * 1.5
				end
				local distmulti = -(vector.distance(p1, targetpos)/def.range)^2+1
				if distmulti > 1 then distmulti = 1 end
				dmg = dmg*distmulti
				if dmg < 0 then dmg = 0 end
				target:punch(player, nil, {damage_groups={fleshy=dmg}})
			end
		end
		for _,player2 in ipairs(minetest.get_connected_players()) do
			if player ~= player2 then
				local pos = player2:get_pos()
				local nearPoint = NearestPointOnFiniteLine(p1, endPoint, pos)
				if not vector.equals(nearPoint, p1) and not vector.equals(nearPoint, p2) then
					local dist = vector.distance(pos, nearPoint)
					local function whizz()
						if dist < 2 then
							minetest.sound_play("bullet_crackdelay", {
								to_player = player2:get_player_name(),
								pos = nearPoint,
								--max_hear_distance = 2,
								gain = 1/pellets,
								pitch = math.random(90, 110)/100
							})
						end
						if dist < 8 then
							minetest.sound_play("bullet_whizz", {
								to_player = player2:get_player_name(),
								pos = nearPoint,
								--max_hear_distance = 8,
								gain = 1/pellets,
								pitch = math.random(8, 12)/10
							})
						end
					end
					if pellets > 1 then
						minetest.after(math.random(20)/100, whizz)
					else
						whizz()
					end
					--[[
					local marker = player2:hud_add({
							hud_elem_type = "waypoint",
							name = "closepoint",
							number = 0xFF0000,
							world_pos = nearPoint
						})
					minetest.after(5, function() player2:hud_remove(marker) end, player2, marker)--]]
				end
			end
		end
	end
	
	play_delayed_sound(def.fire_sound, {gain = def.fire_gain}, player:get_pos(), player, true)
	play_delayed_sound(def.fire_sound_distant, {max_hear_distance = 400, gain = 10}, player:get_pos(), player)
	if minetest.get_node(p1).name == "air" then
		minetest.set_node(p1, {name = "spriteguns:flash"})
	end
	
	tbl.offset.y = tbl.offset.y + math.random(def.offsetrecoil/2,def.offsetrecoil)/1000
	tbl.offset.x = tbl.offset.x + math.random(def.offsetrecoil/-2,def.offsetrecoil/2)/1000
	tbl.target.x = tbl.target.x + math.random(-def.targetrecoil,def.targetrecoil)/1000
	tbl.target.y = tbl.target.y + math.random(-def.targetrecoil,def.targetrecoil)/1000
	tbl.stack = stack
	if not itemstack then
		player:set_wielded_item(stack)
	else
		return itemstack
	end
end

local function reload(player, def, stack, wear)
	local inv = player:get_inventory()
	if def.reloadresume then
		stack:get_meta():set_int("reloadframe", 0)
	end
	local ammo = ItemStack(def.ammo)
	if def.magazine then
		if inv:contains_item("main", ammo) then
			local id
			local magstack
			local magwear = 65535
			for i = 1, inv:get_size("main") do
				local tempmagwear = inv:get_stack("main", i):get_wear()
				if inv:get_stack("main", i):get_name() == def.ammo and tempmagwear <= magwear then
					id = i
					magstack = inv:get_stack("main", i)
					magwear = tempmagwear
				end
			end
			if not magstack then return end
			stack:get_meta():set_int("nomag", 0)
			wear = magwear
			magstack:take_item()
			inv:set_stack("main", id, magstack)
		end
	else
		local bullets = def.size-math.floor((wear/max_wear)*def.size+.5)
		if bullets + ammo:get_count() > def.size then
			ammo:set_count(def.size-bullets)
		end
		local removed = inv:remove_item("main", ammo)
		bullets = bullets + removed:get_count()
		wear = max_wear-(bullets/def.size)*max_wear
	end
	if wear < 1 then wear = 1 end
	stack:set_wear(wear)
	gun_huds[player:get_player_name()].stack = stack
	player:set_wielded_item(stack)
	return wear
end

local function unload(dropper, def, itemstack, wear, pos)
	local newstack
	if def.magazine then
		newstack = ItemStack({name = def.ammo, wear = wear})
		itemstack:get_meta():set_int("nomag", 1)
		wear = max_wear
		itemstack:set_wear(wear)
	else
		local tempstack = ItemStack(def.ammo)
		local bullets = def.size-math.floor((wear/max_wear)*def.size+.5)
		local unload = def.unload_amount or def.size
		if unload > bullets then
			unload = bullets
		end
		bullets = bullets-unload
		wear = max_wear-(bullets/def.size)*max_wear
		if wear > max_wear then wear = max_wear end
		itemstack:set_wear(wear)
		newstack = ItemStack({name = tempstack:get_name(), count = unload})
	end
	local inv = dropper:get_inventory()
	if inv:room_for_item("main", newstack) then
		inv:add_item("main", newstack)
	else
		minetest.add_item(pos, newstack)
	end
	gun_huds[dropper:get_player_name()].stack = itemstack
	dropper:set_wielded_item(itemstack)
	return wear
end

local orig_func = minetest.set_player_privs
minetest.set_player_privs = function(name, privs)
	local val = orig_func(name, privs)
	if not minetest.check_player_privs(name, {interact=true}) then
		remove_gun(name)
	end
	return val
end

--[[local a = .2
local f = 1.2--]]

local skipstep = false

local warnedplayers = {}
minetest.register_globalstep(function(dtime)
	local t1 = minetest.get_us_time()/1000000
	skipstep = not skipstep
	for _, player in pairs(minetest.get_connected_players()) do --todo only check on inv move or wield index change
		local name = player:get_player_name()
		if not gun_huds[name] then
			local wield = player:get_wielded_item():get_name()
			local def = spriteguns.registered_guns[wield]
			if def and minetest.check_player_privs(name, {interact=true}) then
				if def.concealed or player:get_wield_index() == 1 then
					add_gun(name, wield)
				elseif not warnedplayers[name] or warnedplayers[name] ~= wield then
					warnedplayers[name] = wield
					minetest.chat_send_player(name, "This gun must be placed in slot 1 to be used.")
				end
			end
		end
	end
	for name, tbl in pairs(gun_huds) do
		local player = minetest.get_player_by_name(name)
		if not player then gun_huds[name] = nil return end
		local stack = player:get_wielded_item()
		local wield = stack:get_name()
		local wear = stack:get_wear()
		if stack:to_string() ~= tbl.stack:to_string() or player:get_wield_index() ~= tbl.index then remove_gun(name) return end
		local def = spriteguns.registered_guns[tbl.gun]
		local ctrl = player:get_player_control()
		local inv = player:get_inventory()
		local ammo = ItemStack(def.ammo)
		ammo:set_count(1)
		if not tbl.anim and ctrl.zoom and wear > 1 and inv:contains_item("main", ammo) and (not def.magazine or (wear == max_wear and tbl.stack:get_meta():get_int("nomag") == 1)) then
			tbl.anim = "reload"
		end
		local speed = vector.length(player:get_player_velocity())
		if speed > max_speed then speed = max_speed end
		local f = speed*.3
		if tbl.f and f ~= tbl.f and f ~= 0 then
			tbl.t = (tbl.f/f)*tbl.t
		end
		tbl.f = f
		local a = speed*.05
		tbl.t = tbl.t + dtime
		if tbl.t > 1/f then tbl.t = 0 end
		local t = tbl.t
		local yaw = player:get_look_horizontal()
		local pldir = player:get_look_dir()
		if not tbl.zoom then
			local change = vector.subtract(pldir, tbl.lastlook)
			change.x, change.z = rotateVector(change.x, change.z, -yaw)
			for dir, val in pairs(tbl.target) do
				if math.abs(val + change[dir]) < def.maxdev then
					tbl.target[dir] = val + change[dir]
				elseif val ~= 0 then
					tbl.target[dir] = def.maxdev*(val/math.abs(val))
				end
			end
			--tbl.target = vector.add(tbl.target, change)
		end
		--have gun move around when idle
		if not tbl.t2 then tbl.t2 = 1 end
		local wagspeed = .5
		if tbl.wag then
			wagspeed = wagspeed*tbl.wag
		end
		if hb and hb.get_hudtable("sprint") then--if sprinting with hudbars is enabled use it to decide if wagspeed should be higher
			local state = hb.get_hudtable("sprint").hudstate[name]
			if state then
				local val = state.value
				wagspeed = math.max(.5+(10-val)*.4, wagspeed)
			end		
		end
		tbl.t2 = tbl.t2 + dtime
		if not tbl.vel.x then
			tbl.vel = {x=0,y=0,z=0}
		end
		if tbl.t2 > .2 + math.random(10)/100 then
			tbl.t2 = 0
			local randvel = vector.normalize({x=math.random(-10,10),y=math.random(-10,10),z=0})
			randvel = vector.multiply(randvel, wagspeed/200)
			randvel = vector.subtract(randvel, vector.multiply(tbl.target, wagspeed/10))
			randvel = vector.add(randvel, tbl.vel)
			randvel = vector.normalize(randvel)
			randvel = vector.multiply(randvel, wagspeed/100)
			tbl.vel = randvel
		end
		tbl.target = vector.add(tbl.target, vector.multiply(tbl.vel, dtime))
		for dir, val in pairs(tbl.target) do
			local max = def.maxdev
			if tbl.zoom then max = def.maxzoomdev end
			if math.abs(val) > max then
				local sign = val/math.abs(val)
				val = val*.8
				val = val - dtime*.1*sign
				if val*sign<max then val = max*sign end
			end
			--[[if off ~= 0 and sign ~= off/math.abs(off) then
				off = 0
			end--]]
			tbl.target[dir] = val
		end
		for dir, val in pairs(tbl.offset) do
			if val ~= 0 then
				local sign = val/math.abs(val)
				val = val*.85
				val = val - dtime*.05*sign
				if val/math.abs(val) ~= sign then
					val = 0
				end
				tbl.offset[dir] = val
			end
		end
		local offset = vector.add(tbl.target, tbl.offset)
		offset.x = offset.x + math.sin(2*math.pi*f*t)*a
		offset.y = offset.y + math.sin(2*math.pi*f*2*t)*a*.5
		
		local lookrot = vector.dir_to_rotation(pldir)
		lookrot.x = lookrot.x + offset.y
		lookrot.y = lookrot.y - offset.x
		tbl.point = vector.rotate({x=0,y=0,z=1}, lookrot)
		local pos = vector.multiply(tbl.point, 100000)
		local plpos = player:get_pos()
		plpos.y = plpos.y + 1
		pos = vector.add(pos, plpos)
		if not skipsteppref[name] or not skipstep then
			player:hud_change(tbl.hud, "world_pos", pos)
		end
		
		local tex = ""
		if tbl.anim then
			local anim = def.textures[tbl.anim]
			
			if tbl.animrepeat and (tbl.animtimer/anim.length)*#anim.frames > (anim.loopend or #anim.frames) and anim.endfunc then
				tbl.animrepeat = anim.endfunc(player, def)
			end
			if not tbl.animrepeat and tbl.animtimer and tbl.animtimer > anim.length then
				--[[if not anim.loopend and anim.endfunc then
					anim.endfunc(player, def)
				end--]]
				if anim.speed then
					set_physics(player, nil)
				end
				tbl.anim = nil
				tbl.animtimer = nil
			end
			if tbl.anim and not tbl.animtimer then
				tbl.animtimer = 0
				if anim.endfunc then
					tbl.animrepeat = true
				end
				local frames = anim.frames
				if tbl.zoom and anim.zoomframes then
					frames = anim.zoomframes
				end
				if tbl.anim == "reload" and def.reloadresume then
					tbl.animtimer = (stack:get_meta():get_int("reloadframe")/#frames)*anim.length+.01
					if tbl.animtimer<0 then tbl.animtimer = 0 end
				end
				if tbl.zoom and not anim.zoomframes then
					zoom(name, def, false)
				end
				if anim.speed then
					set_physics(player, anim.speed)
				end
				if anim.startfunc then
					anim.startfunc(player, def)
				end
				if anim.sounds and anim.sounds[1] then
					minetest.sound_play(anim.sounds[1], {
						object = player,
						max_hear_distance = 4,
						pitch = math.random(90,110)/100
					}, true)
				end
			end
			if tbl.anim and tbl.animtimer then
				local frames = anim.frames
				if tbl.zoom and anim.zoomframes then
					frames = anim.zoomframes
				end
				local currentframe = math.ceil((tbl.animtimer/anim.length)*#frames)
				if currentframe <= 0 then
					currentframe = 1
				end
				if currentframe > #frames then
					currentframe = #frames
				end
				if tbl.anim == "reload" and def.reloadresume and stack:get_meta():get_int("reloadframe") ~= currentframe then
					stack:get_meta():set_int("reloadframe", currentframe-1)
					tbl.stack = stack
					player:set_wielded_item(stack)
				end
				if tbl.animlastframe and tbl.animlastframe ~= currentframe and anim.sounds and anim.sounds[currentframe] then
					minetest.sound_play(anim.sounds[currentframe], {
						object = player,
						max_hear_distance = 16,
						pitch = math.random(90,110)/100
					}, true)
				end
				tex = (def.textures.prefix)..(frames[currentframe])
				tbl.animlastframe = currentframe
				tbl.animtimer = tbl.animtimer + dtime
			end
		end
		if not tbl.anim then
			if tbl.zoom then tex = tex.."aim" else tex = tex.."hip" end
			if tbl.firing and t1-tbl.firing < def.firetime then
				if t1-tbl.firing < .1 then
					tex = tex.."fire"
				else
					tex = tex.."postfire"
				end
			else
				if tbl.firing then
					tbl.firing = nil
					if def.loadtype == "auto" and ctrl.LMB then
						fire(player, def)
					elseif def.loadtype == "manual" and wear<max_wear then
						tbl.anim = "load"
					end
				end
				tex = tex.."idle"
				if def.magazine and wear == max_wear and tbl.stack:get_meta():get_int("nomag") == 1 then
					tex = tex.."nomag"
				end
			end
			tex = def.textures.prefix..def.textures[tex]
		end
		if not tbl.firing or t1-tbl.firing > .1 then
			local light = minetest.get_node_light(plpos) or 0
			local lightvalcolors = {
				"000000",
				"131313",
				"1f1f1f",
				"2b2b2b",
				"383838",
				"454545",
				"535353",
				"616161",
				"6f6f6f",
				"7e7e7e",
				"8d8d8d",
				"9d9d9d",
				"acacac",
				"bcbcbc",
				"cdcdcd",
				"dddddd",
				"eeeeee",
				"ffffff"
			}
			tex = tex.."^[multiply:#"..lightvalcolors[light+1]
		end
		if not tbl.lasttex or tbl.lasttex ~= tex then
			player:hud_change(tbl.hud, "text", tex)
		end
		tbl.lasttex = tex
		tbl.lastlook = pldir
		tbl.lastctrl = ctrl
	end
end)

function spriteguns.register_gun(gunname, def)
	def.gunname = gunname
	if def.damage then
		local oldfunc
		if def.textures.reload then
			oldfunc = def.textures.reload.endfunc
		end
		def.textures.reload.endfunc = function(player, def)
			if oldfunc then
				oldfunc(player, def)
			end
			local tbl = gun_huds[player:get_player_name()]
			local stack = player:get_wielded_item()
			local wear = stack:get_wear()
			local inv = player:get_inventory()
			wear = reload(player, def, stack, wear)
			local ammo = ItemStack(def.ammo)
			ammo:set_count(1)
			if not def.magazine and wear and wear > 1 and inv:contains_item("main", ammo) and not tbl.animcancel then
				tbl.anim = "reload"
				local start = 0
				local anim = def.textures.reload
				if anim.loopstart then
					start = anim.loopstart-.99999
					start = start*(anim.length/#anim.frames)
				end
				tbl.animtimer = start
				return true
			end
			if tbl.animcancel then tbl.animcancel = nil end
		end
		local oldfunc2 = def.textures.unload.endfunc
		def.textures.unload.endfunc = function(player, def)
			if oldfunc then
				oldfunc(player, def)
			end
			local tbl = gun_huds[player:get_player_name()]
			local stack = player:get_wielded_item()
			local wear = stack:get_wear()
			wear = unload(player, def, stack, wear, player:get_pos())
			if wear and wear < max_wear and not tbl.animcancel then
				tbl.anim = "unload"
				local start = 0
				local anim = def.textures.unload
				if anim.loopstart then
					start = anim.loopstart-.99999
					start = start*(anim.length/#anim.frames)
				end
				tbl.animtimer = start
				return true
			end
			if tbl.animcancel then tbl.animcancel = nil end
		end
	end
	local tooldef = {}
	tooldef.description = def.description
	tooldef.inventory_image = def.inventory_image
	tooldef.wield_image = def.wield_image
	tooldef.wear_represents = "ammunition"
	if def.damage and def.damage > 0 then
		tooldef.on_use = function(itemstack, user, pointed_thing)
			return fire(user, def, itemstack)
		end
		tooldef.on_drop = function(itemstack, dropper, pos)
			local wear = itemstack:get_wear()
			local name = dropper:get_player_name()
			local stackname = itemstack:get_name()
			if name and dropper:get_wielded_item():get_name() == stackname and gun_huds[name] and gun_huds[name].anim ~= "unload" then
				if def.magazine then
					if wear < max_wear or itemstack:get_meta():get_int("nomag") == 0 then
						gun_huds[name].anim = "unload"
						return
					end
				else
					if wear < max_wear then
						gun_huds[name].anim = "unload"
						return
					end
				end
			end
			minetest.item_drop(itemstack, dropper, pos)
			itemstack:clear()
			return itemstack
		end
	end
	tooldef.on_place = function(itemstack, placer, pointed_thing)
		local name = placer:get_player_name()
		if not gun_huds[name] or (gun_huds[name].anim and not gun_huds[name].zoom) then return end
		zoom(name, def)
	end
	tooldef.on_secondary_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		if not gun_huds[name] or (gun_huds[name].anim and not gun_huds[name].zoom) then return end
		zoom(name, def)
	end
	minetest.register_tool(gunname, tooldef)
	spriteguns.registered_guns[gunname] = def
end

function spriteguns.register_magazine(magazine, ammunition, size)
	minetest.override_item(magazine, {
    groups = {spriteguns_magazine=1},
	wear_represents = "ammunition"
	})
	minetest.register_craft({
		type = "shapeless",
		output = magazine,
		recipe = {magazine, ammunition.." "..size},
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
			local bullets = math.floor((size+.5) - ((hasmag/max_wear)*size))
			craft_inv:add_item("craft", {name = ammunition, count = bullets})
		end
		
		if hasbullet and hasmag then
			craft_inv:add_item("craft", {name = ammunition})
			local needbullets = math.floor((hasmag/max_wear)*size+.5)
			if needbullets == 0 then
				return
			end
			if hasbullet >= needbullets then
				itemstack:set_wear(1)
				craft_inv:remove_item("craft", {name = ammunition, count = needbullets})
			else
				local wear = hasmag-(hasbullet*(max_wear/size))
				if wear < 1 then wear = 1 end
				itemstack:set_wear(wear)
				craft_inv:remove_item("craft", {name = ammunition, count = hasbullet})
			end
		end
	end)
end

function spriteguns.set_wag(name, value)
	if not name or not gun_huds[name] then return end
	gun_huds[name].wag = value
end

local mp = minetest.get_modpath("spriteguns")
dofile(mp.."/guns.lua")
dofile(mp.."/invspace.lua")
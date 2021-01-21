cars = {}
local go = false
local DEBUG_WAYPOINT = false
local DEBUG_TEXT = false
local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
end
local function rnd(number, decimal)
	if not decimal then decimal = 1 end
	return math.floor(number*decimal+.5)/decimal
end
local player_attached = {}

local attachTimer = 0
local animateTimer = 0
minetest.register_globalstep(function(dtime)
	attachTimer = attachTimer + dtime;
	animateTimer = animateTimer + dtime
	if attachTimer >= 5 then
		minetest.after(0, function() attachTimer = 0 end)
	end
	if animateTimer >= .08 then
		minetest.after(0, function() animateTimer = 0 end)
	end
end)

local keydef = minetest.registered_items["default:skeleton_key"]
local orig_func = keydef.on_use
local new_func = function(itemstack, user, pointed_thing)
	if pointed_thing.type == "object" then
		local obj = pointed_thing.ref
		obj:punch(user, nil, {damage_groups={fleshy=0}})
		return itemstack
	end
	return orig_func(itemstack, user, pointed_thing)
end
minetest.override_item("default:skeleton_key", {on_use = new_func})

function cars.setlighttexture(obj, table, prefix)
	if not obj or not table then return end
	local texture = "invisible.png"
	for index, val in pairs(table) do
		if val then
			texture = texture.."^"..prefix..index..".png"
		end
	end
	local prop = obj:get_properties()
	prop.textures[1] = texture
	obj:set_properties(prop)
	return texture
end

function cars.setlight(obj, light, val)
	if not obj then return end
	if obj[light] == val then return end
	if val == "toggle" then val = not obj[light] end
	if string.find(light, "blinker") then
		obj.leftblinker = false
		obj.rightblinker = false
	end
	if light == "headlights" or string.find(light, "blinker") then
		minetest.sound_play("lighton", {
			max_hear_distance = 6,
			gain = 1,
			object = light.object
		}, true)
	end
	if beamlight and light == "headlights" then
		if val then
				beamlight.beams[string.sub(tostring(obj), 8)] = {object = obj.object:get_attach(), x = 3}
		else
				beamlight.beams[string.sub(tostring(obj), 8)] = nil
		end
	end
	obj[light] = val
	obj.update = true
end

local function detach(player)
	if not player then return end
	local name = player:get_player_name()
	if not name then return end
	
	local attached = player_attached[name]
	if not attached then return end
	player_attached[name] = nil
	local i = 0
	while i <= #attached.passengers do
	i = i + 1
		if attached.passengers[i].player == player then
			attached.passengers[i].player = nil
			if i == 1 then player:hud_remove(attached.hud) end
			break
		end
	end
	player:set_detach()
	player:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
	default.player_attached[name] = false
	default.player_set_animation(player, "stand" , 30)
end

local function get_yaw(yaw)
	return math.atan2(math.sin(yaw), math.cos(yaw))
end

local function get_deg(yaw)
	yaw =  yaw % 360
	yaw = (yaw + 360) % 360
	if (yaw > 180) then
		yaw = yaw - 360
	end
	return yaw
end

local function get_velocity(v, yaw, velocity)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x = x, y = velocity.y, z = z}
end

local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

local function serializeContents(contents)
   if not contents then return "" end

   local tabs = {}
   for i, stack in ipairs(contents) do
      tabs[i] = stack and stack:to_table() or ""
   end

   return minetest.serialize(tabs)
end

local function deserializeContents(data)
   if not data or data == "" then return nil end
   local tabs = minetest.deserialize(data)
   if not tabs or type(tabs) ~= "table" then return nil end

   local contents = {}
   for i, tab in ipairs(tabs) do
      contents[i] = ItemStack(tab)
   end

   return contents
end

local charset = {}  do -- [A-Z]
    for c = 65, 90 do table.insert(charset, string.char(c)) end
end
local numset = {}  do -- [0-9]
    for c = 48, 57  do table.insert(numset, string.char(c)) end
end

local function randomString(length)
	local text = ""
	local i = 0
    if not length or length <= 0 then return text end
	while i < length do
		text = text..charset[math.random(1, #charset)]
		i = i + 1
	end
	return text
end

local function randomNumber(length)
	local text = ""
	local i = 0
    if not length or length <= 0 then return text end
	while i < length do
		text = text..numset[math.random(1, #numset)]
		i = i + 1
	end
	return text
end
local function wheelspeed(car)
	if not car then return end
	if not car.object then return end
	if not car.object:getvelocity() then return end
	if not car.wheel then return end
	local direction = 1
	if car.v then
		direction = get_sign(car.v)
	end
	local v = get_v(car.object:get_velocity())
	local fps = v*4
	for id, wheel in pairs(car.wheel) do
		wheel:set_animation({x=2, y=9}, fps*direction, 0, true)
	end
	car.object:set_animation({x=2, y=9}, fps*direction, 0, true)
	if v ~= 0 then
		local i = 16
		while true do
			if i/fps > 1 then i = i/2 else break end
		end
		minetest.after(i/fps, wheelspeed, car)
	end
end

local function rotateVector(x, y, a)
  local c = math.cos(a)
  local s = math.sin(a)
  return c*x - s*y, s*x + c*y
end

function car_formspec(clickername, owner, keyinvname, def)
    local form = "" ..
    "size[9,7]" ..
    "list[current_player;main;0.5,2.75;8,4.25;0]" ..
    "button[0.25,0.25;1,1;ignition;Ignition]" ..
    "list[detached:"..minetest.formspec_escape(keyinvname)..";key;1.25,0.25;1,1;0]" ..
    "button[0.25,1.5;1.5,1;headlights;Headlights]" ..
    "button[2,1.5;1.5,1;flashers;Flashers]"
    if def.siren then
		form = form.."button_exit[3.75,1.5;1.5,1;siren;Siren]"
	end
    if clickername == owner then
		form = form.."field[3,0.68;3,1;owner;Owner;"..minetest.formspec_escape(owner).."]" .."button_exit[5.5,0.35;2,1;changeowner;Change Owner]"
	else
		form = form.."label[3,0.5;Owner: "..owner.."]"
	end

    return form
end

function getClosest(player, car, distance)
	local def = cars_registered_cars[car.object:get_entity_name()]
	local playerPos = player:getpos()
	local dir = player:get_look_dir()
	playerPos.y = playerPos.y + 1.45
	local carPos = car.object:getpos()
	local offset, _ = player:get_eye_offset()
	local playeryaw = player:get_look_horizontal()
	local x, z = rotateVector(offset.x, offset.z, playeryaw)
	offset = vector.multiply({x=x, y=offset.y, z=z}, .1)
	if not player:get_attach() then playerPos = vector.add(playerPos, offset) end
		if DEBUG_WAYPOINT then 
			local marker = player:hud_add({
				hud_elem_type = "waypoint",
				name = "start",
				number = 0xFF0000,
				world_pos = playerPos
			})
			minetest.after(5, function() player:hud_remove(marker) end, player, marker)
		end
	local punchPos = vector.add(playerPos, vector.multiply(dir, distance or vector.distance(playerPos, carPos)))
	if minetest.raycast then
		local ray = minetest.raycast(playerPos, vector.add(playerPos, vector.multiply(dir, vector.distance(playerPos, carPos))))
		if ray then
			local pointed = ray:next()
			if pointed and pointed.ref == player then
				pointed = ray:next()
			end
			--minetest.chat_send_all(dump(pointed))
			--minetest.chat_send_all(tostring(pointed.ref))
			if pointed and (pointed.ref == car.object or (car.extension and pointed.ref == car.extension)) and pointed.intersection_point then
				punchPos = pointed.intersection_point
			end
		end
	end
	if not punchPos then return end
		if DEBUG_WAYPOINT then 
			local marker = player:hud_add({
				hud_elem_type = "waypoint",
				name = "end",
				number = 0xFF0000,
				world_pos = punchPos
			})
			minetest.after(5, function() player:hud_remove(marker) end, player, marker)
		end
	punchPos = vector.subtract(punchPos, carPos)
	local carYaw = get_yaw(car.object:get_yaw())
	local closest = {}
	closest.id = 0
	local trunkloc = def.trunkloc
	if trunkloc then
		local x, z = rotateVector(trunkloc.x, trunkloc.z, carYaw)
		trunkloc = vector.multiply({x=x, y=trunkloc.y, z=z}, .1)
		closest.distance = vector.distance(punchPos, trunkloc)
	end
		if DEBUG_WAYPOINT then 
			local marker = player:hud_add({
				hud_elem_type = "waypoint",
				name = "0",
				number = 0xFF0000,
				world_pos = vector.add(trunkloc, carPos)
			})
			minetest.after(5, function() player:hud_remove(marker) end, player, marker)
		end
	for id in pairs(car.passengers) do
		local loc = car.passengers[id].loc
		local x, z = rotateVector(loc.x, loc.z, carYaw)
		loc = vector.multiply({x=x, y=loc.y, z=z}, .1)
		if DEBUG_WAYPOINT then 
			local marker = player:hud_add({
				hud_elem_type = "waypoint",
				name = id,
				number = 0xFF0000,
				world_pos = vector.add(loc, carPos)
			})
			minetest.after(5, function() player:hud_remove(marker) end, player, marker)
		end
		local dis = vector.distance(punchPos, loc)
		if not closest.distance then
			closest.distance = dis
			closest.id = id
		elseif dis < closest.distance then closest.id = id closest.distance = dis end
	end
	return closest.id
end

local function turncaroff(car, lights)
	if not lights and car.lights then lights = car.lights:get_luaentity() end
	cars.setlight(lights, "leftblinker", false)
	cars.setlight(lights, "rightblinker", false)
	car.ignition = nil
end

local trunkplayer = {}
local function trunk_rightclick(self, clicker)
	local def = cars_registered_cars[self.object:get_entity_name()]
	local name = clicker:get_player_name()
	trunkplayer[name] = self
	local selfname = string.sub(tostring(self), 8)
	local inventory = minetest.create_detached_inventory("cars"..selfname, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			if self.object:get_luaentity() then
				return count
			else
				return 0
			end
		end,
		allow_put = function(inv, listname, index, stack, player)
			if self.object:get_luaentity() then
				return stack:get_count()
			else
				return 0
			end
		end,
		allow_take = function(inv, listname, index, stack, player)
			if self.object:get_luaentity() then
				return stack:get_count()
			else
				return 0
			end
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			self.trunkinv = inv:get_list("trunk")
		end,
		on_put = function(inv, listname, index, stack, player)
			self.trunkinv = inv:get_list("trunk")
		end,
		on_take = function(inv, listname, index, stack, player)
			self.trunkinv = inv:get_list("trunk")
		end,
	})
	local x = def.trunksize.x
	local y = def.trunksize.y
	local formx = x
	inventory:set_size("trunk", x * y)
	if x < 8 then formx = 8 end
	inventory:set_list("trunk", table.copy(self.trunkinv))
	local formspec =
           "size["..formx..","..5+y.."]"..
           "list[detached:cars"..selfname..";trunk;0,.5;"..x..","..y..";]"..
           "list[current_player;main;0,"..1+y..";8,4;]"
    minetest.show_formspec(name, "cars_trunk", formspec)
end

local function driver_rightclick(self, clicker)
	local def = cars_registered_cars[self.object:get_entity_name()]
	local name = clicker:get_player_name()
	local selfname = string.sub(tostring(self), 8)
	local inventory = minetest.create_detached_inventory("cars"..selfname, {
		on_put = function(inv, listname, index, stack, player)
			self.key = inv:contains_item("key", "default:key")
		end,
		on_take = function(inv, listname, index, stack, player)
			self.key = inv:contains_item("key", "default:key")
			if not self.key then turncaroff(self) end
		end,
        allow_put = function(inv, listname, index, stack, player)
			if stack:get_meta():get_string("secret") == self.secret then
				return 1
			else
				return 0
			end
		end,
		--todo: make it so only the right key can be put into the slot
	})
	inventory:set_size("key", 1)
	if self.key then
		local new_stack = ItemStack("default:key")
		local meta = new_stack:get_meta()
		meta:set_string("secret", self.secret)
		meta:set_string("description", string.format("Key to %s's %s", name, def.description))
		inventory:set_stack("key", 1, new_stack)
	end
	local formspec = car_formspec(name, self.owner or "", "cars"..selfname, def)
    minetest.show_formspec(name, "cars_driver", formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "cars_trunk" then
		if fields.quit then
			local name = player:get_player_name()
			if trunkplayer[name] then
				minetest.sound_play("closetrunk", {
					max_hear_distance = 24,
					gain = 1,
					object = trunkplayer[name].object
				}, true)
				trunkplayer[name] = nil
			end
		end
	elseif formname == "cars_driver" then
		local name = player:get_player_name()
		local car = player_attached[name]
		local def
		if car then
			def = cars_registered_cars[car.object:get_entity_name()]
		end
		if def and car.passengers[1].player == player then
			local obj
			if car.lights then obj = car.lights:get_luaentity() end
			if fields.ignition and car.key then
				if car.ignition then
					turncaroff(car, obj)
				else
					minetest.sound_play(def.ignitionsound, {
						max_hear_distance = 24,
						gain = 1,
						object = car.object
					}, true)
					minetest.after(.8, function(car) car.ignition = true end, car)
				end
			elseif fields.headlights then
				cars.setlight(obj, "headlights", "toggle")
			elseif fields.flashers then
				--cars.setlight(obj, "flashers", "toggle")
			elseif fields.siren and def.siren then
				car.siren = not car.siren
			elseif fields.changeowner and car.owner == name or car.owner == "" then
				car.owner = fields.owner
				minetest.chat_send_player(name, "Vehicle owner set to "..fields.owner)
			end
		end
	end
end)

local function car_step(self, dtime)
	if dtime > .2 then dtime = .2 end
	local def = cars_registered_cars[self.object:get_entity_name()]
	local velocity = self.object:getvelocity()
	local yaw = self.object:getyaw()
	if not yaw then return end
	local yaw = get_yaw(yaw)
	local slowing = false
	if not self.v then self.v = 0 end
	self.v = get_v(velocity) * get_sign(self.v)
	--local accel = 0--def.coasting*get_sign(self.v)
	local pos = self.object:getpos()
	if not velocity then return end
	if self.lastv then
		local newv = velocity
		if self.crash == nil then self.crash = false end
		local crash = false
		if math.abs(self.lastv.x) > 5 and newv.x == 0 then crash = true end
		if math.abs(self.lastv.y) > 10 and newv.y == 0 then crash = true end
		if math.abs(self.lastv.z) > 5 and newv.z == 0 then crash = true end
		--[[if crash then
		local start = {x=pos.x, y=pos.y+self.stepheight, z=pos.z}
		local finish = vector.add(start, vector.multiply(vector.normalize(self.lastv), 1))
		if minetest.raycast then
			local ray = minetest.raycast(start, finish)
			if ray then
				local pointed = ray:next()
				if pointed == self then
					pointed = ray:next()
				end
				--minetest.chat_send_all(dump(pointed.ref))
							minetest.add_particle({
				pos = finish,
				expirationtime = 10,
				size = 2,
				texture = "gunslinger_decal.png",
				vertical = true
			})
				if not pointed then crash = false end
			end
		else
			if minetest.get_node(finish).name == "air" then crash = false end
		end
		end--]]
		if crash and not self.crash then
			self.crash = true
			minetest.after(.5, function()
				self.crash = false
			end)
			minetest.sound_play("crash"..math.random(1,3), {
				max_hear_distance = 48,
				pitch = .7,
				gain = 10,
				object = self.object
			}, true)
			local checkpos = vector.add(pos, vector.multiply(vector.normalize(self.lastv), .8))
			local objects = minetest.get_objects_inside_radius(checkpos, 1)
			local dmg = ((vector.length(self.lastv)-4)/(20-4))*20
			--self.object:set_hp(self.object:get_hp()-dmg/2, "crash")
			self.object:punch(self.object, nil, {damage_groups={fleshy=dmg/2}})
			for _,obj in pairs(objects) do
				if obj:is_player() then
					for id, passengers in pairs (self.passengers) do
						if passengers.player == obj then goto next end
					end
					local puncher = self.passengers[1].player
					if not puncher then puncher = self.object end
					local name = obj:get_player_name()
					if default.player_attached[name] then
						dmg = dmg*.5
					elseif obj:is_player() then
						obj:add_player_velocity(self.lastv)
					end
					obj:punch(puncher, nil, {damage_groups={fleshy=dmg}})
					::next::
				end
			end
		end
	end
	local nodepos = pos
	local node = minetest.get_node(nodepos).name
	if node == "air" then
		nodepos.y = nodepos.y - 1
		node = minetest.get_node(nodepos).name
		if node == "air" then
			nodepos.y = nodepos.y - 1
			node = minetest.get_node(nodepos).name
			if node == "air" and math.abs(velocity.y) == 0 then
				node = "unknown"
			end
		end
	end
	local driver = self.passengers[1].player
	if driver and self.ignition then
		driver:hud_change(self.hud, "text", tostring(math.abs(rnd(self.v*2.23694, 10)).." MPH"))
		local ctrl = driver:get_player_control()
		local sign
		local lights
		if self.lights then lights = self.lights:get_luaentity() end
		if self.v == 0 then sign = 0 if self.cruise then self.cruise = nil end else sign = get_sign(self.v) end
		if self.lastctrl then
			if ctrl.sneak and not self.lastctrl.sneak then
				local lookdir = yaw-driver:get_look_horizontal()
				lookdir = math.deg(lookdir)
				lookdir = get_deg(lookdir)
				local vertlook =  math.deg(driver:get_look_vertical())
				if math.abs(vertlook) < 20 then
					if lookdir > 15 then
						cars.setlight(lights, "rightblinker", "toggle")
					elseif lookdir < -15 then
						cars.setlight(lights, "leftblinker", "toggle")
					else
						if self.v <= 0 or (self.cruise and math.abs(self.cruise - self.v) < .1) then
							self.cruise = nil
						else
							self.cruise = rnd(self.v*2.23694)/2.23694
							minetest.sound_play("lighton", {
								max_hear_distance = 6,
								gain = 1,
								object = self.object
							}, true)
						end
					end
				end
			end
		end
		--VELOCITY MOVEMENT
		local newv = self.v
		if ctrl.up then
			if sign >= 0 then
				newv = newv + def.acceleration*dtime
				cars.setlight(lights, "brakelights", false)
			else
				if self.cruise then self.cruise = nil end
				newv = newv + def.braking*dtime
				cars.setlight(lights, "brakelights", true)
				slowing = true
			end
		elseif ctrl.down then
			if self.cruise then self.cruise = nil end
			if sign <= 0 then
				newv = newv - def.acceleration*dtime
				cars.setlight(lights, "brakelights", false)
			else
				newv = newv - def.braking*dtime
				cars.setlight(lights, "brakelights", true)
				slowing = true
			end
		end
		if node ~= "air" then
			self.v = newv
		end
		if not ctrl.up and not ctrl.down and sign ~= 0 then
			if self.cruise and self.v < self.cruise and node ~= "air" then
				self.v = self.v + def.acceleration*dtime
				if self.v > self.cruise then self.v = self.cruise end
			else
				self.v = self.v - def.coasting*dtime*get_sign(self.v)
				cars.setlight(lights, "brakelights", false)
				slowing = true
			end
		end
		if get_sign(self.v) ~= sign and sign ~= 0 then
			self.v = 0
			cars.setlight(lights, "brakelights", false)
		end
		
		--ACCELERATION MOVEMENT
		--[[
		if ctrl.up then
			if sign >= 0 then
				accel = def.acceleration
			else
				accel = -def.braking
			end
		elseif ctrl.down then
			if sign <= 0 then
				accel = -def.acceleration
			else
				accel = def.braking
			end
		end
		if get_sign(self.v) ~= sign and sign ~= 0 or self.v < .1 then
			--accel = 0
		end
--]]
		local abs_v = math.abs(self.v)
		local maxwheelpos = 45*(8/(abs_v+8))
		local lastwheelpos = self.wheelpos
		if ctrl.left and self.wheelpos <= 0 then
			self.wheelpos = self.wheelpos-50*dtime*(4/(abs_v+4))
			if self.wheelpos < -1*maxwheelpos then
				self.wheelpos = -1*maxwheelpos
			end
		elseif ctrl.right and self.wheelpos >= 0 then
			self.wheelpos = self.wheelpos+50*dtime*(4/(abs_v+4))
			if self.wheelpos > maxwheelpos then
				self.wheelpos = maxwheelpos
			end
		else
			local sign = get_sign(self.wheelpos)
			
				self.wheelpos = self.wheelpos - 50*get_sign(self.wheelpos)*dtime
			if math.abs(self.wheelpos) < 5 or sign ~= get_sign(self.wheelpos) then
				self.wheelpos = 0
			end
		end
		if lights and (lights.leftblinker or lights.rightblinker) then
			if not self.maxwheelpos then self.maxwheelpos = self.wheelpos end
			if math.abs(self.wheelpos) > math.abs(self.maxwheelpos) then
				self.maxwheelpos = wheelpos
			end
			if (self.wheelpos == 0 and math.abs(self.maxwheelpos) > 15) then
				cars.setlight(lights, "leftblinker", false)
				cars.setlight(lights, "rightblinker", false)
			end
		else
			self.maxwheelpos = nil
		end
		if animateTimer >= .08 then
			self.wheel.frontright:set_attach(self.object, "", def.wheel.frontright, {x=0,y=self.wheelpos,z=0})
			self.wheel.frontleft:set_attach(self.object, "", def.wheel.frontleft, {x=0,y=self.wheelpos,z=0})
			
			self.object:set_bone_position("steering", def.steeringwheel, {x=0,y=0,z=-self.wheelpos*8})
		end
		if node ~= "air" then
			local axval = def.axisval or 10
			self.object:setyaw(yaw - ((self.wheelpos/axval)*(self.v/axval)*dtime))
		end

		if attachTimer >= 5 then
			if self.wheel.backright then self.wheel.backright:set_attach(self.object, "", {z=-11.75,y=2.5,x=-8.875}, {x=0,y=0,z=0}) end
			if self.wheel.backleft then self.wheel.backleft:set_attach(self.object, "", {z=-11.75,y=2.5,x=8.875}, {x=0,y=0,z=0}) end
			if self.lights then self.lights:set_attach(self.object, "", {x=0,y=0,x=0}, {x=0,y=0,z=0}) end
		end
		self.lastctrl = ctrl
	else
		self.lastctrl = nil
		if math.abs(self.wheelpos) > 0 then
			self.wheelpos = 0
			self.wheel.frontright:set_attach(self.object, "", def.wheel.frontright, {x=0,y=self.wheelpos,z=0})
			self.wheel.frontleft:set_attach(self.object, "", def.wheel.frontleft, {x=0,y=self.wheelpos,z=0})
			if self.steeringwheel then self.steeringwheel:set_attach(self.object, "", def.steeringwheel, {x=0,y=0,z=-self.wheelpos*8}) end
			--self.object:setyaw(yaw - ((self.wheelpos/8)*(self.v/8)*dtime))
		end
		local sign
		if self.v == 0 then sign = 0 else sign = get_sign(self.v) end
		if sign ~= 0 then
			self.v = self.v - def.coasting*dtime*sign
			if get_sign(self.v) ~= sign then
				self.v = 0
			end
		end
	end
	for id, passengers in pairs (self.passengers) do
		local player = passengers.player
		if player then
			local playeryaw = player:get_look_horizontal()
			local offset = table.copy(passengers.offset)
			local x, z = rotateVector(offset.x, offset.z, yaw-playeryaw)
			offset.x = x
			offset.z = z
			player:set_eye_offset(offset, {x=0,y=10,z=-5})
		end
	end
	
	if attachTimer >= 5 and false then --CHANGE BACK, REMOVE 'AND FALSE'
		for id, passengers in pairs (self.passengers) do
			local player = passengers.player
			if player then
				player:set_attach(self.object, "",
					passengers.loc, {x = 0, y = 0, z = 0})
			end
		end
	end
	if self.v > def.max_speed then
		self.v = def.max_speed
	elseif self.v < -1*def.max_speed/2 then
		self.v = -1*def.max_speed/2
	end
	if node ~= "air" and math.abs(self.v) > 1 and minetest.get_item_group(node, "water") > 0 then
		self.v = 1*get_sign(self.v)
	end
	local new_velo
	--local yaw = self.object:getyaw()
	yaw = yaw - self.wheelpos/57.32
	new_velo = get_velocity(self.v, yaw, velocity)
	self.object:setvelocity(new_velo)
	--ACCELERATION TEST
	--[[if accel ~= 0 then
		self.object:setacceleration(get_velocity(accel, self.object:getyaw(), {y=-10}))
	end--]]
	if math.abs(self.v) < .05 and math.abs(self.v) > 0 then
		self.object:setvelocity({x = 0, y = 0, z = 0})
		self.v = 0
		cars.setlight(lights, "brakelights", false)
		if self.wheelsound then
			minetest.sound_stop(self.wheelsound)
		end
		if self.windsound then
			minetest.sound_fade(self.windsound, .1, 0)
		end
		wheelspeed(self)
		return
	end
	if self.lastv and vector.length(self.lastv) == 0 and math.abs(self.v) > 0 then
		wheelspeed(self)
	end
	--[[set acceleration for replication
	if self.lastv then
		local accel = vector.subtract(self.lastv, new_velo)
		if self.v < 1 then
			accel = {x=0,y=0,z=0}
		end
		accel = vector.multiply(accel, 20)
		accel.y = -10
		self.object:setacceleration(accel)
	end--]]
	self.lastv = new_velo
	
	--sound
	local abs_v = math.abs(self.v)
	--if abs_v > 0 and driver ~= nil then
	if self.ignition then
		self.timer1 = self.timer1 + dtime
		local rpm = 1
		for i, tab in pairs(def.rpmvalues) do
				if abs_v >= tab[1] then
					rpm = abs_v/tab[2]+tab[3]
					break
				end
		end
		pitch = rpm+.2
		if self.timer1 > .2/pitch-.05 then
				local gain = pitch
				if slowing or abs_v == 0 then
					gain = .2
				end
				if abs_v == 0 then
					gain = .15
				end
				minetest.sound_play(def.enginesound, {
					max_hear_distance = 48*gain,
					pitch = pitch,
					object = self.object,
					gain = gain,
				}, true)
			self.timer1 = 0
		end
	end
	self.timer2 = self.timer2 + dtime
	local pitch = 1 + (abs_v/def.max_speed)*.6
	if self.timer2 > 2/pitch-.5 then
		if abs_v > .2 then
			if node ~= "air" then
				if string.find(node, "asphalt") then
					self.wheelsound = minetest.sound_play("tyresound-asphaltfade", {
						max_hear_distance = 48,
						object = self.object,
						pitch = pitch,
						gain = (abs_v/def.max_speed)*.2
					})
				else
					self.wheelsound = minetest.sound_play("tyresound-gravelfade", {
						max_hear_distance = 48,
						object = self.object,
						pitch = pitch,
						gain = .5 + (abs_v/def.max_speed)*2
					})

				
				end
			elseif self.wheelsound then
				minetest.sound_stop(self.wheelsound)
			end
			--[[self.windsound = minetest.sound_play("wind", {
				max_hear_distance = 10,
				object = self.object,
				pitch = 1 + (abs_v/def.max_speed)*.6,
				gain = 0 + (abs_v/def.max_speed)*4
			})--]]
		end
		self.timer2 = 0
	end
end

function car_rightclick(self, clicker, closeid)
	if self.locked then return end
	if not clicker or not clicker:is_player() then
		return
	end
	local name = clicker:get_player_name()
	if player_attached[name] and player_attached[name] ~= self then
		return
	else
		local i = 0
		if not closeid then closeid = getClosest(clicker, self) end
		--knockout support
		if knockout then
			local Cname = knockout.carrying[name]
			if Cname and minetest.get_player_by_name(Cname) and (knockout.downedplayers and not knockout.downedplayers[Cname]) then
				knockout.wake_up(Cname)
				minetest.after(.1, function() car_rightclick(self, minetest.get_player_by_name(Cname), closeid) end)
				return
			end
		end
		if DEBUG_TEXT then
			minetest.chat_send_all(tostring(closeid))
		end
		if closeid then
			if closeid == 0 then
				minetest.sound_play("opentrunk", {
					max_hear_distance = 24,
					gain = 1,
					object = self.object
				}, true)
				trunk_rightclick(self, clicker)
				return
			end
			if self.passengers[closeid].player == clicker then
				if closeid == 1 and clicker:get_player_control().sneak then
					driver_rightclick(self, clicker)
				else
					detach(clicker)
				end
				return
			end
			if not self.passengers[closeid].player then
				i = closeid
			end
		else
			while i <= #self.passengers do
				i = i + 1
				if not self.passengers[i].player then break end
			end
		end
	if i == 0 or i == #self.passengers+1 then return end
	if player_attached[name] == self then
		detach(clicker)
		if not clicker:get_player_control().sneak then
			return
		end
	end
	self.passengers[i].player = clicker
		--add hud for driver
		if i == 1 then
			self.hud = clicker:hud_add({
				 hud_elem_type = "text",
				 position      = {x = 0.5, y = 0.8},
				 offset        = {x = 0,   y = 0},
				 text          = tostring(math.abs(math.floor(self.v*2.23694*10)/10)).." MPH",
				 alignment     = {x = 0, y = 0},  -- center aligned
				 scale         = {x = 100, y = 100}, -- covered later
				 number    = 0xFFFFFF,
			})
		end
		
		player_attached[name] = self
		--[[local obj = minetest.add_entity(self.object:getpos(), "cars:seat")
		obj:set_attach(self.object, "", self.passengers[i].loc, {x = 0, y = 0, z = 0})
		clicker:set_attach(obj, "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
		clicker:set_eye_offset({x=0,y=-6,z=0}, {x=0,y=0,z=0})--]]
		clicker:set_attach(self.object, "",
			self.passengers[i].loc, self.passengers[i].rot or {x = 0, y = 0, z = 0})
		clicker:set_eye_offset(self.passengers[i].offset, {x=0,y=0,z=0})
		default.player_attached[name] = true
		minetest.after(.1, function()
			default.player_set_animation(clicker, "sit" , 30)
		end)
		clicker:set_look_horizontal(get_yaw(self.object:getyaw()))
	end
end

cars_registered_cars = {}
function cars_register_car(def)
	cars_registered_cars[def.name] = def
	minetest.register_entity(def.name, {
		initial_properties = def.initial_properties,
		trunkinv = {},
		key = true,
		owner = "",
		on_activate = function(self, staticdata)
			if not self.wheelpos then self.wheelpos = 0 end
			if not self.timer1 then self.timer1 = 0 end
			if not self.timer2 then self.timer2 = 0 end
			if not self.hp then self.hp = 20 end
			if not self.platenumber then
				self.platenumber = {}
			end
			self.passengers = table.copy(def.passengers)
			if staticdata then
				local deserialized = minetest.deserialize(staticdata)
				if deserialized then
					self.owner = deserialized.owner or ""
					self.secret = deserialized.secret
					self.locked = deserialized.locked
					self.trunkinv = deserializeContents(deserialized.trunk)
					self.key = deserialized.key
					self.hp = deserialized.hp or 20
					if deserialized.plate then
						self.platenumber.text = deserialized.plate.text
					end
				elseif minetest.get_player_by_name(staticdata) then
					self.owner = staticdata
				end
			end
			if not self.secret then
				local random = math.random
				self.secret = string.format(
					"%04x%04x%04x%04x",
					random(2^16) - 1, random(2^16) - 1,
					random(2^16) - 1, random(2^16) - 1)
			end
			if not self.platenumber.text or self.platenumber.text == "" then self.platenumber.text = randomNumber(3).."-"..randomString(3) end
			if font_api then
				local textTex = font_api.get_font("04b03"):render(self.platenumber.text, 6*7, 8, {maxlines = 1, halign = 'center', valign = 'center'}) --42x8
				local prop = self.object:get_properties()
				prop.textures[1] = prop.textures[1].."^"..textTex
				self.object:set_properties(prop)
			end
			self.object:setacceleration({x=0, y=-10, z=0})
			--self.object:set_armor_groups({immortal = 1})
			self.wheel = {}
			wheelspeed(self)
			local pos = self.object:getpos()
			for index, wheel in pairs(def.wheel) do
				if not self.wheel[index] then
					self.wheel[index] = minetest.add_entity(pos, def.wheelname or "cars:wheel")
				end
				if self.wheel[index] then
					self.wheel[index]:set_attach(self.object, "", wheel, {x=0,y=0,z=0})
				end
			end
			if not self.lights and def.lights then
				self.lights = minetest.add_entity(pos, def.lights)
			end
			if self.lights then
				self.lights:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
			end
			if def.extension and def.extensionname and not self.extension then
				self.extension = minetest.add_entity(pos, def.extensionname)
			end
			if self.extension then
				self.extension:set_attach(self.object, "", def.extension, {x=0,y=0,z=0})
			end
			self.object:set_hp(self.hp)
		end,
		get_staticdata = function(self)
			return minetest.serialize({owner = self.owner, trunk = serializeContents(self.trunkinv), secret = self.secret, locked = self.locked, key = self.key, plate = self.platenumber, hp = self.hp})
		end,
		on_step = function(self, dtime)
			car_step(self, dtime)
		end,
		on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
			if puncher ~= self.object then
				local name = puncher:get_player_name()
				if puncher == self.passengers[1].player then
					minetest.sound_play(def.horn, {
						max_hear_distance = 48,
						gain = 8,
						object = self.object
					}, true)
					return true
				end
				local punchitem = puncher:get_wielded_item():get_name()
				if (punchitem == "") and (time_from_last_punch >= tool_capabilities.full_punch_interval) and math.random(1,2) == 1 then
					local closeid = getClosest(puncher, self)
					if DEBUG_TEXT then
						minetest.chat_send_all(tostring(closeid))
					end
					if not closeid or closeid == 0 then return true end
					if self.passengers[closeid].player then
						detach(self.passengers[closeid].player)
					elseif cuffedplayers then
						local pos = self.object:get_pos()
						for name, val in pairs (cuffedplayers) do
							local player = minetest.get_player_by_name(name)
							if player and vector.distance(player:get_pos(), pos) < 2 then
								car_rightclick(self, player, closeid)
								break
							end
						end
					end
				elseif punchitem == "default:key" then
					local secret = puncher:get_wielded_item():get_meta():get_string("secret")
					if self.secret == secret then
						self.locked = not self.locked
						minetest.sound_play("lock", {
							max_hear_distance = 6,
							gain = 1,
							object = self.object
						}, true)
					end
				elseif punchitem == "default:skeleton_key" and self.owner == name then
					local inv = minetest.get_inventory({type="player", name=name})
					-- update original itemstack
					local wieldstack = puncher:get_wielded_item()
					wieldstack:take_item()
					-- finish and return the new key
					local new_stack = ItemStack("default:key")
					local meta = new_stack:get_meta()
					meta:set_string("secret", self.secret)
					meta:set_string("description", string.format("Key to %s's %s", name, def.description))

					if wieldstack:get_count() == 0 then
						wieldstack = new_stack
					else
						if inv:add_item("main", new_stack):get_count() > 0 then
							minetest.add_item(user:get_pos(), new_stack)
						end -- else: added to inventory successfully
					end
					minetest.after(0, function() puncher:set_wielded_item(wieldstack) end)
				elseif player_attached[name] ~= self then
					--minetest.chat_send_all("ow")
					return true
				else
					return true
				end
			end
			local hp = self.object:get_hp() - tool_capabilities.damage_groups.fleshy
			self.hp = hp
			if hp <= 0 then
				for id, wheel in pairs(self.wheel) do
					wheel:remove()
				end
				--todo remove all children
				for id, passengers in pairs (self.passengers) do
					local player = passengers.player
					if player then
						detach(player)
					end
				end
			end
		end,
		on_rightclick = function(self, clicker)
			car_rightclick(self, clicker)
		end
	})
	minetest.register_craftitem(def.name, {
		description = def.description,
		inventory_image = def.inventory_image,
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return
			end
			local ent
			if minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "liquid") == 0 then
				pointed_thing.above.y = pointed_thing.above.y - 0.5
				ent = minetest.add_entity(pointed_thing.above, def.name, placer:get_player_name())
			end
			ent:setyaw(placer:get_look_yaw() - math.pi/2)
			itemstack:take_item()
			return itemstack
		end
	})
	if def.recipe then
		minetest.register_craft({
			output = def.name,
			recipe = def.recipe
		})
	end
end
	
minetest.register_entity("cars:wheel", {
    hp_max = 1,
    physical = false,
	pointable = false,
	collide_with_objects = false,
    weight = 5,
    collisionbox = {-0.2,-0.2,-0.2, 0.2,0.2,0.2},
    visual = "mesh",
    visual_size = {x=1, y=1},
    mesh = "wheel.x",
    textures = {"car_dark_grey.png"}, -- number of required textures depends on visual
    is_visible = true,
    --makes_footstep_sound = false,
    --automatic_rotate = true,
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(.1, function()
			if not self.object:get_attach() then
				self.object:remove()
			end
		end)
	end,
})

minetest.register_on_leaveplayer(function(player)
	detach(player)
end)
minetest.register_on_dieplayer(function(player)
	detach(player)
end)

dofile(minetest.get_modpath("cars").."/car01.lua")
dofile(minetest.get_modpath("cars").."/newcars.lua")
local go = false
local DEBUG_WAYPOINT = false
local DEBUG_TEXT = false
local max_speed = 20
local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
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
	local sign = get_sign(yaw)
	local newyaw = math.abs(yaw)
	while newyaw > math.pi do
		newyaw = newyaw - math.pi
	end
	return newyaw*sign
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

local function getClosest(player, car)
	local playerPos = player:getpos()
	local dir = player:get_look_dir()
	playerPos.y = playerPos.y + 1.45
	local carPos = car.object:getpos()
	local offset, _ = player:get_eye_offset()
	local playeryaw = player:get_look_horizontal()
	local x, z = rotateVector(offset.x, offset.z, playeryaw)
	offset = vector.multiply({x=x, y=offset.y, z=z}, .1)
	playerPos = vector.add(playerPos, offset)
		if DEBUG_WAYPOINT then 
			local marker = player:hud_add({
				hud_elem_type = "waypoint",
				name = "start",
				number = 0xFF0000,
				world_pos = playerPos
			})
			minetest.after(5, function() player:hud_remove(marker) end, player, marker)
		end
	local punchPos = vector.add(playerPos, vector.multiply(dir, vector.distance(playerPos, carPos)))
	if minetest.raycast then
		local ray = minetest.raycast(playerPos, vector.add(playerPos, vector.multiply(dir, vector.distance(playerPos, carPos))))
		if ray then
			local pointed = ray:next()
			if pointed and pointed.ref == player then
				pointed = ray:next()
			end
			if pointed and pointed.ref == car.object and pointed.intersection_point then
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
	local carYaw = car.object:getyaw()
	local closest = {}
	closest.id = 0
	local trunkloc = car.trunkloc or {x = 0, y = 4, z = -8}
	local x, z = rotateVector(trunkloc.x, trunkloc.z, carYaw)
	trunkloc = vector.multiply({x=x, y=trunkloc.y, z=z}, .1)
	closest.distance = vector.distance(punchPos, trunkloc)
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
		if dis < closest.distance then closest.id = id closest.distance = dis end
	end
	return closest.id
end

local trunkplayer = {}
local function trunk_rightclick(self, clicker)
	local name = clicker:get_player_name()
	trunkplayer[name] = self
	local inventory = minetest.create_detached_inventory("cars_"..name, {
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
	inventory:set_size("trunk", 12)
	local templist = table.copy(self.trunkinv)
	inventory:set_list("trunk", templist)
	local formspec =
           "size[8,8]"..
           "list[detached:cars_"..name..";trunk;1,1;6,2;]"..
           "list[current_player;main;0,4;8,4;]"
    minetest.show_formspec(name, "cars_trunk", formspec)
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
				})
				trunkplayer[name] = nil
			end
		end
	end
end)

local function car_step(self, dtime)
	if not self.v then self.v = 0 end
	self.v = get_v(self.object:getvelocity()) * get_sign(self.v)
	local pos = self.object:getpos()
	if self.lastv then
		local newv = self.object:getvelocity()
		if not self.crash then self.crash = false end
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
			})
			local checkpos = vector.add(pos, vector.multiply(vector.normalize(self.lastv), .8))
			local objects = minetest.get_objects_inside_radius(checkpos, 1)
			for _,obj in pairs(objects) do
				if obj:is_player() then
					for id, passengers in pairs (self.passengers) do
						if passengers.player == obj then goto next end
					end
					local puncher = self.passengers[1].player
					if not puncher then puncher = self.object end
					local dmg = ((vector.length(self.lastv)-4)/(20-4))*20
					local name = obj:get_player_name()
					if default.player_attached[name] then dmg = dmg*.5 end
					obj:punch(puncher, nil, {damage_groups={fleshy=dmg}})
					::next::
				end
			end
		end
	end
	local driver = self.passengers[1].player
	if driver then
		driver:hud_change(self.hud, "text", tostring(math.abs(math.floor(self.v*2.23694*10)/10)).." MPH")
		local ctrl = driver:get_player_control()
		local yaw = self.object:getyaw()
		local sign
		if self.v == 0 then sign = 0 else sign = get_sign(self.v) end
		if ctrl.up then
			if sign >= 0 then
				self.v = self.v + 4*dtime
			else
				self.v = self.v + 10*dtime
			end
		elseif ctrl.down then
			if sign <= 0 then
				self.v = self.v - 4*dtime
			else
				self.v = self.v - 10*dtime
			end
		elseif sign ~= 0 then
			self.v = self.v - 2*dtime*get_sign(self.v)
		end
		if get_sign(self.v) ~= sign and sign ~= 0 then
			self.v = 0
		end
		
		local abs_v = math.abs(self.v)
		local maxwheelpos = 45*(8/(abs_v+8))
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
			
				self.wheelpos = self.wheelpos - 100*get_sign(self.wheelpos)*dtime
			if math.abs(self.wheelpos) < 5 or sign ~= get_sign(self.wheelpos) then
				self.wheelpos = 0
			end
		end
		if animateTimer >= .08 then
			self.wheel.frontright:set_attach(self.object, "", {z=10.75,y=2.5,x=-8.875}, {x=0,y=self.wheelpos,z=0})
			self.wheel.frontleft:set_attach(self.object, "", {z=10.75,y=2.5,x=8.875}, {x=0,y=self.wheelpos,z=0})
			self.steeringwheel:set_attach(self.object, "", {z=5.62706,y=8.25,x=-4.0}, {x=0,y=0,z=-self.wheelpos*8})
		end
		self.object:setyaw(yaw - ((self.wheelpos/8)*(self.v/8)*dtime))

		if attachTimer >= 5 then
			self.licenseplate:set_attach(self.object, "", {x = -.38, y = -0.85, z = -15.51}, {x = 0, y = 0, z = 0})
			self.wheel.backright:set_attach(self.object, "", {z=-11.75,y=2.5,x=-8.875}, {x=0,y=0,z=0})
			self.wheel.backleft:set_attach(self.object, "", {z=-11.75,y=2.5,x=8.875}, {x=0,y=0,z=0})
		end

	else
		if math.abs(self.wheelpos) > 0 then
			local yaw = self.object:getyaw()
			self.wheelpos = 0
			self.wheel.frontright:set_attach(self.object, "", {z=10.75,y=2.5,x=-8.875}, {x=0,y=self.wheelpos,z=0})
			self.wheel.frontleft:set_attach(self.object, "", {z=10.75,y=2.5,x=8.875}, {x=0,y=self.wheelpos,z=0})
			self.steeringwheel:set_attach(self.object, "", {z=5.62706,y=8.25,x=-4.0}, {x=0,y=0,z=-self.wheelpos*8})
			self.object:setyaw(yaw - ((self.wheelpos/8)*(self.v/8)*dtime))
		end
		local sign
		if self.v == 0 then sign = 0 else sign = get_sign(self.v) end
		if sign ~= 0 then
			self.v = self.v - 2*dtime*get_sign(self.v)
			if get_sign(self.v) ~= sign then
				self.v = 0
			end
		end
	end
	
	if attachTimer >= 5 then
		for id, passengers in pairs (self.passengers) do
			local player = passengers.player
			if player then
				player:set_attach(self.object, "",
					passengers.loc, {x = 0, y = 0, z = 0})
			end
		end
	end
	if self.v > max_speed then
		self.v = max_speed
	elseif self.v < -1*max_speed/2 then
		self.v = -1*max_speed/2
	end
	if math.abs(self.v) > 1 and minetest.get_item_group(minetest.get_node(pos).name, "water") > 0 then
		self.v = 1*get_sign(self.v)
	end
	local new_velo
	local velocity = self.object:getvelocity()
	new_velo = get_velocity(self.v, self.object:getyaw(), velocity)
	self.object:setvelocity(new_velo)
	
	if math.abs(self.v) < .05 and math.abs(self.v) > 0 then
		self.object:setvelocity({x = 0, y = 0, z = 0})
		self.v = 0
		if self.wheelsound then
			minetest.sound_fade(self.wheelsound, 30, 0)
		end
		if self.windsound then
			minetest.sound_fade(self.windsound, 30, 0)
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
	if abs_v > 0 and driver ~= nil then
		self.timer1 = self.timer1 + dtime
		if self.timer1 > .1 then
			--if driver:get_player_control().up then
				local rpm = 1
				if abs_v > 16 then
					rpm = abs_v/16+.5
				elseif abs_v > 10 then
					rpm = abs_v/10+.4
				else
					rpm = abs_v/5+.3
				end
				minetest.sound_play("longerenginefaded", {
					max_hear_distance = 48,
					pitch = rpm+.1,
					object = self.object
				})
			--[[else
				minetest.sound_play("longerenginefaded", {
					max_hear_distance = 48,
					object = self.object
				})
			--end--]]
		self.timer1 = 0
		end
	end
	self.timer2 = self.timer2 + dtime
	if self.timer2 > 1.5-self.v/max_speed*1.1 then
		if math.abs(self.v) > .2 then
			if math.abs(velocity.y) < .1 then 
				self.wheelsound = minetest.sound_play("tyresound", {
					max_hear_distance = 48,
					object = self.object,
					pitch = 1 + (self.v/max_speed)*.6,
					gain = .5 + (self.v/max_speed)*2
				})
			elseif self.windsound then
				minetest.sound_fade(self.windsound, 30, 0)
			end
			self.windsound = minetest.sound_play("wind", {
				max_hear_distance = 10,
				object = self.object,
				pitch = 1 + (self.v/max_speed)*.6,
				gain = 0 + (self.v/max_speed)*4
			})
		end
		self.timer2 = 0
	end
end

local carlist = {"black", "blue", "brown", "cyan", 
"dark_green", "dark_grey", "green", "grey", "magenta", 
"orange", "pink", "red", "violet", "white", "yellow"}

for id, color in pairs (carlist) do
	minetest.register_entity("cars:car_"..color, {
		hp_max = 1,
		physical = true,
		stepheight = 1.1,
		weight = 5,
		collisionbox = {-0.6, -0.05, -0.6, 0.6, 1.1, 0.6},
		visual = "mesh",
		visual_size = {x=1, y=1},
		mesh = "car.x",
		textures = {"car_"..color..".png^licenseplate.png"}, -- number of required textures depends on visual
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = false,
		trunkinv = {},
		on_activate = function(self, staticdata)
			if not self.wheelpos then self.wheelpos = 0 end
			if not self.timer1 then self.timer1 = 0 end
			if not self.timer2 then self.timer2 = 0 end
			if not self.platenumber then
				self.platenumber = {}
			end
			self.passengers = {
				{loc = {x = -4, y = 3, z = 3}, offset = {x = -4, y = -2, z = 2} },
				{loc = {x = 4, y = 3, z = 3}, offset = {x = 4, y = -2, z = 2} },
				{loc = {x = -4, y = 3, z = -4}, offset = {x = -4, y = -2, z = -2} },
				{loc = {x = 4, y = 3, z = -4}, offset = {x = 4, y = -2, z = -2} },
			}
			if staticdata then
				local deserialized = minetest.deserialize(staticdata)
				if deserialized then
					self.trunkinv = deserializeContents(deserialized.trunk)
					if deserialized.plate then
						self.platenumber.text = deserialized.plate.text
					end
				end
			end
			if not self.platenumber.text or self.platenumber.text == "" then self.platenumber.text = randomNumber(3).."-"..randomString(3) end
			
			self.object:setacceleration({x=0, y=-10, z=0})
			self.object:set_armor_groups({immortal = 1})
			self.wheel = {}
			wheelspeed(self)
			local pos = self.object:getpos()
			if not self.wheel.frontright then
				self.wheel.frontright = minetest.add_entity(pos, "cars:wheel")
			end
			if self.wheel.frontright then
				self.wheel.frontright:set_attach(self.object, "", {z=10.75,y=2.5,x=-8.875}, {x=0,y=0,z=0})
			end
			if not self.wheel.frontleft then
				self.wheel.frontleft = minetest.add_entity(pos, "cars:wheel")
			end
			if self.wheel.frontleft then
				self.wheel.frontleft:set_attach(self.object, "", {z=10.75,y=2.5,x=8.875}, {x=0,y=0,z=0})
			end
			if not self.wheel.backright then
				self.wheel.backright = minetest.add_entity(pos, "cars:wheel")
			end
			if self.wheel.backright then
				self.wheel.backright:set_attach(self.object, "", {z=-11.75,y=2.5,x=-8.875}, {x=0,y=0,z=0})
			end
			if not self.wheel.backleft then
				self.wheel.backleft = minetest.add_entity(pos, "cars:wheel")
			end
			if self.wheel.backleft then
				self.wheel.backleft:set_attach(self.object, "", {z=-11.75,y=2.5,x=8.875}, {x=0,y=0,z=0})
			end
			if not self.steeringwheel then
				self.steeringwheel = minetest.add_entity(pos, "cars:steeringwheel")
			end
			if self.steeringwheel then
				self.steeringwheel:set_attach(self.object, "", {z=5.62706,y=8.25,x=-4.0}, {x=0,y=0,z=0})
			end
			--[[if not self.driverseat then
				self.driverseat = minetest.add_entity(pos, "cars:seat")
			end
			if self.driverseat then
				self.driverseat:set_attach(self.object, "", {x = -4, y = 3, z = 3}, {x = 0, y = 0, z = 0})
			end--]]
			if not self.licenseplate and minetest.get_modpath("signs") ~= nil then
				self.licenseplate = minetest.add_entity(pos, "cars:licenseplate")
			end
			if self.licenseplate then
				self.licenseplate:set_attach(self.object, "", {x = -.38, y = -0.85, z = -15.51}, {x = 0, y = 0, z = 0})
			end
		end,
		get_staticdata = function(self)
			return minetest.serialize({trunk = serializeContents(self.trunkinv), plate = self.platenumber})
		end,
		on_step = function(self, dtime)
			car_step(self, dtime)
		end,
		on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
			if puncher == self.passengers[1].player then
				minetest.sound_play("horn", {
					max_hear_distance = 48,
					gain = 8,
					object = self.object
				})
				return
			end
			if (puncher:get_wielded_item():get_name() == "") and (time_from_last_punch >= tool_capabilities.full_punch_interval) and math.random(1,2) == 1 then
				local closeid = getClosest(puncher, self)
				if DEBUG_TEXT then
					minetest.chat_send_all(tostring(closeid))
				end
				if not closeid or closeid == 0 then return end
				detach(self.passengers[closeid].player)
			end
		end,
		on_rightclick = function(self, clicker)
			if not clicker or not clicker:is_player() then
				return
			end
			local name = clicker:get_player_name()
			if player_attached[name] == self then
				detach(clicker)
			elseif player_attached[name] then
				return
			else
				local i = 0
				local closeid = getClosest(clicker, self)
				if DEBUG_TEXT then
					minetest.chat_send_all(tostring(closeid))
				end
				if closeid then
					if closeid == 0 then
						minetest.sound_play("opentrunk", {
							max_hear_distance = 24,
							gain = 1,
							object = self.object
						})
						trunk_rightclick(self, clicker)
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
				clicker:set_attach(self.object, "",
					self.passengers[i].loc, {x = 0, y = 0, z = 0})
				clicker:set_eye_offset(self.passengers[i].offset, {x=0,y=0,z=0})
				default.player_attached[name] = true
				minetest.after(.1, function()
					default.player_set_animation(clicker, "sit" , 30)
				end)
				clicker:set_look_horizontal(self.object:getyaw())
			end
		end
	})
	minetest.register_craftitem("cars:car_"..color, {
		description = color:gsub("^%l", string.upper):gsub("_", " ").." car",
		inventory_image = "inv_car_"..color..".png",
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return
			end
			local ent
			if minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "liquid") == 0 then
				pointed_thing.above.y = pointed_thing.above.y - 0.5
				ent = minetest.add_entity(pointed_thing.above, "cars:car_"..color)				
			end
			ent:setyaw(placer:get_look_yaw() - math.pi/2)
			itemstack:take_item()
			return itemstack
		end
	})
	--minetest.register_alias("cars:car_"..color, "vehicle_mash:car_"..color)
	minetest.register_craft({
	output = "cars:car_"..color,
	recipe = {
		{"default:steel_ingot", "wool:"..color, "default:steel_ingot"},
		{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"}
	}
	})
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
minetest.register_entity("cars:licenseplate", {
    collisionbox = { 0, 0, 0, 0, 0, 0 },
    visual = "upright_sprite",
    textures = {"invisible.png"},
	visual_size = {x=1.2, y=1.2, z=1.2},
	physical = false,
	pointable = false,
	collide_with_objects = false,
    on_activate = function(self)
		minetest.after(.1, function()
			if not self.object:get_attach() or minetest.get_modpath("signs") == nil then
				self.object:remove()
			else
				self.object:set_armor_groups({immortal = 1})
				local text = self.object:get_attach():get_luaentity().platenumber.text
				if not text then return end
				self.object:set_properties({textures={generate_texture(create_lines(text))}})
			end
		end)
    end
})
minetest.register_entity("cars:steeringwheel", {
    hp_max = 1,
    physical = false,
	pointable = false,
	collide_with_objects = false,
    weight = 5,
    collisionbox = {-0.2,-0.3,-0.2, 0.2,0.3,0.2},
    visual = "mesh",
    visual_size = {x=1, y=1},
    mesh = "steering.x",
    textures = {"car_dark_grey.png"}, -- number of required textures depends on visual
    is_visible = true,
    --makes_footstep_sound = false,
    --automatic_rotate = true,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		minetest.sound_play("horn", {
			max_hear_distance = 48,
			gain = 8,
			object = self.object
		})
	end,
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(.1, function()
			if not self.object:get_attach() then
				self.object:remove()
			else
				self.object:set_armor_groups({immortal = 1})
			end
		end)
	end,
})

minetest.register_entity("cars:trunk", {
	on_activate = function(self, staticdata, dtime_s)
		self.object:remove()
	end
})
minetest.register_on_leaveplayer(function(player)
	detach(player)
end)
minetest.register_on_dieplayer(function(player)
	detach(player)
end)

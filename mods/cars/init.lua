local go = false
local max_speed = 20
local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
end

local player_attached = {}

local function detach(player)
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

local function wheelspeed(car, forced)
	if not car then return end
	if not car.object then return end
	if not car.object:getvelocity() then return end
	local direction = 1
	if car.v then
		direction = get_sign(car.v)
	end
	local v = get_v(car.object:get_velocity())
	local fps = v*4
	for id, wheel in pairs(car.wheel) do
		wheel:set_animation({x=2, y=9}, fps*direction, 0, true)
	end
	if not forced then
		if v == 0 then
			minetest.after(1, wheelspeed, car, false)
		else
			local i = 8
			if i/fps > 1 then i = i/2 end
			if i/fps > 1 then i = i/2 end
			minetest.after(i/fps, wheelspeed, car, false)
		end
	end
end

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
			minetest.after(.1, function()
				self.crash = false
			end)
			minetest.sound_play("crash"..math.random(1,3), {
				max_hear_distance = 48,
				pitch = .7,
				gain = 10,
				object = self.object
			})
		end
	end
	local driver = self.passengers[1].player
	if driver then
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
		self.wheel.frontright:set_attach(self.object, "", {z=10.75,y=2.5,x=-8.875}, {x=0,y=self.wheelpos,z=0})
		self.wheel.frontleft:set_attach(self.object, "", {z=10.75,y=2.5,x=8.875}, {x=0,y=self.wheelpos,z=0})
		self.steeringwheel:set_attach(self.object, "", {z=5.62706,y=8.25,x=-4.0}, {x=0,y=0,z=-self.wheelpos*8})
		self.object:setyaw(yaw - ((self.wheelpos/8)*(self.v/8)*dtime))
		
		--self.trunk:set_detach()
		--self.trunk:setpos(self.object:getpos())
		self.trunk:set_attach(self.object, "", {x = 0, y = 4, z = -10}, {x = 0, y = 0, z = 0})
		self.wheel.backright:set_attach(self.object, "", {z=-11.75,y=2.5,x=-8.875}, {x=0,y=0,z=0})
		self.wheel.backleft:set_attach(self.object, "", {z=-11.75,y=2.5,x=8.875}, {x=0,y=0,z=0})

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
	
	if math.abs(self.v) < .05 then
		self.object:setvelocity({x = 0, y = 0, z = 0})
		self.v = 0
		if self.wheelsound then
			minetest.sound_fade(self.wheelsound, 30, 0)
		end
		if self.windsound then
			minetest.sound_fade(self.windsound, 30, 0)
		end
		wheelspeed(self, true)
		return
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
	if driver ~= nil then
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
		textures = {"car_"..color..".png"}, -- number of required textures depends on visual
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = false,
		trunkinv = {},
		on_activate = function(self, staticdata)
			if not self.wheelpos then self.wheelpos = 0 end
			if not self.timer1 then self.timer1 = 0 end
			if not self.timer2 then self.timer2 = 0 end
			self.passengers = {
				{loc = {x = -4, y = 3, z = 3}, offset = {x = -4, y = -2, z = 2} },
				{loc = {x = 4, y = 3, z = 3}, offset = {x = 4, y = -2, z = 2} },
				{loc = {x = -4, y = 3, z = -4}, offset = {x = -4, y = -2, z = -2} },
				{loc = {x = 4, y = 3, z = -4}, offset = {x = 4, y = -2, z = -2} },
			}
			self.trunkinv = deserializeContents(staticdata)
			self.object:setacceleration({x=0, y=-10, z=0})
			self.object:set_armor_groups({immortal = 1})
			self.wheel = {}
			wheelspeed(self)
			local pos = self.object:getpos()
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
			if not self.trunk then
				self.trunk = minetest.add_entity(pos, "cars:trunk")
			end
			if self.trunk then
				self.trunk:set_attach(self.object, "", {x = 0, y = 4, z = -10}, {x = 0, y = 0, z = 0})
			end
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
		end,
		get_staticdata = function(self)
			return serializeContents(self.trunkinv)
		end,
		on_step = function(self, dtime)
			car_step(self, dtime)
		end,
		on_rightclick = function(self, clicker)
			if not clicker or not clicker:is_player() then
				return
			end
			local name = clicker:get_player_name()
			if player_attached[name] == self then
				detach(clicker)
			else
				i = 0
				while i <= #self.passengers do
					i = i + 1
					if not self.passengers[i].player then break end
				end
				if i == 0 then return end
				self.passengers[i].player = clicker
				
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
minetest.register_entity("cars:steeringwheel", {
    hp_max = 1,
    physical = false,
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
    hp_max = 1,
    physical = false,
    weight = 5,
	owner = {},
    collisionbox = {-0.5,-0.3,-0.5, 0.5,0.3,0.5},
    visual = "mesh",
    visual_size = {x=1, y=1},
    mesh = "steering.x",
    textures = {"car_dark_grey.png"}, -- number of required textures depends on visual
    is_visible = true,
    --makes_footstep_sound = false,
    --automatic_rotate = true,
	on_rightclick = function(self, clicker)
		if not self.owner then return end
		local inventory = minetest.create_detached_inventory("cars_"..clicker:get_player_name(), {
			on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
				self.owner.trunkinv = inv:get_list("trunk")
			end,
			on_put = function(inv, listname, index, stack, player)
				self.owner.trunkinv = inv:get_list("trunk")
			end,
			on_take = function(inv, listname, index, stack, player)
				self.owner.trunkinv = inv:get_list("trunk")
			end,
		})
		inventory:set_size("trunk", 12)
		local templist = table.copy(self.owner.trunkinv)
		inventory:set_list("trunk", templist)
		local formspec =
            "size[8,8]"..
            "list[detached:cars_"..clicker:get_player_name()..";trunk;1,1;6,2;]"..
            "list[current_player;main;0,4;8,4;]"

        minetest.show_formspec(
        clicker:get_player_name(), "cars_trunk", formspec)
	end,
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(.1, function()
			if not self.object:get_attach() then
				self.object:remove()
			else
				self.owner = self.object:get_attach():get_luaentity()
				self.object:set_armor_groups({immortal = 1})
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
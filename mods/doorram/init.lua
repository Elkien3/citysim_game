local size = .3
local rammable = {}
rammable["doors:door_steel"] = true

local function is_rammable(nodename)
	for name, val in pairs(rammable) do
		if string.find(nodename, name) then
			return val
		end
	end
end

local doorhp = {}

if doors then
	local orig_func = doors.door_toggle
	doors.door_toggle = function(pos, node, clicker)
		local hash = minetest.hash_node_position(pos)
		if doorhp[hash] and doorhp[hash] <= 0 then
			return false
		else
			return orig_func(pos, node, clicker)
		end
	end
end

minetest.register_entity("doorram:ram", {
	initial_properties = {
		hp_max = 1,
		visual = "mesh",
		mesh = "ram.b3d",
		textures = {"ramuv.png"},
		physical = true,
		collide_with_objects = false,
		collisionbox = {-size, -.2, -size, size, .175, size}
	},
	on_activate = function(self, staticdata, dtime_s)
		local obj = self.object
		obj:set_yaw(staticdata or 0)
		obj:set_acceleration({x=0,y=-10,z=0})
	end,
	get_staticdata = function(self)
		return self.object:get_yaw()
	end,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local inv = puncher:get_inventory()
		if not inv then return end
		if not inv:add_item("main", "doorram:ram") then
			minetest.add_item(self.object:get_pos(), "doorram:ram")
		end
		self.object:remove()
	end,
	on_step = function(self, dtime, collide)
		local obj = self.object
		local pos = obj:get_pos()
		local velocity = obj:get_velocity()
		if obj:get_acceleration().y ~= -10 then
			obj:set_acceleration({x=0,y=-10,z=0})
		end
		if vector.length(velocity) == 0 and not self.left and not self.right then return end
		local oldvel = vector.new(velocity)
		local slowdown = .9
		if not self.left and not self.right then goto skip end
		if (self.right and not self.left) or (self.left and not self.right) then--only one player holding
			local side = "left"
			if self.right then
				side = "right"
			end
			local name = self[side]
			local player = minetest.get_player_by_name(name)
			if not player then self[side] = nil goto skip end
			local ppos = player:get_pos()
			local distance = vector.distance(ppos, pos)
			if distance > 2 then
				self[side] = nil
				goto skip
			elseif distance > 1 then
				local direction = vector.direction(ppos, pos)
				velocity = vector.subtract(velocity, (vector.multiply(direction, dtime*5)))
				if self.left then
					direction = vector.rotate(direction, {x=0,y=math.pi/2,z=0})
				else
					direction = vector.rotate(direction, {x=0,y=-math.pi/2,z=0})
				end
				obj:set_yaw(minetest.dir_to_yaw(direction))
			end
		else
			for side, name in pairs({left = self.left, right = self.right}) do
				local player = minetest.get_player_by_name(name)
				if not player then self[side] = nil goto skip end
				local ppos = player:get_pos()
				local distance = vector.distance(ppos, pos)
				if distance > 2 then
					self[side] = nil
					goto skip
				end
			end
			if not collide.touching_ground and collide.collides then
				for i, hit in pairs(collide.collisions) do
					if hit.axis ~= "y" then--do door check up here
						local strength = math.abs(hit.old_velocity[hit.axis]-hit.new_velocity[hit.axis])
						if strength > 2 then
							local node = minetest.get_node(hit.node_pos)
							if is_rammable(node.name) then
								minetest.sound_play("ramhit", {
									pos = hit.node_pos,
									max_hear_distance = 64,
									pitch = math.random(90,110)/100
								}, true)
								local hash = minetest.hash_node_position(hit.node_pos)
								local hp = (doorhp[hash] or 10) - strength
								if hp <= 0 then
									--if math.random(20/math.floor(strength+.5)) == 1 then
									doors.door_toggle(hit.node_pos)
								end
								doorhp[hash] = hp
								minetest.after(30, function(oldhp)
									if not doorhp[hash] then return end
									if doorhp[hash] ~= oldhp then return end
									doorhp[hash] = nil
								end, doorhp[hash])
								break
							end
						end
					end
				end
			end
			local p1 = minetest.get_player_by_name(self.right)
			local p2 = minetest.get_player_by_name(self.left)
			if not p1 then self.right = nil goto skip end
			if not p2 then self.left = nil goto skip end
			local pos1 = p1:get_pos()
			local pos2 = p2:get_pos()
			local difference = vector.subtract(pos2, pos1)--player 2 coords in reference to player 1
			obj:set_yaw(minetest.dir_to_yaw(vector.normalize(difference))-math.pi/2)
			local target = vector.add(pos1, vector.multiply(difference, .5)) -- go halfway
			target.y = target.y + .7
			if obj:get_acceleration().y ~= 0 then
				obj:set_acceleration({x=0,y=0,z=0})
			end
			difference = vector.subtract(target, pos)
			velocity = vector.add(velocity, (vector.multiply(difference, dtime*10)))
			slowdown = .95
		end
		::skip::
		if vector.length(oldvel) >= .01 and vector.length(velocity) < .01 then
			velocity = {x=0,y=0,z=0}
			obj:set_pos(pos)
		end
		velocity = vector.multiply(velocity, slowdown)
		obj:set_velocity(velocity)
		--collisionbox changes
		local col = obj:get_properties().collisionbox
		local newcol
		local absyaw = math.abs(math.deg(obj:get_yaw()))
		if absyaw < 45 or absyaw > 135 then--pointing north-south
			newcol = {-size, -.2, -size*3, size, .175, size*3}
		else--pointing east-west
			newcol = {-size*3, -.2, -size, size*3, .175, size}
		end
		if table.concat(col) ~= table.concat(newcol) then--use concat
			obj:set_properties({collisionbox = newcol})
		end
	end,
	on_rightclick = function(self, clicker)
		local name = clicker:get_player_name()
		local obj = self.object
		local pos1 = obj:get_pos()
		local pos2 = clicker:get_pos()
		pos1.y = 0
		pos2.y = 0
		local yaw = obj:get_yaw()
		local angle = vector.direction(pos2, pos1)
		angle = vector.rotate(angle, {x=0,y=-yaw,z=0})
		angle = minetest.dir_to_yaw(angle)
		local side = "left"
		if angle > 0 then
			side = "right"
		end
		for i, tempside in pairs({"left", "right"}) do
			if self[tempside] then
				if self[tempside] == name then
					self[tempside] = nil
				end
				return
			end
		end
		self[side] = name
	end,
})

minetest.register_tool("doorram:ram", {
	description = "Door Battering Ram",
	inventory_image = "ram.png",
	on_place = function(itemstack, placer, pointed_thing)
		minetest.add_entity(pointed_thing.above, "doorram:ram", placer:get_look_horizontal() + math.pi/2)
		itemstack:take_item()
		return itemstack
	end
})

local craftmat = "default:steelblock"
if minetest.get_modpath("technic") then
	craftmat = "technic:carbon_steel_block"
end
minetest.register_craft({
	recipe = {
		{"", "default:steel_ingot", ""},
		{craftmat, "default:steel_ingot", "default:steel_ingot"},
		{"", "default:steel_ingot", ""}
	},
	output = "doorram:ram"
})
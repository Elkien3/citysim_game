-- Minetest: builtin/item_entity.lua

-- override ice to make slippery for 0.4.16
minetest.override_item("default:ice", {
	groups = {cracky = 3, puts_out_fire = 1, cools_lava = 1, slippery = 3}})


function core.spawn_item(pos, item)

	local stack = ItemStack(item)
	local obj = core.add_entity(pos, "__builtin:item")

	if obj then
		obj:get_luaentity():set_item(stack:to_string())
	end

	return obj
end


-- If item_entity_ttl is not set, enity will have default life time
-- Setting it to -1 disables the feature

local time_to_live = tonumber(core.settings:get("item_entity_ttl")) or 900
local gravity = tonumber(core.settings:get("movement_gravity")) or 9.81
local destroy_item = core.settings:get_bool("destroy_item") ~= false


-- water flow functions by QwertyMine3, edited by TenPlus1
local function to_unit_vector(dir_vector)

	local inv_roots = {
		[0] = 1,
		[1] = 1,
		[2] = 0.70710678118655,
		[4] = 0.5,
		[5] = 0.44721359549996,
		[8] = 0.35355339059327
	}

	local sum = dir_vector.x * dir_vector.x + dir_vector.z * dir_vector.z

	return {
		x = dir_vector.x * inv_roots[sum],
		y = dir_vector.y,
		z = dir_vector.z * inv_roots[sum]
	}
end


local function node_ok(pos)

	local node = minetest.get_node_or_nil(pos)

	if node and minetest.registered_nodes[node.name] then
		return node
	end

	return minetest.registered_nodes["default:dirt"]
end


local function quick_flow_logic(node, pos_testing, direction)

	local node_testing = node_ok(pos_testing)

	if minetest.registered_nodes[node_testing.name].liquidtype ~= "flowing"
	and minetest.registered_nodes[node_testing.name].liquidtype ~= "source" then
		return 0
	end

	local param2_testing = node_testing.param2

	if param2_testing < node.param2 then

		if (node.param2 - param2_testing) > 6 then
			return -direction
		else
			return direction
		end

	elseif param2_testing > node.param2 then

		if (param2_testing - node.param2) > 6 then
			return direction
		else
			return -direction
		end
	end

	return 0
end


local function quick_flow(pos, node)

	if not minetest.registered_nodes[node.name].groups.liquid then
		return {x = 0, y = 0, z = 0}
	end

	local x, z = 0, 0

	x = x + quick_flow_logic(node, {x = pos.x - 1, y = pos.y, z = pos.z},-1)
	x = x + quick_flow_logic(node, {x = pos.x + 1, y = pos.y, z = pos.z}, 1)
	z = z + quick_flow_logic(node, {x = pos.x, y = pos.y, z = pos.z - 1},-1)
	z = z + quick_flow_logic(node, {x = pos.x, y = pos.y, z = pos.z + 1}, 1)

	return to_unit_vector({x = x, y = 0, z = z})
end
-- END water flow functions


-- particle effects for when item is destroyed
local function add_effects(pos)

	minetest.add_particlespawner({
		amount = 1,
		time = 0.25,
		minpos = pos,
		maxpos = pos,
		minvel = {x = -1, y = 2, z = -1},
		maxvel = {x = 1, y = 4, z = 1},
		minacc = {x = 0, y = 0, z = 0},
		maxacc = {x = 0, y = 0, z = 0},
		minexptime = 1,
		maxexptime = 3,
		minsize = 1,
		maxsize = 4,
		texture = "tnt_smoke.png",
	})
end


core.register_entity(":__builtin:item", {

	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
		visual = "wielditem",
		visual_size = {x = 0.4, y = 0.4},
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = false,
		infotext = "",
	},

	itemstring = "",
	moving_state = true,
	slippery_state = false,
	age = 0,

	set_item = function(self, item)

		local stack = ItemStack(item or self.itemstring)

		self.itemstring = stack:to_string()

		if self.itemstring == "" then
			return
		end

		local itemname = stack:is_known() and stack:get_name() or "unknown"
		local max_count = stack:get_stack_max()
		local count = math.min(stack:get_count(), max_count)
		local size = 0.2 + 0.1 * (count / max_count) ^ (1 / 3)
		local col_height = size * 0.75
		local col_depth = -col_height
		local itemdef = minetest.registered_items[ItemStack(self.itemstring):get_name()]
		if itemdef and itemdef.inventory_image ~= "" then col_depth = col_depth*.125 end
		local def = core.registered_nodes[itemname]
		local glow = def and def.light_source
		local c1, c2 = "",""

		if not(stack:get_count() == 1) then
			c1 = " x"..tostring(stack:get_count())
			c2 = " "..tostring(stack:get_count())
		end

		local name1 = stack:get_meta():get_string("description")

		if name1 == "" then
			name = core.registered_items[itemname].description
		else
			name = name1
		end

		self.object:set_properties({
			is_visible = true,
			visual = "wielditem",
			textures = {itemname},
			visual_size = {x = size, y = size},
			collisionbox = {-size, col_depth, -size, size, col_height, size},
			selectionbox = {-size, -size, -size, size, size, size},
			--automatic_rotate = 0.314 / size,
			wield_item = self.itemstring,
			glow = glow,
			infotext = name..c1.."\n("..itemname..c2..")"
		})

	end,

	get_staticdata = function(self)

		return core.serialize({
			itemstring = self.itemstring,
			age = self.age,
			dropped_by = self.dropped_by
		})
	end,

	on_activate = function(self, staticdata, dtime_s)

		if string.sub(staticdata, 1, string.len("return")) == "return" then

			local data = core.deserialize(staticdata)

			if data and type(data) == "table" then
				self.itemstring = data.itemstring
				self.age = (data.age or 0) + dtime_s
				self.dropped_by = data.dropped_by
			end
		else
			self.itemstring = staticdata
		end
		minetest.after(0, function()
			local itemdef = minetest.registered_items[ItemStack(self.itemstring):get_name()]
			if itemdef and itemdef.inventory_image == "" then
				self.object:set_rotation({x=0, y=math.random(-math.pi, math.pi), z=0})
			else
				self.object:set_rotation({x=1.57075, y=0, z=math.random(-math.pi, math.pi)})
			end
			self:set_item()
		end)
		self.object:set_armor_groups({immortal = 1})
		self.object:set_velocity({x = 0, y = 2, z = 0})
		self.object:set_acceleration({x = 0, y = -gravity, z = 0})
	end,

	try_merge_with = function(self, own_stack, object, entity)

		if self.age == entity.age then
			return false -- Can not merge with itself
		end

		local stack = ItemStack(entity.itemstring)
		local name = stack:get_name()

		if own_stack:get_name() ~= name
		or own_stack:get_meta() ~= stack:get_meta()
		or own_stack:get_wear() ~= stack:get_wear()
		or own_stack:get_free_space() == 0 then
			return false -- Can not merge different or full stack
		end

		local count = own_stack:get_count()
		local total_count = stack:get_count() + count
		local max_count = stack:get_stack_max()

		if total_count > max_count then
			return false
		end

		-- Merge the remote stack into this one
		local pos = object:get_pos()
		pos.y = pos.y + ((total_count - count) / max_count) * 0.15

		self.object:move_to(pos)
		self.age = 0 -- Handle as new entity

		own_stack:set_count(total_count)
		self:set_item(own_stack)

		entity.itemstring = ""
		object:remove()

		return true
	end,

	on_step = function(self, dtime)

		local pos = self.object:get_pos()

		self.age = self.age + dtime

		if time_to_live > 0 and self.age > time_to_live then

			self.itemstring = ""
			self.object:remove()

			add_effects(pos)

			return
		end

		-- get nodes every 1/4 second
		self.timer = (self.timer or 0) + dtime

		if self.timer > 0.25 or not self.node_inside then

			self.node_inside = minetest.get_node_or_nil(pos)
			self.def_inside = self.node_inside
					and core.registered_nodes[self.node_inside.name]

			self.node_under = minetest.get_node_or_nil({
				x = pos.x,
				y = pos.y + self.object:get_properties().collisionbox[2] - 0.05,
				z = pos.z
			})
			self.def_under = self.node_under
					and core.registered_nodes[self.node_under.name]

			self.timer = 0
		end

		local node = self.node_inside

		-- Delete in 'ignore' nodes
		if node and node.name == "ignore" then

			self.itemstring = ""
			self.object:remove()

			return
		end

		-- do custom step function
		local name = ItemStack(self.itemstring):get_name() or ""
		local custom = core.registered_items[name]
			and core.registered_items[name].dropped_step

		if custom and custom(self, pos, dtime) == false then
			return -- skip further checks if false
		end

		local vel = self.object:get_velocity()
		local def = self.def_inside
		local is_slippery = false
		local is_moving = (def and not def.walkable) or
			vel.x ~= 0 or vel.y ~= 0 or vel.z ~= 0

		-- destroy item when dropped into lava (if enabled)
		if destroy_item and def and def.groups and def.groups.lava then

			minetest.sound_play("builtin_item_lava", {
				pos = pos,
				max_hear_distance = 6,
				gain = 0.5
			})

			self.itemstring = ""
			self.object:remove()

			add_effects(pos)

			return
		end

		-- water flowing
		if def and def.liquidtype == "flowing" then

			local vec = quick_flow(pos, node)
			local v = self.object:get_velocity()

			self.object:set_velocity({x = vec.x, y = v.y, z = vec.z})

			return
		end

		-- item inside block, move to vacant space
		if def and (def.walkable == nil or def.walkable == true)
		and (def.collision_box == nil or def.collision_box.type == "regular")
		and (def.node_box == nil or def.node_box.type == "regular") then

			local npos = minetest.find_node_near(pos, 1, "air")

			if npos then
				self.object:move_to(npos)
			end

			self.node_inside = nil -- force get_node

			return
		end

		-- Switch locals to node under
		node = self.node_under
		def = self.def_under


		-- Slippery node check
		if def and def.walkable then

			local slippery = core.get_item_group(node.name, "slippery")

			is_slippery = slippery ~= 0

			if is_slippery and (math.abs(vel.x) > 0.2 or math.abs(vel.z) > 0.2) then

				-- Horizontal deceleration
				local slip_factor = 4.0 / (slippery + 4)

				self.object:set_acceleration({
					x = -vel.x * slip_factor,
					y = 0,
					z = -vel.z * slip_factor
				})

			elseif vel.y == 0 then
				is_moving = false
			end
		end

		if self.moving_state == is_moving
		and self.slippery_state == is_slippery then
			return -- No further updates until moving state changes
		end

		self.moving_state = is_moving
		self.slippery_state = is_slippery

		if is_moving then
			self.object:set_acceleration({x = 0, y = -gravity, z = 0})
		else
			self.object:set_acceleration({x = 0, y = 0, z = 0})
			self.object:set_velocity({x = 0, y = 0, z = 0})
		end

		--Only collect items if not moving
		if is_moving then
			return
		end

		-- Collect the items around to merge with
		local own_stack = ItemStack(self.itemstring)

		if own_stack:get_free_space() == 0 then
			return
		end

		local objects = core.get_objects_inside_radius(pos, 1.0)

		for k, obj in pairs(objects) do

			local entity = obj:get_luaentity()

			if entity and entity.name == "__builtin:item" then

				if self:try_merge_with(own_stack, obj, entity) then

					own_stack = ItemStack(self.itemstring)

					if own_stack:get_free_space() == 0 then
						return
					end
				end
			end
		end
	end,

	on_punch = function(self, hitter)

		local inv = hitter:get_inventory()

		if inv and self.itemstring ~= "" then

			local left = inv:add_item("main", self.itemstring)

			if left and not left:is_empty() then
				self:set_item(left)
				return
			end
		end

		self.itemstring = ""
		self.object:remove()
	end,
})

local modpath, S = ...

--
--Square Ball Game for the Puppy
--

function petz.spawn_square_ball(user, strength)
	local pos = user:get_pos()
	pos.y = pos.y + 1.5 -- camera offset
	local dir = user:get_look_dir()
	local yaw = user:get_look_horizontal()

	local obj = minetest.add_entity(pos, "petz:ent_square_ball")
	if not obj then
		return
	end
	obj:get_luaentity().shooter_name = user:get_player_name()
	obj:set_yaw(yaw - 0.5 * math.pi)
	obj:set_velocity(vector.multiply(dir, strength))
	return true
end

minetest.register_node("petz:square_ball", {
	description = S("Square Ball (use to throw)"),
	--inventory_image = "petz_square_ball.png",
	tiles = {"petz_square_ball.png", "petz_square_ball.png", "petz_square_ball.png", "petz_square_ball.png",
					"petz_square_ball.png", "petz_square_ball.png"},
	visual_scale = 0.35,
	is_ground_content = false,
    groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
    sounds = default.node_sound_wood_defaults(),
	on_use = function(itemstack, user, pointed_thing)
		local strength = 20
		if not petz.spawn_square_ball(user, strength) then
			return -- something failed
		end
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
    type = "shaped",
    output = 'petz:square_ball',
    recipe = {
        {'wool:blue', 'wool:white', 'wool:red'},
        {'wool:white', 'farming:string', 'wool:white'},
        {'wool:yellow', 'wool:white', 'wool:white'},
    }
})

petz.attach_squareball = function(self, thing_ent, thing_ref, shooter_name)
	self.object:set_properties({visual = "cube",  physical = true, visual_size = {x = 0.045, y = 0.045},
			textures = {"petz_square_ball.png", "petz_square_ball.png", "petz_square_ball.png", "petz_square_ball.png",
			"petz_square_ball.png", "petz_square_ball.png"}, groups = {immortal = 1}, collisionbox = {-0.15, -0.15, -0.15, 0.15, 0.15, 0.15},})
	self.object:set_attach(thing_ref, "head", {x=-0.0, y=0.5, z=-0.45}, {x=0, y=0, z=0})
	thing_ent.square_ball_attached = true
	thing_ent.attached_squared_ball = self
	mobkit.remember(thing_ent, "square_ball_attached", thing_ent.square_ball_attached)
	mobkit.make_sound(thing_ent, "moaning")
	if shooter_name then
		local player = minetest.get_player_by_name(shooter_name)
		if player then
			mobkit.clear_queue_low(thing_ent)
			mobkit.hq_follow(thing_ent, 15, player)
			self.shooter_name = "" --disable de 'on_step' event
		end
	end
end

minetest.register_entity("petz:ent_square_ball", {
	hp_max = 4,       -- possible to catch the arrow (pro skills)
	physical = false, -- use Raycast
	collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
	visual = "wielditem",
	textures = {"petz:square_ball"},
	visual_size = {x = 0.2, y = 0.15},
	old_pos = nil,
	shooter_name = "",
	parent_entity = nil,
	waiting_for_removal = false,

	on_activate = function(self)
		self.object:set_acceleration({x = 0, y = -9.81, z = 0})
	end,

	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		return false
	end,

	on_rightclick = function(self, clicker)
		if self.object:get_attach() then --if attached
			local attach = self.object:get_attach()
			local inv = clicker:get_inventory()
			local new_stack = "petz:square_ball"
			if inv:room_for_item("main", new_stack) then
				inv:add_item("main", new_stack)
			else
				local parent_pos = attach:get_pos()
				minetest.add_item(parent_pos, new_stack)
			end
			self.object:set_detach()
			local parent_ent = attach:get_luaentity()
			parent_ent.square_ball_attached = false
			parent_ent.attached_squared_ball = nil
			mobkit.clear_queue_low(parent_ent)
			petz.ownthing(parent_ent)
			self.object:remove()	--remove the square ball
			mobkit.clear_queue_low(parent_ent)
			petz.ownthing(parent_ent)
		end
	end,

	on_step = function(self, dtime)
		if self.shooter_name == "" then
			if self.object:get_attach() == nil then
				self.object:remove()
			end
			return
		end
		if self.waiting_for_removal then
			self.object:remove()
			return
		end
		local pos = self.object:get_pos()
		self.old_pos = self.old_pos or pos

		local cast = minetest.raycast(self.old_pos, pos, true, false)
		local thing = cast:next()
		while thing do
			if thing.type == "object" and thing.ref ~= self.object then
				--minetest.chat_send_player("singleplayer", thing.type)
				if not(thing.ref:is_player()) and not(thing.ref:get_player_name() == self.shooter_name) then
					local thing_ent = thing.ref:get_luaentity()
					if thing_ent then
						--minetest.chat_send_player("singleplayer", thing_ent.type)
						if (thing_ent.type == "puppy") and not(thing.ref.square_ball_attached) then
							--minetest.chat_send_player("singleplayer", "test")
							petz.attach_squareball(self, thing_ent, thing.ref, self.shooter_name)
							return
						end
					end
				end
			elseif thing.type == "node" then
				local name = minetest.get_node(thing.under).name
				if minetest.registered_items[name].walkable then
					local itemstack_squareball = ItemStack("petz:square_ball")
					--local meta = itemstack_squareball:get_meta()
					--meta:set_string("shooter_name", self.shooter_name)
					minetest.item_drop(itemstack_squareball,
						nil, vector.round(self.old_pos))
					self.waiting_for_removal = true
					self.object:remove()
					return
				end
			end
			thing = cast:next()
		end
		self.old_pos = pos
	end,
})

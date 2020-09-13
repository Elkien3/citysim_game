local modpath, S = ...

--effects can be: fire

function petz.throw(self, dtime, damage, effect, particles, sound)
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
			local thing_ent = thing.ref:get_luaentity()
			if not(thing.ref:is_player()) or (thing.ref:is_player() and not(thing.ref:get_player_name() == self.shooter_name)) then
				local ent_pos
				if thing.ref:is_player() then
					thing.ref:punch(thing.ref, 1.0, {full_punch_interval = 1.0, damage_groups = {fleshy=damage}}, nil)
					ent_pos = thing.ref:get_pos()
					if sound then
						mokapi.make_sound("player", thing.ref, sound, petz.settings.max_hear_distance)
					end
				else
					mobkit.hurt(thing_ent, damage)
					ent_pos = thing.ref:get_pos()
					if sound then
						mokapi.make_sound("object", thing.ref, sound, petz.settings.max_hear_distance)
					end
				end
				if effect then
					if effect == "cobweb" then
						minetest.set_node(ent_pos, {name = "petz:cobweb"})
					end
				end
				if particles then
					petz.do_particles_effect(nil, pos, particles)
				end
				self.waiting_for_removal = true
				self.object:remove()
				return
			end
		elseif thing.type == "node" then
			local node_pos = thing.above
			local node = minetest.get_node(node_pos)
			local node_name = node.name
			--minetest.chat_send_player("singleplayer", node.name)
			if minetest.registered_items[node_name].walkable and minetest.registered_items[node_name] ~= "air" then
				if effect then
					if effect == "fire" then
						local pos_above = {
							x = node_pos.x,
							y = node_pos.y +1,
							z = node_pos.z,
						}
						local node_above = minetest.get_node(pos_above)
						if minetest.get_item_group(node_name, "flammable") > 1 then
							minetest.set_node(node_pos, {name = "fire:basic_flame"})
						end
						if node_above.name == "air" then
							--if minetest.get_node(pos_above).name == "air" then
							petz.do_particles_effect(nil, pos_above, "fire")
							--end
						end
						mokapi.make_sound("pos", node_pos, "petz_firecracker", petz.settings.max_hear_distance)
					elseif effect == "cobweb" then
						local pos_above = {
							x = node_pos.x,
							y = node_pos.y +1,
							z = node_pos.z,
						}
						local node_above = minetest.get_node(pos_above)
						if node_above.name == "air" then
							minetest.set_node(pos_above, {name = "petz:cobweb"})
						end
					end
				end
				self.waiting_for_removal = true
				self.object:remove()
				return
			end
		end
		thing = cast:next()
	end
	self.old_pos = pos
end

function petz.spawn_throw_object(user, strength, entity)
	local pos = user:get_pos()
	if user:is_player() then
		pos.y = pos.y + 1.5 -- camera offset
	end
	--minetest.chat_send_player("singleplayer", tostring(pos))
	local obj = minetest.add_entity(pos, entity)
	if not obj then
		return
	end
	local dir
	local yaw
	local user_name
	if user:is_player() then
		yaw = user:get_look_horizontal()
		dir = user:get_look_dir()
		user_name = user:get_player_name()
	else
		yaw = user:get_yaw()
		dir = minetest.yaw_to_dir(yaw)
		user_name = user:get_luaentity().type
	end
	--minetest.chat_send_player("singleplayer", "test")
	obj:get_luaentity().shooter_name = user_name
	obj:set_yaw(yaw - 0.5 * math.pi)
	obj:set_velocity(vector.multiply(dir, strength))
	return true
end

function petz.register_throw_entity(name, textures, damage, effect, particles, sound)
	minetest.register_entity(name, {
		hp_max = 4,       -- possible to catch the arrow (pro skills)
		physical = false, -- use Raycast
		collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
		visual = "wielditem",
		textures = {textures},
		visual_size = {x = 1.0, y = 1.0},
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

		on_step = function(self, dtime)
			petz.throw(self, dtime, damage, effect, particles, sound)
		end,
	})
end

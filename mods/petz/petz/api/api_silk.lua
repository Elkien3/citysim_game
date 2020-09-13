local modpath, S = ...

--Coocon
minetest.register_node("petz:cocoon", {
    description = S("Silkworm Cocoon"),
    inventory_image = "petz_cocoon_inv.png",
    groups = {snappy=1, bendy=2, cracky=1},
    sounds = default.node_sound_wood_defaults(),
    paramtype = "light",
    drawtype = "mesh",
	mesh = 'petz_cocoon.b3d',
    visual_scale = 1.0,
	tiles = {"petz_cocoon.png"},
	collision_box = {
		type = "fixed",
		fixed = {-0.125, -0.5, -0.375, 0.0625, -0.25, 0.3125},
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.125, -0.5, -0.375, 0.0625, -0.25, 0.3125},
	},
    on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(math.random(400, 600))
    end,
	on_timer = function(pos)
		if not minetest.registered_entities["petz:moth"] then
			return
		end
		if pos and petz.is_night() == true then --only spawn at night, to it does not die
			local mob = minetest.add_entity(pos, "petz:moth")
			local ent = mob:get_luaentity()
			minetest.set_node(pos, {name= "air"})
			return false
		end
		return true
	end
})

--Silkworm Egg
minetest.register_node("petz:silkworm_eggs", {
    description = S("Silkworm Eggs"),
    inventory_image = "petz_silkworm_eggs_inv.png",
    groups = {snappy=1, bendy=2, cracky=1, falling_node = 1},
    sounds = default.node_sound_wood_defaults(),
    paramtype = "light",
    drawtype = "mesh",
	mesh = 'petz_silkworm_eggs.b3d',
    visual_scale = 1.0,
	tiles = {"petz_silkworm_eggs.png"},
	collision_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.062500, 0.1875, -0.4375, 0.1875},
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.062500, 0.1875, -0.4375, 0.1875},
	},
    on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(math.random(200, 300))
    end,
	on_timer = function(pos)
		if not minetest.registered_entities["petz:silkworm"] then
			return
		end
		minetest.set_node(pos, {name= "air"})
		minetest.add_entity(pos, "petz:silkworm")
		local pos2 = {
			x = pos.x + 1,
			y = pos.y,
			z = pos.z + 1,
		}
		if minetest.get_node(pos2) and minetest.get_node(pos2).name == "air" then
			minetest.add_entity(pos2, "petz:silkworm")
		end
		local pos3 = {
			x = pos.x - 1,
			y = pos.y,
			z = pos.z -1,
		}
		if minetest.get_node(pos3) and minetest.get_node(pos3).name == "air" then
			minetest.add_entity(pos3, "petz:silkworm")
		end
		return false
	end
})

--Spinning Wheel
minetest.register_node("petz:spinning_wheel", {
    description = S("Spinning Wheel"),
    groups = {snappy=1, bendy=2, cracky=1},
    sounds = default.node_sound_wood_defaults(),
    paramtype = "light",
    drawtype = "mesh",
	mesh = 'petz_spinning_wheel.b3d',
	tiles = {"petz_spinning_wheel_loaded.png"},
	collision_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.25, 0.5, 0.3125, 0.1875},
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.25, 0.5, 0.3125, 0.1875},
	},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		meta:set_int("silk_count", 1)
		meta:set_string("infotext", S("Silk Count").." = "..meta:get_int("silk_count"))
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local player_name = player:get_player_name()
		--minetest.chat_send_player(player_name, "name="..itemstack:get_name())
		local meta = minetest.get_meta(pos)
		local silk_count = meta:get_int("silk_count")
		if itemstack:get_name() == "petz:cocoon" then
			if silk_count == 3 then
				minetest.chat_send_player(player_name, S("First, extract the silk bobbin from the spinning wheel."))
			elseif silk_count == 2 then
				silk_count = silk_count + 1
				meta:set_int("silk_count", silk_count)
				meta:set_string("infotext", S("Silk Count").." = "..tostring(silk_count))
				itemstack:take_item()
				minetest.chat_send_player(player_name, S("A silk bobbin has been created!"))
				return itemstack
			else
				silk_count = silk_count + 1
				meta:set_int("silk_count", silk_count)
				meta:set_string("infotext", S("Silk Count").." = "..tostring(silk_count))
				itemstack:take_item()
				minetest.chat_send_player(player_name, S("There are still").." ".. tostring(3-silk_count).." "..S("more to create the bobbin."))
				return itemstack
			end
		elseif silk_count == 3 then --get the bobbin
			local inv = player:get_inventory()
			if inv:room_for_item("main", "petz:silk_bobbin") then --firstly check for room in the inventory
				local itemstack_name = itemstack:get_name()
				local stack = ItemStack("petz:silk_bobbin 1")
				if (itemstack_name == "petz:silk_bobbin" or itemstack_name == "") and (itemstack:get_count() < itemstack:get_stack_max()) then
					itemstack:add_item(stack)
				else
					inv:add_item("main", stack)
				end
				meta:set_int("silk_count", 0) --reset the silk count
				meta:set_string("infotext", S("Silk Count").." = 0")
				minetest.chat_send_player(player_name, S("You got the bobbin!"))
				return itemstack
			else
				minetest.chat_send_player(player_name, S("No room in your inventory for the silk bobbin."))
			end
		end
	end,
})

minetest.register_craft({
    type = "shaped",
    output = "petz:spinning_wheel",
    recipe = {
        {'', 'group:wood', ''},
        {'group:wood', 'petz:silk_bobbin', 'group:wood'},
        {'', 'group:wood', ''},
    }
})

petz.init_convert_to_chrysalis = function(self)
	minetest.after(math.random(1200, 1500), function(self)
		if not(mobkit.is_alive(self)) then
			return
		end
		local pos = self.object:get_pos()
		if minetest.get_node(pos) and minetest.get_node(pos).name ~= "air" then
			return
		end
		minetest.set_node(pos, {name= "petz:cocoon"})
		mokapi.remove_mob(self)
	end, self)
end

petz.init_lay_eggs = function(self)
	minetest.after(math.random(150, 240), function(self)
		if not(mobkit.is_alive(self)) then
			return
		end
		if self.eggs_count > 0 then
			return
		end
		petz.alight(self)
		minetest.after(10.0, function(self)
			if not(mobkit.is_alive(self)) then
				return
			end
			local pos = self.object:get_pos()
			if minetest.get_node(pos) and minetest.get_node(pos).name ~= "air" then
				return
			end
			local node_name = mobkit.node_name_in(self, "below")
			local spawn_egg = false
			if string.sub(petz.settings.silkworm_lay_egg_on_node, 1, 5) == "group" then
				local node_group = minetest.get_item_group(node_name, string.sub(petz.settings.silkworm_lay_egg_on_node, 7))
				if node_group > 0 then
					spawn_egg = true
				end
			else
				if node_name == petz.settings.silkworm_lay_egg_on_node then
					spawn_egg = true
				end
			end
			if spawn_egg == true then
				minetest.set_node(pos, {name= "petz:silkworm_eggs"})
				self.eggs_count = mobkit.remember(self, "eggs_count", (self.eggs_count+1)) --increase the count of eggs
			else
				petz.init_lay_eggs(self) --reinit the timer, to try to lay eggs later
			end
			petz.ownthing(self)
		end, self)
    end, self)
end

--Silk

minetest.register_craftitem("petz:silk_bobbin", {
    description = S("Silk Bobbin"),
    inventory_image = "petz_silk_bobbin.png",
    stack_max = 25,
})

minetest.register_craft({
    type = "shaped",
    output = 'petz:silk_bobbin',
    recipe = {
        {'petz:cocoon', 'default:stick', 'petz:cocoon'},
        {'petz:cocoon', 'default:stick', 'petz:cocoon'},
        {'petz:cocoon', 'default:stick', 'petz:cocoon'},
    }
})

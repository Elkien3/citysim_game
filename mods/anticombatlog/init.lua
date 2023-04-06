local ghost_time = 5*60--time in seconds to keep a disconnect ghost, timer is reset when interacted with
local storage = minetest.get_mod_storage()

local bodytable = minetest.deserialize(storage:get_string("bodytable")) or {}

for name, tbl in pairs(bodytable) do
	if tbl.time and tbl.time >= os.time() and not (tbl.pos or tbl.hp or tbl.inv) then
		bodytable[name] = nil
	end
end
storage:set_string("bodytable", minetest.serialize(bodytable))

local lastupdate
local updatetime = 2
local updatequeued
local function update_bodies()
	if not lastupdate or os.time()-lastupdate >= updatetime then
		lastupdate = os.time()
		updatequeued = nil
		storage:set_string("bodytable", minetest.serialize(bodytable))
	elseif not updatequeued then
		updatequeued = true
		minetest.after(updatetime-(os.time()-lastupdate), update_bodies)
	end
end

bodies_dragging = {}

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

local function get_look_yaw(pos)
	local pi = math.pi
	local rotation = minetest.get_node(pos).param2
	if rotation > 3 then
		rotation = rotation % 4 -- Mask colorfacedir values
	end
	if rotation == 1 then
		return pi / 2, rotation
	elseif rotation == 3 then
		return -pi / 2, rotation
	elseif rotation == 0 then
		return pi, rotation
	else
		return 0, rotation
	end
end

local function remove_body(self)
	local parent = self.object:get_attach()
	if parent and parent:get_player_name() then
		bodies_dragging[parent:get_player_name()] = nil
	end
	if self.owner and bodytable[self.owner] and not bodytable[self.owner]["pos"] and not bodytable[self.owner]["inv"] and not bodytable[self.owner]["hp"] then
		bodytable[self.owner] = nil
		storage:set_string("bodytable", minetest.serialize(bodytable))
	end
	self.object:remove()
end

minetest.register_entity("anticombatlog:entity", {
	hp_max = 20,
	physical = true,
	weight = 5,
	collisionbox = {-0.3, 0, -0.3, 0.3, .3, 0.3},
	visual = "mesh",
	mesh = "character.b3d",
	textures = {"invisible.png"},
	is_visible = true,
	makes_footstep_sound = false,
    automatic_rotate = 0,
    on_activate = function(self, staticdata, dtime_s)
		local deserialized = minetest.deserialize(staticdata)
		if not deserialized then
			remove_body(self)
			return
		end
		self.inv = deserialized.inv
		self.owner = deserialized.owner
		if not bodytable[self.owner] then self.object:remove() return end
		storage:set_string("bodytable", minetest.serialize(bodytable))
		self.sleeping = deserialized.sleeping
		self.time = deserialized.expiretime
		self.hp = deserialized.hp
		self.steallist = deserialized.steallist
		self.armor_groups = deserialized.armor_groups
		self.object:set_armor_groups(self.armor_groups)
		if self.hp then
			self.object:set_hp(self.hp)
		end
		if self.time <= os.time() then
			remove_body(self)
			return
		end
		
		if self.sleeping then
			self.object:set_properties({infotext = self.owner.." (sleeping)"})
		else
			self.object:set_properties({infotext = self.owner.." (dead)"})
		end
		
		local allowfunc = function(inv, listname, index, stack, player, count)
			if not self or not self.object or not self.object:get_pos() then return 0 end
			if count then
				return count
			else
				return stack:get_count()
			end
		end
		local onfunc = function(inv)
			local lists = inv:get_lists()
			local listtable = {}
			for listname, list in pairs(lists) do
				listtable[listname] = serializeContents(list)
			end
			self.inv = listtable
			bodytable[self.owner]["inv"] = self.inv
			self.time = os.time() + ghost_time
			bodytable[self.owner]["time"] = self.time
			storage:set_string("bodytable", minetest.serialize(bodytable))
		end
		local selfname = string.sub(tostring(self), 8)
		local inv = minetest.create_detached_inventory("sleeping_"..selfname, {
			allow_move = allowfunc,
			allow_put = allowfunc,
			allow_take = function(inv, listname, index, stack, player2)
				local returnval = allowfunc(inv, listname, index, stack, player2, count)
				if returnval == 0 then return returnval end
				if not bones_take_one or bones_take_one(self, player2, stack) then
					return returnval
				end
				return 0
			end,
			on_take = onfunc,
			on_move = onfunc,
			on_put = onfunc,
		})
		local lists = {}
		for listname, serializedList in pairs(self.inv) do
			lists[listname] = deserializeContents(serializedList)
		end
		inv:set_lists(lists)
		self.object:set_acceleration({x=0,y=-9.81,z=0})
		if deserialized.mesh and deserialized.textures and deserialized.yaw then
			self.mesh = deserialized.mesh
			self.textures = deserialized.textures
			self.yaw = deserialized.yaw
			self.object:set_properties({mesh = deserialized.mesh, textures = deserialized.textures})
			self.object:set_yaw(deserialized.yaw)
			self.object:set_animation({x=162,y=167}, 1)
		end
    end,
	get_staticdata = function(self)
		return minetest.serialize({owner = self.owner, sleeping = self.sleeping, expiretime = self.time, mesh = self.mesh, textures = self.textures, yaw = self.yaw, inv = self.inv, hp = self.hp, armor_groups = self.armor_groups, steallist = self.steallist})
	end,
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
		if not self.owner or not bodytable[self.owner] then return end
		self.hp = (self.hp or self.object:get_hp()) - damage
		bodytable[self.owner]["hp"] = self.hp
		self.time = os.time() + ghost_time
		bodytable[self.owner]["time"] = self.time
		if self.hp <= 0 then
			if minetest.settings:get_bool("bones_steal_one", false) then--disable all this if players are only allowed to steal one item
				self.hp = 1
				self.object:set_hp(1)
				return true
			end
			local drop = function(pos, itemstack)
				local obj = minetest.add_item(pos, itemstack:take_item(itemstack:get_count()))
				if obj then
					obj:set_velocity({
						x = math.random(-10, 10) / 9,
						y = 5,
						z = math.random(-10, 10) / 9,
					})
				end
			end
			local lists = {}
			for listname, serializedList in pairs(self.inv) do
				local list = deserializeContents(serializedList)
				lists[listname] = list
				for index, itemstack in pairs(list) do
					minetest.after(0, drop, self.object:get_pos(), itemstack)
					lists[listname][index] = ItemStack()
				end
			end
			local listtable = {}
			for listname, list in pairs(lists) do
				listtable[listname] = serializeContents(list)
			end
			self.inv = listtable
			bodytable[self.owner]["inv"] = self.inv
			local parent = self.object:get_attach()
			if parent and parent:get_player_name() then
				bodies_dragging[parent:get_player_name()] = nil
			end
		end
		storage:set_string("bodytable", minetest.serialize(bodytable))
    end,
    on_rightclick = function(self, clicker)
		local name = clicker:get_player_name()
		if clicker:get_player_control().sneak then
			self.object:set_attach(clicker, "", {x = 0, y = 0, z = -12}, {x = 0, y = 180, z = 0})
			bodies_dragging[name] = self
		else
			local selfname = string.sub(tostring(self), 8)
			local formspec =
			   "size[8,12]"..
			   "list[detached:sleeping_"..selfname..";craft;2.5,0;3,3;]"..
			   "list[detached:sleeping_"..selfname..";main;0,3.5;8,4;]"..
			   "list[current_player;main;0,8;8,4;]"..
			   "listring[]"
			minetest.show_formspec(name, "bones_inv", formspec)
		end
    end,
	on_step = function(self, dtime, moveresult)
		if not self.owner or not bodytable[self.owner] then remove_body(self) return end
		if self.time <= os.time() then
			remove_body(self)
			return
		end
		local pos = self.object:get_pos()
		if self.lastpos and vector.distance(self.lastpos, pos) > .1 then
			bodytable[self.owner]["pos"] = pos
			self.time = os.time() + ghost_time
			bodytable[self.owner]["time"] = self.time
			update_bodies()
		end
		local parent = self.object:get_attach()
		if parent and parent:get_player_name() then
			if parent:get_player_control().jump then--i might be changing this key
				self.object:set_detach()
				self.object:set_acceleration({x=0,y=-9.81,z=0})
				bodies_dragging[parent:get_player_name()] = nil
			end
		end
		self.lastpos = pos
	end,
})

if beds then
	local original = beds.on_rightclick
	beds.on_rightclick = function(pos, player)
		local entity = bodies_dragging[player:get_player_name()]
		if entity then
			entity.object:set_detach()
			entity.object:set_acceleration({x=0,y=-9.81,z=0})
			bodies_dragging[player:get_player_name()] = nil
			local yaw, param2 = get_look_yaw(pos)
			--entity.object:set_yaw(yaw)
			local dir = minetest.facedir_to_dir(param2)
			-- p.y is just above the nodebox height of the 'Simple Bed' (the highest bed),
			-- to avoid sinking down through the bed.
			local p = {
				x = pos.x + dir.x / 2,
				y = pos.y + 0.07,
				z = pos.z + dir.z / 2
			}
			entity.object:set_pos(p)
			beds.spawn[entity.owner] = p
			beds.save_spawns()
			return
		end
		original(pos, player)
	end
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local pos = player:get_pos()
	if not bodytable[name] then return end
	if bodytable[name]["pos"] then
		player:set_pos(bodytable[name]["pos"])
		minetest.chat_send_player(name, "You were moved while you were sleeping.")
	end
	if bodytable[name]["inv"] then
		local player_inv = player:get_inventory()
		local lists = {}
		for listname, serializedList in pairs(bodytable[name]["inv"]) do
			lists[listname] = deserializeContents(serializedList)
		end
		player_inv:set_lists(lists)
		minetest.chat_send_player(name, "Your inventory was edited while you were sleeping.")
	end
	if bodytable[name]["hp"] then
		player:set_hp(bodytable[name]["hp"])
		minetest.chat_send_player(name, "You were damaged while you were sleeping.")
	end
	bodytable[name] = nil
	storage:set_string("bodytable", minetest.serialize(bodytable))
end)

local function place_bone(player, sleeping)
	local pos = player:get_pos()
	local name = player:get_player_name()
	if minetest.check_player_privs(name, {give=true}) or minetest.check_player_privs(name, {creative=true}) then return end
	local player_inv = player:get_inventory()
	local lists = player_inv:get_lists()
	local listtable = {}
	for listname, list in pairs(lists) do
		listtable[listname] = serializeContents(list)
	end
	pos.y = pos.y-- + 1
	local props = player:get_properties()
	local yaw = player:get_look_horizontal()
	bodytable[name]= {}
	bodytable[name]["time"] = os.time() + ghost_time
	local e = minetest.add_entity(pos, "anticombatlog:entity", minetest.serialize({owner = name, sleeping = sleeping, expiretime = os.time() + ghost_time, mesh = props.mesh, textures = props.textures, yaw = yaw, inv = listtable, hp = player:get_hp(), armor_groups = player:get_armor_groups()}))
end

minetest.register_on_leaveplayer(function(player)
	place_bone(player, true)
end)

minetest.register_on_shutdown(function()
	for _,player in ipairs(minetest.get_connected_players()) do
		place_bone(player, true)
	end
end)

--[[minetest.register_on_dieplayer(function(player)
	place_bone(player)
end)--]]
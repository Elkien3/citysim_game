local share_bones_time = tonumber(minetest.settings:get("share_bones_time")) or 3600
local remove_bones_time = tonumber(minetest.settings:get("remove_bones_time")) or 0
bones_entity = {}

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

function bones_take_one(self, player, stack)
	if stack and string.find(stack:get_name(), "currency:minegeld") then return true end
	if stack and string.find(stack:get_name(), "medical:") then return true end
	if not minetest.settings:get_bool("bones_steal_one", false) then return false end
	local name = player:get_player_name()
	if not name then return false end
	if not self.steallist then self.steallist = {} end
	if self.steallist[name] then return false end
	self.steallist[name] = true
	return true
end

local boneid = 0--goes up every time a bone is activated, reboot to reset. used for seperating bone inventories from the same player from each other

minetest.register_entity("bones_entity:entity", {
	hp_max = 1,
	physical = true,
	weight = 5,
	collisionbox = {-0.3, -.01, -0.3, 0.3, .2, 0.3},
	visual = "mesh",
	mesh = "character.b3d",
	textures = {"invisible.png"},
	is_visible = true,
	makes_footstep_sound = false,
    automatic_rotate = false,
    on_activate = function(self, staticdata, dtime_s)
		if not self.owner then
			local deserialized = minetest.deserialize(staticdata)
			if deserialized then
				self.inv = deserializeContents(deserialized.inv)
				if deserialized.owner then
					self.owner = deserialized.owner
				end
				boneid = boneid + 1
				self.boneid = boneid
				if deserialized.expiretime then
					self.time = deserialized.expiretime
					if self.time < os.time() then
						self.object:set_properties({infotext = self.owner.."'s old bones"})
						self.steallist = nil
					else
						self.object:set_properties({infotext = self.owner.."'s fresh bones"})
						minetest.after(self.time-os.time(), function(self) 
							self.object:set_properties({infotext = self.owner.."'s old bones"})
							self.steallist = nil
						end, self)
					end
				end
				if deserialized.removetime then
					self.removetime = deserialized.removetime
					if self.removetime < os.time() then
						self.object:remove()
					else
						minetest.after(self.removetime-os.time(), function(self) 
							self.object:remove()
						end, self)
					end
				end
				if deserialized.steallist then
					self.steallist = deserialized.steallist
				end
				local inv = minetest.create_detached_inventory("bones_"..self.owner..self.boneid, {
					allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
						return 0
					end,
					allow_put = function(inv, listname, index, stack, player)
						return 0
					end,
					allow_take = function(inv, listname, index, stack, player)
						if not self or not self.object or not self.object:get_pos() then return 0 end
						local name = player:get_player_name()
						if not name or vector.distance(player:get_pos(), self.object:get_pos()) > 10 then return 0 end
						if name == self.owner or self.time < os.time() or minetest.check_player_privs(name, "protection_bypass") or bones_take_one(self, player, stack) then
							return stack:get_count()
						end
						return 0
					end,
					on_take = function(inv, listname, index, stack, player)
						self.inv = inv:get_list("main")
						if inv:is_empty("main") then
							self.object:remove()
						end
					end,
				})
				inv:set_size("main", 8 * 6)
				inv:set_list("main",self.inv)
				if inv:is_empty("main") then
					self.object:remove()
				end
			end
			self.object:set_armor_groups({immortal = 1})
			self.object:set_acceleration({x=0,y=-10,z=0})
			if deserialized.mesh and deserialized.textures and deserialized.yaw then
				self.mesh = deserialized.mesh
				self.textures = deserialized.textures
				self.yaw = deserialized.yaw
				self.object:set_properties({mesh = deserialized.mesh, textures = deserialized.textures})
				self.object:set_yaw(deserialized.yaw)
				self.object:set_animation({x=162,y=167}, 1)
			end
		end
    end,
	get_staticdata = function(self)
		return minetest.serialize({owner = self.owner, expiretime = self.time, removetime = self.removetime, mesh = self.mesh, textures = self.textures, yaw = self.yaw, inv = serializeContents(self.inv), steallist = self.steallist})
	end,
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local name = puncher:get_player_name()
		if name ~= self.owner and self.time > os.time() and not minetest.check_player_privs(name, "protection_bypass") then return end
		
		local player_inv = puncher:get_inventory()
		local has_space = true
		local inv = minetest.get_inventory({type="detached", name="bones_"..self.owner..self.boneid})
		--The MIT License (MIT) (Following 12 lines)
		--Copyright (C) 2012-2016 PilzAdam
		--Copyright (C) 2012-2016 Various Minetest developers and contributors
		for i = 1, inv:get_size("main") do
			local stk = inv:get_stack("main", i)
			if player_inv:room_for_item("main", stk) then
				inv:set_stack("main", i, nil)
				player_inv:add_item("main", stk)
			else
				has_space = false
				break
			end
		end
		-- remove bones if player emptied them
		if has_space then
			self.object:remove()
		else
			self.inv = inv:get_list("main")
		end
    end,
	on_deactivate = function(self, removal)
		minetest.remove_detached_inventory("bones_"..self.owner..self.boneid)
	end,
    on_rightclick = function(self, clicker)
		local name = clicker:get_player_name()
		if not self.owner then return end
		local invname = "bones_"..self.owner..self.boneid
		local formspec =
			   "size[12,9]"..
			   "list[detached:"..invname..";main;0,0;12,4;]"..
			   "list[current_player;main;2,5;8,4;]"
		minetest.show_formspec(name, "bones_inv", formspec)
    end
})

bones_entity.place_bones = function(player)
	local name = player:get_player_name()
	local pos = player:get_pos()
	local player_inv = player:get_inventory()
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
	if player_inv:is_empty("main") and
		player_inv:is_empty("craft") then
		return
	end
	local steallist
	if medical and medical.data[name] then
		steallist = medical.data[name].steallist
	end
	local inv = minetest.create_detached_inventory("bones_"..name, {})--temporary inventory in order to serialize to bones object
	inv:set_size("main", 8 * 6)
	--The MIT License (MIT) (Following 14 lines)
	--Copyright (C) 2012-2016 PilzAdam
	--Copyright (C) 2012-2016 Various Minetest developers and contributors
	for i = 1, player_inv:get_size("craft") do
		local stack = player_inv:get_stack("craft", i)
		if inv:room_for_item("main", stack) then
			inv:add_item("main", stack)
		else
			--drop if no space left
			drop(pos, stack)
		end
	end
	--armor support
	if armor then
		local name, armor_inv = armor:get_valid_player(player, "[on_dieplayer]")
		if name then
			local drop = {}
			for i=1, armor_inv:get_size("armor") do
				local stack = armor_inv:get_stack("armor", i)
				if stack:get_count() > 0 then
					if inv:room_for_item("main", stack) then
						inv:add_item("main", stack)
					else
						--drop if no space left
						drop(pos, stack)
					end
					armor:set_inventory_stack(player, i, nil)
					armor:run_callbacks("on_unequip", player, i, stack)
				end
			end
		end
	end
	pos.y = pos.y + .1
	local props = player:get_properties()
	local yaw = player:get_look_horizontal()
	local e = minetest.add_entity(pos, "bones_entity:entity", minetest.serialize({owner = name, expiretime = os.time() + share_bones_time, removetime = (remove_bones_time ~= 0 and os.time() + remove_bones_time), mesh = props.mesh, textures = props.textures, yaw = yaw, inv = serializeContents(inv:get_list("main")), steallist = steallist}))
	minetest.remove_detached_inventory("bones_"..name)
	player_inv:set_list("main", {})
	player_inv:set_list("craft", {})
	minetest.remove_detached_inventory("bones_"..name)
end

minetest.register_on_dieplayer(bones_entity.place_bones)
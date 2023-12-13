local gunitems = {}
local invsize = minetest.settings:get("invsize") or 32

minetest.register_entity("spriteguns:gunitem",{
	hp_max = 1,
	visual="wielditem",
	visual_size={x=.4,y=.4},
	collisionbox = {0,0,0,0,0,0},
	physical=false,
	textures={"air"},
	on_activate = function(self, staticdata)
		if not staticdata or staticdata == "" then self.object:remove() return end
		local data = minetest.deserialize(staticdata)
		if not data or not data.owner or not data.item then self.object:remove() return end
		local player = minetest.get_player_by_name(data.owner)
		if not player then gunitems[data.owner] = nil self.object:remove() return end
		self.object:set_attach(player, "Body", {x=0,y=4,z=1.5}, {x=0,y=0,z=0})
		self.object:set_properties({textures = { data.item }})
	end
})

local function get_weapons(player)
	local name = player:get_player_name()
	local inv = player:get_inventory()
	assert(name, "invalid player")
	assert(inv, "invalid inventory")
	local lists = inv:get_lists()
	local weapons = {}
	for list, data in pairs(lists) do
		local size = inv:get_size(list)
		for i = 1, size do
			
			local stack = inv:get_stack(list, i)
			local stackname = stack:get_name()
			if stackname then
				local stacksub = stackname
				if spriteguns.registered_guns[stacksub] and not spriteguns.registered_guns[stacksub].concealed then
					if (wieldview or wield3d) and list == "main" and player:get_wield_index() == i then
						weapons["wield"] = stackname
					else
						table.insert(weapons, stackname)
					end
				end
			end
		end
	end
	return weapons
end

local function get_largest(weapons)
	local size = 0
	local bigindex
	for index, weapon in pairs(weapons) do
		if index ~= "wield" then
			local gunsize = spriteguns.registered_guns[weapon].space
			if gunsize and gunsize > size then size = gunsize bigindex = index end
		end
	end
	return bigindex or 1
end

local function update_weapon(player)
	local weapons = get_weapons(player)
	local weapon = weapons[get_largest(weapons)]
	local name = player:get_player_name()
	local gunspace = 0
	for index, gun in pairs(weapons) do
		gun = gun or ""
		local def = spriteguns.registered_guns[gun]
		if def and def.space then
			gunspace = gunspace + def.space-1
		end
	end
	local player_inv = player:get_inventory()
	local newspace = invsize-gunspace
	if newspace < 1 then newspace = 1
	if invsize-gunspace ~= player_inv:get_size("main") then
		for i = newspace+1, invsize do
			minetest.item_drop(player_inv:get_stack("main", i), player, player:get_pos())
		end
		player_inv:set_size("main", newspace)
	end
	if not weapon then
		if gunitems[name] then
			gunitems[name]:remove()
			gunitems[name] = nil
		end
		return
	end
	if not gunitems[name] then
		gunitems[name] = minetest.add_entity(player:get_pos(), "spriteguns:gunitem", minetest.serialize({owner = name, item = weapon}))
	else
		gunitems[name]:set_properties({textures = { weapon }})
	end
end

minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
	--minetest.chat_send_all("oi")
	--return 0
end)
--[[    * Determines how much of a stack may be taken, put or moved to a
      player inventory.
    * `player` (type `ObjectRef`) is the player who modified the inventory
      `inventory` (type `InvRef`).
    * List of possible `action` (string) values and their
      `inventory_info` (table) contents:
        * `move`: `{from_list=string, to_list=string, from_index=number, to_index=number, count=number}`
        * `put`:  `{listname=string, index=number, stack=ItemStack}`
        * `take`: Same as `put`
    * Return a numeric value to limit the amount of items to be taken, put or
      moved. A value of `-1` for `take` will make the source stack infinite.--]]

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	local stack = inventory_info.stack
	if not stack and action == "move" then
		stack = inventory:get_stack(inventory_info.to_list, inventory_info.to_index)
		if not stack or not spriteguns.registered_guns[stack:get_name()] then
			stack = inventory:get_stack(inventory_info.from_list, inventory_info.from_index)
		end
	end
	if stack and spriteguns.registered_guns[stack:get_name()] then
		update_weapon(player)
	end
end)

minetest.register_on_joinplayer(function(player, last_login)
	update_weapon(player)
end)
minetest.register_on_leaveplayer(function(player, last_login)
	local name = player:get_player_name()
	if gunitems[name] then
		gunitems[name]:remove()
		gunitems[name] = nil
	end
end)
minetest.register_on_respawnplayer(function(player, last_login)
	local name = player:get_player_name()
	if gunitems[name] then
		gunitems[name]:remove()
		gunitems[name] = nil
	end
end)

if armor then 
	local origfunc = armor.update_player_visuals
	armor.update_player_visuals = function(self, player)
		minetest.after(0, update_weapon, player)
		return origfunc(self, player)
	end
else
	local wieldtimer = 0
	local lastwield = {}
	minetest.register_globalstep(function(dtime)
		wieldtimer = wieldtimer + dtime
		if wieldtimer > .5 then
			for _,player in ipairs(minetest.get_connected_players()) do
				local name = player:get_player_name()
				local wielditem = player:get_wielded_item():get_name()
				if not lastwield[name] then lastwield[name] = wielditem else
					if wielditem ~= lastwield[name] then
						update_weapon(player)
					end
					lastwield[name] = wielditem
				end
			end
			wieldtimer = 0
		end
	end)
end

local function reattach()
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if gunitems[name] then
			gunitems[name]:set_attach(player, "Body", {x=0,y=4,z=1.5}, {x=0,y=0,z=0})
		end
	end
	minetest.after(5, reattach)
end
--minetest.after(5, reattach) --uncomment if you have issues with item getting detached in multiplayer
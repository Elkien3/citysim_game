
-- Load support for intllib.
local path = minetest.get_modpath(minetest.get_current_modname()) .. "/"

local S = minetest.get_translator and minetest.get_translator("mobs_farm") or
		dofile(path .. "intllib.lua")

mobs.intllib = S

mobs_farm = {}
mobs_farm.round = function(num)
	if not num then return end
	return math.floor(num+.5)
end

minetest.register_node("mobs_farm:bones", {
	description = S("Animal Bones"),
	inventory_image = "bones_inv.png",
	wield_image = "bones_inv.png",
	tiles = {"bones_bone.png"},
	drawtype = "nodebox",
	node_box = {
			type = "fixed",
			fixed = {
				{-0.125, -0.5, -0.5, 0.0625, -0.375, 0.0625}, -- NodeBox1
				{-0.1875, -0.5, 0.0625, 0.125, -0.3125, 0.25}, -- NodeBox2
				{0.0625, -0.5, -0.5, 0.3125, -0.4375, -0.375}, -- NodeBox3
				{-0.375, -0.5, -0.5, -0.125, -0.4375, -0.375}, -- NodeBox4
				{0.0625, -0.5, -0.3125, 0.3125, -0.4375, -0.25}, -- NodeBox5
				{-0.375, -0.5, -0.3125, -0.125, -0.4375, -0.25}, -- NodeBox6
				{-0.375, -0.4375, -0.3125, -0.3125, -0.3125, -0.25}, -- NodeBox7
				{0.25, -0.4375, -0.3125, 0.3125, -0.3125, -0.25}, -- NodeBox8
				{0, -0.3125, -0.3125, 0.3125, -0.25, -0.25}, -- NodeBox9
				{-0.375, -0.3125, -0.3125, -0.0625, -0.25, -0.25}, -- NodeBox10
				{-0.0625, -0.3125, -0.3125, 0, -0.25, -0.0625}, -- NodeBox11
				{-0.375, -0.5, -0.1875, -0.125, -0.4375, -0.125}, -- NodeBox12
				{-0.375, -0.3125, -0.1875, -0.0625, -0.25, -0.125}, -- NodeBox13
				{-0.375, -0.4375, -0.1875, -0.3125, -0.3125, -0.125}, -- NodeBox14
				{0.0625, -0.5, -0.1875, 0.3125, -0.4375, -0.125}, -- NodeBox15
				{0.25, -0.4375, -0.1875, 0.3125, -0.3125, -0.125}, -- NodeBox16
				{0.375, -0.5, -0.4375, 0.4375, -0.4375, -0.125}, -- NodeBox17
				{-0.4375, -0.5, -0.25, -0.375, -0.4375, 0.0625}, -- NodeBox18
				{-0.3125, -0.5, 0.125, -0.1875, -0.4375, 0.4375}, -- NodeBox19
				{0.1875, -0.5, 0, 0.25, -0.375, 0.4375}, -- NodeBox20
				{0.3125, -0.5, -0.0625, 0.5, -0.4375, 0.125}, -- NodeBox21
				{0.25, -0.375, -0.125, 0.4375, -0.1875, 0.1875}, -- NodeBox23
				{0.3125, -0.4375, -0.0625, 0.4375, -0.375, 0.125}, -- NodeBox28
				{0.3125, -0.5, 0.4375, 0.5, -0.4375, 0.5}, -- NodeBox29
				{-0.4375, -0.5, 0.1875, -0.375, -0.4375, 0.375}, -- NodeBox30
				{0.4375, -0.25, -0.125, 0.5, -0.1875, 0.1875}, -- NodeBox31
				{0.4375, -0.375, -0.125, 0.5, -0.3125, 0.1875}, -- NodeBox32
				{0.4375, -0.3125, -0.125, 0.5, -0.25, -0.0625}, -- NodeBox33
				{0.4375, -0.3125, 0.125, 0.5, -0.25, 0.1875}, -- NodeBox34
				{0.4375, -0.3125, 0, 0.5, -0.25, 0.0625}, -- NodeBox35
			}
		},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = true,
	groups = {dig_immediate = 2, attached_node = 1, temp_pass = 1, falling_node = 1},
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local name
		if player then name = player:get_player_name() end
		if meta:get_string("infotext") == "" then
			return true
		else
			return minetest.is_protected(pos, name)
		end
	end,
	--sounds = default.node_sound_gravel_defaults(),
})

mobs_farm.on_die = function(self, pos)
	if not self.owner or self.owner == "" then return end
	local bonepos
	if minetest.get_node(pos).name == "air" then
		bonepos = pos
	else
		bonepos = minetest.find_node_near(pos, 2, "air", false)
	end
	if bonepos then
		minetest.set_node(bonepos, {name = "mobs_farm:bones"})
		local str = self.owner.."'s "..self.name
		local cod = self.cause_of_death
		if self.nametag then
			str = str.." '"..self.nametag.."'"
		end
		str = str.." died from "
		if cod.puncher then
			local punchername = ""
			if cod.puncher:is_player() then
				punchername = cod.puncher:get_player_name()
			elseif cod.puncher:get_luaentity() then
				local owner = cod.puncher:get_luaentity().owner
				if owner then
					str = str..owner.."'s "
				end
				punchername = cod.puncher:get_luaentity().name
			end
			str = str..punchername.."'s "
		end
		str = str..(cod.node or cod.type or "unknown")
		if cod.puncher and cod.puncher:is_player() and cod.puncher:get_wielded_item():get_name() ~= "" then
			str = str.." (holding "..cod.puncher:get_wielded_item():get_name()..")"
		end
		local meta = minetest.get_meta(bonepos)
		--minetest.chat_send_all(dump(cod))
		meta:set_string("infotext", str)
	end
	return false
end


local bowltbl = {}
bowltbl["bucket:bucket_water"] = "mobs_farm:pet_bowl_water"
bowltbl["mobs:meat_raw"] = "mobs_farm:pet_bowl_meat"
bowltbl["fishing:fish_raw"] = "mobs_farm:pet_bowl_fish"
bowltbl["default:grass_1"] = "mobs_farm:pet_bowl_grass"

local function get_item(nodename)
	for item, node in pairs(bowltbl) do
		if node == nodename then
			return item
		end
	end
end

local bowldef = {
	description = "Pet Bowl",
	groups = {crumbly = 3},
	tiles = {
		"pet_bowl.png",
		"pet_bowl.png",
		"pet_bowl.png",
		"pet_bowl.png",
		"pet_bowl.png",
		"pet_bowl.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, -0.1875, 0.1875, -0.375, 0.1875}, -- NodeBox1
			{-0.1875, -0.5, 0.1875, 0.1875, -0.25, 0.3125}, -- NodeBox2
			{-0.3125, -0.5, -0.1875, -0.1875, -0.25, 0.1875}, -- NodeBox3
			{-0.1875, -0.5, -0.3125, 0.1875, -0.25, -0.1875}, -- NodeBox4
			{0.1875, -0.5, -0.1875, 0.3125, -0.25, 0.1875}, -- NodeBox5
		}
	},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local tool = itemstack:get_name()
		if bowltbl[tool] then
			minetest.set_node(pos, {name = bowltbl[tool]})
			itemstack:take_item()
			clicker:set_wielded_item(itemstack)
			if tool == "bucket:bucket_water" then
				local inv = clicker:get_inventory()
				local newstack = ItemStack("bucket:bucket_empty")
				if inv:room_for_item("main", newstack) then
					minetest.after(0, function(inv, newstack) inv:add_item("main", newstack) end, inv, newstack)
				else
					minetest.add_item(pos, newstack)
				end
			end
		end
		return itemstack
	end,
}

minetest.register_node("mobs_farm:pet_bowl", table.copy(bowldef))

minetest.register_craft({
	output = "mobs_farm:pet_bowl",
	recipe = {{"basic_materials:plastic_sheet", "dye:red", "basic_materials:plastic_sheet"},
		{"", "basic_materials:plastic_sheet", ""},
	}
})

local after_dig_node = function(pos, oldnode, oldmetadata, digger)
	minetest.add_item(pos, get_item(oldnode.name))
end

bowldef.tiles[1] = "pet_bowl_water.png"
bowldef.node_box.fixed[1] = {-0.1875, -0.5, -0.1875, 0.1875, -0.3125, 0.1875} -- NodeBox1
bowldef.on_rightclick = nil
bowldef.groups.not_in_creative_inventory = 1
bowldef.description = "Pet Bowl with Water"
bowldef.drop = "mobs_farm:pet_bowl"
minetest.register_node("mobs_farm:pet_bowl_water", table.copy(bowldef))
bowldef.after_dig_node = after_dig_node
bowldef.description = "Pet Bowl with Meat"
bowldef.tiles[1] = "pet_bowl_meat.png"
minetest.register_node("mobs_farm:pet_bowl_meat", table.copy(bowldef))
bowldef.description = "Pet Bowl with Fish"
bowldef.tiles[1] = "pet_bowl_fish.png"
minetest.register_node("mobs_farm:pet_bowl_fish", table.copy(bowldef))
bowldef.description = "Pet Bowl with Grass"
bowldef.tiles[1] = "pet_bowl_grass.png"
minetest.register_node("mobs_farm:pet_bowl_grass", table.copy(bowldef))

function mobs_farm.get_stay_near(self, food, water)
	if not self.owner or self.owner == "" then return nil end
	if not water then water = {"default:water_source", "static_ocean:water_source"} end
	local stay_near = {{}, 10}
	if not self.food or mobs_farm.round(self.food) < 20 then
		for i, item in pairs(food) do
			table.insert(stay_near[1], item)
		end
	end
	if not self.water or mobs_farm.round(self.water) < 20 then
		for i, item in pairs(water) do
			table.insert(stay_near[1], item)
		end
	end
	if self.water <= 4 or self.food <= 4 then
		--self.randomly_turn = false
		self.replace_rate = 2
	else
		--self.randomly_turn = true
		self.replace_rate = 4
	end
	return stay_near
end

-- Check for custom mob spawn file
local input = io.open(path .. "spawn.lua", "r")

if input then
	mobs.custom_spawn_animal = true
	input:close()
	input = nil
end


-- Animals
dofile(path .. "cow.lua") -- KrupnoPavel
dofile(path .. "chicken.lua")
dofile(path .. "bunny.lua")
dofile(path .. "kitten.lua")
dofile(path .. "wolf.lua")

-- Load custom spawning
if mobs.custom_spawn_animal then
	dofile(path .. "spawn.lua")
end


print (S("[MOD] Mobs Redo Animals loaded"))

cooking = {}
cooking.registered_stackcrafts = {}
cooking.registered_mixcrafts = {}
cooking.registered_cutcrafts = {}
cooking.registered_presscrafts = {}
cooking.registered_rollcrafts = {}
cooking.registered_cookcrafts = {}
cooking.registered_soupcrafts = {}

local mp = minetest.get_modpath("cooking")

minetest.register_craftitem("cooking:burnt_food", {
	description = "Burnt Food",
	inventory_image = "cooking_burnt_food.png",
	on_use = minetest.item_eat(-2)
})
minetest.register_craftitem("cooking:burnt_soup", {
	description = "Burnt Soup",
	inventory_image = "cooking_burnt_soup.png",
	param2 = 253,
	on_use = minetest.item_eat(-2, "cooking:bowl")
})

local function table_to_string(tbl)
	local str = ""
	if type(tbl) == "string" then return tbl end
	for i, item in pairs(tbl) do
		str = str..item
		if i ~= #tbl then
			str=str..","
		end
	end
	return str
end

cooking.register_craft = function(tbl)
	assert(tbl.type, "No Craft Type Specified")
	assert(tbl.recipe, "No Craft Recipe Specified")
	assert(tbl.output, "No Craft Output Specified")
	if unified_inventory then
		local output = table_to_string(tbl.output)
		for word in string.gmatch(tbl.output, '([^,]+)') do
			output = word
			break
		end
		local items
		if type(tbl.recipe) == "string" then
			items = {tbl.recipe}
		else
			items = table.copy(tbl.recipe)
		end
		unified_inventory.register_craft({
			type = string.gsub(tbl.type, "^%l", string.upper),
			output = output,
			items = items,
			width = 0,
		})
	end
	if tbl.type == "oven" or tbl.type == "stove" then
		tbl.recipe = table_to_string(tbl.recipe)
		cooking.registered_cookcrafts[tbl.recipe] = {output = tbl.output, time = tbl.cooktime or 10, method = tbl.type}
		if not cooking.registered_cookcrafts[table_to_string(tbl.output)] then
			cooking.registered_cookcrafts[table_to_string(tbl.output)] = {output = tbl.burned or "cooking:burnt_food", time = 60, method = tbl.type}
		end
	elseif tbl.type == "cut" or tbl.type == "press" or tbl.type == "roll" then
		tbl.recipe = table_to_string(tbl.recipe)
		tbl.output = table_to_string(tbl.output)
		cooking["registered_"..tbl.type.."crafts"][tbl.recipe] = tbl.output
	elseif tbl.type == "stack" or tbl.type == "mix" or tbl.type == "soup" then
		tbl.output = table_to_string(tbl.output)
		cooking["registered_"..tbl.type.."crafts"][tbl.output] = tbl.recipe
	else
		assert(nil, "Invalid Craft Type")
	end
end

minetest.register_tool("cooking:rolling_pin", {
	description = "Rolling Pin",
	inventory_image = "jelys_pizzaria_rolling_pin_inv.png",
	tool_capabilities = {
		groupcaps = {cooking_roller = {maxlevel=3, uses=50, times={[3]=8}}}
	}
})

local item_offsets = {}
item_offsets["cooking:hand_press"] = {input = {x=2.5/16,y=0,z=0}, output = {x=-8/16,y=-.2,z=0}}
item_offsets["cooking:pot_4"] = {x=0,y=-7/16,z=0}
item_offsets["cooking:stove"] = {fuel = {x=0,y=-.05,z=-.1}, src = {x=0,y=.425,z=-.1}}
item_offsets["cooking:stove_active"] = item_offsets["cooking:stove"]
item_offsets["cooking:oven"] = {fuel = {x=0,y=-.3,z=-.1}, src = {x=0,y=.1,z=-.1}}
item_offsets["cooking:oven_active"] = item_offsets["cooking:oven"]
item_offsets["cooking:electric_stove"] = {src = {x=0,y=.34,z=-.25}}
item_offsets["cooking:electric_stove_active"] = item_offsets["cooking:electric_stove"]
item_offsets["cooking:electric_oven"] = {src = {x=0,y=-.08,z=0}}
item_offsets["cooking:electric_oven_active"] = item_offsets["cooking:electric_oven"]
	
function cooking.get_item_offset(node, index)
	local offset = item_offsets[node.name] or {x=0,y=-.45,z=0}
	if not offset.x then
		if offset[index] then
			offset = offset[index]
		else
			offset = offset["input"] or {x=0,y=-.45,z=0}
		end
	end
	local yaw = minetest.facedir_to_dir(node.param2)
	yaw = minetest.dir_to_yaw(yaw)
	offset = vector.rotate(offset, {x=0,y=yaw,z=0})
	if type(index) == "number" then
		offset.y = offset.y + (index*.06)
	end
	return offset
end

local function add_item(pos, stack, param2, flatten)
	local stackname = stack:get_name()
	local obj = minetest.add_entity(pos, "cooking:item", stack:to_string())
	if not obj then return nil end
	local itemdef = minetest.registered_items[stackname]
	local yaw = minetest.facedir_to_dir(param2)
	yaw = minetest.dir_to_yaw(yaw)
	yaw = yaw + math.random(-20,20)/100
	if itemdef.inventory_image == "" then
		obj:set_rotation({x=0, y=yaw, z=0})
		if flatten then
			obj:set_properties({visual_size = {x=.33, y=.07}})
		else
			local posy = math.floor(pos.y+.5)
			pos.y = pos.y + .125
			if math.floor(pos.y+.5) > posy then pos.y = posy+.5 end
			obj:set_pos(pos)
			obj:set_properties({visual_size = {x=.25, y=.25}})
		end
	else
		obj:set_rotation({x=-1.57075, y=yaw, z=0})
	end
	return obj
end

local crafter_on_rightclick = function(pos, node, clicker, itemstack, pointed_thing, single)
	stackname = itemstack:get_name()
	if stackname == "" then return end
	local meta = minetest.get_meta(pos)
	local tbl = minetest.deserialize(meta:get_string("table")) or {}
	if single and #tbl > 0 then return end
	local stackstring = ItemStack(itemstack)
	stackstring:set_count(1)
	stackstring = stackstring:to_string()
	table.insert(tbl, stackstring)
	local pos2 = vector.add(pos, cooking.get_item_offset(node, #tbl))
	if pos2.y-pos.y > .5 then return end
	meta:set_string("table", minetest.serialize(tbl))
	add_item(pos2, itemstack, node.param2, single ~= true)
	if not minetest.is_creative_enabled(clicker:get_player_name()) then
		itemstack:take_item()
	end
	return itemstack
end

function cooking.remove_items(pos, consume, tbl)
	local pos1 = vector.subtract(pos, .5)
	local pos2 = vector.add(pos, .5)
	local objects = minetest.get_objects_in_area(pos1, pos2)
	for i, obj in pairs(objects) do
		if obj and obj:get_entity_name() == "cooking:item" then-- and obj:get_luaentity().item == stackname then
			if consume ~= true then
				for i2, stackstring in pairs(tbl) do
					local itemstack = ItemStack(stackstring)
					local stackname = itemstack:get_name()
					if obj:get_luaentity() and obj:get_luaentity().item == stackname then
						--[[local drops = minetest.get_node_drops(item)
						if drops then
							item = drops[math.random(#drops)]
						end--]]
						minetest.add_item(vector.add(pos, cooking.get_item_offset(minetest.get_node(pos), "input")), itemstack)
						break
					end
				end
			end
			obj:remove()
		end
	end
end

local function is_stackcraft(tbl)
	if not cooking.registered_stackcrafts then return end
	local stacknames = {}
	for i, stackstring in pairs(tbl) do
		local stackname = ItemStack(stackstring):get_name()
		table.insert(stacknames, stackname)
	end
	for name, craft in pairs(cooking.registered_stackcrafts) do
		if table.concat(stacknames) == table.concat(craft) then
			return name
		end
	end
end

local function is_mixcraft(tbl, crafttype)
	if not crafttype then crafttype = "registered_mixcrafts" end--crafttype is not really useful atm, just for a possible soup craft in future
	if not string.find(crafttype, "registered_") then
		crafttype = "registered_"..crafttype
	end
	if not cooking[crafttype] then return end
	local stacknames = {}
	for i, stackstring in pairs(tbl) do
		local stackname = ItemStack(stackstring):get_name()
		table.insert(stacknames, stackname)
	end
	for name, craft in pairs(cooking[crafttype]) do
		local tblcopy = table.copy(stacknames)
		if #stacknames == #craft then
			for i, name in pairs(craft) do
				local hasitem = false
				for i2, name2 in pairs(tblcopy) do
					if name2 == name then
						table.remove(tblcopy, i2)
						hasitem = true
						break
					end
				end
				if not hasitem then return end
			end
		end
		if #tblcopy == 0 then return name end
	end
end

local function is_cutcraft(tbl)
	if not cooking.registered_cutcrafts then return end
	local stacknames = {}
	for i, stackstring in pairs(tbl) do
		local stackname = ItemStack(stackstring):get_name()
		table.insert(stacknames, stackname)
	end
	if #tbl ~= 1 then return end
	return cooking.registered_cutcrafts[stacknames[1]]
end

local function is_presscraft(tbl)
	if not cooking.registered_presscrafts then return end
	local stacknames = {}
	for i, stackstring in pairs(tbl) do
		local stackname = ItemStack(stackstring):get_name()
		table.insert(stacknames, stackname)
	end
	if #tbl ~= 1 then return end
	return cooking.registered_presscrafts[stacknames[1]]
end

local function is_rollcraft(tbl)
	if not cooking.registered_rollcrafts then return end
	local stacknames = {}
	for i, stackstring in pairs(tbl) do
		local stackname = ItemStack(stackstring):get_name()
		table.insert(stacknames, stackname)
	end
	if #tbl ~= 1 then return end
	return cooking.registered_rollcrafts[stacknames[1]]
end

local function is_soupcraft(tbl)
	return is_mixcraft(tbl, "registered_soupcrafts")
end

local crafter_on_dig = function(pos, node, digger, craftfunc, successfunc, nodignode)
	local meta = minetest.get_meta(pos)
	local tbl = minetest.deserialize(meta:get_string("table"))
	if tbl and #tbl > 0 then
		local results = {}
		if craftfunc then
			for substring in (craftfunc(tbl) or ""):gmatch("([^,]+)") do
			   table.insert(results, substring)
			end
		end
		if results and #results > 0 then
			for i, result in pairs(results) do
				cooking.remove_items(pos, true, tbl)
				local itemstack = ItemStack(result)
				if cooking_aftercraft then--if foodspoil is on, use one of its functions to get the newly crafted items expiration
					local craft_grid = {}
					for i2, stackstring in pairs(tbl) do
						table.insert(craft_grid, ItemStack(stackstring))
					end
					itemstack = cooking_aftercraft(itemstack, craft_grid)
				end
				tbl = {itemstack:to_string()}
				if successfunc then
					successfunc(pos, node, digger, itemstack)
				else
					minetest.add_item(vector.add(pos, cooking.get_item_offset(node, "output")), itemstack)
				end
			end
		else
			cooking.remove_items(pos, false, tbl)
		end
		meta:set_string("table", "")
		return false
	end
	if not nodignode then
		minetest.node_dig(pos, node, digger)
	end
	return true
end

function cooking.update_furnace_objects(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local tbl = {}
	tbl["fuel"] = inv:get_stack("fuel", 1):to_string()
	tbl["src"] = inv:get_stack("src", 1):to_string()
	cooking.remove_items(pos, true, tbl)
	for i, stackstring in pairs(tbl) do
		local itemstack = ItemStack(stackstring)
		local stackname = itemstack:get_name()
		local offset = cooking.get_item_offset(node, i)
		local obj = add_item(vector.add(pos, offset), itemstack, node.param2)
		if obj then
			local ent = obj:get_luaentity()
			ent.owner = pos
			ent.listname = i
			--local props = obj.get_properties()
			--props.pointable = true
			obj:set_properties({pointable = true})
		end
	end
end

function cooking.get_craft_result(tbl)
	local empty = {time = 0, item = ItemStack()}, {items = {}}
	if not tbl then return empty end
	local method = tbl.method
	local items = table.copy(tbl.items)
	if not method or not items then return empty end
	local item = items[1]
	if not item then return empty end
	item = item:get_name()
	local soup = item == "cooking:pot_4"
	if soup then
		local itemmeta = tbl.items[1]:get_meta()
		item = ItemStack(itemmeta:get_string("soup")):get_name()
	end
	if not cooking.registered_cookcrafts[item] then return empty end
	local craft = table.copy(cooking.registered_cookcrafts[item])
	if craft.method ~= method then return empty end
	if type(craft.output) == "string" then
		craft.output = ItemStack(craft.output)
	end
	if cooking_aftercraft then
		if soup then
			local itemmeta = tbl.items[1]:get_meta()
			craft.output = cooking_aftercraft(ItemStack(craft.output), {ItemStack(itemmeta:get_string("soup"))})
		else
			craft.output = cooking_aftercraft(ItemStack(craft.output), {tbl.items[1]})
		end
	end
	if soup then
		local itemmeta = craft.output:get_meta()
		local itemname = craft.output:get_name()
		itemmeta:set_string("soup", craft.output:to_string())
		itemmeta:set_string("description", "Pot of "..craft.output:get_description())
		itemmeta:set_string("palette_index", minetest.registered_items[itemname].param2 or "0")
		craft.output:set_name("cooking:pot_4")
	end
	local cooked = {time = craft.time, item = craft.output, replacements = craft.replacements}
	local aftercooked = {items = {}}
	return cooked, aftercooked
end

dofile(mp.."/ovenstove.lua")
if technic then
	dofile(mp.."/technic.lua")
end

minetest.register_entity("cooking:item",{
	initial_properties = {
		hp_max = 10,
		visual="wielditem",
		visual_size={x=.33,y=.33},
		collisionbox = {-.3,-.1,-.3,.3,.1,.3},
		pointable=false,
		textures={"air"},
	},
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local objpos = self.object:get_pos()
		local pos = self.owner or vector.round(objpos)
		local meta = minetest.get_meta(pos)
		local tbl = minetest.deserialize(meta:get_string("table"))
		if self.listname then
			local inv = meta:get_inventory()
			local playerinv = puncher:get_inventory()
			local itemstack = inv:get_stack(self.listname, 1)
			if not playerinv or not playerinv:add_item("main", itemstack):is_empty() then
				minetest.add_item(objpos, itemstack)
			end
			inv:remove_item(self.listname, itemstack)
			cooking.update_furnace_objects(pos)
			minetest.get_node_timer(pos):start(1.0)
		--[[elseif tbl then --unused code, was for picking out specific items from a stack, but i decided that its better to just have you start over if you put something wrong in.
			local newstack = ItemStack(tbl[#tbl])
			local inv = minetest.get_inventory({type="player", name=puncher:get_player_name()})
			if not inv or not inv:room_for_item("main", newstack) then return true end
			cooking.remove_items(pos, true, tbl)--]]
			--[[local index = pos.y - objpos.y
			index = (.45-index)/.06
			index = math.floor(index+.5)
			if not tbl[index] then return true end
			minetest.chat_send_all(tostring(index))--]]
			--[[table.remove(tbl)
			meta:set_string("table", minetest.serialize(tbl))
			for i, stackstring in pairs(tbl) do
				local itemstack = ItemStack(stackstring)
				local pos2 = vector.add(pos, cooking.get_item_offset(minetest.get_node(pos), i))
				add_item(pos2, itemstack:get_name(), minetest.get_node(pos).param2, true)
			end
			inv:add_item("main", newstack)
			return true
		else
			return true--]]
		end
		self.object:remove()
		return true
	end,
	on_activate = function(self, staticdata)
		if not staticdata or staticdata == "" then self.object:remove() return end
		local itemstack = ItemStack(staticdata)
		self.item = itemstack:get_name()
		local itemdef = minetest.registered_items[self.item]
		if not itemdef then self.object:remove() return end
		self.object:set_properties({
			textures={self.item},
			wield_item = itemstack
		})
	end,
	get_staticdata = function(self)
		--return self.item
	end,
})

minetest.register_node("cooking:plate", {
	description = "Plate",
	tiles = {
		"default_snow.png",
		"default_snow.png",
		"default_snow.png",
		"default_snow.png",
		"default_snow.png",
		"default_snow.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.3125, 0.3125, -0.4375, 0.3125}, -- NodeBox1
			{-0.4375, -0.4375, -0.5, 0.4375, -0.375, -0.3125}, -- NodeBox2
			{-0.4375, -0.4375, 0.3125, 0.4375, -0.375, 0.5}, -- NodeBox4
			{0.3125, -0.4375, -0.4375, 0.5, -0.375, 0.4375}, -- NodeBox5
			{-0.5, -0.4375, -0.4375, -0.3125, -0.375, 0.4375}, -- NodeBox6
		}
	},
	--[[selection_box = {
		type = "fixed",
		fixed = {
			{-4 / 16, -0.5, -4 / 16, 4 / 16, 0.5, 4 / 16},
			},
	},--]]
	sunlight_propagates = true,
	walkable = true,
	groups = {oddly_breakable_by_hand = 3, cookingholder = 1},
	on_rightclick = crafter_on_rightclick,
	on_dig = function(pos, node, digger)
		return crafter_on_dig(pos, node, digger, is_stackcraft)
	end,
})

minetest.register_tool("cooking:spoon", {
	description = "Mixing Spoon",
	inventory_image = "cooking_spoon.png",
})

local function register_mixer(name, value)
	if not name or not value then return end
	local groups = minetest.registered_items[name]
	if not groups then return end
	groups = groups.tool_capabilities or {}
	if not groups.groupcaps then
		groups.groupcaps = {}
	end
	groups.groupcaps.cooking_mixer = {maxlevel=3, uses=50, times={[3]=value}}
	minetest.override_item(name, {tool_capabilities = groups})
end

register_mixer("default:stick", 12)
register_mixer("cooking:spoon", 6)

minetest.register_node("cooking:mixing_bowl", {
	description = "Mixing Bowl",
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, -0.1875, 0.1875, -0.4375, 0.1875}, -- NodeBox7
			{-0.3125, -0.4375, 0.1875, 0.3125, -0.375, 0.3125}, -- NodeBox8
			{-0.3125, -0.4375, -0.3125, 0.3125, -0.375, -0.1875}, -- NodeBox4
			{-0.3125, -0.375, -0.375, 0.3125, 0.0625, -0.3125}, -- NodeBox5
			{0.3125, -0.375, -0.3125, 0.375, 0.0625, 0.3125}, -- NodeBox6
			{-0.375, -0.375, -0.3125, -0.3125, 0.0625, 0.3125}, -- NodeBox7
			{-0.3125, -0.4375, -0.3125, -0.1875, -0.375, 0.3125}, -- NodeBox8
			{0.1875, -0.4375, -0.3125, 0.3125, -0.375, 0.25}, -- NodeBox10
			{-0.3125, -0.375, 0.3125, 0.3125, 0.0625, 0.375}, -- NodeBox11
		}
	},
	--[[selection_box = {
		type = "fixed",
		fixed = {
			{-4 / 16, -0.5, -4 / 16, 4 / 16, 0.5, 4 / 16},
			},
	},--]]
	sunlight_propagates = true,
	walkable = true,
	groups = {oddly_breakable_by_hand = 3, cookingholder = 1, cooking_mixer = 3},
	on_rightclick = crafter_on_rightclick,
	on_dig = function(pos, node, digger)
		local craftfunc = is_mixcraft
		if digger then
			local tool = digger:get_wielded_item():get_tool_capabilities()
			if not tool or not tool.groupcaps or not tool.groupcaps.cooking_mixer then
				craftfunc = nil
			end
		end
		return crafter_on_dig(pos, node, digger, craftfunc)
	end,
})

local function register_cutter(name, value)
	if not name or not value then return end
	local groups = minetest.registered_items[name]
	if not groups then return end
	groups = groups.tool_capabilities or {}
	if not groups.groupcaps then
		groups.groupcaps = {}
	end
	groups.groupcaps.cooking_cutter = {maxlevel=3, uses=50, times={[3]=value}}
	minetest.override_item(name, {tool_capabilities = groups})
end

for name, value in pairs({wood = 8, stone = 6, bronze = 4, steel = 4, mese = 4, diamond = 4}) do
	register_cutter("default:sword_"..name, value)
end
--add any more swords/knives here


minetest.register_node("cooking:cutting_board", {
	description = "Cutting Board",
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.3125, 0.375, -0.4375, 0.3125}, -- NodeBox1
			{0.375, -0.5, -0.125, 0.4375, -0.4375, 0.125}, -- NodeBox2
			{-0.4375, -0.5, -0.125, -0.375, -0.4375, 0.125}, -- NodeBox3
		}
	},
	--[[selection_box = {
		type = "fixed",
		fixed = {
			{-4 / 16, -0.5, -4 / 16, 4 / 16, 0.5, 4 / 16},
			},
	},--]]
	sunlight_propagates = true,
	walkable = true,
	groups = {cookingholder = 1, cooking_cutter = 3, oddly_breakable_by_hand = 3, cooking_roller = 3},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		crafter_on_rightclick(pos, node, clicker, itemstack, pointed_thing, true)
	end,
	on_dig = function(pos, node, digger)
		local craftfunc
		if digger then
			local tool = digger:get_wielded_item():get_tool_capabilities()
			if tool and tool.groupcaps then
				if tool.groupcaps.cooking_cutter then
					craftfunc = is_cutcraft
				elseif tool.groupcaps.cooking_roller then
					craftfunc = is_rollcraft
				end
			end
		end
		return crafter_on_dig(pos, node, digger, craftfunc)
	end,
})

minetest.register_node("cooking:hand_press", {
	description = "Hand Press",
	tiles = {
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.125, 0.375, -0.0625, 0.1875}, -- NodeBox1
			{0, -0.0625, -0.125, 0.3125, 0, 0.1875}, -- NodeBox2
			{-0.0625, -0.0625, -0.125, 0, 0.125, 0.1875}, -- NodeBox4
			{0.3125, -0.0625, -0.125, 0.375, 0.125, 0.1875}, -- NodeBox5
			{0, -0.0625, -0.1875, 0.3125, 0.125, -0.125}, -- NodeBox6
			{0, -0.0625, 0.1875, 0.3125, 0.125, 0.25}, -- NodeBox8
			--{-0.4375, -0.25, -0.0625, -0.25, -0.0625, 0.125}, -- NodeBox9
			{0.375, -0.25, -0.0625, 0.4375, 0.25, 0.0625}, -- NodeBox10
		}
	},
	--[[selection_box = {
		type = "fixed",
		fixed = {
			{-4 / 16, -0.5, -4 / 16, 4 / 16, 0.5, 4 / 16},
			},
	},--]]
	sunlight_propagates = true,
	walkable = true,
	groups = {cookingholder = 1, oddly_breakable_by_hand = 3},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		crafter_on_rightclick(pos, node, clicker, itemstack, pointed_thing, true)
	end,
	on_dig = function(pos, node, digger)
		return crafter_on_dig(pos, node, digger, is_presscraft)
	end,
})

--Soup Pot

local function on_soup_craft(pos, node, digger, itemstack)
	local itemname = itemstack:get_name()
	local recipedef = cooking.registered_soupcrafts[itemname]
	node.param2 = minetest.registered_items[itemname].param2 or node.param2
	minetest.swap_node(pos, node)
	local meta = minetest.get_meta(pos)
	meta:set_string("soup", itemstack:to_string())
	meta:set_string("description", "Pot of "..itemstack:get_description())
end

local function pot_on_punch(pos, node, player, replacement)
	local meta = minetest.get_meta(pos)
	local player_inv = player:get_inventory()
	local itemstack = player:get_wielded_item()
	if itemstack:get_name() == "cooking:bowl" and meta:get_string("soup") ~= "" then
		node.name = replacement
		minetest.swap_node(pos, node)
		itemstack:take_item(1)
		if itemstack:get_count() > 0 then
			minetest.add_item(pos, player_inv:add_item("main", meta:get_string("soup")))
		else
			itemstack:replace(meta:get_string("soup"))
		end
		player:set_wielded_item(itemstack)
		if replacement == "cooking:pot_0" then
			node.name = "cooking:pot_0"
			node.param2 = 0
			minetest.set_node(pos, node)
		end
	elseif itemstack:get_name() == "bucket:bucket_empty" then
		node.name = "cooking:pot_0"
		node.param2 = 0
		if meta:get_string("soup") == "" then
			itemstack:replace("bucket:bucket_water")
			player:set_wielded_item(itemstack)
		end
		crafter_on_dig(pos, node, player, nil, nil, true)
		minetest.set_node(pos, node)
	end
	return itemstack
end
local potdef = {
	drawtype = "mesh",
	mesh = "cooking_pot_4.b3d",
	use_texture_alpha = true,
	tiles = {{name = "cooking_potuv.png", color = "white"}},
	overlay_tiles = {{name = "cooking_pot_overlay.png"}},
	description= "Filled Pot",
	paramtype = "light",
	paramtype2 = "color",
	palette = "palette.png",
	groups = {oddly_breakable_by_hand=3, cookingholder = 1, cooking_mixer = 3, not_in_creative_inventory = 1},
	legacy_facedir_simple = true,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.375, 0.25, 0.1875, -0.25}, -- NodeBox1
			{-0.25, -0.5, 0.25, 0.25, 0.1875, 0.375}, -- NodeBox3
			{-0.375, -0.5, -0.25, -0.25, 0.1875, 0.25}, -- NodeBox4
			{0.25, -0.5, -0.25, 0.375, 0.1875, 0.25}, -- NodeBox5
			{-0.25, -0.5, -0.25, 0.25, -0.375, 0.25}, -- NodeBox6
		}
	},
	on_punch = function(pos, node, player)
		return pot_on_punch(pos, node, player, "cooking:pot_3")
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		if meta:get_string("soup") == "" then
			return crafter_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
		else
			return itemstack
		end
	end,
	on_dig = function(pos, node, digger)
		local craftfunc = is_soupcraft
		if digger then
			local tool = digger:get_wielded_item():get_tool_capabilities()
			if not tool or not tool.groupcaps or not tool.groupcaps.cooking_mixer then
				craftfunc = nil
			end
		end
		return crafter_on_dig(pos, node, digger, craftfunc, on_soup_craft)
	end,
	preserve_metadata = function(pos, oldnode, oldmeta, drops)
		for i, drop in pairs(drops) do
			local itemmeta = drop:get_meta()
			itemmeta:set_string("soup", oldmeta.soup)
			itemmeta:set_string("description", oldmeta.description)
		end
		return drops
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local itemmeta = itemstack:get_meta()
		local meta = minetest.get_meta(pos)
		meta:set_string("description", itemmeta:get_string("description"))
		meta:set_string("soup", itemmeta:get_string("soup"))
	end,
}
minetest.register_node("cooking:pot_4", table.copy(potdef))

potdef.description= "3/4 Filled Pot"
potdef.on_dig = nil
potdef.on_rightclick = nil
potdef.mesh = "cooking_pot_3.b3d"
potdef.groups = {oddly_breakable_by_hand=3, not_in_creative_inventory=1}
potdef.on_punch = function(pos, node, player)
	return pot_on_punch(pos, node, player, "cooking:pot_2")
end
minetest.register_node("cooking:pot_3", table.copy(potdef))

potdef.description= "1/2 Filled Pot"
potdef.mesh = "cooking_pot_2.b3d"
potdef.on_punch = function(pos, node, player)
	return pot_on_punch(pos, node, player, "cooking:pot_1")
end
minetest.register_node("cooking:pot_2", table.copy(potdef))

potdef.description= "1/4 Filled Pot"
potdef.mesh = "cooking_pot_1.b3d"
potdef.on_punch = function(pos, node, player)
	return pot_on_punch(pos, node, player, "cooking:pot_0")
end
minetest.register_node("cooking:pot_1", table.copy(potdef))


potdef.description= "Empty Pot"
potdef.mesh = "cooking_pot_0.b3d"
potdef.groups = {oddly_breakable_by_hand=3}
potdef.on_punch = nil
potdef.on_rightclick = function(pos, node, clicker, itemstack)
	if itemstack:get_name() == "bucket:bucket_water" then
		node.name = "cooking:pot_4"
		minetest.swap_node(pos, node)
		return {name="bucket:bucket_empty"}
	end
end
potdef.preserve_metadata = function(pos, oldnode, oldmeta, drops)
	for i, drop in pairs(drops) do
		local itemmeta = drop:get_meta()
		itemmeta:from_table({})
	end
	return drops
end
potdef.after_place_node = nil
minetest.register_node("cooking:pot_0", table.copy(potdef))

minetest.register_craftitem("cooking:bowl", {
	description = "Bowl",
	inventory_image = "cooking_bowl.png",
	param2 = 222
})

minetest.register_lbm({
	name = "cooking:additems",
	nodenames = {"group:cookingholder"},
	run_at_every_load = true,
	action = function(pos, node, _, _)
		if minetest.get_item_group(node.name, "furnace") > 0 then
			return cooking.update_furnace_objects(pos)
		end
		local meta = minetest.get_meta(pos)
		local tbl = minetest.deserialize(meta:get_string("table"))
		if not tbl then return end
		for i, stackstring in pairs(tbl) do
			local itemstack = ItemStack(stackstring)
			local pos2 = vector.add(pos, cooking.get_item_offset(node, i))
			add_item(pos2, itemstack, node.param2, true)
		end
	end,
})

dofile(mp.."/crafts.lua")
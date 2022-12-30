-- textures LGLv2.1" = "ShadMOrdre.  Tenplus1, Gail de Sailly, VannessaE, runs, and numerous others."
oil = {}
oil.fueling = {}

minetest.register_node("oil:gasoline_source", {
	description = "Gasoline Source",
	drawtype = "liquid",
	waving = 3,
	tiles = {
		{
			name = "cars_gasoline_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
		{
			name = "cars_gasoline_source_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	alpha = 240,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	lifetime = 30,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquid_renewable = false,
	liquidtype = "source",
	liquid_alternative_flowing = "oil:gasoline_flowing",
	liquid_alternative_source = "oil:gasoline_source",
	liquid_viscosity = 4,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, vaporizable = 1, flammable = 1},
	sounds = default.node_sound_water_defaults(),
	gas = "oil:gasoline_vapor"
})

minetest.register_node("oil:gasoline_flowing", {
	description = "Gasoline Flowing",
	drawtype = "flowingliquid",
	waving = 3,
	tiles = {"cars_gasoline_source.png"},
	special_tiles = {
		{
			name = "cars_gasoline_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			},
		},
		{
			name = "cars_gasoline_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			},
		},
	},
	alpha = 240,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquid_renewable = false,
	liquidtype = "flowing",
	liquid_alternative_flowing = "oil:gasoline_flowing",
	liquid_alternative_source = "oil:gasoline_source",
	liquid_viscosity = 4,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, not_in_creative_inventory = 1, flammable = 1},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("oil:oil_source", {
	description = "Crude Oil Source",
	drawtype = "liquid",
	waving = 3,
	tiles = {
		{
			name = "cars_oil_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
		{
			name = "cars_oil_source_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	alpha = 240,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquid_renewable = false,
	liquidtype = "source",
	liquid_alternative_flowing = "oil:oil_flowing",
	liquid_alternative_source = "oil:oil_source",
	liquid_viscosity = 4,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, vaporizable = 1, flammable = 1},
	sounds = default.node_sound_water_defaults(),
	gas = "oil:gasoline_vapor",
	gas_byproduct = "oil:tar",
	gas_byproduct_chance = 1
})

minetest.register_node("oil:oil_flowing", {
	description = "Crude Oil Flowing",
	drawtype = "flowingliquid",
	waving = 3,
	tiles = {"cars_oil_source.png"},
	special_tiles = {
		{
			name = "cars_oil_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			},
		},
		{
			name = "cars_oil_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			},
		},
	},
	alpha = 240,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquid_renewable = false,
	liquidtype = "flowing",
	liquid_alternative_flowing = "oil:oil_flowing",
	liquid_alternative_source = "oil:oil_source",
	liquid_viscosity = 4,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, not_in_creative_inventory = 1, flammable = 1},
	sounds = default.node_sound_water_defaults(),
})

dynamic_liquid.liquid_abm("oil:oil_source", "oil:oil_flowing", 1)
dynamic_liquid.liquid_abm("oil:gasoline_source", "oil:gasoline_flowing", 1)
if waterworks then
	waterworks.register_liquid("oil:oil_source", {flowing = "oil:oil_flowing"})
	waterworks.register_liquid("oil:gasoline_source", {flowing = "oil:gasoline_flowing"})
end

minetest.register_node("oil:tar", {
	description = "Tar Block",
	tiles = {"cars_oil_source.png"},
	groups = {oddly_breakable_by_hand = 1},
	drop = "oil:tar_item 9"
})
minetest.register_craftitem("oil:tar_item", {
	description = "Tar",
	inventory_image = "cars_oil_source.png",
})
minetest.register_craft({
	recipe = {
		{"oil:tar_item", "oil:tar_item", "oil:tar_item"},
		{"oil:tar_item", "oil:tar_item", "oil:tar_item"},
		{"oil:tar_item", "oil:tar_item", "oil:tar_item"},
	},
	output = "oil:tar"
})
--replace asphalt craft if able
if minetest.get_modpath("technic") and minetest.get_modpath("streets") then
	minetest.clear_craft({output = "streets:asphalt"})
	technic.register_alloy_recipe({input = {"oil:tar_item", "default:gravel 32"}, output = "streets:asphalt 32"})
end

minetest.register_ore({
	ore_type = "blob",
	ore = "oil:oil_source",
	wherein = "default:stone",
	clust_scarcity = 32 * 32 * 32,
	clust_num_ores = 16,
	clust_size = 6,
	y_min = -31000,
	y_max = -64,
})

bucket.register_liquid(
	"oil:gasoline_source",
	"oil:gasoline_flowing",
	"oil:bucket_gasoline",
	"bucket_water.png",
	"Gasoline Bucket",
	{tool = 1, gasoline_bucket = 1}
)
bucket.register_liquid(
	"oil:oil_source",
	"oil:oil_flowing",
	"oil:bucket_oil",
	"bucket_water.png",
	"Oil Bucket",
	{tool = 1, oil_bucket = 1}
)

gas_lib.register_gas("oil:gasoline_vapor", {
	description = 'Gasoline Vapor',
	tiles = {{
		name = "smoke.png^gui_hb_bg.png",
		--backface_culling=false,
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 6,
		},
	}},
	inventory_image = "smoke.png^[verticalframe:16:1^gui_hb_bg.png",
	wield_image =  "smoke.png^[verticalframe:16:1^gui_hb_bg.png",
	post_effect_color = {a = 60, r = 100, g = 100, b = 100},
	damage_per_second = 1,
	drowning = 1,
	interval = 3,
	weight = -8,
	deathchance = 2,
	liquid = "oil:gasoline_source"
})

local bucket_liters = 1000
local pump_capacity = 2*bucket_liters

local reclick_stopper = {}

local function form_pump(pos, owner)
	local meta = minetest.get_meta(pos)
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
	local price = meta:get_string("price")
	if price == "" then price = "0" end
	local form = "size[8,7]" ..
		"list[current_player;main;0,3;8,4;0]" ..
		"list[nodemeta:"..spos..";input;6,0.9;1,1.1;0]" ..
		"label[5.7,0.1;Gas: "..meta:get_int("gas").."L]" ..
		"label[5.7,0.4;Bought: "..meta:get_int("gasbought").."L]" ..
		"button_exit[6,1.8;1,1;buy;Buy]"..
		"label[5.7,-.2;Price: "..price.." minegeld/L]"
		if owner then
			form = form..
				"label[0.5,0;Customers gave:]" ..
				"list[nodemeta:" .. spos .. ";output;0.5,0.5;2.5,2;0]"..
				"field[3,0.6;2.5,1;price;Price (minegeld/L);"..price.."]"
		else
			
		end
	return form
end

local form_table = {}

local function rotateVector(x, y, a)
  local c = math.cos(a)
  local s = math.sin(a)
  return c*x - s*y, s*x + c*y
end

oil.stopfuel = function(name)
	local data = oil.fueling[name]
	if not data then return end
	if data.obj then
		data.obj:remove()
	end
	local meta = minetest.get_meta(data.pos)
	meta:set_string("name", "")
	minetest.get_node_timer(data.pos):stop()
	oil.fueling[name] = nil
end

minetest.register_entity("oil:line", {
    hp_max = 1,
    physical = false,
	pointable = false,
    weight = 5,
    collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
    visual = "cube",
    visual_size = {x=.05, y=.1},
    textures = {"blackline.png", "blackline.png", "blackline.png", "blackline.png", "blackline.png", "blackline.png"}, -- number of required textures depends on visual
    colors = {}, -- number of required colors depends on visual
    spritediv = {x=1, y=1},
    initial_sprite_basepos = {x=0, y=0},
    is_visible = true,
    makes_footstep_sound = false,
    automatic_rotate = 0,
	on_step = function(self, dtime)
		if self.startobj then
			self.start = self.startobj:get_pos()
		end
		if self.finishobj then
			self.finish = self.finishobj:get_pos()
			if self.finishoffset then
				local offset = table.copy(self.finishoffset)
				local yaw
				if self.finishobj:is_player() then
					yaw = self.finishobj:get_look_horizontal() or 0
				else
					yaw = self.finishobj:get_yaw() or 0
				end
				offset.x, offset.z = rotateVector(offset.x, offset.z, yaw)
				self.finish = vector.add(self.finish,offset)
			end
		end
		local sp = self.start
		local fp = self.finish
		if not sp or not fp then self.object:remove() return end
		if self.laststart and self.lastfinish and vector.equals(self.laststart, sp) and vector.equals(self.lastfinish, fp) then return end
		
		local dist = vector.distance(sp, fp)
		if dist > 4 then 
			for name, data in pairs(oil.fueling) do
				if data.obj == self.object then
					oil.stopfuel(name)
				end
			end
			return
		end
		local delta = vector.subtract(sp, fp)
		local yaw = math.atan2(delta.z, delta.x) - math.pi / 2
		local pitch = math.atan2(delta.y,  math.sqrt(delta.z*delta.z + delta.x*delta.x))
		pitch = pitch + math.pi/2
		
		self.object:move_to({x=(sp.x+fp.x)/2, y=(sp.y+fp.y)/2, z=(sp.z+fp.z)/2, })
		self.object:set_rotation({x=pitch, y=yaw, z=0})
		self.object:set_properties({visual_size = {x=.05, y=dist}})
		self.laststart = sp
		self.lastfinish = fp
	end,
	on_activate = function(self, staticdata, dtime_s)
		if not staticdata or staticdata == "" then self.object:remove() return end
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "oil:gas_pump" then return end
	if not player then return end
	local name = player:get_player_name()
	local pos = form_table[name]
	if not pos then return end
	local meta = minetest.get_meta(pos)
	if fields.buy then
		local inv = meta:get_inventory()
		local price = tonumber(meta:get_string("price")) or 0
		local input = inv:get_stack("input", 1)
		local moneys = {minegeld = 1, minegeld_5 = 5, minegeld_10 = 10}
		local amount = (moneys[string.gsub(input:get_name(), "currency:", "")] or 0) * input:get_count()
		if amount > 0 and price > 0 and (amount >= price or meta:get_int("gasbought") > 0) then
			local gasbought = math.floor(amount/price)
			local gas = meta:get_int("gas")
			if gasbought > gas then gasbought = gas end
			local change = math.floor(amount-gasbought*price)
			local output = ItemStack({name = "currency:minegeld", count = amount-change})
			local changestack = ItemStack({name = "currency:minegeld", count = change})
			if inv:room_for_item("output", output) then
				if change > 0 then
					inv:set_stack("input", 1, changestack)
				else
					inv:set_stack("input", 1, ItemStack())
				end
				meta:set_int("gas", gas-gasbought)
				inv:add_item("output", output)
				gasbought = gasbought+meta:get_int("gasbought")
				meta:set_int("gasbought", gasbought)
				if gasbought > 0 then
					minetest.chat_send_player(name, "Punch the car you wish to gas up.")
					local obj = minetest.add_entity(pos, "oil:line", "sup")
					local ent = obj:get_luaentity()
					local offset = {x=.4,y=.1,z=-.4}
					local yaw = minetest.dir_to_yaw(minetest.facedir_to_dir(minetest.get_node(pos).param2))
					offset.x, offset.z = rotateVector(offset.x, offset.z, yaw)
					ent.start = vector.add(pos, offset)
					ent.finishobj = player
					ent.finishoffset = {x=0,y=1.2,z=.3}
					oil.stopfuel(name)
					oil.fueling[name] = {pos = pos, obj = obj}
				end
			else
				minetest.chat_send_player(name, "Pump is full and cannot fit payment, contact pump owner.")
			end
		end
	end
	if fields.key_enter_field == "price" then
		if default.can_interact_with_node(player, pos) then
			if tonumber(fields.price) then
				meta:set_string("price", fields.price)
			end
		end
	end
	if fields.quit then
		form_table[name] = nil
		return true
	end
end)

minetest.register_node("oil:pump", {
	description = "Gas Pump",
	drawtype = "mesh",
	mesh = "gaspump.b3d",
	paramtype2 = "facedir",
	tiles = {"gaspumpUV.png"},
	groups = {cracky = 3, stone = 1},
	sounds = default.node_sound_stone_defaults(),
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("input") and
			inv:is_empty("output") and
			default.can_interact_with_node(player, pos)
	end,
	on_rightclick = function(pos, node, clicker)
		if not clicker then return end
		local name = clicker:get_player_name()
		if not name then return end
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		minetest.show_formspec(name,"oil:gas_pump", form_pump(pos, default.can_interact_with_node(clicker, pos)))
		form_table[name] = pos
	end,
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("output", 4)
		meta:set_string("owner", placer:get_player_name() or "")
		meta:set_string("infotext", "Gas Pump (owned by "..meta:get_string("owner")..")")
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		if not puncher then return end
		local meta = minetest.get_meta(pos)
		local name = puncher:get_player_name()
		if not name then return end
		if not default.can_interact_with_node(puncher, pos) then return end
		if reclick_stopper[name] then reclick_stopper[name] = nil return end
		local wield = puncher:get_wielded_item():get_name()
		local gas = meta:get_int("gas") or 0
		if wield == "bucket:bucket_empty" then
			if gas >= bucket_liters then
				meta:set_string("gas", gas-bucket_liters)
				if puncher:get_wielded_item():get_count() > 1 then
					local inv = puncher:get_inventory()
					puncher:set_wielded_item(puncher:get_wielded_item():take_item(1))
					minetest.add_item(puncher:get_pos(), inv:add_item("main", {name = "oil:bucket_gasoline"}))
				else
					puncher:set_wielded_item("oil:bucket_gasoline")
				end
				reclick_stopper[name] = true
				minetest.after(.5, function() reclick_stopper[name] = nil end)
			end
		elseif wield == "oil:bucket_gasoline" then
			if gas + bucket_liters <= pump_capacity then
				puncher:set_wielded_item("bucket:bucket_empty")
				meta:set_string("gas", gas+bucket_liters)
				reclick_stopper[name] = true
				minetest.after(.5, function() reclick_stopper[name] = nil end)
			end
		end
	end,
	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		
		local name = meta:get_string("name")
		if name == "" then return end
		local data = oil.fueling[name]
		if not data then return end
		
		if not data.obj or data.obj:is_player() then return end
		
		local ent = data.obj:get_luaentity()
		if not ent or not ent.finishobj then return end
		local def = cars_registered_cars[ent.finishobj:get_entity_name()]
		if not def then return end
		local carent = ent.finishobj:get_luaentity()
		
		local maxgas = def.gas_cap or 50	
		if not carent.gas then carent.gas = 0 end
		local gas = meta:get_int("gasbought") or 0
		if gas == 0 then oil.stopfuel(name) return end
		
		meta:set_int("gasbought", gas - 1)
		carent.gas = carent.gas + 1
		--minetest.chat_send_all(carent.gas)
		if carent.gas >= maxgas then carent.gas = maxgas oil.stopfuel(name) return end
		
		return true
	end
})
if minetest.get_modpath("mesecons_button") and minetest.get_modpath("currency") and minetest.get_modpath("basic_materials") then
	minetest.register_craft({
		recipe = {
			{"default:steel_ingot", "default:steel_ingot"},
			{"mesecons_button:button_off", "currency:shop"},
			{"bucket:bucket_empty", "basic_materials:motor"},
		},
		output = "oil:pump"
	})
else
	minetest.register_craft({
		recipe = {
			{"default:steel_ingot", "default:steel_ingot"},
			{"default:stick", "default:mese_crystal"},
			{"bucket:bucket_empty", "default:copper_ingot"},
		},
		output = "oil:pump"
	})
end
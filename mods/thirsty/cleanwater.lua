thirsty.config.node_drinkable = {}--clear all drinkable waters
thirsty.config.regen_from_node = {}

thirsty.config.node_drinkable["thirsty:water_clean_source"] = true
thirsty.config.regen_from_node["thirsty:water_clean_source"] = 0.5

local def = table.copy(minetest.registered_nodes["default:river_water_source"])
def.liquid_alternative_source = "thirsty:water_clean_source"
def.liquid_alternative_flowing = "thirsty:water_clean_flowing"
def.liquid_renewable = false
def.description = "Clean Water Source"
minetest.register_node("thirsty:water_clean_source", def)

def = table.copy(minetest.registered_nodes["default:river_water_flowing"])
def.liquid_alternative_source = "thirsty:water_clean_source"
def.liquid_alternative_flowing = "thirsty:water_clean_flowing"
def.liquid_renewable = false
def.description = "Clean Water Flowing"
minetest.register_node("thirsty:water_clean_flowing", def)

dynamic_liquid.liquid_abm("thirsty:water_clean_source", "thirsty:water_clean_flowing", 1)
waterworks.register_liquid("thirsty:water_clean_source", {flowing = "thirsty:water_clean_flowing"})

bucket.register_liquid(
	"thirsty:water_clean_source",
	"thirsty:water_clean_flowing",
	"thirsty:bucket_water_clean",
	"bucket_river_water.png",
	"Clean Water Bucket",
	{tool = 1, water_bucket = 1}
)

local PPA = thirsty.persistent_player_attributes
local place_outlet = function(pos)
	local node = minetest.get_node(pos)
	local dir = minetest.facedir_to_dir(node.param2)
	local target = vector.subtract(pos, dir)
	waterworks.place_connected(pos, "outlet", {pos = pos, target = target, pressure = target.y})
	--local meta = minetest.get_meta(pos)
	--meta:set_string("infotext", "Outlet elevation " .. tostring(target.y))
end
minetest.register_node("thirsty:fountain", {
	description = "Drinking Fountain",
	tiles = {
		"waterworks_metal.png",
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {oddly_breakable_by_hand = 1, waterworks_connected = 1},
	
	paramtype = "light",
	
	sounds = default.node_sound_metal_defaults(),
	_waterworks_update_connected = place_outlet,
	on_construct = function(pos)
		place_outlet(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Drinking Fountain 0L")
	end,
	on_destruct = function(pos)
		waterworks.remove_connected(pos, "outlet")
	end,
	on_rotate = function(pos, node, user, mode, new_param2)
		waterworks.remove_connected(pos, "outlet")
		node.param2 = new_param2
		minetest.swap_node(pos, node)
		place_outlet(pos)
		return true
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not clicker:is_player() then return end
		local meta = minetest.get_meta(pos)
		local water = meta:get_float("water")
		local thirst = math.abs(20-PPA.get_value(clicker, 'thirsty_hydro'))
		if water-thirst <= 0 then
			thirst = water
		end
		if thirst > 0 then
			meta:set_float("water", water - thirst)
			meta:set_string("infotext", "Drinking Fountain "..math.floor(water - thirst).."L")
			thirsty.drink(clicker, thirst)
		end
	end
})

minetest.override_item("gas_lib:steam", { liquid = "thirsty:water_clean_source"})

minetest.register_abm({
	label = "clean water near dirty water or dirt gets dirty",
	nodenames = {"thirsty:water_clean_source"},
	neighbors = {"default:water_source", "default:water_flowing", "group:crumbly"},
	interval = 4,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.remove_node(pos)
		--minetest.add_node(pos, {name = "default:water_source"})
	end,
})
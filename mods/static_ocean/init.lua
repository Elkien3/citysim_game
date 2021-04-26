local def = table.copy(minetest.registered_nodes["default:water_source"])
def.liquid_alternative_source = "static_ocean:water_source"
def.liquid_alternative_flowing = "static_ocean:water_flowing"
def.liquid_renewable = true
minetest.register_node("static_ocean:water_source", def)

local def = table.copy(minetest.registered_nodes["default:water_flowing"])
def.liquid_alternative_source = "static_ocean:water_source"
def.liquid_alternative_flowing = "static_ocean:water_flowing"
def.liquid_renewable = true
minetest.register_node("static_ocean:water_flowing", def)
local source = "static_ocean:water_source"
local flowing = "static_ocean:water_flowing"
bucket.liquids[source] = {
		source = source,
		flowing = flowing,
		itemname = "bucket:bucket_water",
		force_renew = false,
	}
	bucket.liquids[flowing] = bucket.liquids[source]

minetest.register_alias_force("mapgen_water_source", "static_ocean:water_source")--replace mapgen water with static water (not effected by dynamic_liquid)

if waterworks then
	waterworks.register_liquid("static_ocean:water_source", {flowing = "static_ocean:water_flowing", replace = "default:water_source"})
end

minetest.register_abm({
	label = "delete normal water near ocean",
	nodenames = {"static_ocean:water_source"},
	neighbors = {"default:water_source"},
	interval = 4,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local pos1 = vector.subtract(pos, 1)
		local pos2 = vector.add(pos, 1)
		local nodes = minetest.find_nodes_in_area(pos1, pos2, "default:water_source")
		for index, nodepos in pairs(nodes) do
			minetest.remove_node(nodepos)
		end
	end,
})
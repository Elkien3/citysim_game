for name, def in pairs(farming.registered_plants) do
	local steps = def.steps
	local crop = def.crop
	local node = table.copy(minetest.registered_nodes[crop.."_"..steps])
	node.groups.growing = 1
	minetest.override_item(crop.."_"..steps, {groups = node.groups, minlight = 0, maxlight = 15})
	for index, tile in pairs(node.tiles) do
		node.tiles[index] = node.tiles[index].."^[colorize:#642700:60"
	end
	node.minlight = 0
	node.maxlight = 15
	minetest.register_node(":"..crop.."_"..steps+1, node)
	local step = math.floor(steps/1.5+.5)
	if step < 1 then step = 1 end
	node = table.copy(minetest.registered_nodes[crop.."_"..step])
	for index, tile in pairs(node.tiles) do
		node.tiles[index] = node.tiles[index].."^[colorize:#642700:120"
	end
	node.drop = ""--def.seed
	node.groups.growing = 0
	node.minlight = 0
	node.maxlight = 15
	minetest.register_node(":"..crop.."_"..steps+2, node)
	def.steps = def.steps + 2
end
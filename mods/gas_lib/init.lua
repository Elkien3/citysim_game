gas_lib = {}

local function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
end

function gas_lib.find_air_neighbor(pos)
	local gn=minetest.get_node
	if math.random(3) == 1 and gn(pos).name == "air" then return pos end
	local pos_table = {{"z", 0}, {"z", 1}, {"z", -1}, {"x", 1}, {"x", -1}}
	shuffle(pos_table)
	for k, v in pairs(pos_table) do
		local newpos = vector.new(pos)
		newpos[v[1]] = newpos[v[1]] + v[2]
		if gn(newpos).name == "air" then return newpos end
	end
	return nil
end

function gas_lib.tick(itemstring, pos, elapsed)
	local def = minetest.registered_nodes[itemstring]
	local node = minetest.get_node(pos)
	if node.param2 == 0 then node.param2 = def.lifetime+1 end
	--node deletion
	if math.random(100) <= def.deathchance then
		minetest.remove_node(pos)
		return
	end
	local pos1 = vector.new({x = pos.x + 1, y = pos.y + 1, z = pos.z + 1})
	local pos2 = vector.new({x = pos.x - 1, y = pos.y - 1, z = pos.z - 1})
	local nodes = minetest.find_nodes_in_area(pos1, pos2, "air")
	if #nodes == 0 then minetest.get_node_timer(pos):start(def.interval+math.random(10)/10) return end -- gas has no space to move, may as well not do anything
	if node.param2 ~= 0 and #nodes > 13 then
		node.param2 = node.param2 - 1
		if node.param2 <=1 then
			minetest.remove_node(pos)
			return
		else
			minetest.swap_node(pos, node)
		end
	end
	
	local rand = math.random(10)
	local weight = def.weight
	if weight == 0 then --if has no weight, have a small chance to either go up or down
		weight = math.random(2)
		if weight == 2 then weight = -1 end
	end
	if rand <= math.abs(weight) then --  move up/down
		local sign = weight/math.abs(weight)
		local newpos = vector.new(pos)
		newpos.y = newpos.y - sign
		newpos = gas_lib.find_air_neighbor(newpos)
		if newpos then
			minetest.remove_node(pos)
			minetest.add_node(newpos, node)
			return
		end
	end
	--hasn't moved up or down, so move horizontally.
	local newpos = gas_lib.find_air_neighbor(vector.new(pos))
	if newpos then
		minetest.remove_node(pos)
		minetest.add_node(newpos, node)
		return
	end
	minetest.get_node_timer(pos):start(def.interval+math.random(10)/10)
end

local function table_combine(table1, table2)
	local newtable = table.copy(table1) -- table 1 gets written over
	for index,data in pairs(table2) do newtable[index] = data end
	return newtable
end

local defaultdef =  {
	drawtype = "glasslike",
	paramtype = "light",
	paramtype2 = "none",
	drop="",
	use_texture_alpha=true,
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	floodable= true,
	interval = 2.5,
	lifetime = 10, --how many intervals it can last in open air
	weight = 0, --chance out of 10 to go up, use negative to go down
	deathchance = 0, --chance out of 100 to randomly die
	on_flood = function(pos, oldnode, newnode)
		local newpos = gas_lib.find_air_neighbor(pos)
		if newpos then
			minetest.add_node(newpos, oldnode)
		end
	end
}

function gas_lib.register_gas(itemstring, def)
	def = table_combine(defaultdef, def)
	def.on_construct = function(pos) minetest.get_node_timer(pos):start(def.interval+math.random(10)/10) end
	def.on_timer = function(pos, elapsed) gas_lib.tick(itemstring, pos, elapsed) end
	if not def.groups then def.groups = {} end
	if not def.groups.gas then def.groups.gas = 1 end
	minetest.register_node(itemstring, def)
end

minetest.register_abm{
	label="Remove gas",
	nodenames= {"group:gas"},
	interval=60,
	chance=20,
	action=function(pos)
		minetest.remove_node(pos)
	end
}
minetest.register_lbm{
	name="gas_lib:ensuretimer",
	nodenames= {"group:gas"},
	run_at_every_load = true,
	action=function(pos)
		local timer = minetest.get_node_timer(pos)
		if not timer:is_started() then
			local node = minetest.get_node(pos)
			local def = minetest.registered_nodes[node.name]
			minetest.get_node_timer(pos):start(def.interval+math.random(10)/10)
		end
	end
}

local path = minetest.get_modpath(minetest.get_current_modname())
dofile(path .. "/gasses.lua")
dofile(path .. "/tools.lua")
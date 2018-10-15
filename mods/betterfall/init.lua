-- MOD STRUCT INITIALIZATION
betterfall = {}
betterfall.path = minetest.get_modpath("betterfall")
betterfall.ghost_nodes = {} -- those nodes will just disappear instead of falling
betterfall.falling_timer = 0.0

dofile(betterfall.path.."/helpers.lua")
dofile(betterfall.path.."/config.lua")
dofile(betterfall.path.."/attached.lua")
dofile(betterfall.path.."/fallingqueue.lua")

for nodename, nodedef in pairs(minetest.registered_nodes) do
    if nodedef.groups.falling_node == nil and
         nodedef.name ~= "air" and
         minetest.get_item_group(nodedef.name, "attached_node") == 0 and
         minetest.get_item_group(nodedef.name, "liquid") == 0
        then
            nodedef.groups.falling_node = 2 
    end
end

local function is_node_supporting(n, p_bottom)
    local n_bottom = core.get_node_or_nil(p_bottom)
    local d_bottom = n_bottom and core.registered_nodes[n_bottom.name]

    if d_bottom and
        (core.get_item_group(n.name, "float") == 0 or
        d_bottom.liquidtype == "none") and

        (n.name ~= n_bottom.name or (d_bottom.leveled and
        core.get_node_level(p_bottom) <
        core.get_node_max_level(p_bottom))) and

        (not d_bottom.walkable or d_bottom.buildable_to) then
            return false 
    end

    return true
end

local supporting_neighbours_lateral = {
    {x = 1, y = 0, z = 0},
    {x = -1, y = 0, z = 0},
    
    {x = 0, y = 0, z = -1},
    {x = 0, y = 0, z = 1},
    
    {x = 1, y = 0, z = 1},
    {x = -1, y = 0, z = -1},
    
    {x = 1, y = 0, z = -1},    
    {x = -1, y = 0, z = 1},
}

local supporting_neighbours_diagonal = {
    {x = 1, y = -1, z = 0},
    {x = -1, y = -1, z = 0},
    
    {x = 0, y = -1, z = -1},
    {x = 0, y = -1, z = 1},
    
    {x = 1, y = -1, z = 1},
    {x = -1, y = -1, z = -1},
    
    {x = 1, y = -1, z = -1},    
    {x = -1, y = -1, z = 1}
}

function betterfall.should_node_fall(n, p, range)
    if is_node_supporting(p, {x = p.x, y = p.y - 1, z = p.z}) then
        return false
    end

    if range > 0 then
        for i, diagneighpos in pairs(supporting_neighbours_diagonal) do
            local dp = { 
                x = p.x + diagneighpos.x,
                y = p.y + diagneighpos.y,
                z = p.z + diagneighpos.z
            }

            if is_node_supporting(p, dp, n) then
                return false
            else
                for i, latneighpos in pairs(supporting_neighbours_lateral) do
                    local lp = {
                        x = p.x + latneighpos.x,
                        y = p.y + latneighpos.y,
                        z = p.z + latneighpos.z
                    }
                    
                    if is_node_supporting(p, lp, n) then
                        local ldp = {
                            x = dp.x + latneighpos.x,
                            y = dp.y + latneighpos.y,
                            z = dp.z + latneighpos.z
                        }

                        if is_node_supporting(p, ldp, n) then
                            return false
                        end
                    end
                end
            end
        end
    end

    return true 
end

minetest.check_single_for_falling = function(p)
    local n = core.get_node(p)
    local meta = minetest.get_meta(p);

    local falling_node_group = core.get_item_group(n.name, "falling_node")

	if falling_node_group ~= 0 and meta:get_int("falling") ~= 1 then
        local result = betterfall.should_node_fall(n, p, falling_node_group - 1)

        if result then
            meta:set_int("falling", 1)
            n = core.get_node(p)
            betterfall.enqueue_falling_node(p, n, meta)
        end

        return result
    end

	if core.get_item_group(n.name, "attached_node") ~= 0 then
		if not check_attached_node(p, n) then
			drop_attached_node(p)
			return true
		end
	end

    return false
end

local check_for_falling_neighbors = {
	{x = -1, y = -1, z = 0},
	{x = 1, y = -1, z = 0},
	{x = 0, y = -1, z = -1},
	{x = 0, y = -1, z = 1},
    {x = 0, y = -1, z = 0},

	{x = -1, y = 0, z = 0},
	{x = 1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1},
    {x = 0, y = 0, z = 0},
    
    {x = -1, y = 0, z = -1},
	{x = 1, y = 0, z = 1},
	{x = -1, y = 0, z = 1},
	{x = 1, y = 0, z = -1},

	{x = -1, y = 1, z = 0},
	{x = 1, y = 1, z = 0},
	{x = 0, y = 1, z = 1},
	{x = 0, y = 1, z = -1},
    {x = 0, y = 1, z = 0},

    {x = -1, y = 1, z = -1},
	{x = 1, y = 1, z = 1},
	{x = -1, y = 1, z = 1},
	{x = 1, y = 1, z = -1},

    {x = 0, y = 2, z = 0}
}

minetest.check_for_falling = function(p)
   -- print("check for falling " .. p.x .. " " .. p.y .. " " .. p.z)

	p = vector.round(p)

	local s = {}
	local n = 0
	local v = 1

	while true do
		n = n + 1
		s[n] = {p = p, v = v}
		p = vector.add(p, check_for_falling_neighbors[v])
		if not core.check_single_for_falling(p) then
			repeat
				local pop = s[n]
				p = pop.p
				v = pop.v
				s[n] = nil
				n = n - 1
				if n == 0 and v == #check_for_falling_neighbors then
					return
				end
			until v < #check_for_falling_neighbors 
			v = v + 1
		else
            v = 1
		end
	end
end

-- Panes type nodes by Dan with xyz's xpanes code.

local function rshift(x, by)
  return math.floor(x / 2 ^ by)
end

local directions = {
    {x = 1, y = 0, z = 0},
    {x = 0, y = 0, z = 1},
    {x = -1, y = 0, z = 0},
    {x = 0, y = 0, z = -1},
}

local function update_fence(pos)
    if minetest.get_node(pos).name:find("army:camouflage") == nil then
        return
    end
    local sum = 0
    for i = 1, 4 do
        local node = minetest.get_node({x = pos.x + directions[i].x, y = pos.y + directions[i].y, z = pos.z + directions[i].z})
        if minetest.registered_nodes[node.name].walkable ~= false then
            sum = sum + 2 ^ (i - 1)
        end
    end
    if sum == 0 then
        sum = 15
    end
    minetest.add_node(pos, {name = "army:camouflage_"..sum})
end

local function update_nearby(pos)
    for i = 1,4 do
        update_fence({x = pos.x + directions[i].x, y = pos.y + directions[i].y, z = pos.z + directions[i].z})
    end
end

local half_blocks = {
    {0, -0.5, -0.06, 0.5, 0.5, 0.06},
    {-0.06, -0.5, 0, 0.06, 0.5, 0.5},
    {-0.5, -0.5, -0.06, 0, 0.5, 0.06},
    {-0.06, -0.5, -0.5, 0.06, 0.5, 0}
}

local full_blocks = {
    {-0.5, -0.5, -0.06, 0.5, 0.5, 0.06},
    {-0.06, -0.5, -0.5, 0.06, 0.5, 0.5}
}

for i = 1, 15 do
    local need = {}
    local cnt = 0
    for j = 1, 4 do
        if rshift(i, j - 1) % 2 == 1 then
            need[j] = true
            cnt = cnt + 1
        end
    end
    local take = {}
    if need[1] == true and need[3] == true then
        need[1] = nil
        need[3] = nil
        table.insert(take, full_blocks[1])
    end
    if need[2] == true and need[4] == true then
        need[2] = nil
        need[4] = nil
        table.insert(take, full_blocks[2])
    end
    for k in pairs(need) do
        table.insert(take, half_blocks[k])
    end
    local texture = "army_camouflage.png"
    if cnt == 1 then
        texture = "army_camouflage.png"
    end
    minetest.register_node("army:camouflage_"..i, {
        drawtype = "nodebox",
        tile_images = {"army_camouflage.png", "army_camouflage.png", texture},
        paramtype = "light",
        groups = {cracky=2},
        drop = "army:camouflage",
        node_box = {
            type = "fixed",
            fixed = take
        },
        selection_box = {
            type = "fixed",
            fixed = take
        }
    })
end

minetest.register_node("army:camouflage", {
    description = "Camouflage Fence",
    tiles = {"army_camouflage.png"},
    inventory_image = "army_camouflage.png",
    wield_image = "army_camouflage.png",
    node_placement_prediction = "",
    on_construct = update_fence
})

minetest.register_on_placenode(update_nearby)
minetest.register_on_dignode(update_nearby)

minetest.register_craft({
	output = "army:camouflage 12",
	recipe = {
		{"group:leaves","group:leaves"},
		{"group:leaves","group:leaves"},
	}
})


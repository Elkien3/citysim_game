-- Panes type nodes by Dan with xyz's xpanes code.

local S = minetest.get_translator("army")

local function is_pane(pos)
	return minetest.get_item_group(minetest.get_node(pos).name, "pane") > 0
end

local function connects_dir(pos, name, dir)
	local aside = vector.add(pos, minetest.facedir_to_dir(dir))
	if is_pane(aside) then
		return true
	end

	local connects_to = minetest.registered_nodes[name].connects_to
	if not connects_to then
		return false
	end
	local list = minetest.find_nodes_in_area(aside, aside, connects_to)

	if #list > 0 then
		return true
	end

	return false
end

local function swap(pos, node, name, param2)
	if node.name == name and node.param2 == param2 then
		return
	end

	minetest.swap_node(pos, {name = name, param2 = param2})
end

local function update_pane(pos)
	if not is_pane(pos) then
		return
	end
	local node = minetest.get_node(pos)
	local name = node.name
	if name:sub(-5) == "_flat" then
		name = name:sub(1, -6)
	end

	local any = node.param2
	local c = {}
	local count = 0
	for dir = 0, 3 do
		c[dir] = connects_dir(pos, name, dir)
		if c[dir] then
			any = dir
			count = count + 1
		end
	end

	if count == 0 then
		swap(pos, node, name .. "_flat", any)
	elseif count == 1 then
		swap(pos, node, name .. "_flat", (any + 1) % 4)
	elseif count == 2 then
		if (c[0] and c[2]) or (c[1] and c[3]) then
			swap(pos, node, name .. "_flat", (any + 1) % 4)
		else
			swap(pos, node, name, 0)
		end
	else
		swap(pos, node, name, 0)
	end
end

minetest.register_on_placenode(function(pos, node)
	if minetest.get_item_group(node, "pane") then
		update_pane(pos)
	end
	for i = 0, 3 do
		local dir = minetest.facedir_to_dir(i)
		update_pane(vector.add(pos, dir))
	end
end)

minetest.register_on_dignode(function(pos)
	for i = 0, 3 do
		local dir = minetest.facedir_to_dir(i)
		update_pane(vector.add(pos, dir))
	end
end)

army_panes = {}
function army_panes.register_pane(name, def)
	for i = 1, 15 do
		minetest.register_alias("army:" .. name .. "_" .. i, "army:" .. name .. "_flat")
	end

	local flatgroups = table.copy(def.groups)
	flatgroups.pane = 1
	minetest.register_node(":army:" .. name .. "_flat", {
		description = def.description,
		drawtype = "nodebox",
		use_texture_alpha = true,
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		paramtype2 = "facedir",
		tiles = {
			def.textures[3],
			def.textures[3],
			def.textures[3],
			def.textures[3],
			def.textures[1],
			def.textures[1]
		},
		groups = flatgroups,
		drop = "army:" .. name .. "_flat",
		sounds = def.sounds,
		use_texture_alpha = def.use_texture_alpha and "blend" or "clip",
		node_box = {
			type = "fixed",
			fixed = {{-1/2, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		selection_box = {
			type = "fixed",
			fixed = {{-1/2, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		connect_sides = { "left", "right" },
	})

	local groups = table.copy(def.groups)
	groups.pane = 1
	groups.not_in_creative_inventory = 1
	minetest.register_node(":army:" .. name, {
		drawtype = "nodebox",
		use_texture_alpha = true,
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		description = def.description,
		tiles = {
			def.textures[3],
			def.textures[3],
			def.textures[1]
		},
		groups = groups,
		drop = "army:" .. name .. "_flat",
		sounds = def.sounds,
		use_texture_alpha = def.use_texture_alpha and "blend" or "clip",
		node_box = {
			type = "connected",
			fixed = {{-1/32, -1/2, -1/32, 1/32, 1/2, 1/32}},
			connect_front = {{-1/32, -1/2, -1/2, 1/32, 1/2, -1/32}},
			connect_left = {{-1/2, -1/2, -1/32, -1/32, 1/2, 1/32}},
			connect_back = {{-1/32, -1/2, 1/32, 1/32, 1/2, 1/2}},
			connect_right = {{1/32, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		connects_to = {"group:pane", "group:stone", "group:glass", "group:wood", "group:tree"},
	})

	minetest.register_craft({
		output = "army:" .. name .. "_flat 16",
		recipe = def.recipe
	})
end

army_panes.register_pane("chainlink", {
	description = S("Chainlink Fence"),
	textures = {"army_chainlink.png", "", "army_chainlink.png"},
	inventory_image = "army_chainlink.png",
	wield_image = "army_chainlink.png",
	groups = {cracky=2},
	recipe = {
		{"default:steel_ingot","default:stick","default:steel_ingot"},
		{"default:stick","default:steel_ingot","default:stick"},
		{"default:steel_ingot","default:stick","default:steel_ingot"},
	}
})

army_panes.register_pane("camouflage", {
	description = S("Camouflage Fence"),
	textures = {"army_camouflage.png", "", "army_camouflage.png"},
	inventory_image = "army_camouflage.png",
	wield_image = "army_camouflage.png",
	groups = {cracky=2},
	recipe = {
		{"group:leaves","group:leaves"},
		{"group:leaves","group:leaves"},
	}
})


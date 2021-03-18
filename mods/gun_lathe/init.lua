technic.register_recipe_type("lvlathe", {description = "LV Lathe" })
technic.register_recipe_type("mvlathe", {description = "MV Lathe" })
technic.register_recipe_type("hvlathe", {description = "HV Lathe" })

local construct = function(pos, nodename)
	--local nodename = minetest.get_node(pos).name
	minetest.sound_play("lathestart", {
		pos = pos,
	}, true)--startup sound
	--after 2 seconds, start the running sound
	minetest.after(3, function(pos)
	local meta = minetest.get_meta(pos)
	if minetest.get_node(pos).name ~= nodename then return end
	if meta:get_string("sound") ~= "" then return end
	local sound = minetest.sound_play("latherunning", {
		pos = pos,
		fade = .5,
		loop = true,
	})
	meta:set_string("sound", sound)
	end, pos)--running sound loop
end
local destruct = function(pos)
	local meta = minetest.get_meta(pos)
	local sound = meta:get_string("sound")
	if sound ~= "" then
		minetest.sound_play("lathestop", {
			pos = pos,
		}, true)--shutdown sound
		minetest.sound_fade(sound, -2, 0)--fade out running sound
		meta:set_string("sound", "")
	end
end

technic.register_base_machine({
	typename = "lvlathe",
	machine_name = "lathe",
	machine_desc = "LV Lathe",
	tier = "LV",
	demand = {200},
	speed = 1,
})

technic.register_base_machine({
	typename = "mvlathe",
	machine_name = "lathe",
	machine_desc = "MV Lathe",
	tier = "MV",
	demand = {400},
	speed = 1,
})

technic.register_base_machine({
	typename = "hvlathe",
	machine_name = "lathe",
	machine_desc = "HV Lathe",
	tier = "HV",
	demand = {800},
	speed = 1,
})

technic.swap_node = function(pos, name)
	local node = minetest.get_node(pos)
	if name ~= node.name then
		node.name = name
		minetest.swap_node(pos, node)
		if string.find(name, "gun_lathe:%av_lathe") then
			if string.find(name, "_active") then
				construct(pos, name)
			else
				destruct(pos)
			end
		end
	end
end

minetest.register_craftitem("gun_lathe:gun_barrel_iron", {
	description = "Iron Gun Barrel",
	inventory_image = "gunbarrel.png"
})
minetest.register_craftitem("gun_lathe:gun_barrel_carbon_steel", {
	description = "Carbon Steel Gun Barrel",
	inventory_image = "gunbarrel_carbon_steel.png"
})
minetest.register_craftitem("gun_lathe:gun_barrel_stainless_steel", {
	description = "Stainles Steel Gun Barrel",
	inventory_image = "gunbarrel_stainless_steel.png"
})
technic.register_recipe("lvlathe", {input = {"default:steel_ingot 4"}, output = "gun_lathe:gun_barrel_iron", time = 60})

technic.register_recipe("mvlathe", {input = {"default:steel_ingot 4"}, output = "gun_lathe:gun_barrel_iron", time = 30})
technic.register_recipe("mvlathe", {input = {"technic:carbon_steel_ingot 4"}, output = "gun_lathe:gun_barrel_carbon_steel", time = 120})

technic.register_recipe("hvlathe", {input = {"default:steel_ingot 4"}, output = "gun_lathe:gun_barrel_iron", time = 15})
technic.register_recipe("hvlathe", {input = {"technic:carbon_steel_ingot 4"}, output = "gun_lathe:gun_barrel_carbon_steel", time = 60})
technic.register_recipe("hvlathe", {input = {"technic:stainless_steel_ingot 4"}, output = "gun_lathe:gun_barrel_stainless_steel", time = 120})
local modpath, S = ...

minetest.register_node("petz:jack_o_lantern_grenade", {
	description = S("Jack-o'-lantern Grenade").. " ("..S("use to throw")..")",
	tiles = {"petz_jackolantern_grenade_top.png", "petz_jackolantern_grenade_bottom.png",
		"petz_jackolantern_grenade_right.png", "petz_jackolantern_grenade_left.png",
		"petz_jackolantern_grenade_back.png", "petz_jackolantern_grenade_front.png"},
	visual_scale = 0.35,
	is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
    sounds = default.node_sound_wood_defaults(),
	on_use = function(itemstack, user, pointed_thing)
		local strength = 20
		mokapi.make_sound("player", user, "petz_fireball", petz.settings.max_hear_distance)
		if not petz.spawn_throw_object(user, strength, "petz:ent_jack_o_lantern_grenade") then
			return -- something failed
		end
		itemstack:take_item()
		return itemstack
	end,
})

petz.register_throw_entity("petz:ent_jack_o_lantern_grenade", "petz:jack_o_lantern_grenade", petz.settings.pumpkin_grenade_damage, "fire", "fire", "petz_firecracker")

minetest.register_craft({
	type = "shapeless",
	output = "petz:jack_o_lantern_grenade",
	recipe = {"petz:jack_o_lantern", "tnt:gunpowder", "farming:string"},
})


-- COBWEB
minetest.register_node("petz:cobweb", {
	description = S("Cobweb"),
	drawtype = "plantlike",
	visual_scale = 1.2,
	tiles = {"petz_cobweb.png"},
	inventory_image = "petz_cobweb.png",
	paramtype = "light",
	sunlight_propagates = true,
	liquid_viscosity = 11,
	liquidtype = "source",
	liquid_alternative_flowing = "petz:cobweb",
	liquid_alternative_source = "petz:cobweb",
	liquid_renewable = false,
	liquid_range = 0,
	walkable = false,
	groups = {snappy = 1, disable_jump = 1},
	drop = "farming:string",
	sounds = default.node_sound_leaves_defaults(),
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos) --throwed cobwebs dissapear after some time
		timer:start(petz.settings.cobweb_decay)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if placer:is_player() then
			local timer = minetest.get_node_timer(pos) --put cobwebs by players do not dissapear
			timer:stop()
		end
	end,
	on_timer = function(pos, elapsed)
		minetest.remove_node(pos)
		return false
	end,
})

petz.register_throw_entity("petz:ent_cobweb", "petz:cobweb", 1, "cobweb", nil, "petz_cobweb_throw")

minetest.register_craft({
	output = "petz:cobweb",
	recipe = {
		{"farming:string", "", "farming:string"},
		{"", "farming:string", ""},
		{"farming:string", "", "farming:string"},
	}
})

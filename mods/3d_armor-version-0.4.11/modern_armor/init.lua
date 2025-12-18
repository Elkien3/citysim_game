--[[
modern_armor_loot = 
{
"modern_armor_inv_helmet_biker", "modern_armor_inv_helmet_construction", "modern_armor_inv_helmet_military", "modern_armor_inv_helmet_swat", 
"modern_armor_inv_vest_civilian", "modern_armor_inv_vest_military", "modern_armor_inv_vest_police", "modern_armor_inv_vest_swat"
}
--]]
local enable_craft = true

armor:register_armor("modern_armor:vest_civilian", {
	description = ("Civilian Soft Armor"),
	inventory_image = "modern_armor_inv_vest_civilian.png",
	groups = {armor_torso=1, armor_heal=0, armor_use=800,
		physics_speed=-0.04, physics_gravity=0.04},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("modern_armor:vest_construction", {
	description = ("Construction Vest"),
	inventory_image = "modern_armor_inv_vest_construction.png",
	groups = {armor_torso=1, armor_heal=0, armor_use=800,
		physics_speed=-0.00, physics_gravity=0.00},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("modern_armor:vest_police", {
	description = ("Police Soft Armor"),
	inventory_image = "modern_armor_inv_vest_police.png",
	groups = {armor_torso=1, armor_heal=0, armor_use=800,
		physics_speed=-0.04, physics_gravity=0.04},
	armor_groups = {fleshy=12},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("modern_armor:vest_swat", {
	description = ("SWAT Plate Carrier"),
	inventory_image = "modern_armor_inv_vest_swat.png",
	groups = {armor_torso=1, armor_heal=0, armor_use=800,
		physics_speed=-0.08, physics_gravity=0.08},
	armor_groups = {fleshy=20},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("modern_armor:vest_military", {
	description = ("Military Plate Carrier"),
	inventory_image = "modern_armor_inv_vest_military.png",
	groups = {armor_torso=1, armor_heal=0, armor_use=800,
		physics_speed=-0.08, physics_gravity=0.08},
	armor_groups = {fleshy=20},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})

armor:register_armor("modern_armor:helmet_swat", {
	description = ("SWAT Helmet"),
	inventory_image = "modern_armor_inv_helmet_swat.png",
	groups = {armor_head=1, armor_heal=0, armor_use=800},
	armor_groups = {fleshy=5},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})

armor:register_armor("modern_armor:helmet_military", {
	description = ("Military Helmet"),
	inventory_image = "modern_armor_inv_helmet_military.png",
	groups = {armor_head=1, armor_heal=0, armor_use=800},
	armor_groups = {fleshy=5},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})

armor:register_armor("modern_armor:helmet_construction", {
	description = ("Construction Helmet"),
	inventory_image = "modern_armor_inv_helmet_construction.png",
	groups = {armor_head=1, armor_heal=0, armor_use=800},
	armor_groups = {fleshy=3},
	
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})

armor:register_armor("modern_armor:helmet_police", {
	description = ("Police Hat"),
	inventory_image = "modern_armor_inv_helmet_police.png",
	groups = {armor_head=1, armor_heal=0, armor_use=800},
	armor_groups = {fleshy=4},
	
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})

armor:register_armor("modern_armor:helmet_firefighter", {
	description = ("Firefighter Helmet"),
	inventory_image = "modern_armor_inv_helmet_firefighter.png",
	groups = {armor_head=1, armor_heal=0, armor_use=800, abovehair = 1},
	armor_groups = {fleshy=4},
	
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})

armor:register_armor("modern_armor:helmet_biker", {
	description = ("Biker Helmet"),
	inventory_image = "modern_armor_inv_helmet_biker.png",
	groups = {armor_head=1, armor_heal=0, armor_use=800},
	armor_groups = {fleshy=3},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})

if enable_craft then
minetest.register_craftitem("modern_armor:kevlar", {
	description = "Kevlar",
	inventory_image = "modern_armor_kevlar.png",
})
minetest.register_craft({
	output = "modern_armor:kevlar 4",
	recipe = {
		{"default:paper","group:wool","default:paper"},
		{"group:wool","default:paper","group:wool"},
		{"default:paper","group:wool","default:paper"}
	}
})
minetest.register_craft({
	output = "modern_armor:vest_civilian",
	recipe = {
		{"modern_armor:kevlar","","modern_armor:kevlar"},
		{"modern_armor:kevlar","modern_armor:kevlar","modern_armor:kevlar"},
		{"modern_armor:kevlar","modern_armor:kevlar","modern_armor:kevlar"}
	}
})
minetest.register_craft({
	output = "modern_armor:vest_construction",
	recipe = {
		{"wool:orange","","wool:orange"},
		{"wool:yellow","technic:gold_dust","wool:yellow"},
		{"wool:orange","homedecor:plastic_sheeting","wool:orange"}
	}
})
minetest.register_craft({
	output = "modern_armor:vest_police",
	recipe = {
		{"modern_armor:kevlar","default:gold_ingot","modern_armor:kevlar"},
		{"modern_armor:kevlar","modern_armor:kevlar","modern_armor:kevlar"},
		{"modern_armor:kevlar","modern_armor:kevlar","modern_armor:kevlar"}
	}
})
minetest.register_craft({
	output = "modern_armor:vest_swat",
	recipe = {
		{"modern_armor:kevlar","","modern_armor:kevlar"},
		{"modern_armor:kevlar","technic:copper_plate","modern_armor:kevlar"},
		{"modern_armor:kevlar","technic:copper_plate","modern_armor:kevlar"}
	}
})
minetest.register_craft({
	output = "modern_armor:vest_military",
	recipe = {
		{"modern_armor:kevlar","","modern_armor:kevlar"},
		{"modern_armor:kevlar","technic:composite_plate","modern_armor:kevlar"},
		{"modern_armor:kevlar","technic:composite_plate","modern_armor:kevlar"}
	}
})
minetest.register_craft({
	output = "modern_armor:helmet_swat",
	recipe = {
		{"modern_armor:kevlar","modern_armor:kevlar","modern_armor:kevlar"},
		{"modern_armor:kevlar","default:glass","modern_armor:kevlar"},
		{"default:steel_ingot","",""}
	}
})
minetest.register_craft({
	output = "modern_armor:helmet_military",
	recipe = {
		{"modern_armor:kevlar","modern_armor:kevlar","modern_armor:kevlar"},
		{"modern_armor:kevlar","default:glass","modern_armor:kevlar"},
		{"default:steel_ingot","dye:yellow",""}
	}
})
minetest.register_craft({
	output = "modern_armor:helmet_construction",
	recipe = {
		{"homedecor:plastic_sheeting","homedecor:plastic_sheeting","homedecor:plastic_sheeting"},
		{"homedecor:plastic_sheeting","wool:yellow","homedecor:plastic_sheeting"}
	}
})
minetest.register_craft({
	output = "modern_armor:helmet_police",
	recipe = {
		{"wool:blue","default:gold_ingot","wool:blue"},
		{"wool:blue","homedecor:plastic_sheeting","wool:blue"},
		{"","dye:black",""}
	}
})
minetest.register_craft({
	output = "modern_armor:helmet_firefighter",
	recipe = {
		{"homedecor:plastic_sheeting","default:gold_ingot","homedecor:plastic_sheeting"},
		{"homedecor:plastic_sheeting","modern_armor:kevlar","homedecor:plastic_sheeting"},
		{"modern_armor:kevlar","wool:red","modern_armor:kevlar"}
	}
})
minetest.register_craft({
	output = "modern_armor:helmet_biker",
	recipe = {
		{"homedecor:plastic_sheeting","homedecor:plastic_sheeting","homedecor:plastic_sheeting"},
		{"homedecor:plastic_sheeting","default:glass","homedecor:plastic_sheeting"},
		{"homedecor:plastic_sheeting","wool:black","homedecor:plastic_sheeting"},
	}
})
end
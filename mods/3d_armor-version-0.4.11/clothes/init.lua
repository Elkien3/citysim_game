--[[
clothes_loot = 
{
"clothes:shirt_sweater", "clothes:shirt_tshirt", "clothes:shirt_tanktop", "clothes:shirt_jacket", 
"clothes:shirt_hoodie", "clothes:shirt_police", "clothes:shirt_military", "clothes:shirt_swat", "clothes:shirt_buttonup",
"clothes:pants_jeans", "clothes:pants_cargo", "clothes:pants_shorts", "clothes:pants_police", "clothes:pants_military",
"clothes:hat_wool","clothes:hat_balaclava", "clothes:hat_bandit", "clothes:hat_sunglasses",
"clothes:boots_sneakers", "clothes:boots_police", "clothes:boots_military", "clothes:boots_hiking"
}
--]]

local modpath = minetest.get_modpath(minetest.get_current_modname())
dofile(modpath.."/dyedclothes.lua")

register_dyed_clothes("clothes:shirt_sweater", {
	description = ("Sweater"),
	inventory_image = "clothes_inv_shirt_sweater.png",
	groups = {armor_torso=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
register_dyed_clothes("clothes:shirt_tshirt", {
	description = ("T-Shirt"),
	inventory_image = "clothes_inv_shirt_tshirt.png",
	groups = {armor_torso=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
register_dyed_clothes("clothes:shirt_tanktop", {
	description = ("Tank Top"),
	inventory_image = "clothes_inv_shirt_tanktop.png",
	groups = {armor_torso=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:shirt_jacket", {
	description = ("Jacket"),
	inventory_image = "clothes_inv_shirt_jacket.png",
	groups = {armor_torso=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
register_dyed_clothes("clothes:shirt_hoodie", {
	description = ("Hoodie"),
	inventory_image = "clothes_inv_shirt_hoodie.png",
	texmask = "clothes_shirt_hoodie_mask.png",
	groups = {armor_torso=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:shirt_police", {
	description = ("Police Uniform"),
	inventory_image = "clothes_inv_shirt_police.png",
	groups = {armor_torso=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:shirt_military", {
	description = ("Military Uniform"),
	inventory_image = "clothes_inv_shirt_military.png",
	groups = {armor_torso=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:shirt_swat", {
	description = ("SWAT Uniform"),
	inventory_image = "clothes_inv_shirt_swat.png",
	groups = {armor_torso=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
register_dyed_clothes("clothes:shirt_buttonup", {
	description = ("Button-Up Shirt"),
	inventory_image = "clothes_inv_shirt_buttonup.png",
	texmask = "clothes_shirt_buttonup_mask.png",
	groups = {armor_torso=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:brown_jacket", {
    description = ("Brown Jacket With Blue Shirt"),
    inventory_image = "clothes_inv_brown_jacket.png",
    groups = {armor_torso=2, clothing=1, armor_heal=0, armor_use=100},
    armor_groups = {fleshy=0},
    damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
register_dyed_clothes("clothes:shirt_checker", {
	description = ("Checkered Shirt"),
	inventory_image = "clothes_inv_shirt_checker.png",
	groups = {armor_torso=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
register_dyed_clothes("clothes:shirt_blouse", {
    description = ("Blouse"),
    inventory_image = "clothes_inv_shirt_blouse.png",
    groups = {armor_torso=2, clothing=1, armor_heal=0, armor_use=800},
    armor_groups = {fleshy=0},
    damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:pants_jeans", {
	description = ("Jeans"),
	inventory_image = "clothes_inv_pants_jeans.png",
	groups = {armor_legs=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:pants_cargo", {
	description = ("Cargo Pants"),
	inventory_image = "clothes_inv_pants_cargo.png",
	groups = {armor_legs=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:pants_cargoshorts", {
	description = ("Cargo Shorts"),
	inventory_image = "clothes_inv_pants_cargoshorts.png",
	groups = {armor_legs=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:pants_police", {
	description = ("Police Pants"),
	inventory_image = "clothes_inv_pants_police.png",
	groups = {armor_legs=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:pants_military", {
	description = ("Military Pants"),
	inventory_image = "clothes_inv_pants_military.png",
	groups = {armor_legs=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
register_dyed_clothes("clothes:pants_sweatpants", {
	description = ("Sweatpants"),
	inventory_image = "clothes_inv_pants_sweatpants.png",
	groups = {armor_legs=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
register_dyed_clothes("clothes:pants_shorts", {
	description = ("Shorts"),
	inventory_image = "clothes_inv_pants_shorts.png",
	groups = {armor_legs=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:pants_overalls", {
	description = ("Overalls"),
	inventory_image = "clothes_inv_pants_overalls.png",
	groups = {armor_legs=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:pants_canvas", {
	description = ("Canvas Pants"),
	inventory_image = "clothes_inv_pants_canvas.png",
	groups = {armor_legs=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
register_dyed_clothes("clothes:hat_wool", {
	description = ("Woolen Hat"),
	inventory_image = "clothes_inv_hat_wool.png",
	groups = {armor_head=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:hat_balaclava", {
	description = ("Balaclava"),
	inventory_image = "clothes_inv_hat_balaclava.png",
	groups = {armor_head=2, clothing=1, armor_heal=0, armor_use=100, abovehair = 1},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:hat_bandit", {
	description = ("Bandit Mask"),
	inventory_image = "clothes_inv_hat_bandit.png",
	groups = {armor_head=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:hat_sunglasses", {
	description = ("Sunglasses"),
	inventory_image = "clothes_inv_hat_sunglasses.png",
	groups = {armor_head=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
register_dyed_clothes("clothes:boots_sneakers", {
	description = ("Sneakers"),
	inventory_image = "clothes_inv_boots_sneakers.png",
	texmask = "clothes_boots_sneakers_mask.png",
	groups = {armor_feet=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:boots_police", {
	description = ("Police Shoes"),
	inventory_image = "clothes_inv_boots_police.png",
	groups = {armor_feet=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:boots_kneehigh", {
	description = ("Kneehigh Boots"),
	inventory_image = "clothes_inv_boots_kneehigh.png",
	groups = {armor_feet=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:boots_military", {
	description = ("Miitary Boots"),
	inventory_image = "clothes_inv_boots_military.png",
	groups = {armor_feet=2, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:boots_hiking", {
	description = ("Hiking Boots"),
	inventory_image = "clothes_inv_boots_hiking.png",
	groups = {armor_feet=2, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:shirt_suit", {
	description = ("Suit Coat"),
	inventory_image = "clothes_inv_shirt_suit.png",
	groups = {armor_torso=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:pants_suit", {
	description = ("Suit Pants"),
	inventory_image = "clothes_inv_pants_suit.png",
	groups = {armor_legs=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:shirt_prisoner", {
	description = ("Prisoner Shirt"),
	inventory_image = "clothes_inv_shirt_prisoner.png",
	groups = {armor_torso=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})
armor:register_armor("clothes:pants_prisoner", {
	description = ("Prisoner Pants"),
	inventory_image = "clothes_inv_pants_prisoner.png",
	groups = {armor_legs=2, clothing=1, armor_heal=0, armor_use=100},
	armor_groups = {fleshy=0},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
})

for itemstring, def in pairs(minetest.registered_items) do
	if def.groups.clothing then
		minetest.register_craft({
			output = 'farming:cotton 3',
			type = "shapeless",
			recipe = {itemstring},
		})
	end
end

local modpath = minetest.get_modpath("clothes")
dofile(modpath.."/loom.lua")
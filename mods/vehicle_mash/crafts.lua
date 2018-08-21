local colors = {"black", "blue", "brown", "cyan", 
"dark_green", "dark_grey", "green", "grey", "magenta", 
"orange", "pink", "red", "violet", "white", "yellow"}

for id, color in pairs(colors) do
	minetest.register_craft({
	output = "vehicle_mash:car_"..color,
	recipe = {
		{"default:steel_ingot", "wool:"..color, "default:steel_ingot"},
		{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"}
	}
	})
end
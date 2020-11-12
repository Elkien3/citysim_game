local clothes_dyes = {
	{"grey",       "8c8c8c",       "Grey"},
	{"dark_grey",  "313131",  "Dark Grey"},
	{"black",      "292929",      "Black"},
	{"violet",     "440578",     "Violet"},
	{"blue",       "003c82",       "Blue"},
	{"cyan",       "008a92",       "Cyan"},
	{"dark_green", "195600", "Dark Green"},
	{"green",      "4fbe1c",      "Green"},
	{"yellow",     "fde40f",     "Yellow"},
	{"brown",      "482300",      "Brown"},
	{"orange",     "c74410",     "Orange"},
	{"red",        "ba1414",        "Red"},
	{"magenta",    "c30469",    "Magenta"},
	{"pink",       "f57b7b",       "Pink"},
}

local function col_img(image, color, mask)
	if mask then
		return "("..image.."^("..mask.."^[multiply:#"..color.."))"
	end
	return "("..image.."^[multiply:#"..color..")"
end

function register_dyed_clothes(name, def)
	armor:register_armor(name, def)
	for row, data in pairs(clothes_dyes) do
		local newdef = table.copy(def)
		local string = data[1]
		local hex = data[2]
		local color = data[3]
		newdef.description = (color.." "..newdef.description)
		newdef.inventory_image = col_img(newdef.inventory_image, hex, newdef.invmask)
		newdef.groups.not_in_creative_inventory = 1
		local image = name:gsub("%:", "_")
		newdef.texture = col_img(image..".png", hex, newdef.texmask)
		newdef.preview = "("..col_img(image.."_preview.png", hex, newdef.prevmask).."^[resize:32x64)"
		armor:register_armor(name.."_"..string, newdef)
		minetest.register_craft({
			output = name.."_"..string,
			type = "shapeless",
			recipe = {name, "dye:"..string}
		})
		minetest.register_craft({
			output = name,
			type = "shapeless",
			recipe = {name.."_"..string, "dye:white"}
		})
	end
end
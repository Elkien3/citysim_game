local modpath, S = ...

petz.get_color_group = function(item_name)
	local color_name
	local name
	for _, row in ipairs(dye.dyes) do
		name = row[1]
		color_name = "color_" .. name
		if minetest.get_item_group(item_name, color_name) > 0 then
			break
		end
	end
	name = name:gsub("%_", "")
	return name
end

petz.colorize = function(self, color)
	local background_texture = "petz_"..self.type.."_background.png"
	local overlay_texture = "(petz_"..self.type.."_overlay.png^[colorize:"..color..":125)"
	local colorized_texture = background_texture .."^"..overlay_texture
	petz.set_properties(self, {textures = {colorized_texture}})
	self.colorized = mobkit.remember(self, "colorized", color)
end

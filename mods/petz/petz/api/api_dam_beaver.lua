local modpath, S = ...

--
--Create Dam Beaver Mechanics
--

petz.create_dam = function(self, pos)
	if petz.settings.beaver_create_dam == true and self.dam_created == false then --a beaver can create only one dam
		if math.random(1, 60000) > 1 then --chance of the dam to be created
			return false
		end
		local pos_underwater = { --check if water below (when the beaver is still terrestrial but float in the surface of the water)
			x = pos.x,
			y = pos.y - 4.5,
			z = pos.z,
		}
		if minetest.get_node(pos_underwater).name == "default:sand" then
			local pos_dam = { --check if water below (when the beaver is still terrestrial but float in the surface of the water)
				x = pos.x,
				y = pos.y - 2.0,
				z = pos.z,
			}
			minetest.place_schematic(pos_dam, modpath..'/schematics/beaver_dam.mts', 0, nil, true)
			self.dam_created = true
			return true
		end
    end
    return false
end

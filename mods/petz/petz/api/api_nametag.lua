local modpath, S = ...

petz.update_nametag = function(self)
	local name_tag
	if self.show_tag == true and self.tag and not(self.tag == "") then
		name_tag = self.tag
		self.object:set_nametag_attributes({text = name_tag .." ♥ "..tostring(self.hp).."/"..tostring(self.max_hp),})
	else
		self.object:set_nametag_attributes({text = "",})
	end
end

petz.delete_nametag = function(self)
	self.object:set_nametag_attributes({text = nil,})
end

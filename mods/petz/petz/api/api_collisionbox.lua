local modpath, S = ...

petz.get_collisionbox = function(p1, p2, scale_model, scale_baby)
	p1 = vector.multiply(p1, scale_model)
	p2 = vector.multiply(p2, scale_model)
	local collisionbox = {p1.x, p1.y, p1.z, p2.x, p2.y, p2.z}
	local collisionbox_baby
	if scale_baby then
		local p1b = vector.multiply(p1, scale_baby)
		local p2b = vector.multiply(p2, scale_baby)
		collisionbox_baby = {p1b.x, p1b.y, p1b.z, p2b.x, p2b.y, p2b.z}
	end
	return collisionbox, collisionbox_baby
end

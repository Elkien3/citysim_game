local mod_storage = minetest.get_mod_storage()

wikilib.owners = minetest.deserialize(mod_storage:get_string("owners")) or {}
wikilib.editors = minetest.deserialize(mod_storage:get_string("editors")) or {}

wikilib.owners_save = function()
	mod_storage:set_string("owners", minetest.serialize(wikilib.owners))
end
wikilib.editors_save = function()
	mod_storage:set_string("editors", minetest.serialize(wikilib.editors))
end

wikilib.split = function(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[str] = true
	end
	return t
end
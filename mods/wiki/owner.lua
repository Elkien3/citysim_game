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

wikilib.permission = function(pagename, playername, ownercheck)
	if minetest.check_player_privs(playername, {wiki_admin=true}) then return true end
	if not minetest.check_player_privs(playername, {wiki=true}) then return false end
	local owner = wikilib.owners[pagename]
	if not owner then return true end
	if owner == playername then return true end
	if jobs and jobs.permissionstring(playername, owner) then return true end
	if ownercheck then return false end
	if owner == ":public:" then return true end
	if wikilib.editors[pagename] then
		if wikilib.editors[pagename][playername] or wikilib.editors[pagename][":public:"] then return true end
		if jobs then
			for name, val in pairs(wikilib.editors[pagename]) do
				if jobs.permissionstring(playername, name) then return true end
			end
		end
	end
	return false
end
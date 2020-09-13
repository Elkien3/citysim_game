--
-- petz
-- License:GPLv3
--

local modname = "petz"
local modpath = minetest.get_modpath(modname)
local mg_name = minetest.get_mapgen_setting("mg_name")

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

--
--The Petz
--

petz = {}

--
--Settings
--
petz.settings = {}
petz.settings.mesh = nil
petz.settings.visual_size = {}
petz.settings.rotate = 0

assert(loadfile(modpath .. "/settings.lua"))(modpath) --Load the settings

petz.tamed_by_owner = {} --a list of tamed petz with owner

assert(loadfile(modpath .. "/api/api.lua"))(modpath, modname, S)
assert(loadfile(modpath .. "/mobkit/mobkit.lua"))(modpath, S)
assert(loadfile(modpath .. "/misc/misc.lua"))(modpath, S)
assert(loadfile(modpath .. "/server/cron.lua"))(modname)

petz.file_exists = function(name)
   local f = io.open(name,"r")
   if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

for i = 1, #petz.settings["petz_list"] do --load all the petz.lua files
	local file_name = modpath .. "/petz/"..petz.settings["petz_list"][i].."_mobkit"..".lua"
	if petz.file_exists(file_name) then
		assert(loadfile(file_name))(S)
	end
end

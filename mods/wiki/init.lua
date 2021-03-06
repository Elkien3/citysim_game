
local MODPATH = minetest.get_modpath("wiki")

wikilib = { }

local ie = minetest.request_insecure_environment()
assert(ie, "you must allow `wiki` in `secure.trusted_mods`")

local private = { }

private.open = ie.io.open
private.mkdir = ie.core.mkdir
loadfile(MODPATH.."/owner.lua")(private)
--dofile(MODPATH.."/owner.lua")
loadfile(MODPATH.."/strfile.lua")(private)
loadfile(MODPATH.."/wikilib.lua")(private)
--dofile(MODPATH.."/wikilib.lua")
loadfile(MODPATH.."/internal.lua")(private)
loadfile(MODPATH.."/plugins.lua")(private)

loadfile(MODPATH.."/plugin_forum.lua")(private)

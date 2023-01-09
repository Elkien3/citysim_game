digistuff = {}
local http = minetest.request_http_api()
if not http then
	minetest.log("error","digistuff is not allowed to use the HTTP API - digilines NIC will not be available!")
	minetest.log("error","If this functionality is desired, please add digistuff to your secure.http_mods setting")
else
	loadfile(string.format("%s%s%s.lua",minetest.get_modpath(minetest.get_current_modname()),DIR_DELIM,"nic"))(http)
end

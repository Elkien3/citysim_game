local package_path_origin = package.path
do
	local modname = minetest.get_current_modname()
	local modpath = minetest.get_modpath(modname)
	package.path = modpath .. "/?.lua;" .. package.path
	package.path = modpath .. "/src/?.lua;" .. package.path
	require("src/init")
end
package.path = package_path_origin

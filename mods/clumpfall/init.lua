--[[
   Copyright 2018 Noodlemire

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
--]]

clumpfall = {} --global variable

--the maximum radius of blocks to cause to fall at once. 
clumpfall.clump_radius = 1

--Short for modpath, this stores this really long but automatic modpath get
local mp = minetest.get_modpath(minetest.get_current_modname()).."/"

--Load other lua components
dofile(mp.."functions.lua")
dofile(mp.."override.lua")

--After all items have been registered and 0 seconds have passed, set the do_clump_fall function to run at any postion where a node is dug, placed, or punched,
minetest.after(0, clumpfall.override.register_add_on_digplacepunchnode, clumpfall.functions.do_clump_fall)
--run the make_nodes_fallable function to make most nodes into Clump Fall Nodes,
minetest.after(0, clumpfall.override.make_nodes_fallable)
--and run the place_node() fix 
minetest.after(0, clumpfall.override.fix_falling_nodes)


medical = {}
medical.mod_storage = minetest.get_mod_storage()
medical.usedtools = {}
medical.attachedtools = {}
medical.data = minetest.deserialize(medical.mod_storage:get_string("data")) or {}
medical.entities = {}
medical.save = function()
	medical.mod_storage:set_string("data", minetest.serialize(medical.data))
end
minetest.register_on_shutdown(medical.save)

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/controls.lua")
dofile(modpath.."/hud_anim.lua")
dofile(modpath.."/timers.lua")
dofile(modpath.."/vitals.lua")
dofile(modpath.."/hitloc.lua")
dofile(modpath.."/body.lua")
dofile(modpath.."/tools.lua")
dofile(modpath.."/injuries.lua")

--medical.data["sparky"] = {}
--medical.data["Elkien"] = {}
--medical.data["Elkien"].injuries = {Arm_Left = {name = "fracture"}}--]]
--medical.data["Elkien"].injuries = {Arm_Left = {name = "burn"}, Arm_Right = {name = "bruise"}, Head = {name = "wound"}, Leg_Left = {name = "fracture"}, Leg_Right = {name = "wound_arterial"}, Body = {name = "abrasion"}, Back = {name = "burn"}}--]]
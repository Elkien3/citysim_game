local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/shooter.lua")

if SHOOTER_ENABLE_CROSSBOW == true then
	dofile(modpath.."/crossbow.lua")
end
if SHOOTER_ENABLE_GUNS == true then
	dofile(modpath.."/guns.lua")
end
if SHOOTER_ENABLE_FLARES == true then
	dofile(modpath.."/flaregun.lua")
end
if SHOOTER_ENABLE_HOOK == true then
	dofile(modpath.."/grapple.lua")
end
if SHOOTER_ENABLE_GRENADES == true then
	dofile(modpath.."/grenade.lua")
end
if SHOOTER_ENABLE_ROCKETS == true then
	dofile(modpath.."/rocket.lua")
end
if SHOOTER_ENABLE_TURRETS == true then
	dofile(modpath.."/turret.lua")
end

minetest.register_alias("shooter:rifle", "gunslinger_rangedweapons:ak47")
minetest.register_alias("shooter:pistol", "gunslinger_rangedweapons:glock17")
minetest.register_alias("shooter:shotgun", "gunslinger_rangedweapons:benelli")
minetest.register_alias("shooter:machine_gun", "gunslinger_rangedweapons:uzi")
minetest.register_alias("shooter:ammo", "default:bronze_ingot")
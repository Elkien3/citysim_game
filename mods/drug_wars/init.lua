-- MOD STRUCT INITIALIZATION

drug_wars = {}
drug_wars.path = minetest.get_modpath("drug_wars")
drug_wars.aftereffects = {}
drug_wars.addictions = {}

-- IMPORTS

dofile(drug_wars.path.."/config.lua")
dofile(drug_wars.path.."/helpers.lua")
dofile(drug_wars.path.."/globalupdates.lua")
dofile(drug_wars.path.."/hpeffects.lua")

if drug_wars.ENABLE_INVSEARCH then
    dofile(drug_wars.path.."/invsearch.lua")
end

if drug_wars.ENABLE_MACHETES then
    dofile(drug_wars.path.."/machetes.lua")
end

if drug_wars.ENABLE_PIPES then
    dofile(drug_wars.path.."/pipes.lua")
end

if drug_wars.ENABLE_CANNABIS then
    dofile(drug_wars.path.."/cannabis.lua")
end

if drug_wars.ENABLE_COCA then
    dofile(drug_wars.path.."/coca.lua")
end

if drug_wars.ENABLE_OPIUMPOPPY then
    dofile(drug_wars.path.."/opiumpoppy.lua")
end

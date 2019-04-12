playeranim = {}
playeranim.Model = require("model") -- Can be used by external mods

if not minetest.settings:get("playeranim.disable_forcing_60fps") then
	minetest.settings:set("dedicated_server_step", 1 / 60)
end

require("api")
require("mtg_models")
require("animate_player")

local model = minetest.settings:get("playeranim.model_version")
if model == "" or model == nil then
	model = "MTG_4_Nov_2017"
end
playeranim.set_default_player_model(model)

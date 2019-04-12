local registered_models = {}
local default_player_model = nil

function playeranim.register_model(model_name, model)
	if registered_models[model_name] then
		minetest.log("warning", "playeranim.register_model: Model \"" .. model_name .. "\" is already registered, override.")
	end
	model:validate()
	registered_models[model_name] = model
end

function playeranim.get_model(model_name)
	local model = registered_models[model_name]
	if model then
		return model
	else
		error("playeranim.get_model: Model \"" .. model_name .. "\" doesn't exist.")
	end
end

function playeranim.set_default_player_model(model_name)
	if registered_models[model_name] then
		default_player_model = model_name
	else
		minetest.log("warning", "playeranim.set_default_player_model: Model \"" .. model_name .. "\" doesn't exist.")
	end
end

function playeranim.get_default_player_model()
	if default_player_model == nil then
		error("playeranim.get_default_player_model: Default player model isn't set.")
	end
	return playeranim.get_model(default_player_model)
end


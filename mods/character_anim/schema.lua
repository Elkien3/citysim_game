local function angle(description, default)
    return { type = "number", range = { min = -180, max = 180 }, description = description, default = default }
end
local function range(description, default_min, default_max)
    return {
        type = "table",
        entries = {
            min = angle(description .. " (min)", default_min),
            max = angle(description .. " (max)", default_max)
        },
        func = function(range)
            if range.max < range.min then return "Minimum range value is not <= maximum range value" end
        end
    }
end
local model = {
	type = "table",
	entries = {
		body = {
			type = "table",
			entries = {
                turn_speed = {
                    type = "number",
                    range = { min_exclusive = 0, max = 1e3 },
                    description = "Body turn speed",
                    default = 0.2
                }
            }
		},
		head = {
			type = "table",
			entries = {
				pitch = range("Head pitch", -60, 80),
				yaw = range("Head yaw", -90, 90),
				yaw_restricted = range("Head yaw restricted", 0, 45),
				yaw_restriction = angle("Head yaw restriction", 60)
			}
		},
		arm_right = {
			type = "table",
			entries = {
                radius = angle("Right arm spin radius", 10),
                speed = {
                    type = "number",
                    range = { min_exclusive = 0, max = 1e4 },
                    description = "Right arm spin speed",
                    default = 1e3
                },
                yaw = range("Right arm yaw", -30, 160)
            }
		}
	}
}

return {
    type = "table",
    entries = {
        default = model,
        models = {
            type = "table",
            keys = { type = "string" },
            values = model,
            description = "Other models, same format as `default` model"
        }
    }
}
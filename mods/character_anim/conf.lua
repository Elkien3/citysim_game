local angle = { type = "number", range = { -180, 180 } }
local range = {
	type = "table",
	children = { angle, angle },
	func = function(range)
		if range[2] < range[1] then return "First range value is not <= second range value" end
	end
}
local model = {
	type = "table",
	children = {
		body = {
			type = "table",
			children = { turn_speed = { type = "number", range = { 0, 1e3 } } }
		},
		head = {
			type = "table",
			children = {
				pitch = range,
				yaw = range,
				yaw_restricted = range,
				yaw_restriction = angle
			}
		},
		arm_right = {
			type = "table",
			children = { radius = angle, speed = { type = "number", range = { 0, 1e4 } }, yaw = range }
		}
	}
}
conf = modlib.conf.import(minetest.get_current_modname(), {
    type = "table",
    children = {
	    default = model,
        models = { type = "table", keys = { type = "string" }, values = model }
    }
})
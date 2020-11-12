local speedgun = {}

local function getspeed(player)
	local eye_offset = {x = 0, y = 1.45, z = 0}
	local dir = player:get_look_dir()
	local p1 = vector.add(player:get_pos(), eye_offset)
	local p2 = vector.add(p1, vector.multiply(dir, 200))
	local ray = minetest.raycast(p1, p2)
	local pointed = ray:next()
	if pointed and pointed.ref and pointed.ref == player then
		pointed = ray:next()
	end
	if pointed and pointed.type == "object" then
		local target = pointed.ref
		local v = target:get_velocity() or {x=0,y=0,z=0}
		if target:is_player() then
			v = target:get_player_velocity() or {x=0,y=0,z=0}
		end
		return vector.length(v)
	end
	return 0
end

local function dospeed(player, name)
	if not player or not player:is_player() then speedgun[name] = nil return end
	if not name then speedgun[name] = nil return end
	local speed = getspeed(player)
	if speed > speedgun[name] then
		speedgun[name] = speed
	end
	minetest.sound_play("blip", {
		object = player,
		max_hear_distance = 10,
		pitch = speed/60+.5,
		gain = .5
	})
	if player:get_player_control().LMB then
		minetest.after(.2, dospeed, player, name)
	else
		minetest.chat_send_player(name, "Speed gun reads "..tostring(math.floor(speedgun[name]*2.237*10)*.1).." MPH")
		speedgun[name] = nil
	end
end

minetest.register_tool('policetools:speedgun', {
	description = ('Speed Gun'),
	inventory_image = 'policetools_speedgun.png',
	on_use = function(stack, player, pointedThing)
		local name = player:get_player_name()
		speedgun[name] = getspeed(player)
		minetest.after(.1, dospeed, player, name)
	end,
})
minetest.register_craft({
	output = 'policetools:speedgun',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', ''},
		{'default:glass', 'mesecons_torch:mesecon_torch_on', 'default:steel_ingot'},
		{'dye:red', 'default:steel_ingot',''},
	}
})
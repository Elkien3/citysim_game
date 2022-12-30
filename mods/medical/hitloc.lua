--standing locations
local limb = {}
limb["standing"]= {Head = {x=0,y=1.6,z=0}, Body = {x=0,y=1,z=.12}, Back = {x=0,y=1,z=-.12}, Arm_Right = {x=.3,y=1,z=0}, Arm_Left = {x=-.3,y=1,z=0}, Leg_Right = {x=.1,y=.4,z=0}, Leg_Left = {x=-.1,y=.4,z=0}}

-- sitting locations
limb["sitting"] = {Head = {x=0,y=.9,z=0}, Body = {x=0,y=.4,z=.12}, Back = {x=0,y=.4,z=-.12}, Arm_Right = {x=.3,y=.4,z=0}, Arm_Left = {x=-.3,y=.4,z=0}, Leg_Right = {x=.1,y=.1,z=.35}, Leg_Left = {x=-.1,y=.1,z=.35}}

-- laying locations
limb["laying"] = {Head = {x=0,y=.1,z=-.65}, Body = {x=0,y=.1,z=-.2}, Arm_Right = {x=.4,y=.1,z=-.125}, Arm_Left = {x=-.4,y=.1,z=-.125}, Leg_Right = {x=.2,y=.1,z=.5}, Leg_Left = {x=-.2,y=.1,z=.5}}

limb["recumbant"] = {Back = {x=0,y=.2,z=1.6}}
--[[ old anim range based way of doing it
function medical.get_limb_locations(player, tbl)
	if not tbl then tbl = limb end
	local anim_range = player:get_animation()
	if (anim_range.x >= 0 and anim_range.x <= 80) or (anim_range.x >= 168 and anim_range.x <= 220) then
		return tbl["standing"] or {}, "standing"
	elseif (anim_range.x >= 81 and anim_range.x <= 161) then
		return tbl["sitting"] or {}, "sitting"
	elseif (anim_range.x >= 162 and anim_range.x <= 167) then
		return tbl["laying"] or {}, "laying"
	elseif (anim_range.x >= 223 and anim_range.x <= 224) then
		return tbl["recumbant"] or {}, "rightrecumbant"
	elseif (anim_range.x >= 225 and anim_range.x <= 226) then
		return tbl["recumbant"] or {}, "leftrecumbant"
	end
end
--]]
function medical.get_limb_locations(player, tbl)
	if not tbl then tbl = limb end
	local anim = player_api.get_animation(player).animation
	local anim_range = player:get_animation()
	if (anim_range.x >= 223 and anim_range.x <= 224) then
		return tbl["recumbant"] or {}, "rightrecumbant"
	elseif (anim_range.x >= 225 and anim_range.x <= 226) then
		return tbl["recumbant"] or {}, "leftrecumbant"
	elseif anim == "sit" then
		return tbl["sitting"] or {}, "sitting"
	elseif anim == "lay" then
		return tbl["laying"] or {}, "laying"
	else
		return tbl["standing"] or {}, "standing"
	end
end
local DEBUG_WAYPOINT = false
local DEBUG_CHAT = false

local function rotateVector(x, y, a)
  local c = math.cos(a)
  local s = math.sin(a)
  return c*x - s*y, s*x + c*y
end

function medical.gethitloc(player, hitter, tool_capabilities, dir)
	if not player or not hitter then return end
	local playerpos = player:get_pos()
	local hitpos
	local hitterpos = hitter:get_pos()
	local adj_hitterpos = hitterpos
	local isPlayer = hitter:is_player()
	if isPlayer then
		adj_hitterpos.y = adj_hitterpos.y + 1.45 -- eye offset
		local offset, _ = hitter:get_eye_offset()
		local hitteryaw = hitter:get_look_horizontal()
		local x, z = rotateVector(offset.x, offset.z, hitteryaw)
		offset = vector.multiply({x=x, y=offset.y, z=z}, .1)
		adj_hitterpos = vector.add(adj_hitterpos, offset)
	else
		local properties = hitter:get_properties()
		local offset = properties.eye_height or math.abs(properties.collisionbox[2] - properties.collisionbox[4])
		adj_hitterpos.y = adj_hitterpos.y + offset/2
	end
	if tool_capabilities and tool_capabilities.damage_groups and dir and tool_capabilities.damage_groups.medical_dir then
		hitpos = vector.add(adj_hitterpos, vector.multiply(dir, vector.distance(playerpos, hitterpos)))
	else
		local pointdir = hitter:get_look_dir() or {}
		if not pointdir or pointdir == nil or not isPlayer then
			local yaw = hitter:getyaw()
			local pitch = 0
			pointdir.x = -1*math.cos(yaw)*math.cos(pitch)
			pointdir.z = -1*math.sin(yaw)*math.cos(pitch)
			pointdir.y = math.sin(pitch)
		end
		hitpos = vector.add(adj_hitterpos, vector.multiply(pointdir, vector.distance(playerpos, hitterpos)))
	end
	if minetest.raycast then
		local ray = minetest.raycast(adj_hitterpos, hitpos) -- it checks the players exact front before anything else because the default hit dir is weird, this may cause inaccuracies if a weapon with spread gives a look vector as a dir and the ray that goes stright ahead still hits the player
		local pointed = ray:next()
		if pointed and pointed.ref and pointed.ref == hitter then
			pointed = ray:next()
		end
		if pointed and pointed.ref == player then
			hitpos = pointed.intersection_point
		end
	end
	local playeryaw
	if player:is_player() then
		local parent, bone, attachpos, attachrot =  player:get_attach()
		if parent and not parent:is_player() then
			playeryaw = math.rad(parent:get_yaw())
			playeryaw = playeryaw+math.rad(attachrot.y)
		elseif parent then--parent is player
			playeryaw = parent:get_look_horizontal()
		else
			playeryaw = player:get_look_horizontal()
		end
	else
		playeryaw = player:get_yaw()
	end
	local loc = vector.subtract(hitpos, playerpos)
	local x, z = rotateVector(loc.x, loc.z, playeryaw)
	local local_hitpos = {x=x,y=loc.y,z=z}
	if DEBUG_WAYPOINT then
		local marker = hitter:hud_add({
			hud_elem_type = "waypoint",
			name = "hit",
			number = 0xFF0000,
			world_pos = hitpos
		})
		minetest.after(10, function() hitter:hud_remove(marker) end, hitter, marker)
	end
	return hitpos, local_hitpos
end

function medical.getclosest(table, local_hitpos)
	local distance
	local closest
	for name, loc in pairs (table) do
		if not distance then
			distance = vector.distance(loc, local_hitpos)
			closest = name
		else
			if vector.distance(loc, local_hitpos) < distance then
				distance = vector.distance(loc, local_hitpos)
				closest = name
			end
		end
	end
	return distance, closest
end

function medical.getlimb(player, hitter, tool_capabilities, dir, hitloc)
	local hitpos
	if hitloc then
		hitpos = hitloc
	else
		hitpos = medical.gethitloc(player, hitter, tool_capabilities, dir)
		if not hitpos then return end
	end
	local hitlimb
	local hitdistance
	local playeryaw
	local playerpos = player:get_pos()
	if player:is_player() then
		local parent, bone, attachpos, attachrot =  player:get_attach()
		if parent and not parent:is_player() then
			playeryaw = parent:get_yaw()
			playeryaw = playeryaw+math.rad(attachrot.y)
		else
			playeryaw = player:get_look_horizontal()
		end
	else
		playeryaw = player:get_yaw()
	end
	for id, pos in pairs(medical.get_limb_locations(player)) do
		local x, z = rotateVector(pos.x, pos.z, playeryaw)
		local rot_pos = {x=x,y=pos.y,z=z}
		local adj_pos = vector.add(playerpos, rot_pos)
		local dist = vector.distance(adj_pos, hitpos)
		if hitdistance == nil or dist < hitdistance then
			hitdistance = dist
			hitlimb = id
		end
		if DEBUG_WAYPOINT then 
			local mrker = hitter:hud_add({
				hud_elem_type = "waypoint",
				name = id,
				number = 0xFF0000,
				world_pos = adj_pos
			})
			minetest.after(5, function() hitter:hud_remove(mrker) end, hitter, mrker)
		end
	end
	if DEBUG_CHAT then
		minetest.chat_send_all(dump(hitlimb))
	end
	return hitlimb
end
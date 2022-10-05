local hud_animations = {}

function medical.add_anim_hud(player, def)
	local name = player:get_player_name()
	if not name or not def then return end
	local def = table.copy(def)
	if not def.timer then def.timer = 0 end
	if not def.frame_duration then def.frame_duration = .25 end--4 fps default
	local currentframe = math.floor((def.timer/(def.frame_duration*def.frame_amount))*def.frame_amount)
	--minetest.chat_send_all(currentframe)
	local tbl = table.copy(def)
	def.text = def.text.."^[verticalframe:"..def.frame_amount..":"..currentframe
	if not hud_animations[name] then hud_animations[name] = {} end
	local id = player:hud_add(def)
	hud_animations[name][id] = tbl
	return id
end

function medical.remove_anim_hud(player, id)
	local name = player:get_player_name()
	if not name or not id or not hud_animations[name] then return end
	hud_animations[name][id] = nil
	if #hud_animations[name] == 0 then
		hud_animations[name] = nil
	end
	player:hud_remove(id)
	return true
end

minetest.register_globalstep(function(dtime)
	for name, hudlist in pairs(hud_animations) do
		local player = minetest.get_player_by_name(name)
		if not player then
			hud_animations[name] = nil
			goto next1
		end
		for id, def in pairs(hudlist) do
			local oldframe = math.floor((def.timer/(def.frame_duration*def.frame_amount))*def.frame_amount)
			def.timer = def.timer + dtime
			local currentframe = math.floor((def.timer/(def.frame_duration*def.frame_amount))*def.frame_amount)
			if currentframe >= def.frame_amount then
				if not def.loop then
					if def.keep_at_end then
						currentframe = def.frame_amount - 1
					else
						medical.remove_anim_hud(player, id)
						goto next2
					end
				else
					def.timer = def.timer - (def.frame_duration*def.frame_amount)
					currentframe = math.floor((def.timer/(def.frame_duration*def.frame_amount))*def.frame_amount)
				end
			end
			if oldframe~=currentframe then
				player:hud_change(id, "text", def.text.."^[verticalframe:"..def.frame_amount..":"..currentframe)
			end
			::next2::
		end
		::next1::
	end
end)
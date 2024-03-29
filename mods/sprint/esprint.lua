--[[
Sprint mod for Minetest by GunshipPenguin

To the extent possible under law, the author(s)
have dedicated all copyright and related and neighboring rights 
to this software to the public domain worldwide. This software is
distributed without any warranty. 
]]

local players = {}
local staminaHud = {}

local function setSprinting(playerName, sprinting) --Sets the state of a player (0=stopped/moving, 1=sprinting)
	local player = minetest.get_player_by_name(playerName)
	if players[playerName] then
		players[playerName]["sprinting"] = sprinting
		local newPhy = player:get_physics_override()
		local privs = minetest.get_player_privs(playerName)

		if sprinting == true then
			if playercontrol then
				newPhy.speed = playercontrol.set_effect(playerName, "speed", (1+SPRINT_SPEED), "sprint", true)
				newPhy.jump = playercontrol.set_effect(playerName, "jump", (1+SPRINT_JUMP), "sprint", true)
			else
				newPhy.speed = newPhy.speed + SPRINT_SPEED
				newPhy.jump = newPhy.jump + SPRINT_JUMP
			end
			if player:hud_get_flags().wielditem or interacthandler then
				if interacthandler then
					interacthandler.revoke(playerName)
				else
					players[playerName].hasinteract = privs.interact
					privs.interact = nil
					minetest.set_player_privs(playerName, privs)
				end
				if player:hud_get_flags().wielditem then
					players[playerName].haswield = true
					player:hud_set_flags({wielditem=false})
				end
			end
		elseif sprinting == false then
			if playercontrol then
				newPhy.speed = playercontrol.set_effect(playerName, "speed", nil, "sprint", true)
				newPhy.jump = playercontrol.set_effect(playerName, "jump", nil, "sprint", true)
			else
				newPhy.speed = newPhy.speed - SPRINT_SPEED
				newPhy.jump = newPhy.jump - SPRINT_JUMP
			end
			minetest.after(0.2, function()
					if players[playerName] and players[playerName]["sprinting"] == false then
						if interacthandler then
							interacthandler.grant(playerName)
						else
							privs.interact = players[playerName].hasinteract
							minetest.set_player_privs(playerName, privs)
						end
						if players[playerName].haswield then
							player:hud_set_flags({wielditem=true})
							players[playerName].haswield = nil
						end
					end
			end)
			
		end
		if not playercontrol then
			player:set_physics_override(newPhy)
		end
		return true
	end
	return false
end

minetest.register_on_joinplayer(function(player)
	local playerName = player:get_player_name()

	players[playerName] = {
		sprinting = false,
		timeOut = 0, 
		stamina = SPRINT_STAMINA, 
		shouldSprint = false,
	}
	if SPRINT_HUDBARS_USED then
		hb.init_hudbar(player, "sprint")
	else
		players[playerName].hud = player:hud_add({
			hud_elem_type = "statbar",
			position = {x=0.5,y=1},
			size = {x=24, y=24},
			text = "sprint_stamina_icon.png",
			number = 20,
			alignment = {x=0,y=1},
			offset = {x=-263, y=-110},
			}
		)
	end
end)
minetest.register_on_leaveplayer(function(player)
	local playerName = player:get_player_name()
	if not interacthandler then
		local privs = minetest.get_player_privs(playerName)
		if players[playerName].hasinteract then
			privs.interact = players[playerName].hasinteract
		end
		minetest.set_player_privs(playerName, privs)
	end
	players[playerName] = nil
end)
minetest.register_globalstep(function(dtime)
	--Get the gametime
	local gameTime = minetest.get_gametime()

	--Loop through all connected players
	for playerName,playerInfo in pairs(players) do
		local player = minetest.get_player_by_name(playerName)
		if player ~= nil then
			--Check if the player should be sprinting
			if player:get_player_control()["aux1"] and player:get_player_control()["up"] then
				players[playerName]["shouldSprint"] = true
			else
				players[playerName]["shouldSprint"] = false
			end
			
			--If the player is sprinting, create particles behind him/her 
			if playerInfo["sprinting"] == true and gameTime % 0.1 == 0 then
				local numParticles = math.random(1, 2)
				local playerPos = player:getpos()
				local playerNode = minetest.get_node({x=playerPos["x"], y=playerPos["y"]-1, z=playerPos["z"]})
				if playerNode["name"] ~= "air" then
					for i=1, numParticles, 1 do
						minetest.add_particle({
							pos = {x=playerPos["x"]+math.random(-1,1)*math.random()/2,y=playerPos["y"]+0.1,z=playerPos["z"]+math.random(-1,1)*math.random()/2},
							velocity = {x=0, y=5, z=0},
							acceleration = {x=0, y=-13, z=0},
							expirationtime = math.random(),
							size = math.random()+0.5,
							collisiondetection = true,
							vertical = false,
							texture = "sprint_particle.png",
						})
					end
				end
			end

			--Adjust player states
			if players[playerName]["shouldSprint"] == true and players[playerName].sprinting == false and playerInfo["stamina"] > SPRINT_STAMINA/4 and minetest.check_player_privs(playerName, {interact=true}) then --Stopped
				setSprinting(playerName, true)
			elseif players[playerName]["shouldSprint"] == false and players[playerName].sprinting == true then
				setSprinting(playerName, false)
			end
			
			--Lower the player's stamina by dtime if he/she is sprinting and set his/her state to 0 if stamina is zero
			if playerInfo["sprinting"] == true then 
				playerInfo["stamina"] = playerInfo["stamina"] - dtime
				if playerInfo["stamina"] <= 0 then
					playerInfo["stamina"] = 0
					setSprinting(playerName, false)
				end
			
			--Increase player's stamina if he/she is not sprinting and his/her stamina is less than SPRINT_STAMINA
			elseif playerInfo["sprinting"] == false and playerInfo["stamina"] < SPRINT_STAMINA then
				playerInfo["stamina"] = playerInfo["stamina"] + dtime
			end
			-- Cap stamina at SPRINT_STAMINA
			if playerInfo["stamina"] > SPRINT_STAMINA then
				playerInfo["stamina"] = SPRINT_STAMINA
			end
			
			--Update the players's hud sprint stamina bar

			if SPRINT_HUDBARS_USED then
				hb.change_hudbar(player, "sprint", playerInfo["stamina"])
			else
				local numBars = (playerInfo["stamina"]/SPRINT_STAMINA)*20
				player:hud_change(playerInfo["hud"], "number", numBars)
			end
		end
	end
end)

minetest.log('action', '[MOD] Frisk loading ...')
local frisk_version = "0.0.2"
local take_items = false
local modstorage = minetest.get_mod_storage()
local i18n --internationalization

local wassneaking = {}
local cuffdamage = minetest.deserialize(modstorage:get_string("cuffdamage")) or {}

if minetest.get_modpath("intllib") then
	i18n = intllib.Getter()
else
	i18n = function(s,a,...)
		a={a,...}
		local v = s:gsub("@(%d+)", function(n)
			return a[tonumber(n)]
		end)
		return v
	end
end

local function finishfrisk(player, pName, oldpos)
	local pPlayer = minetest.get_player_by_name(pName)
	local name = player:get_player_name()
	if vector.distance(pPlayer:getpos(), oldpos) > .1 then
		minetest.chat_send_player(pName, "You moved, frisk canceled.")
		minetest.chat_send_player(name, pName.." moved, frisk canceled.")
		return
	end
	local player_inv = minetest.get_inventory({type='player', name = pName}) --InvRef
	local detached_inv = minetest.create_detached_inventory(pName, {
	allow_move = function()
		return 0
	end,
	allow_put = function()
		return 0
	end,
	allow_take = function()
		return 0
	end,
	}) --InvRef
	if take_items then
		detached_inv = minetest.create_detached_inventory(pName, {
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			player_inv:set_list('main', inv:get_list('main'))
			player_inv:set_list('craft', inv:get_list('craft'))
		end,

		on_put = function(inv, listname, index, stack, player)
			player_inv:set_list('main', inv:get_list('main'))
			player_inv:set_list('craft', inv:get_list('craft'))
		end,
		on_take = function(inv, listname, index, stack, player)
			player_inv:set_list('main', inv:get_list('main'))
			player_inv:set_list('craft', inv:get_list('craft'))
		end,
		})
	end	--InvRef
	detached_inv:set_list('main', player_inv:get_list('main'))
	detached_inv:set_list('craft', player_inv:get_list('craft'))
	local formspec =
		'size[8,12]' ..
		'label[0,0;' .. i18n("@1\'s inventory", pName) ..']'..
		'list[detached:'.. pName..';craft;3,0;3,3;]'..
		'list[detached:'.. pName..';main;0,4;8,4;]'..
		"list[current_player;main;0,8;8,4;]"
	minetest.show_formspec(player:get_player_name(), 'frisk:frisk', formspec)
	minetest.chat_send_player(pName, "You were frisked by "..name..".")
end

local function startfrisk(stack, player, pointedThing)
	local obj = pointedThing.ref
	if obj and pointedThing.type == "object" then
		local pName = obj:get_player_name()
		if pName ~= "" then
			local name = player:get_player_name()
			minetest.chat_send_player(pName, name.." is frisking you, move to cancel.")
			minetest.chat_send_player(name, "You are frisking "..pName..".")
			local oldpos = obj:getpos()
			minetest.after(8, finishfrisk, player, pName, oldpos)
		end
	end
end

minetest.register_privilege("frisk", "Player can check other players\' inventory.")

minetest.register_tool('frisk:screen', {
	description = i18n('Screening Device'),
	inventory_image = 'frisk_screen.png',
	range = 1,
	on_use = startfrisk,
})

--HANDCUFFS

local cuffedplayers = minetest.deserialize(modstorage:get_string("cuffedplayers")) or {}
local hasshout = minetest.deserialize(modstorage:get_string("hasshout")) or {}
minetest.register_on_joinplayer(function(player)
	local playerName = player:get_player_name()
	if cuffedplayers[playerName] ~= nil then
		if interacthandler then
			interacthandler.revoke(playerName)
		end
		player:hud_set_flags({wielditem=false})
	end
end)

minetest.register_on_prejoinplayer(function(playerName, ip)
	if cuffedplayers[playerName] ~= nil then
		if not interacthandler then
			local privs = minetest.get_player_privs(playerName)
			privs.shout = nil
			privs.interact = nil
			minetest.set_player_privs(playerName, privs)
		end
	end
end)

local function finishcuff(player, pName, oldpos)
	local pPlayer = minetest.get_player_by_name(pName)
	local name = player:get_player_name()
	if vector.distance(pPlayer:getpos(), oldpos) > .1 then
		minetest.chat_send_player(pName, "You moved, cuff canceled.")
		minetest.chat_send_player(name, pName.." moved, cuff canceled.")
		local wearcalc
		if cuffdamage[pName] then
			wearcalc = cuffdamage[pName]/400*65535
		else
			wearcalc = 0
		end
		minetest.add_item(pPlayer:getpos(), {name="frisk:handcuffs", count=1, wear=wearcalc, metadata=""})
		cuffdamage[pName] = nil
		modstorage:set_string("cuffdamage", minetest.serialize(cuffdamage))
		return
	end
	if interacthandler then
		interacthandler.revoke(pName)
		cuffedplayers[pName] = true
	else
		local privs = minetest.get_player_privs(pName)
		
		--[[if privs.shout then
			hasshout[pName] = true
		else
			hasshout[pName] = false
		end
		privs.shout = nil
		modstorage:set_string("hasshout", minetest.serialize(hasshout))--]]
		
		if privs.interact then
			cuffedplayers[pName] = true
		else
			cuffedplayers[pName] = false
		end
		privs.interact = nil
		minetest.set_player_privs(pName, privs)
	end
	pPlayer:hud_set_flags({wielditem=false})
	modstorage:set_string("cuffedplayers", minetest.serialize(cuffedplayers))
	minetest.chat_send_player(pName, "You were cuffed.")
	minetest.chat_send_player(name, "You cuffed "..pName..".")
end

local function startcuff(stack, player, pointedThing)
	local obj = pointedThing.ref
	if obj and pointedThing.type == "object" then
		local pName = obj:get_player_name()
		if obj:get_luaentity() and obj:get_luaentity().name == "knockout:entity" then
			pName = obj:get_luaentity().grabbed_name
		end
		if pName ~= "" then
			if cuffedplayers[pName] == nil then
				local itemstack = player:get_wielded_item()
				if itemstack:get_name() == "frisk:handcuffs" then
					cuffdamage[pName] = itemstack:get_wear()/65535*400 or 0
					itemstack:take_item()
					local name = player:get_player_name()
					minetest.chat_send_player(pName, name.." is cuffing you, move to cancel.")
					minetest.chat_send_player(name, "You are cuffing "..pName..".")
					local oldpos = obj:getpos()
					minetest.after(6, finishcuff, player, pName, oldpos)
					minetest.sound_play("cuff", {
						pos = obj:getpos(),
						max_hear_distance = 10,
						gain = 1.0,
						object = obj
					})
					modstorage:set_string("cuffdamage", minetest.serialize(cuffdamage))
					return itemstack
				end
			else
				minetest.chat_send_player(pName, "Player already cuffed.")
			end
		end
	end
end

local function uncuff(stack, player, pointedThing)
	local obj = pointedThing.ref
	if obj and pointedThing.type == "object" then
		local pName = obj:get_player_name()
		if obj:get_luaentity() and obj:get_luaentity().name == "knockout:entity" then
			pName = obj:get_luaentity().grabbed_name
		end
		if pName ~= "" then
			if cuffedplayers[pName] ~= nil then
				if interacthandler then
					interacthandler.grant(pName)
				else
					local privs = minetest.get_player_privs(pName)
					if cuffedplayers[pName] == true then
						privs.interact = true
					else
						privs.interact = nil
					end
					
					--[[if hasshout[pName] == true then
						privs.shout = true
					else
						privs.shout = nil
					end
					hasshout[pName] = nil
					modstorage:set_string("hasshout", minetest.serialize(hasshout))--]]
					
					minetest.set_player_privs(pName, privs)
				end
				obj:hud_set_flags({wielditem=true})
				cuffedplayers[pName] = nil
				modstorage:set_string("cuffedplayers", minetest.serialize(cuffedplayers))
				local player_inv = player:get_inventory()
				local wearcalc
				if cuffdamage[pName] then
					wearcalc = cuffdamage[pName]/400*65535
				else
					wearcalc = 0
				end
				minetest.sound_play("uncuff", {
					pos = obj:getpos(),
					max_hear_distance = 10,
					gain = 1.0,
					object = obj
				})
				minetest.add_item(obj:getpos(), player_inv:add_item("main", {name="frisk:handcuffs", count=1, wear=wearcalc, metadata=""}))
				cuffdamage[pName] = nil
				modstorage:set_string("cuffdamage", minetest.serialize(cuffdamage))
			end
		end
	end
end

minetest.register_craft({
	output = 'frisk:screen',
	recipe = {
		{'', 'default:steel_ingot', ''},
		{'default:steel_ingot', 'default:glass', 'default:steel_ingot'},
		{'', 'default:steel_ingot',''},
	}
})

minetest.register_tool('frisk:handcuffs', {
	description = ('Handcuffs'),
	inventory_image = 'frisk_handcuffs.png',
	range = 2,
	on_use = startcuff,
})
minetest.register_craft({
	output = 'frisk:handcuffs',
	recipe = {
		{'', 'default:steel_ingot', ''},
		{'default:steel_ingot', 'default:bronze_ingot', 'default:steel_ingot'},
		{'', 'default:steel_ingot',''},
	}
})
minetest.register_tool('frisk:handcuff_key', {
	description = ('Handcuff Key'),
	inventory_image = 'frisk_handcuff_key.png',
	range = 1,
	on_use = uncuff,
})
minetest.register_craft({
	output = 'frisk:handcuff_key',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', ''},
		{'default:steel_ingot', '', ''},
		{'', '', ''},
	}
})
--player:set_bone_position(bone, bone_position[bone], rotation)
minetest.register_globalstep(function(dtime)
	for name in pairs(cuffedplayers) do
		local player = minetest.get_player_by_name(name)
		if player then
			if player:get_player_control().sneak then
				if wassneaking[name] == nil then
					wassneaking[name] = true
					if not cuffdamage[name] then
						cuffdamage[name] = 0
					end
					cuffdamage[name] = cuffdamage[name] + math.random(1,3)
					if math.random(1,5) == 1 then
						minetest.sound_play("wriggle", {
							pos = player:getpos(),
							max_hear_distance = 10,
							gain = 1.0,
							object = player
						})
					end
					if cuffdamage[name] >= 400 then
						if interacthandler then
							interacthandler.grant(name)
						else
							local privs = minetest.get_player_privs(name)
							if cuffedplayers[name] == true then
								privs.interact = true
							else
								privs.interact = nil
							end
							--[[if hasshout[name] == true then
								privs.shout = true
							else
								privs.shout = nil
							end
							hasshout[name] = nil
							modstorage:set_string("hasshout", minetest.serialize(hasshout))--]]
							minetest.set_player_privs(name, privs)
						end
						cuffdamage[name] = nil
						player:hud_set_flags({wielditem=true})
						minetest.sound_play("uncuff", {
							pos = player:getpos(),
							max_hear_distance = 10,
							gain = 1.0,
							object = player
						})
						cuffedplayers[name] = nil
						modstorage:set_string("cuffedplayers", minetest.serialize(cuffedplayers))
					end
					modstorage:set_string("cuffdamage", minetest.serialize(cuffdamage))
				end
			else
				if wassneaking[name] then
					wassneaking[name] = nil
				end
			end
		end
	end
end)

minetest.register_on_dieplayer(function(player)
	local pName = player:get_player_name()
	if cuffedplayers[pName] ~= nil then
		local privs = minetest.get_player_privs(pName)
		if cuffedplayers[pName] == true then
			privs.interact = true
		else
			privs.interact = nil
		end
		if hasshout[pName] == true then
			privs.shout = true
		else
			privs.shout = nil
		end
		hasshout[pName] = nil
		modstorage:set_string("hasshout", minetest.serialize(hasshout))
		
		minetest.set_player_privs(pName, privs)
		player:hud_set_flags({wielditem=true})
		cuffedplayers[pName] = nil
		modstorage:set_string("cuffedplayers", minetest.serialize(cuffedplayers))
		local player_inv = player:get_inventory()
		local wearcalc
		if cuffdamage[pName] then
			wearcalc = cuffdamage[pName]/400*65535
		else
			wearcalc = 0
		end
		minetest.add_item(player:getpos(), {name="frisk:handcuffs", count=1, wear=wearcalc, metadata=""})
		cuffdamage[pName] = nil
		modstorage:set_string("cuffdamage", minetest.serialize(cuffdamage))
	end
end)

minetest.log('action', 'MOD: Frisk version ' .. frisk_version .. ' loaded.')

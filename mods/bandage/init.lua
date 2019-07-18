local bandagers = {}
local HEAL_TIME = 6
local HEAL_AMOUNT = 4
local HEAL_MAX = 10

function bandage(bandager, player)
	if not bandager or not player then return end
	local bandagerName = bandager:get_player_name()
	local playerName = player:get_player_name()
	if not bandagerName or not playerName then return end
	if bandagers[bandagerName] then
		--cancel bandaging if either of them move, or the bandager changes slot, drops bandage, or stops holding down LMB
		if vector.distance(bandagers[bandagerName].bandagerpos, bandager:get_pos()) > .1 then
			minetest.chat_send_player(bandagerName, "You moved, bandaging canceled.")
			if bandagerName ~= playerName then
				minetest.chat_send_player(playerName, bandagerName.." moved, bandaging canceled.")
			end
			bandagers[bandagerName] = nil
			return
		elseif vector.distance(bandagers[bandagerName].playerpos, player:get_pos()) > .1 then
			minetest.chat_send_player(bandagerName, playerName.." moved, bandaging canceled.")
			minetest.chat_send_player(playerName, "You moved, bandaging canceled.")
			bandagers[bandagerName] = nil
			return
		elseif not minetest.check_player_privs(bandager, {interact=true}) or not bandager:get_player_control().LMB or bandagers[bandagerName].index ~= bandager:get_wield_index() or bandager:get_wielded_item():get_name() ~= "bandage:bandage" then
			minetest.chat_send_player(bandagerName, "You stopped bandaging.")
			if bandagerName ~= playerName then
				minetest.chat_send_player(playerName, bandagerName.." stopped bandaging.")
			end
			bandagers[bandagerName] = nil
			return
		end
		if player:get_hp() > HEAL_MAX and not (knockout and knockout.downedplayers and knockout.downedplayers[playerName] == true) then
			if bandagerName == playerName then
				minetest.chat_send_player(bandagerName, "You are above max bandaging health.")
			else
				minetest.chat_send_player(bandagerName, playerName.." is above max bandaging health.")
			end
			bandagers[bandagerName] = nil
			return
		end
		--finish bandaging
		if (os.time() - bandagers[bandagerName].time) > HEAL_TIME then
			local inv = bandager:get_inventory()
			local list = bandager:get_wield_list()
			local stack = inv:get_stack(list, bandagers[bandagerName].index)
			stack:take_item()
			inv:set_stack(list, bandagers[bandagerName].index, stack)
			minetest.sound_play("bandagefinish", {
				pos = bandagers[bandagerName].bandagerpos,
				max_hear_distance = 10,
				gain = 1.0,
				object = bandager
			})
			local hp = player:get_hp()
			--knockout revive support
			if knockout and knockout.downedplayers and knockout.downedplayers[playerName] == true then
				player:set_hp(HEAL_AMOUNT)
				knockout.downedplayers[playerName] = nil
				knockout.savedownedplayers()
				knockout.wake_up(playerName)
			else
				if (hp + HEAL_AMOUNT) >= HEAL_MAX then
					player:set_hp(HEAL_MAX)
				else
					player:set_hp(hp + HEAL_AMOUNT)
				end
			end
			if bandagerName == playerName then
				minetest.chat_send_player(bandagerName, "You bandaged yourself.")
			else
				minetest.chat_send_player(bandagerName, "You bandaged "..playerName..".")
				minetest.chat_send_player(playerName, bandagerName.." bandaged you.")
			end
			bandagers[bandagerName] = nil
			return
		else
			minetest.after(1, bandage, bandager, player)
		end
	else --start bandaging
		if player:get_hp() > HEAL_MAX and not (knockout and knockout.downedplayers and knockout.downedplayers[playerName] == true) then
			if bandagerName == playerName then
				minetest.chat_send_player(bandagerName, "You are above max bandaging health.")
			else
				minetest.chat_send_player(bandagerName, playerName.." is above max bandaging health.")
			end
			return
		end
		bandagers[bandagerName] = {}
		bandagers[bandagerName].bandagerpos = bandager:get_pos()
		bandagers[bandagerName].playerpos = player:get_pos()
		bandagers[bandagerName].time = os.time()
		bandagers[bandagerName].index = bandager:get_wield_index()
		minetest.sound_play("bandagestart", {
			pos = bandagers[bandagerName].bandagerpos,
			max_hear_distance = 10,
			gain = 1.0,
			object = bandager
		})
		if bandagerName == playerName then
			minetest.chat_send_player(bandagerName, "You have started bandaging yourself, move to cancel.")
		else
			minetest.chat_send_player(bandagerName, "You have started bandaging "..playerName..", move to cancel.")
			minetest.chat_send_player(playerName, bandagerName.." has started bandaging you, move to cancel.")
		end
		minetest.after(1, bandage, bandager, player)
	end
end

minetest.register_craftitem('bandage:bandage', {
	description = ('Bandage'),
	inventory_image = 'bandage.png',
	range = 3,
	on_use = function(itemstack, user, pointed_thing)
		local obj = pointed_thing.ref
		if obj and pointed_thing.type == "object" then
			if obj:get_luaentity() and obj:get_luaentity().name == "knockout:entity" then
				obj = minetest.get_player_by_name(obj:get_luaentity().grabbed_name)
			end
		end
		if not obj or not obj:is_player() then
			obj = user
		end
		bandage(user, obj)
	end
})
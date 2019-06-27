knockout.downedplayers = minetest.deserialize(knockout.storage:get_string("downedplayers")) or {}

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    local hp = player:get_hp()
	local name = player:get_player_name()
	if hp > 0 and hp + hp_change <= 0 and not knockout.downedplayers[name] then
		--minetest.chat_send_all("you down")
		knockout.downedplayers[name] = true
		knockout.storage:set_string("downedplayers", minetest.serialize(knockout.downedplayers))
		knockout.knockout(name, 60)
		player:set_hp(10)
		return 0
	end
	return hp_change
end, true)
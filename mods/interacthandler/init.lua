interacthandler = {}
interacthandler.player = {}

local storage = minetest.get_mod_storage()
local oldplayers = minetest.deserialize(storage:get_string("player"))
--minetest.after(.1, function()
if oldplayers then
	for id, name in pairs(oldplayers) do
		--minetest.chat_send_all(tostring(id.." "..name))
		local privs = minetest.get_player_privs(name)
		privs.interact = true
		minetest.set_player_privs(name, privs)
	end
	oldplayers = nil
	storage:set_string("player", "")
end
--end)

interacthandler.revoke = function(name)
	local privs = minetest.get_player_privs(name)
	if not privs or (not interacthandler.player[name] and not privs.interact) then return end
	if not interacthandler.player[name] then
		interacthandler.player[name] = 0
	end
	interacthandler.player[name] = interacthandler.player[name] + 1
	--minetest.chat_send_all(tostring(interacthandler.player[name]))
	if interacthandler.player[name] > 0 then
		privs.interact = nil
		minetest.set_player_privs(name, privs)
	end
	storage:set_string("player", minetest.serialize(interacthandler.player))
end

interacthandler.grant = function(name, force)
	local privs = minetest.get_player_privs(name)
	if not privs or not interacthandler.player[name] then return end
	interacthandler.player[name] = interacthandler.player[name] - 1
	--minetest.chat_send_all(tostring(interacthandler.player[name]))
	if interacthandler.player[name] <= 0 or force then
		interacthandler.player[name] = nil
		privs.interact = true
		minetest.set_player_privs(name, privs)
	end
	if privs.interact then
		interacthandler.player[name] = nil
	end
	storage:set_string("player", minetest.serialize(interacthandler.player))
end

minetest.register_on_leaveplayer(function(player)
	interacthandler.grant(player:get_player_name(), true)
end)
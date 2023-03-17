local playerchannel = {}

local function get_radiousers(channel)
	local players = {}
	for player, chan in pairs(playerchannel) do
		if chan == channel then
			table.insert(players, player)
		end
	end
	return players
end

local function radio_message(channel, message)
	for id, player in pairs(get_radiousers(channel)) do
		minetest.chat_send_player(player, message)
	end
end

minetest.register_chatcommand("r", {
	params = "<text>",
	description = "Send text to send over radio.",
	privs = {shout = true},
	func = function(name, param)
		if not minetest.get_player_by_name(name) then return false, "You are not ingame" end
		if playerchannel[name] then
			voice.speak(minetest.get_player_by_name(name), param, voice.whisper_parameters)
			radio_message(playerchannel[name], "<"..name.."> ("..playerchannel[name].."): "..param)
		else
			return false, "You aren't in a radio channel!"
		end
	end
})

minetest.register_chatcommand("radio", {
	params = "<param>",
	description = "Usage: /radio join [channel], /radio who, /radio leave",
	privs = {shout = true},
	func = function(name, param)
		if not minetest.get_player_by_name(name) then return false, "You are not ingame" end
		local param2 = string.match(param, "^join ([%a%d_-]+)")
		if param == "" then
			if playerchannel[name] then
				voice.speak(minetest.get_player_by_name(name), param, voice.whisper_parameters)
				radio_message(playerchannel[name], "<"..name.."> ("..playerchannel[name].."): "..param)
			else
				return false, "See /help radio."
			end
		end
		if param == "leave" then
			if not playerchannel[name] then return false, "You aren't in a radio channel!" end
			radio_message(playerchannel[name], name.." has left "..playerchannel[name]..".")
			playerchannel[name] = nil
			return true
		end
		if param == "who" then
			if not playerchannel[name] then return false, "You aren't in a radio channel!" end
			local text = "Players in "..playerchannel[name]..":"
			for id, player in pairs(get_radiousers(playerchannel[name])) do
				text = text.." "..player
			end
			minetest.chat_send_player(name, text)
		end
		if param2 then
			if param2 == "" then return false, "You must enter the channel you wish to join." end
			playerchannel[name] = param2
			radio_message(playerchannel[name], name.." has joined "..param2.."!")
			return true
		end
	end
})
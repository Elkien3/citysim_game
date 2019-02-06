--
-- publisher
--
-- Add this mod to trusted_mods
-- Open : minetest.confg
-- Add : secure.http_mods = publisher

publisher ={}

local http_api = minetest.request_http_api and minetest.request_http_api()

if http_api then
	local feed_url = "http://127.0.0.1:8003/pub"
	local receive_interval = 30

	local function fetch_callback(result)
		if result.succeeded then
			return true, "Done"
		end
		minetest.log("error", "Couldn't connect to server!!!")
	end

	function publisher.pub_message(name, message)
		if (name ~= "minetest" and name ~= "irc") and not minetest.get_player_privs(name).shout or message:sub(1, 1) == "/" then
      return
    end
		local json_msg = minetest.write_json({type = "chat", player = name, message = message})
		http_api.fetch({url = feed_url, timeout = receive_interval, post_data = json_msg}, fetch_callback)
	end

	minetest.register_on_chat_message(publisher.pub_message)

  minetest.register_on_joinplayer(function(player)
    publisher.pub_message("minetest", "*** "..player:get_player_name().." joined the game")
  end)

  minetest.register_on_leaveplayer(function(player)
    publisher.pub_message("minetest", "*** "..player:get_player_name().." left the game")
  end)
end
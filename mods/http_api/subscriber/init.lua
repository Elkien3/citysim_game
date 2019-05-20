--
-- subscriber
--
-- Add this mod to trusted_mods
-- Open : minetest.confg
-- Add : secure.http_mods = subscriber

subscriber = {}
local SUPPORT_CMD = true	-- true - enable command support, false - disable

local http_api = minetest.request_http_api and minetest.request_http_api()

if http_api then
	local feed_url = "http://127.0.0.1:8003/sub?timeout=26&category=minetest"
	local receive_interval = 30

	local function pcall_function(data)
--		print(dump(data))
		if data.type == "chat" then
				minetest.chat_send_all( "<"..data.player.."@Disc> "..data.message)
				if minetest.get_modpath("irc") ~= nil then
					irc.say("<"..data.player.."@Disc> "..data.message)
				end
		end
		if data.type == "cmd" and SUPPORT_CMD then
			if data.command == "msg" then
				minetest.chat_send_player(data.player, core.colorize("#de6821", data.message))
			end
			--[[if data.command == "ban" then
				local result = minetest.ban_player(data.args[1]) --Ban a player
				if result then
					publisher.pub_message("minetest", "`Player {"..data.args[1].."} is Banned!`"..result)
				end
			end
			if data.command == "unban" then
				local result = minetest.unban_player_or_ip(data.args[1])
				if result then
					publisher.pub_message("minetest", "`Player {"..data.args[1].."} is UnBanned!`")
				end
			end
			if data.command == "kick" then
				local result = minetest.kick_player(data.args[1], data.message) --Disconnect a player with an optional reason
				if result then
					publisher.pub_message("minetest", "`Player {"..data.args[1].."} is Kicked by reson "..data.message.."`")
				end
			end
			if data.command == "setpassword" then
				local result = minetest.set_player_password(data.args[1], minetest.get_password_hash(data.args[1], data.message))
				if result then
					publisher.pub_message("minetest", "`Password for Player {"..data.args[1].."} changed`")
				end
			end
			if data.command == "grant" then
				local privs = minetest.get_player_privs(data.args[1])--]]
				--if privs[data.args[2]] then
					--privs[data.args[2]] = true
				--[[	minetest.set_player_privs(data.args[1], privs)
					publisher.pub_message("minetest", "`The {"..data.args[1].."} was given the {"..data.args[2].."}`")
				end
			end
			if data.command == "revoke" then
				local privs = minetest.get_player_privs(data.args[1])--]]
				--if privs[data.args[2]] then
					--privs[data.args[2]] = nil
					--[[minetest.set_player_privs(data.args[1], privs)
					publisher.pub_message("minetest", "`The {"..data.args[1].."} was taken away the {"..data.args[2].."}`")
				end
			end--]]
            if data.command == "privs" then
				publisher.pub_message("minetest", "`Privileges of {"..data.args[1].."}: {"..minetest.privs_to_string(minetest.get_player_privs(data.args[1]), ' ').."}`")
			end
			if data.command == "status" then
				publisher.pub_message("minetest", "`"..minetest.get_server_status().."`")
			end
		end
	end

	local function fetch_callback(result)
		if result.succeeded then
			subscriber.get_latest_msg()
			if result.data ~= "" then
					if string.find(result.data, "data") then
						pcall(pcall_function, minetest.parse_json(string.sub(result.data, string.find(result.data, "data")+6, -4)))
					elseif string.find(result.data, "timeout") then
						print("Timeout")
					end
					return
			end
			return
		end
--		minetest.log("error", "Couldn't connect to server!!!")
		minetest.after(receive_interval, subscriber.get_latest_msg)
	end

	function subscriber.get_latest_msg()
		http_api.fetch({url = feed_url, timeout = receive_interval}, fetch_callback)
	end

	minetest.after(3, subscriber.get_latest_msg)
end

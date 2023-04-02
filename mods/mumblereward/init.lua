local ip = minetest.settings:get("mumble_ip") or "!set mumble_ip!"
local channel = minetest.settings:get("mumble_channel") or 0
local port = minetest.settings:get("port") or "30000"
mumblereward_players = {}
local formtimer = {}

local mumbleonly = minetest.settings:get_bool("mumbleonly") or false

local mutetags = {}
minetest.register_entity("mumblereward:tag", {
	physical = false,
	collisionbox = {x=0, y=0, z=0},
	visual = "sprite",
	textures = {"nomumble.png"},
	visual_size = {x=.3, y=.3, z=.3},
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(.1, function()
			if not self.owner or not minetest.get_player_by_name(self.owner):is_player() then self.object:remove() end
		end)
	end,
})
local function addtag(name)
	if mutetags[name] then return end
	local player = minetest.get_player_by_name(name)
	if not player then return end
	local pos = player:get_pos()
	local ent = minetest.add_entity(pos, "mumblereward:tag")
	mutetags[name] = ent:get_luaentity()
	mutetags[name].owner = name
	mutetags[name].object:set_attach(player, "", {x=0,y=20,z=0}, {x=0,y=0,z=0})
end
local function removetag(name)
	if not mutetags[name] then return end
	mutetags[name].object:remove()
	mutetags[name] = nil
end
local function dotag()
	for _, player in pairs (minetest.get_connected_players()) do
		local name = player:get_player_name()
		if not mutetags[name] and not mumblereward_players[name] then
			addtag(name)
		end
	end
	for _, tag in pairs(mutetags) do
		if tag.owner and minetest.get_player_by_name(tag.owner):is_player() then
			tag.object:set_attach(minetest.get_player_by_name(tag.owner), "", {x=0,y=20,z=0}, {x=0,y=0,z=0})
		else
			tag.object:remove()
			tag = nil
		end
	end
end

local function checkfile()
	local input = io.open(minetest.get_worldpath().."/mumble.txt","r")
	if input then
	for line in input:lines() do
			local data = string.split(line, " ")
			local name = data[1]
			local context = data [2]
			local chan = data[3]
			local deaf = data[4] == "True"
			if minetest.get_player_by_name(name) then
				if context == "quit" then
					mumblereward_players[name] = nil
					minetest.chat_send_player(name, "*!Mumblerewards!* Disconnected from Positional Audio. Reason: You quit Mumble.")
				elseif context ~= "TWluZXRlc3QAMTM4LjE5Ny4yMi4xM" then
					mumblereward_players[name] = nil
					minetest.chat_send_player(name, "*!Mumblerewards!* Disconnected from Positional Audio. Reason: Incorrect Server/Context.")
				elseif chan ~= channel then
					mumblereward_players[name] = nil
					minetest.chat_send_player(name, "*!Mumblerewards!* Disconnected from Positional Audio. Reason: Not in the correct mumble channel.")
				elseif deaf then
					mumblereward_players[name] = nil
					minetest.chat_send_player(name, "*!Mumblerewards!* Disconnected from Positional Audio. Reason: You have deafened yourself.")
				elseif mumblereward_players[name] ~= true then
					mumblereward_players[name] = true
					minetest.chat_send_player(name, "*!Mumblerewards!* Connected with Positional Audio!")
					removetag(name)
				end
			end
		end
		io.close(input)
	end
	local output = io.open(minetest.get_worldpath().."/mumble.txt","w")
	output:write("")
	io.close(output)
	dotag()
	minetest.after(1, checkfile)
end
minetest.after(1, checkfile)

local newline = "                                                                                                     "
local function mumbleform(name)

    local form = "" ..
    "size[8,8]" ..
    "image[0.7,0.5;8.2,4.8333333333333;mumbleimage.png]" ..
    "textarea[1,5;5,3;TextArea;;Set up Mumble Positional Audio with Minetest and be able to hear other players (you don't necessarily have to talk), have no mute symbol, and other possible future perks!"..newline.."|"..newline.."Demo vid by Minetest Videos: https://youtu.be/6AsHD9h8IE8 |"..newline.."Tutorial: https://youtu.be/lP7zEydOIEI |"..newline.."Github: https://github.com/Elkien3/minetest-mumble-wrapper |       Mumble: https://www.mumble.com/mumble-download.php |         Discord: https://discord.gg/nG8ZgF9 |"..newline.."|"..newline.."Type in /mumble to view this page again, and /mumble playername to see if a certain player is connected.]" ..
    "button_exit[6,7;1.5,0.5;Close;Close \\[   \\]]" ..
    "label[6.83,7;"..minetest.formspec_escape(tostring(formtimer[name])).."]" ..
    ""

    return form
end

local function countdown(name)
	if mumblereward_players[name] then formtimer[name] = 0 end
	formtimer[name] = formtimer[name] - 1
	minetest.show_formspec(name, "mumbleformspec", mumbleform(name))
	minetest.after(1, countdown, name)
end

local function checkplayer(name, kick)
	if not name then return end
	if not mumblereward_players[name] then
		minetest.chat_send_player(name, "*!Mumblerewards!* Not connected to Positional Audio.")
		if mumbleonly then
			local val, timetil, length = is_mumbleonly()
			local kickmsg = "Server is in a mumble-only period, set up minetest with mumble PA or come back later."
			local warnmsg = "*!Mumblerewards!* The server is in a mumble-only period currently, you will be kicked in 30 seconds."
			if timetil ~= nil and length ~= nil then
				kickmsg = "Server is in a mumble-only period, set up minetest with mumble PA or come back in ".. -timetil .." minutes."
				warnmsg = "*!Mumblerewards!* The server is in a mumble-only period for "..-timetil.." more minutes, you will be kicked in 30 seconds."
			end
			if kick then
				minetest.kick_player(name, kickmsg)
			elseif val then
				minetest.chat_send_player(name, warnmsg)
				minetest.after(30, checkplayer, name, true)
			end
		end
		--formtimer[name] = 0
		--minetest.after(1, countdown, name)
		minetest.show_formspec(name, "mumbleformspec", mumbleform(name))
	end
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	addtag(name)
	local privs = minetest.get_player_privs(name)
	if (privs.interact or (mumbleonly and is_mumbleonly())) and not privs.ban then
		minetest.after(30, checkplayer, name)
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	removetag(name)
	mumblereward_players[name] = nil
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mumbleformspec" then
		local name = player:get_player_name()
		if not formtimer[name] then formtimer[name] = 0 end
		if fields.quit and formtimer[name] > 0 then
			minetest.show_formspec(name, "mumbleformspec", mumbleform(name))
		else
			formtimer[name] = nil
		end
	end
end)
minetest.register_chatcommand("mumble", {func = function(name, param)
	if param ~= "" then
		if mumblereward_players[param] then
			return true, param.." is connected with mumble Positional Audio!"
		else
			return true, param.." is not connected with mumble Positional Audio."
		end
	else
		formtimer[name] = 0
		minetest.show_formspec(name, "mumbleformspec", mumbleform(name))
		return true, "Opened Mumble Info!"
	end
end})

if mumbleonly then
	local path = minetest.get_modpath(minetest.get_current_modname())
	dofile(path .. "/mumbleonly.lua")
end

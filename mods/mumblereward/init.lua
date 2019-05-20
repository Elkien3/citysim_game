local ip = minetest.settings:get("mumble_ip") or "!set mumble_ip!"
local channel = minetest.settings:get("mumble_channel") or 0
local port = minetest.settings:get("port") or "30000"
mumblereward_players = {}
local formtimer = {}

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
	local tag = mutetags[name]
	if tag then return end
	local player = minetest.get_player_by_name(name)
	if not player then return end
	local pos = player:get_pos()
	local ent = minetest.add_entity(pos, "mumblereward:tag")
	tag = ent:get_luaentity()
	tag.owner = name
	tag.object:set_attach(player, "", {x=0,y=12,z=0}, {x=0,y=0,z=0})
end
local function removetag(name)
	local tag = mutetags[name]
	if not tag then return end
	tag.object:remove()
	tag = nil
end
local function dotag()
	for _, player in pairs (minetest.get_connected_players()) do
		local name = player:get_player_name()
		if not mutetags[name] and not mumblereward_players[name] then
			addtag(name)
		end
	end
	for _, tag in pairs(mutetags) do
		if tag.owner then
			tag.object:set_attach(minetest.get_player_by_name(tag.owner), "", {x=0,y=12,z=0}, {x=0,y=0,z=0})
		else
			tag.object:remove()
			tag = nil
		end
	end
end

local function checkfile()
	dotag()
	local input = io.open(minetest.get_worldpath().."/mumble.txt","r")
	if input then
	for line in input:lines() do
			local data = string.split(line, " ")
			local name = data[1]
			local game = data [2]
			local ipport = data[3]
			local chan = data[4]
			local deaf = data[5] == "True"
			if minetest.get_player_by_name(name) then
				if game ~= "Minetest" then
					mumblereward_players[name] = nil
					if game == "quit" then
						minetest.chat_send_player(name, "*!Mumblerewards!* Disconnected from Positional Audio. Reason: You quit Mumble.")
					else
						minetest.chat_send_player(name, "*!Mumblerewards!* Disconnected from Positional Audio. Reason: You are not in Minetest.")
					end
				elseif ipport ~= ip..":"..port then
					mumblereward_players[name] = nil
					minetest.chat_send_player(name, "*!Mumblerewards!* Disconnected from Positional Audio. Reason: incorrect context: '"..ipport.."' Double check that you're using minetest-mumble-wrapper, the CSM is enabled, and Mumble PA is enabled.")
				elseif chan ~= channel then
					mumblereward_players[name] = nil
					minetest.chat_send_player(name, "*!Mumblerewards!* Disconnected from Positional Audio. Reason: Not in the correct mumble channel.")
				elseif deaf then
					mumblereward_players[name] = nil
					minetest.chat_send_player(name, "*!Mumblerewards!* Disconnected from Positional Audio. Reason: You have deafened yourself.")
				else
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
	minetest.after(5, checkfile)
end
minetest.after(5, checkfile)

local newline = "                                                                                                     "
local function mumbleform(name)

    local form = "" ..
    "size[8,8]" ..
    "image[0.7,0.5;8.2,4.8333333333333;mumbleimage.png]" ..
    "textarea[1,5;5,3;TextArea;;Set up Mumble Positional Audio with Minetest and be able to hear other players (you don't necessarily have to talk), get a blue nametag, and get FREE minegelds!"..newline.."|"..newline.."Demo vid by Minetest Videos: https://youtu.be/6AsHD9h8IE8 |"..newline.."Tutorial: https://youtu.be/0rk-004yLyk |"..newline.."Github: https://github.com/chipgw/minetest-mumble-wrapper |       Mumble: https://www.mumble.com/mumble-download.php |"..newline.."|"..newline.."Type in /mumble to view this page again, and /mumble playername to see if a certain player is connected.]" ..
    "button_exit[6,7;1.5,0.5;Close;Close \\[   \\]]" ..
    "label[6.83,7;"..minetest.formspec_escape(tostring(formtimer[name])).."]" ..
    ""

    return form
end

local function countdown(name)
	if formtimer[name] == nil or formtimer[name] == 0 then return end
	formtimer[name] = formtimer[name] - 1
	minetest.show_formspec(name, "mumbleformspec", mumbleform(name))
	minetest.after(1, countdown, name)
end

local function checkplayer(name)
	if not name then return end
	if not mumblereward_players[name] then
		--minetest.chat_send_player(name, "*!Mumblerewards!* Not connected to Positional Audio.")
		formtimer[name] = 5
		minetest.after(1, countdown, name)
		minetest.show_formspec(name, "mumbleformspec", mumbleform(name))
	end
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	addtag(name)
	local privs = minetest.get_player_privs(name)
	if privs.interact and not privs.ban then
		minetest.after(25, checkplayer, name)
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
			return true, param.." is not connected with mumble Positional Audio!"
		end
	else
		formtimer[name] = 0
		minetest.show_formspec(name, "mumbleformspec", mumbleform(name))
		return true, "Opened Mumble Info!"
	end
end})
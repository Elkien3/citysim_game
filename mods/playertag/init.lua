local nametags = {}
local blueboi = {} --to only remove change the white tag to blue for mumble players once

local function add_tag(player)
	local pos = player:get_pos()
	local ent = minetest.add_entity(pos, "playertag:tag")
	local name = player:get_player_name()
	local color = "W"
	if minetest.get_modpath("mumblereward") ~= nil then
		if mumblereward_players[name] then color = "B" end
	end
	local texture = "npcf_tag_bg.png"
	local x = math.floor(134 - ((name:len() * 11) / 2))
	local i = 0
	name:gsub(".", function(char)
		if char:byte() > 64 and char:byte() < 91 then
			char = "U"..char
		end
		texture = texture.."^[combine:84x14:"..(x+i)..",0="..color.."_"..char..".png"
		i = i + 11
	end)
	ent:set_properties({ textures={texture} })

	if ent ~= nil then
		 ent:set_attach(player, "", {x=0,y=18,z=0}, {x=0,y=0,z=0})
		 nametags[name] = ent
		 ent = ent:get_luaentity()
		 ent.wielder = player
	end
	--minetest.chat_send_all("tag made for "..player:get_player_name())
end

local function remove_tag(player)
	local tag = nametags[player:get_player_name()]
	if tag then
		tag:remove()
		tag = nil
	end
end

local nametag = {
	npcf_id = "nametag",
	physical = false,
	collisionbox = {x=0, y=0, z=0},
	visual = "sprite",
	textures = {"default_dirt.png"},--{"npcf_tag_bg.png"},
	visual_size = {x=2.16, y=0.18, z=2.16},--{x=1.44, y=0.12, z=1.44},
	on_activate = function(self, staticdata, dtime_s)
		if staticdata == "expired" then
			if self.wielder then
				remove_tag(wielder)
			else
				self.object:remove()
			end
		end
	end,
	get_staticdata = function(self)
		return "expired"
	end,
}

function nametag:on_step(dtime)
	local wielder = self.wielder
	if wielder == nil then
		self.object:remove()
	elseif minetest.get_player_by_name(wielder:get_player_name()) == nil then
		self.object:remove()
	else
		--self.object:set_attach(wielder, "", {x=0,y=18,z=0}, {x=0,y=0,z=0})
	end
end

minetest.register_entity("playertag:tag", nametag)

local function step()
	for _, player in pairs(minetest.get_connected_players()) do
		if minetest.get_modpath("mumblereward") ~= nil then
			if mumblereward_players[player:get_player_name()] and not blueboi[player:get_player_name()] then
				blueboi[player:get_player_name()] = true
				remove_tag(player)
				add_tag(player)
			end
		end
		if nametags[player:get_player_name()]:get_luaentity() == nil then
			add_tag(player)
			--minetest.chat_send_all("tag made for "..player:get_player_name())
		else
			nametags[player:get_player_name()]:set_attach(player, "", {x=0,y=18,z=0}, {x=0,y=0,z=0})
		end
	end

	minetest.after(10, step)
end
minetest.after(10, step)

minetest.register_globalstep(function(player)
	for _, player in pairs(minetest.get_connected_players()) do
		player:set_nametag_attributes({
			color = {a = 0, r = 0, g = 0, b = 0}
		})
	end
end)

minetest.register_on_joinplayer(function(player)
	if not player.tag then
		player:set_nametag_attributes({
			color = {a = 0, r = 0, g = 0, b = 0}
		})
	end
	add_tag(player)
end)

minetest.register_on_leaveplayer(function (player)
	remove_tag(player)
	blueboi[player:get_player_name()] = nil
end)

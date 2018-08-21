local nametags = {}

local function add_tag(player)
	local pos = player:get_pos()
	local ent = minetest.add_entity(pos, "playertag:tag")

	local color = "W"
	local texture = "npcf_tag_bg.png"
	local x = math.floor(134 - ((player:get_player_name():len() * 11) / 2))
	local i = 0
	player:get_player_name():gsub(".", function(char)
		if char:byte() > 64 and char:byte() < 91 then
			char = "U"..char
		end
		texture = texture.."^[combine:84x14:"..(x+i)..",0="..color.."_"..char..".png"
		i = i + 11
	end)
	ent:set_properties({ textures={texture} })

	if ent ~= nil then
		 ent:set_attach(player, "", {x=0,y=9,z=0}, {x=0,y=0,z=0})
		 nametags[player:get_player_name()] = ent
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
		--self.object:set_attach(wielder, "", {x=0,y=9,z=0}, {x=0,y=0,z=0})
	end
end

minetest.register_entity("playertag:tag", nametag)

local function step()
	for _, player in pairs(minetest.get_connected_players()) do
		if nametags[player:get_player_name()]:get_luaentity() == nil then
			add_tag(player)
			--minetest.chat_send_all("tag made for "..player:get_player_name())
		else
			nametags[player:get_player_name()]:set_attach(player, "", {x=0,y=9,z=0}, {x=0,y=0,z=0})
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
end)

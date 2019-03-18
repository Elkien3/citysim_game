local mod_storage = minetest.get_mod_storage()
local defaultskin = {haircolor = "513C24", hairtype = "1", facecolor = "513C24", facetype = "1", eyecolor = "513C24", eyetype = "3", skintype = "0", skincolor = "e6b27e"}
local modpath = minetest.get_modpath(minetest.get_current_modname())

local function number_of_textures(type)
local number = 0
	while true do
		if io.open(minetest.get_modpath("charactercreation").."/textures/"..type..tostring(number+1)..".png", "r") then
			number = number + 1
		else
			return number
		end
	end
end
function charactercreation_getskin(name)
	if not name then return defaultskin end
	local sd = minetest.deserialize(mod_storage:get_string(name))
	if not sd or sd == "" then sd = defaultskin end
	return sd
end

local eye_num = number_of_textures("eye")
local hair_num = number_of_textures("hair")
local face_num = number_of_textures("face")
local skin_num = number_of_textures("skin")

--[[
Adds the following Functions:
rgbToHsl(r, g, b, a) 	(EmmanuelOga)
hslToRgb(h, s, l, a)	(EmmanuelOga)
rgbToHex(rgb) 			(marceloCodget)
hexToRgb(hex) 			(?)
See colortools.lua for more details
]]--
dofile(modpath.."/colortools.lua")

local function doskinny(player, skindata)
	local name = player:get_player_name()
	local sd = skindata
	if not sd then sd = minetest.deserialize(mod_storage:get_string(name)) end
	if not sd or sd == "" then sd = defaultskin end
	local skin = "(skin"..sd.skintype..".png^[multiply:#"..sd.skincolor..")"
	local eyes = "(eye"..sd.eyetype..".png)^(eye"..sd.eyetype.."color.png^[multiply:#"..sd.eyecolor..")"
	local face = "(face"..sd.facetype..".png^[multiply:#"..sd.facecolor..")"
	local hair = "(hair"..sd.hairtype..".png^[multiply:#"..sd.haircolor..")"
	mod_storage:set_string(name, minetest.serialize(sd))
	if minetest.get_modpath("3d_armor") then
		local skinclothes = armor:get_player_skin(name)
		armor.textures[name].skin = skinclothes
		armor:set_player_armor(player)
	else
		player:set_properties({
			textures = { skin.."^"..eyes.."^"..face.."^"..hair }
		})
	end
end

minetest.register_on_joinplayer(function(player)
	minetest.after(0, doskinny, player)
end)

local function make_HSL_formspec(name, item, itemcolor, itemtype)
	local rgbval = hexToRgb(itemcolor)
	local hslval = rgbToHsl(rgbval)
	local h = "500"
	local s = "500"
	local l = "500"
	if hslval then
		--minetest.chat_send_all(dump(hslval))
		h = hslval.h
		s = hslval.s
		l = hslval.l
	end
	if not name then local name = "Untitled" end
	local formspec = "size[12,10]"
		.."label[5.5,0;"..name.."]"
		.."image[3,1;8,4;empty.png]"
		.."image[3,1;8,4;("..item..itemtype..".png^[multiply:#"..itemcolor..")]"
		.."button[11,3;1,1;next;>]"
		.."button[0,3;1,1;prev;<]"
		.."button[5,6;.5,1;prevtype;<]"
		.."button[10,6;1,1;apply;Apply]"
		.."button_exit[11,6;1,1;exit;Exit]"
		.."button[5.5,6;1,1;type;"..item..itemtype.."]"
		.."button[6.5,6;.5,1;nexttype;>]"
		.."label[5.5,7;Hue]"
		.."scrollbar[1,7.5;10,.5;horizontal;huebar;"..(tonumber(h)*1000).."]"
		.."label[5.5,8;Saturation]"
		.."scrollbar[1,8.5;10,.5;horizontal;satbar;"..(tonumber(s)*1000).."]"
		.."label[5.5,9;Value]"
		.."scrollbar[1,9.5;10,.5;horizontal;valbar;"..(tonumber(l)*1000).."]"
	return formspec
end

local previewcolor = {}
local hudpreview = {}

local function do_HSL_formspec(player, name, fields)
	if fields.apply then
		if previewcolor[name] and previewcolor[name] ~= "" then
			return previewcolor[name]
		end
	end
	if fields.quit then
		if hudpreview[name] then
			player:hud_remove(hudpreview[name])
			hudpreview[name] = nil
		end
	end
	local hue = 0
	local sat = 0
	local val = 0
	local docolor = false
	for k, v in pairs(fields) do
		local scroll_event = minetest.explode_scrollbar_event(v)
		if k == "huebar" then
			hue = ((minetest.explode_scrollbar_event(v).value)/1000)
			if scroll_event.type == "CHG" then docolor = true end
		end
		if k == "satbar" then
			sat = ((minetest.explode_scrollbar_event(v).value)/1000)
			if scroll_event.type == "CHG" then docolor = true end
		end
		if k == "valbar" then
			val = ((minetest.explode_scrollbar_event(v).value)/1000)
			if scroll_event.type == "CHG" then docolor = true end
		end
	end
	if docolor then
		previewcolor[name] = ""
		previewcolor[name] = rgbToHex(hslToRgb(hue, sat, val))
		if hudpreview[name] then
			player:hud_change(hudpreview[name], number, "0x"..previewcolor[name])
		else
			hudpreview[name] = player:hud_add({
				hud_elem_type = "text",
				scale = {x=-100, y=-100},
				text = "███████████",
				number = "0x"..previewcolor[name],
				position = { x = .5, y = 1 },
				offset = {x=0, y=-80},
				alignment = { x = 0, y = 0 },
			})
		end
	end
	return ""
end
local function formspec_hair(name) local skindata = minetest.deserialize(mod_storage:get_string(name)) minetest.show_formspec(name,"charcreate:hair",make_HSL_formspec("Hair", "hair", skindata.haircolor, skindata.hairtype)) end
local function formspec_face(name) local skindata = minetest.deserialize(mod_storage:get_string(name)) minetest.show_formspec(name,"charcreate:face",make_HSL_formspec("Face", "face", skindata.facecolor, skindata.facetype)) end
local function formspec_skin(name) local skindata = minetest.deserialize(mod_storage:get_string(name)) minetest.show_formspec(name,"charcreate:skin",make_HSL_formspec("Skin", "skin", skindata.skincolor, skindata.skintype)) end
local function formspec_eye(name) local skindata = minetest.deserialize(mod_storage:get_string(name)) minetest.show_formspec(name,"charcreate:eye",make_HSL_formspec("Eyes", "eye", skindata.eyecolor, skindata.eyetype)) end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	local skindata = minetest.deserialize(mod_storage:get_string(name))
    if formname == "charcreate:hair" then
		local input = do_HSL_formspec(player, name, fields)
		if fields.prev then
			formspec_eye(name)
			return
		end
		if fields.next then
			formspec_face(name)
			return
		end
		if fields.prevtype then
			if skindata.hairtype == 0 then
				skindata.hairtype = hair_num
			else
				skindata.hairtype = tonumber(skindata.hairtype)-1
			end
			doskinny(player, skindata)
			formspec_hair(name)
			return
		end
		if fields.nexttype then
			if skindata.hairtype == hair_num then
				skindata.hairtype = 0
			else
				skindata.hairtype = tonumber(skindata.hairtype)+1
			end
			doskinny(player, skindata)
			formspec_hair(name)
			return
		end
		if fields.apply then
			if input and input ~= "" then
				skindata.haircolor = input
				previewcolor[name] = nil
				doskinny(player, skindata)
				formspec_hair(name)
			end
		end
    end
	if formname == "charcreate:face" then
		local input = do_HSL_formspec(player, name, fields)
		if fields.prev then
			formspec_hair(name)
			return
		end
		if fields.next then
			formspec_skin(name)
			return
		end
		if fields.prevtype then
			if skindata.facetype == 0 then
				skindata.facetype = face_num
			else
				skindata.facetype = tonumber(skindata.facetype)-1
			end
			doskinny(player, skindata)
			formspec_face(name)
			return
		end
		if fields.nexttype then
			if skindata.facetype == face_num then
				skindata.facetype = 0
			else
				skindata.facetype = tonumber(skindata.facetype)+1
			end
			doskinny(player, skindata)
			formspec_face(name)
			return
		end
		if fields.apply then
			if input and input ~= "" then
				skindata.facecolor = input
				previewcolor[name] = nil
				doskinny(player, skindata)
				formspec_face(name)
			end
		end
    end
	if formname == "charcreate:skin" then
		local input = do_HSL_formspec(player, name, fields)
		if fields.prev then
			formspec_face(name)
			return
		end
		if fields.next then
			formspec_eye(name)
			return
		end
		if fields.prevtype then
			if skindata.skintype == 0 then
				skindata.skintype = skin_num
			else
				skindata.skintype = tonumber(skindata.skintype)-1
			end
			doskinny(player, skindata)
			formspec_skin(name)
			return
		end
		if fields.nexttype then
			if skindata.skintype == skin_num then
				skindata.skintype = 0
			else
				skindata.skintype = tonumber(skindata.skintype)+1
			end
			doskinny(player, skindata)
			formspec_skin(name)
			return
		end
		if fields.apply then
			if input and input ~= "" then
				skindata.skincolor = input
				previewcolor[name] = nil
				doskinny(player, skindata)
				formspec_skin(name)
			end
		end
    end
	if formname == "charcreate:eye" then
		local input = do_HSL_formspec(player, name, fields)
		if fields.prev then
			formspec_skin(name)
			return
		end
		if fields.next then
			formspec_hair(name)
			return
		end
		if fields.prevtype then
			if skindata.eyetype == 0 then
				skindata.eyetype = eye_num
			else
				skindata.eyetype = tonumber(skindata.eyetype)-1
			end
			doskinny(player, skindata)
			formspec_eye(name)
			return
		end
		if fields.nexttype then
			if skindata.eyetype == eye_num then
				skindata.eyetype = 0
			else
				skindata.eyetype = tonumber(skindata.eyetype)+1
			end
			doskinny(player, skindata)
			formspec_eye(name)
			return
		end
		if fields.apply then
			if input and input ~= "" then
				skindata.eyecolor = input
				previewcolor[name] = nil
				doskinny(player, skindata)
				formspec_eye(name)
			end
		end
    end
end)


minetest.register_chatcommand("skinny",{
	params = "<article>",
	description="Shows the character creation menu",
	func = function (name,params)
		local player = minetest.get_player_by_name(name)
		local skindata = minetest.deserialize(mod_storage:get_string(name))
		minetest.show_formspec(name,"charcreate:hair",make_HSL_formspec("Hair", "hair", skindata.haircolor, skindata.hairtype))	
	end,
})
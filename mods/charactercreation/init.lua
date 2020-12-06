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
local function clamp(val, lower, upper)
    assert(val and lower and upper, "not very useful error message here")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end
function charactercreation_getskin(name)
	if not name then return defaultskin end
	local sd = minetest.deserialize(mod_storage:get_string(name))
	if not sd or sd == "" then sd = defaultskin end
	return sd
end

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
	local h = sd.height or 100
	local w = sd.width or 100
	player:set_properties({visual_size = {x = w/100, y = h/100}})
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

local formspecplayer = {}

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
		.."button[1,6;2,1;default;Default Color]"
		.."button[10,6;1,1;apply;Apply]"
		.."button[9,6;1,1;revert;Revert]"
		.."button_exit[11,6;1,1;exit;Exit]"
		.."button[5.5,6;1,1;type;"..item..itemtype.."]"
		.."button[6.5,6;.5,1;nexttype;>]"
		.."label[5.5,7;Hue]"
		.."scrollbar[1,7.5;10,.5;horizontal;huebar;"..(tonumber(h)*1000).."]"
		.."label[5.5,8;Saturation]"
		.."scrollbar[1,8.5;10,.5;horizontal;satbar;"..(tonumber(s)*1000).."]"
		.."label[5.5,9;Value]"
		.."scrollbar[1,9.5;10,.5;horizontal;valbar;"..(tonumber(l)*1000).."]"
		if formspecplayer[name] then
			formspecplayer[name] = nil
			formspec = formspec.." "
		else
			formspecplayer[name] = true
		end
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
	if fields.quit or fields.revert or fields.default then
		if hudpreview[name] then
			player:hud_remove(hudpreview[name])
			hudpreview[name] = nil
			previewcolor[name] = nil
			if fields.quit then formspecplayer[name] = nil end
			return
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

local pagelist = {}
local pagepointer = {}
pagelist["hair"] = {"Hair", 1} pagepointer[1] = "hair"
pagelist["face"] = {"Face", 2} pagepointer[2] = "face"
pagelist["skin"] = {"Skin", 3} pagepointer[3] = "skin"
pagelist["eye"] = {"Eyes", 4} pagepointer[4] = "eye"
local pagenum = 4

local charformspec = {}
local num = {}
for index, page in pairs(pagelist) do
	charformspec[index] = function(name) local skindata = minetest.deserialize(mod_storage:get_string(name)) minetest.show_formspec(name,"charcreate:"..index,make_HSL_formspec(page[1], index, skindata[index.."color"], skindata[index.."type"])) end
	num[index] = number_of_textures(index)
end

local function rn(number, back) --change number from 0-1000 range to 90 to 105 range or vice virsa
	if back then
		return clamp((number-95)*66.666, 0, 1000)
	else
		return clamp(number*.015+95, 90, 105)
	end
end

pagelist["body"] = {"Body", 5} pagepointer[5] = "body"
pagenum = 5
charformspec["body"] = function(name)
	local skindata = minetest.deserialize(mod_storage:get_string(name))
	local h = skindata["height"] or 100
	local w = skindata["width"] or 100
	local fac = 10
	local form = "size[12,10]"
		.."label[5.5,0;Body]"
		.."image["..tostring(4.5-((w-100)/fac)/2)..","..tostring(1-((h-100)/fac)/2)..";"..tostring(3+(w-100)/fac)..","..tostring(6+(h-100)/fac)..";character_preview.png]"
		.."button[11,3;1,1;next;>]"
		.."button[0,3;1,1;prev;<]"
		.."button[10,6;1,1;setheight;Apply]"
		.."button[1,6;2,1;defaultsize;Default Size]"
		--.."scrollbaroptions[min=90;max=105;smallstep=1]"
		.."label[5.5,6.5;Height]"
		.."scrollbar[1,7.5;10,.5;horizontal;heightbar;"..(rn(h, true)).."]"
		.."label[5.5,8.5;Width]"
		.."scrollbar[1,9;10,.5;horizontal;widthbar;"..(rn(w, true)).."]"
		.."button_exit[11,6;1,1;exit;Exit]"
	minetest.show_formspec(name,"charcreate:body", form)
	
	
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	local skindata = minetest.deserialize(mod_storage:get_string(name))
	local input = do_HSL_formspec(player, name, fields)
	local pagename = string.gsub(formname, "charcreate:", "")
	local page = pagelist[pagename]
	if not page then
		return
	end
	if fields.prev then
		local i = page[2]-1
		if i <= 0 then i = pagenum end
		charformspec[pagepointer[i]](name)
		return
	end
	if fields.next then
		local i = page[2]+1
		if i > pagenum then i = 1 end
		charformspec[pagepointer[i]](name)
		return
	end
	if fields.prevtype then
		if skindata[pagename.."type"] == 0 then
			skindata[pagename.."type"] = num[pagename]
		else
			skindata[pagename.."type"] = tonumber(skindata[pagename.."type"])-1
		end
		doskinny(player, skindata)
		charformspec[pagename](name)
		return
	end
	if fields.nexttype then
		if skindata[pagename.."type"] == num[pagename] then
			skindata[pagename.."type"] = 0
		else
			skindata[pagename.."type"] = tonumber(skindata[pagename.."type"])+1
		end
		doskinny(player, skindata)
		charformspec[pagename](name)
		return
	end
	if fields.revert then
		charformspec[pagename](name)
		return
	end
	if fields.apply then
		if input and input ~= "" then
			skindata[pagename.."color"] = input
			previewcolor[name] = nil
			doskinny(player, skindata)
			charformspec[pagename](name)
		end
	end
	if fields.default then
		skindata[pagename.."color"] = defaultskin[pagename.."color"]
		previewcolor[name] = nil
		doskinny(player, skindata)
		charformspec[pagename](name)
    end
	if fields.setheight or fields.defaultsize then
		local h = 100
		local w = 100
		if not fields.defaultsize then
			h = rn(minetest.explode_scrollbar_event(fields.heightbar).value)
			w = rn(minetest.explode_scrollbar_event(fields.widthbar).value)
		end
		if h == 100 and w == 100 then
			h = nil
			w = nil
		end
		skindata["height"] = h
		skindata["width"] = w
		doskinny(player, skindata)
		charformspec[pagename](name)
	end
end)


minetest.register_chatcommand("skinny",{
	params = "<article>",
	description="Shows the character creation menu",
	func = function (name,params)
		local player = minetest.get_player_by_name(name)
		local skindata = minetest.deserialize(mod_storage:get_string(name))
		charformspec["hair"](name)
	end,
})
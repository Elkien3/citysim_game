cars = {}
local go = false
local storage = minetest.get_mod_storage()
local DEBUG_WAYPOINT = false
local DEBUG_TEXT = false
local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
end
local function rnd(number, decimal)
	if not decimal then decimal = 1 end
	return math.floor(number*decimal+.5)/decimal
end
local player_attached = {}
local drilledblocks = {}

local attachTimer = 0
local animateTimer = 0
local drilltimer = 0
minetest.register_globalstep(function(dtime)
	attachTimer = attachTimer + dtime
	animateTimer = animateTimer + dtime
	drilltimer = drilltimer + dtime
	if attachTimer >= 5 then
		minetest.after(0, function() attachTimer = 0 end)
	end
	if animateTimer >= .08 then
		minetest.after(0, function() animateTimer = 0 end)
	end
	if drilltimer >= 1 then
		drilltimer = 0
		for posstring, tbl in pairs(drilledblocks) do
			if tbl.last+300 <= os.time() then
				drilledblocks[posstring] = nil
			end
		end
	end
end)

local skel_key = "default:skeleton_key"
local made_key = "keys:key"

if not minetest.get_modpath("keys") then
	skel_key = "default:skeleton_key"
	made_key = "default:key"
end

local keydef = minetest.registered_items[skel_key]
local orig_func = keydef.on_use
local new_func = function(itemstack, user, pointed_thing)
	if pointed_thing.type == "object" then
		local obj = pointed_thing.ref
		obj:punch(user, nil, {damage_groups={fleshy=0}})
		return itemstack
	end
	return orig_func(itemstack, user, pointed_thing)
end
minetest.override_item(skel_key, {on_use = new_func})

function cars.get_database()
	return minetest.deserialize(storage:get_string("database")) or {}
end
function cars.set_database_entry(licenseplate, tbl)
	if licenseplate == nil then return end
	local db = cars.get_database()
	db[licenseplate] = tbl
	storage:set_string("database", minetest.serialize(db))
end

function cars.setlighttexture(obj, table, prefix)
	if not obj or not table then return end
	local texture = "invisible.png"
	for index, val in pairs(table) do
		if val then
			texture = texture.."^"..prefix..index..".png"
		end
	end
	local prop = obj:get_properties()
	prop.textures[1] = texture
	obj:set_properties(prop)
	return texture
end

function cars.setlight(obj, light, val)
	if not obj then return end
	if obj[light] == val then return end
	if val == "toggle" then val = not obj[light] end
	if string.find(light, "blinker") then
		obj.leftblinker = false
		obj.rightblinker = false
	end
	if light == "headlights" or string.find(light, "blinker") then
		minetest.sound_play("lighton", {
			max_hear_distance = 6,
			gain = 1,
			object = obj.object
		}, true)
	end
	if beamlight and light == "headlights" then
		if val then
				beamlight.beams[string.sub(tostring(obj), 8)] = {object = obj.object:get_attach(), x = 3, length = 3}
		else
				beamlight.beams[string.sub(tostring(obj), 8)] = nil
		end
	end
	obj[light] = val
	obj.update = true
end

local function detach(player)
	if not player then return end
	local name = player:get_player_name()
	if not name then return end
	
	local attached = player_attached[name]
	if not attached then return end
	player_attached[name] = nil
	local i = 0
	while i <= #attached.passengers do
		i = i + 1
		if attached.passengers[i].player == player then
			attached.passengers[i].player = nil
			if i == 1 then player:hud_remove(attached.hud) end
			break
		end
	end
	player:set_detach()
	player:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
	default.player_attached[name] = false
	default.player_set_animation(player, "stand" , 30)
	local yaw = attached.object:get_yaw()
	local def = cars_registered_cars[attached.name]
	local pos = attached.object:get_pos()
	local pos2 = vector.add(pos, vector.multiply(vector.rotate(attached.passengers[i].loc, {x=0,y=yaw,z=0}), .1))
	pos.y = pos.y + .25
	pos2.y = pos.y
	if i and not minetest.line_of_sight(pos, pos2) then
		player:set_pos(pos)
	end
end

local function get_yaw(yaw)
	return math.atan2(math.sin(yaw), math.cos(yaw))
end

local function get_deg(yaw)
	yaw =  yaw % 360
	yaw = (yaw + 360) % 360
	if (yaw > 180) then
		yaw = yaw - 360
	end
	return yaw
end

local function get_velocity(v, yaw, velocity)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x = x, y = velocity.y, z = z}
end

local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

local function serializeContents(contents)
   if not contents then return "" end

   local tabs = {}
   for i, stack in ipairs(contents) do
      tabs[i] = stack and stack:to_table() or ""
   end

   return minetest.serialize(tabs)
end

local function deserializeContents(data)
   if not data or data == "" then return nil end
   local tabs = minetest.deserialize(data)
   if not tabs or type(tabs) ~= "table" then return nil end

   local contents = {}
   for i, tab in ipairs(tabs) do
      contents[i] = ItemStack(tab)
   end

   return contents
end

local charset = {}  do -- [A-Z]
    for c = 65, 90 do table.insert(charset, string.char(c)) end
end
local numset = {}  do -- [0-9]
    for c = 48, 57  do table.insert(numset, string.char(c)) end
end

local function randomString(length)
	local text = ""
	local i = 0
    if not length or length <= 0 then return text end
	while i < length do
		text = text..charset[math.random(1, #charset)]
		i = i + 1
	end
	return text
end

local function randomNumber(length)
	local text = ""
	local i = 0
    if not length or length <= 0 then return text end
	while i < length do
		text = text..numset[math.random(1, #numset)]
		i = i + 1
	end
	return text
end
local function wheelspeed(car)
	if not car then return end
	if not car.object then return end
	if not car.object:get_velocity() then return end
	if not car.wheel then return end
	local direction = 1
	if car.v then
		direction = get_sign(car.v)
	end
	local v = get_v(car.object:get_velocity())
	local fps = v*4
	for id, wheel in pairs(car.wheel) do
		wheel:set_animation({x=2, y=9}, fps*direction, 0, true)
	end
	car.object:set_animation({x=2, y=9}, fps*direction, 0, true)
	if v ~= 0 then
		local i = 16
		while true do
			if i/fps > 1 then i = i/2 else break end
		end
		minetest.after(i/fps, wheelspeed, car)
	end
end

local function rotateVector(x, y, a)
  local c = math.cos(a)
  local s = math.sin(a)
  return c*x - s*y, s*x + c*y
end

local cars_dyes = {
	white = {"white",	 "ffffff",		 "White"},
	grey = {"grey",       "8c8c8c",       "Grey"},
	dark_grey = {"dark_grey",  "313131",  "Dark Grey"},
	black = {"black",      "292929",      "Black"},
	violet = {"violet",     "440578",     "Violet"},
	blue = {"blue",       "003c82",       "Blue"},
	cyan = {"cyan",       "008a92",       "Cyan"},
	dark_green = {"dark_green", "195600", "Dark Green"},
	green = {"green",      "4fbe1c",      "Green"},
	yellow = {"yellow",     "fde40f",     "Yellow"},
	brown = {"brown",      "482300",      "Brown"},
	orange = {"orange",     "c74410",     "Orange"},
	red = {"red",        "ba1414",        "Red"},
	magenta = {"magenta",    "c30469",    "Magenta"},
	pink = {"pink",       "f57b7b",       "Pink"},
}

local function updatetextures(self, def)
	local prop = self.object:get_properties()
	prop.textures = {}
	if self.color and def.initial_properties.textures[3] then
		prop.textures[1] = def.initial_properties.textures[2].."^("..def.initial_properties.textures[3].."^[multiply:#"..cars_dyes[self.color][2]..")"
	else
		prop.textures[1] = def.initial_properties.textures[1]
	end
	if font_api then
		local color = "black"
		--local width = 130--original val
		local textwidth = 47 + ((self.text and #self.text*8) or 0)
		if cars_dyes[self.textcolor] then color = self.textcolor end
		local textTex = font_api.get_font("04b03"):render(" "..self.platenumber.text, 130, 8, {maxlines = 1, halign = 'left', valign = 'center'})
		textTex = textTex.."^("..font_api.get_font("04b03"):render("        "..(self.text or ""), textwidth, 8, {maxlines = 1, halign = 'left', valign = 'center'})..
		"^[colorize:#"..cars_dyes[color][2]..":255)"
		prop.textures[1] = prop.textures[1].."^"..textTex
	end
	self.object:set_properties(prop)
	return prop
end

local function remove_towline(car)
	if not car and not car.towline and not car.get_luaentity then return end
	if not car.towline then car = car:get_luaentity() end
	local ent = car.towline
	if ent.finishobj and ent.finishobj.get_luaentity and ent.finishobj:get_luaentity() then
		ent.finishobj:get_luaentity().towline = nil
	end
	if ent.finishobj and ent.finishobj.is_player and ent.finishobj:is_player() then
		holdingtowlines[ent.finishobj:get_player_name()] = nil
	end
	ent.object:remove()
	car.towline = nil
end

minetest.register_entity("cars:towline", {
    hp_max = 1,
    physical = false,
	pointable = false,
    weight = 5,
    visual = "cube",
    visual_size = {x=.1, y=.1},
    textures = {"towline.png", "towline.png", "towline.png", "towline.png", "towline.png", "towline.png"}, 
	on_step = function(self, dtime)
		--self.los_timer = (self.los_timer or 0) + dtime
		if dtime > .2 then dtime = .2 end
		if self.startobj then
			self.start = self.startobj:get_pos()
			if self.startoffset then
				local offset = table.copy(self.startoffset)
				local rot = {x=0,y=0,z=0}
				if self.startobj:is_player() then
					rot.y = self.startobj:get_look_horizontal() or 0
					--rot.x = self.startobj:get_look_vertical() or 0
				else
					rot = self.startobj:get_rotation()
				end
				if not rot then
					remove_towline(self.startobj)
					return
				end
				offset = vector.rotate(offset, rot)
				self.start = vector.add(self.start,offset)
			end
		end
		if self.finishobj then
			self.finish = self.finishobj:get_pos()
			if self.finishoffset then
				local offset = table.copy(self.finishoffset)
				local rot = {x=0,y=0,z=0}
				if self.finishobj:is_player() then
					rot.y = self.finishobj:get_look_horizontal() or 0
					--rot.x = self.finishobj:get_look_vertical() or 0
				else
					rot = self.finishobj:get_rotation()
				end
				offset = vector.rotate(offset, rot)
				self.finish = vector.add(self.finish,offset)
			end
		end
		local sp = self.start
		local fp = self.finish
		if not sp or not fp then self.object:remove() return end
		if self.laststart and self.lastfinish and vector.equals(self.laststart, sp) and vector.equals(self.lastfinish, fp)
		and (not self.length or self.length == 2.5) then return end
		
		local child = self.finishobj
		if child and self.length then
			local vel = child:get_velocity()
			if self.length > 2.5 then
				self.length = self.length-dtime
				if self.length < 2.5 then
					self.length = 2.5
				end
			end
			local dist = vector.distance(sp, fp)
			if dist > self.length then
				local chainforce = (dist-self.length)*.4
				if chainforce > 2 then
					remove_towline(self.startobj)
					return
				end
				vel = vector.add(vel, vector.multiply(vector.direction(fp, sp), chainforce))
				local olddir = vector.rotate({x=0,y=0,z=1}, child:get_rotation())
				local newdir = vector.direction(fp, sp)
				newdir = vector.add(vector.multiply(newdir, chainforce*.2), olddir)				
				child:set_rotation(vector.dir_to_rotation(newdir))
				child:set_velocity(vel)
			end
		end
		local delta = vector.subtract(sp, fp)
		local yaw = math.atan2(delta.z, delta.x) - math.pi / 2
		local pitch = math.atan2(delta.y,  math.sqrt(delta.z*delta.z + delta.x*delta.x))
		pitch = pitch + math.pi/2
		local dist = vector.distance(sp, fp)
		if dist > 50 then
			remove_towline(self.startobj)
			return
		end
		--[[if self.los_timer > 1 then
			self.los_timer = 0
			if not minetest.line_of_sight(sp, fp)then
				remove_towline(self.startobj)
				return
			end
		end--]]
		self.object:move_to({x=(sp.x+fp.x)/2, y=(sp.y+fp.y)/2, z=(sp.z+fp.z)/2, })
		self.object:set_rotation({x=pitch, y=yaw, z=0})
		self.object:set_properties({visual_size = {x=.1, y=dist}})
		self.laststart = sp
		self.lastfinish = fp
	end,
	on_activate = function(self, staticdata, dtime_s)
		if not staticdata or staticdata == "" then self.object:remove() return end
	end
})

function car_formspec(clickername, car, keyinvname, def)
    local form = "" ..
    "size[9,7]" ..
    "list[current_player;main;0.5,2.75;8,4.25;0]" ..
    "button[0.25,1.5;1,1;ignition;Ignition]" ..
    "button_exit[3.625,1.5;1.75,1;exit;Exit Seat]" ..
    "list[detached:"..minetest.formspec_escape(keyinvname)..";key;1.25,1.5;1,1;0]"
	if def.lights then
		form = form.."button[0.25,0.25;1.5,1;headlights;Headlights]" .. "button[1.6,0.25;1.5,1;flashers;Flashers]"
	end
	if def.drill and minetest.check_player_privs(clickername, {griefing=true}) then
		form = form.."dropdown[0.25,0.25;2,1;drillselect;Drill Off,Drill Front,Drill High,Drill Above,Drill Below;"..(car.drill or 1)..";true]"
	end
    if def.siren then
		form = form.."button[2.95,0.25;1.25,1;siren;Siren]"
	end
	if show_police_formspec and def.policecomputer then
		form = form.."button[4,0.25;1.5,1;computer;Computer]"
	end
	if def.trunkloc then
		form = form.."checkbox[2.175,1.5;trunklock;Lock Trunk;"..tostring(car.trunklock).."]"
	end
    if clickername == car.owner or (jobs and jobs.permissionstring(clickername, car.owner)) or minetest.check_player_privs(clickername, {protection_bypass = true}) then
		local textcolor_item_str = ""
		local current_textcolor_idx = 1
		local i = 0
		for colorname, item in pairs(cars_dyes) do
			i = i + 1
			if car.textcolor and colorname == car.textcolor then current_textcolor_idx = i end
			if i ~= 1 then textcolor_item_str = textcolor_item_str.."," end
			textcolor_item_str = textcolor_item_str .. minetest.formspec_escape(item[1])
		end
		textcolor_item_str = textcolor_item_str..";"..current_textcolor_idx
		form = form.."field[5.6,1.78;1.75,1;owner;Owner;"..minetest.formspec_escape(car.owner).."]" .."button_exit[6.85,1.5;2,1;changeowner;Change Owner]"..
		"field[5.6,.7;2,1;text;Custom Text;"..minetest.formspec_escape(car.text or "").."]" ..
		"dropdown[7.1,0.475;1.5,1;textcolor;"..textcolor_item_str..";false]"
	else
		form = form.."label[6,1.75;Owner: "..car.owner.."]"
	end

    return form
end

function seat_formspec(swap)
    local form = "size[3,3]button_exit[0.5,0.5;2.25,1;exit;Exit Seat]"
	if swap then
		form = form.."button_exit[0.5,1.5;2.25,1;swap;Swap to Seat]"
	end
    return form
end

function getClosest(player, car, distance)
	local def = cars_registered_cars[car.name]
	local playerPos = player:get_pos()
	local dir = player:get_look_dir()
	playerPos.y = playerPos.y + 1.45
	local carPos = car.object:get_pos()
	local offset, _ = player:get_eye_offset()
	local playeryaw = player:get_look_horizontal()
	local x, z = rotateVector(offset.x, offset.z, playeryaw)
	offset = vector.multiply({x=x, y=offset.y, z=z}, .1)
	playerPos = vector.add(playerPos, offset)
	if DEBUG_WAYPOINT then 
		local marker = player:hud_add({
			hud_elem_type = "waypoint",
			name = "start",
			number = 0xFF0000,
			world_pos = playerPos
		})
		minetest.after(5, function() player:hud_remove(marker) end, player, marker)
	end
	local punchPos = vector.add(playerPos, vector.multiply(dir, distance or vector.distance(playerPos, carPos)))
	if minetest.raycast then
		local ray = minetest.raycast(playerPos, vector.add(playerPos, vector.multiply(dir, vector.distance(playerPos, carPos))))
		if ray then
			local pointed = ray:next()
			if pointed and pointed.ref == player then
				pointed = ray:next()
			end
			--minetest.chat_send_all(dump(pointed))
			--minetest.chat_send_all(tostring(pointed.ref))
			if pointed and (pointed.ref == car.object or (car.extension and pointed.ref == car.extension)) and pointed.intersection_point then
				punchPos = pointed.intersection_point
			end
		end
	end
	if not punchPos then return end
		if DEBUG_WAYPOINT then 
			local marker = player:hud_add({
				hud_elem_type = "waypoint",
				name = "end",
				number = 0xFF0000,
				world_pos = punchPos
			})
			minetest.after(5, function() player:hud_remove(marker) end, player, marker)
		end
	punchPos = vector.subtract(punchPos, carPos)
	local carYaw = get_yaw(car.object:get_yaw())
	local closest = {}
	closest.id = 0
	local trunkloc = def.trunkloc
	if trunkloc then
		local x, z = rotateVector(trunkloc.x, trunkloc.z, carYaw)
		trunkloc = vector.multiply({x=x, y=trunkloc.y, z=z}, .1)
		closest.distance = vector.distance(punchPos, trunkloc)
	end
		if DEBUG_WAYPOINT then 
			local marker = player:hud_add({
				hud_elem_type = "waypoint",
				name = "0",
				number = 0xFF0000,
				world_pos = vector.add(trunkloc, carPos)
			})
			minetest.after(5, function() player:hud_remove(marker) end, player, marker)
		end
	for id in pairs(car.passengers) do
		local loc = car.passengers[id].loc
		local x, z = rotateVector(loc.x, loc.z, carYaw)
		loc = vector.multiply({x=x, y=loc.y, z=z}, .1)
		if DEBUG_WAYPOINT then 
			local marker = player:hud_add({
				hud_elem_type = "waypoint",
				name = id,
				number = 0xFF0000,
				world_pos = vector.add(loc, carPos)
			})
			minetest.after(5, function() player:hud_remove(marker) end, player, marker)
		end
		local dis = vector.distance(punchPos, loc)
		if not closest.distance then
			closest.distance = dis
			closest.id = id
		elseif dis < closest.distance then closest.id = id closest.distance = dis end
	end
	return closest.id
end

local function turncaroff(car, lights)
	if not lights and car.lights then lights = car.lights:get_luaentity() end
	cars.setlight(lights, "leftblinker", false)
	cars.setlight(lights, "rightblinker", false)
	car.ignition = nil
end

local car_forms = {}
local function trunk_rightclick(self, clicker)
	local def = cars_registered_cars[self.name]
	local name = clicker:get_player_name()
	car_forms[name] = self
	local selfname = string.sub(tostring(self), 8)
	local inventory = minetest.create_detached_inventory("cars"..selfname, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			if self.object:get_luaentity() then
				return count
			else
				return 0
			end
		end,
		allow_put = function(inv, listname, index, stack, player)
			if self.object:get_luaentity() then
				return stack:get_count()
			else
				return 0
			end
		end,
		allow_take = function(inv, listname, index, stack, player)
			if self.object:get_luaentity() then
				return stack:get_count()
			else
				return 0
			end
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			self.trunkinv = inv:get_list("trunk")
		end,
		on_put = function(inv, listname, index, stack, player)
			self.trunkinv = inv:get_list("trunk")
		end,
		on_take = function(inv, listname, index, stack, player)
			self.trunkinv = inv:get_list("trunk")
		end,
	})
	local x = def.trunksize.x
	local y = def.trunksize.y
	local formx = x
	inventory:set_size("trunk", x * y)
	if x < 8 then formx = 8 end
	if def.towloc then
		y = y + 1
	end
	inventory:set_list("trunk", table.copy(self.trunkinv))
	local formspec =
           "size["..formx..","..5+y.."]"..
           "list[detached:cars"..selfname..";trunk;0,.5;"..x..","..def.trunksize.y..";]"..
			"list[current_player;main;0,"..1+y..";8,4;]"..
			"listring[]"
	if def.towloc then
		if self.towline then
			if self.towline.finishobj == self.object then
				formspec = formspec.."button[3,"..(y-.25)..";2,1;notow;Cannot Tow]"
			else
				formspec = formspec.."button[3,"..(y-.25)..";2,1;detachtow;Detach Tow]"
			end
		else
			formspec = formspec.."button[3,"..(y-.25)..";2,1;attachtow;Attach Tow]"
		end
	end
    minetest.show_formspec(name, "cars_trunk", formspec)
end

local function driver_rightclick(self, clicker)
	local def = cars_registered_cars[self.name]
	local name = clicker:get_player_name()
	local selfname = string.sub(tostring(self), 8)
	local inventory = minetest.create_detached_inventory("cars"..selfname, {
		on_put = function(inv, listname, index, stack, player)
			self.key = inv:contains_item("key", made_key)
			if not self.key and not stack:is_empty() then
				self.key = stack:to_string()
			end
		end,
		on_take = function(inv, listname, index, stack, player)
			self.key = inv:contains_item("key", made_key)
			if not self.key then turncaroff(self) end
			if not self.key and not inv:is_empty("key") then
				self.key = inv:get_stack("key", 1):to_string()
			end
		end,
        allow_put = function(inv, listname, index, stack, player)
			if stack:get_meta():get_string("secret") == self.secret then
				return 1
			else
				local cap = stack:get_tool_capabilities()
				if cap.groupcaps and cap.groupcaps.locked and cap.groupcaps.locked.maxlevel and cap.groupcaps.locked.maxlevel > 1 then
					return 1
				end
				return 0
			end
		end,
	})
	inventory:set_size("key", 1)
	if self.key == true then
		local new_stack = ItemStack(made_key)
		local meta = new_stack:get_meta()
		local description = def.description
		if self.color then
			description = cars_dyes[self.color][3].." "..description
		end
		if self.platenumber and self.platenumber.text then
			description = description.." "..self.platenumber.text
		end
		meta:set_string("secret", self.secret)
		meta:set_string("description", string.format("Key to %s's %s", self.owner, description))
		inventory:set_stack("key", 1, new_stack)
	elseif self.key and type(self.key) == "string" then
		inventory:set_stack("key", 1, ItemStack(self.key))
	end
	local formspec = car_formspec(name, self, "cars"..selfname, def)
    minetest.show_formspec(name, "cars_form", formspec)
end

local function register_lightentity(carname)
	minetest.register_entity("cars:"..carname.."lights",{
		hp_max = 1,
		physical = false,
		pointable = false,
		collide_with_objects = false,
		weight = 5,
		collisionbox = {-0.2,-0.2,-0.2, 0.2,0.2,0.2},
		visual = "mesh",
		visual_size = {x=1, y=1},
		is_visible = true,
		glow = 7,
		mesh = carname.."lights.b3d",
		textures = {"invisible.png"},
		on_activate = function(self, staticdata, dtime_s)
			minetest.after(.1, function()
				if not self.object:get_attach() then
					self.object:remove()
				end
			end)
		end,
		on_step = function(self, dtime)
			if not self.timer then self.timer = 0 end
			if not self.blink then self.blink = false end
			self.timer = self.timer + dtime
			local automatic = self.leftblinker or self.rightblinker or self.flashers
			if (self.timer > .5 and automatic) or self.update then
				if self.update then
					self.update = false
				else
					self.blink = not self.blink
					self.timer = 0
					if self.leftblinker or self.rightblinker or self.flashers then
						if self.blink then
							minetest.sound_play("indicator2", {
								max_hear_distance = 6,
								gain = 1,
								object = self.object
							})
						else
							minetest.sound_play("indicator1", {
								max_hear_distance = 6,
								gain = 1,
								object = self.object
							})
						end
					end
				end
				local lighttable = {headlights = self.headlights, brakelights = self.brakelights, leftblinker = self.leftblinker and self.blink, rightblinker = self.rightblinker and self.blink, flasheron = self.flashers and self.blink, flasheroff = self.flashers and not self.blink}
				
				cars.setlighttexture(self.object, lighttable, carname)
			end
		end,
	})
end

local function drill_remove_node(pos, node)
	diggername = "cars:drill"
	local log = minetest.log
	local def = core.registered_nodes[node.name]
	-- Copy pos because the callback could modify it
	if def and not def.diggable then
		log("info", diggername .. " tried to dig "
			.. node.name .. " which is not diggable "
			.. core.pos_to_string(pos))
		return false
	end

	if core.is_protected(pos, diggername, false, node.name) then
		log("action", diggername
				.. " tried to dig " .. node.name
				.. " at protected position "
				.. core.pos_to_string(pos))
		core.record_protection_violation(pos, diggername)
		return false
	end

	log('action', diggername .. " digs "
		.. node.name .. " at " .. core.pos_to_string(pos))

	local drops = core.get_node_drops(node, "")
	
	local inv = minetest.get_inventory({type="node", pos=pos})
	if inv then
		for listname, listtbl in pairs(inv:get_lists()) do
			for i = 1, inv:get_size(listname) do
				table.insert(drops, inv:get_stack(listname, i))
			end
		end
	end

	-- Handle drops
	core.handle_node_drops(pos, drops)

	-- Remove node and update
	core.remove_node(pos)

	-- Play sound if it was done by a player
	if diggername ~= "" and def and def.sounds and def.sounds.dug then
		core.sound_play(def.sounds.dug, {
			pos = pos,
		}, true)
	end

	return true
end

holdingtowlines = {}

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "cars_trunk" then
		if fields.quit then
			local name = player:get_player_name()
			if car_forms[name] then
				minetest.sound_play("closetrunk", {
					max_hear_distance = 24,
					gain = 1,
					object = car_forms[name].object
				}, true)
				car_forms[name] = nil
			end
		end
		local name = player:get_player_name()
		local car = car_forms[name]
		local def
		if car then
			def = cars_registered_cars[car.name]
		end
		if car and def then
			if fields.detachtow and car.towline and car.towline.finishobj ~= car.object then
				remove_towline(car)
			end
			if fields.attachtow and not car.towline then
				if holdingtowlines[name] then return end
				car.towline = minetest.add_entity(car.object:get_pos(), "cars:towline", "spawn"):get_luaentity()
				local ent = car.towline
				ent.finishobj = player
				ent.startobj = car.object--startobj is what is the 'parent'
				ent.startoffset = vector.multiply(def.towloc, .1)
				ent.finishoffset = {x=0,y=1,z=0}
				holdingtowlines[name] = ent--todo remove other line if the player is already holding one
			end
		end
	elseif formname == "cars_form" then
		local name = player:get_player_name()
		local car = player_attached[name]
		local def
		if car then
			def = cars_registered_cars[car.name]
			if not def then return end
		else
			return
		end
		if car.passengers[1].player == player then
			local obj
			if car.lights then obj = car.lights:get_luaentity() end
			if fields.ignition and car.key and not car.igniting then
				if car.ignition then
					turncaroff(car, obj)
				else
					car.igniting = true
					minetest.sound_play(def.ignitionsound, {
						max_hear_distance = 24,
						gain = 1,
						object = car.object
					}, true)
					minetest.after(.8, function(car)
						car.igniting = nil
						if type(car.key) == "boolean" then
							car.ignition = true
						elseif math.random(10) == 1 then
							car.ignition = true
							car.alarm = 30
							if obj then
								cars.setlight(obj, "flashers", true)
							end
						end
					end, car)
				end
			elseif fields.headlights and car.battery > 0 then
				cars.setlight(obj, "headlights", "toggle")
			elseif fields.flashers and not car.alarm then
				cars.setlight(obj, "flashers", "toggle")
			elseif fields.siren and def.siren then
				if car.siren ~= nil then
					if type(car.siren) == "number" then
						minetest.sound_fade(car.siren, 10, 0)
					end
					car.siren = nil
					car.timer3 = nil
				else
					car.siren = true
					car.timer3 = def.sirenlength or 2
				end
			elseif show_police_formspec and fields.computer then
				show_police_formspec(name)
			elseif fields.trunklock ~= nil then
				if fields.trunklock == "true" then
					car.trunklock = true
				else
					car.trunklock = nil
				end
			elseif car.ignition and fields.drillselect and minetest.check_player_privs(name, {griefing=true}) then
				car.drill = tonumber(fields.drillselect)
				--car.driller = name
				if car.drill == 1 then
					car.drill = nil
					--car.driller = nil
					if car.drillsound then
						minetest.sound_fade(car.drillsound, 10, 0)
						car.drillsound = nil
					end
				elseif not car.drillsound then
					car.drillsound = minetest.sound_play("jackhammerloop", {
						max_hear_distance = 64,
						loop = true,
						gain = 1,
						object = car.object
					})
				end
				car.drilltimer = nil
				local prop = car.object:get_properties()
				prop.mesh = string.gsub(def.initial_properties.mesh, ".b3d", "")..(car.drill or "")..".b3d"
				car.object:set_properties(prop)
			end
			if car.owner == name or car.owner == "" or (jobs and jobs.permissionstring(name, car.owner)) or minetest.check_player_privs(name, {protection_bypass = true}) then
				if fields.changeowner and fields.owner then
					if minetest.player_exists(fields.owner) or (jobs and jobs.is_job_string(fields.owner)) then
						car.owner = fields.owner
						local color = "Unpainted"
						if car.color then
							color = cars_dyes[car.color][3]
						end
						cars.set_database_entry(car.platenumber.text, {color = color, owner = car.owner, desc = def.description})
						minetest.chat_send_player(name, "Vehicle owner set to "..fields.owner)
					else
						minetest.chat_send_player(name, "Invalid owner name")
					end
				elseif fields.text or fields.textcolor then
					if fields.text then
						car.text = fields.text
					end
					if fields.textcolor and cars_dyes[fields.textcolor]then
						car.textcolor = fields.textcolor
					end
					updatetextures(car, def)
				end
			end
		end
		if fields.exit then
			detach(player)
		elseif fields.swap then
			if car_forms[name] then
				detach(player)
				car_rightclick(car, player, car_forms[name])
			end
		end
		if fields.quit then
			car_forms[name] = nil
		end
	end
end)
local lagtable = {}
local lagcounter = 1
local function car_step(self, dtime, moveresult)
	if dtime > .2 then dtime = .2 end
	local def = cars_registered_cars[self.name]
	if self.deathtime and os.time()-self.deathtime >= 7200 then--repair the car within 2 hours and it will be saved
		self.object:remove()
		return
	end
	if self.alarm then
		local oldalarm = math.floor(self.alarm)
		self.alarm = self.alarm - dtime
		local newalarm = math.floor(self.alarm)
		if oldalarm ~= newalarm then
			minetest.sound_play(def.horn, {
				max_hear_distance = 48,
				gain = 8,
				object = self.object
			}, true)
		end
		if self.alarm <= 0 then
			self.alarm = nil
			if self.lights then
				local obj = self.lights:get_luaentity()
				cars.setlight(obj, "flashers", false)
			end
		end
	end
	if self.ignition and oil and def.gas_usage then
		if self.gas <= 0 then
			self.ignition = false
			self.gas = 0
		end
	end
	local velocity = self.object:get_velocity()
	local yaw = self.object:get_yaw()
	if not yaw then return end
	local yaw = get_yaw(yaw)
	local slowing = false
	local lights
	if self.lights then lights = self.lights:get_luaentity()
		if lights.headlights then
			self.battery = self.battery - dtime
			if self.battery <= 0 then
				self.battery = 0
				cars.setlight(lights, "headlights", false)
			end
		end
	end
	if not self.v then self.v = 0 end
	self.v = get_v(velocity) * get_sign(self.v)
	--local accel = 0--def.coasting*get_sign(self.v)
	local pos = self.object:get_pos()
	if not velocity then return end
	if self.lastv then
		local newv = velocity
		if self.crash == nil then self.crash = false end
		local crash = false
		if math.abs(self.lastv.x) > 5 and newv.x == 0 then crash = true end
		if math.abs(self.lastv.y) > 10 and newv.y == 0 then crash = true end
		if math.abs(self.lastv.z) > 5 and newv.z == 0 then crash = true end
		--[[if crash then
			local crashconfirm = false
			local abovecol = false
			local collisions = moveresult.collisions or {}
			for i, col in pairs(collisions) do
				if col.type == "node" then
					if col.axis == "y" then
						--minetest.chat_send_all(col.node_pos.y)
					else
						local props = self.object:get_properties()
						local cbox = props.collisionbox
						local stepheight = (col.node_pos.y - pos.y)-cbox[2]+.5 --last +.5 is assuming block has a full collisionbox
						if stepheight > props.stepheight then
							crashconfirm = true
							break
						end
					end
				end
			end
			if not crashconfirm then
				crash = false
				self.object:set_velocity(self.lastv)
				self.v = get_v(velocity) * get_sign(self.v)
			end
		end--]]
		if crash and not self.crash then
			self.crash = true
			minetest.after(.5, function()
				self.crash = false
			end)
			minetest.sound_play("crash"..math.random(1,3), {
				max_hear_distance = 48,
				pitch = .7,
				gain = 10,
				object = self.object
			}, true)			
			local dmg = ((vector.length(self.lastv)-4)/(20-4))*20
			--self.object:set_hp(self.object:get_hp()-dmg/2, "crash")
			self.object:punch(self.object, nil, {damage_groups={vehicle=dmg/2}})
			local objects = {}
			if moveresult and moveresult.collisions then
				for i, collision in pairs(moveresult.collisions) do
					if collision.type == "object" then
						table.insert(objects, collision.object)
					end
				end
			elseif not moveresult then
				local checkpos = vector.add(pos, vector.multiply(vector.normalize(self.lastv), .8))
				local objects = minetest.get_objects_inside_radius(checkpos, 1)
			end
			for _,obj in pairs(objects) do
				if obj:is_player() then
					for id, passengers in pairs (self.passengers) do
						if passengers.player == obj then goto next end
					end
					local puncher = self.passengers[1].player
					if not puncher then puncher = self.object end
					local name = obj:get_player_name()
					if default.player_attached[name] then
						dmg = dmg*.5
					else
						obj:add_player_velocity(self.lastv)
					end
					obj:punch(puncher, nil, {damage_groups={fleshy=dmg}})
					::next::
				elseif cars_registered_cars[obj:get_luaentity().name] then
					obj:punch(self.object, nil, {damage_groups={vehicle=dmg/2}})
				end
			end
		end
	end
	if self.towline and self.towline.finishobj == self.object then
		local vel = self.object:get_velocity()
		if moveresult.touching_ground then
			vel = vector.multiply(vel, 1-4*dtime)
			local rot = self.object:get_rotation()
			local function get_sign(num)
				if num == 0 then return 1 end
				return num/math.abs(num)
			end
			local sign = get_sign(rot.x)
			rot.x = rot.x*.96-.02*sign
			if get_sign(rot.x)~=sign then
				rot.x = 0
			end
			sign = get_sign(rot.z)
			rot.z = rot.z*.96-.02*sign
			if get_sign(rot.z)~=sign then
				rot.z = 0
			end
			self.object:set_rotation(rot)
		else
			vel = vector.multiply(vel, 1-.5*dtime)
		end
		self.object:set_velocity(vel)
		return
	end
	local nodepos = table.copy(pos)
	local node = minetest.get_node(nodepos).name
	if node == "air" then
		nodepos.y = nodepos.y - 1
		node = minetest.get_node(nodepos).name
		if node == "air" then
			nodepos.y = nodepos.y - 1
			node = minetest.get_node(nodepos).name
			if node == "air" and math.abs(velocity.y) == 0 then
				node = "unknown"
			end
		end
	end
	local on_asphalt = string.find(node, "asphalt") or string.find(node, "road_black")
	local max_speed = def.max_speed
	if not on_asphalt then
		max_speed = def.max_offroad_speed or max_speed*.66
	end
	if self.hp <= (def.initial_properties.hp_max or 20)/2 then
		local halfmax = (def.initial_properties.hp_max or 20)/2
		local damagefactor = (self.hp-1)/halfmax
		max_speed = max_speed*damagefactor
	end
	local driver = self.passengers[1].player
	if driver then
		local text = tostring(math.abs(rnd(self.v*2.23694, 10)).." MPH")
		if oil and def.gas_usage then
			text = text.." "..tostring(math.floor(self.gas*10)/10).."L Gas"
		end
		driver:hud_change(self.hud, "text", text)
		local ctrl = driver:get_player_control()
		local sign
		local brakes = false
		if self.v == 0 then sign = 0 else sign = get_sign(self.v) end
		if self.lastctrl then
			if ctrl.sneak and not self.lastctrl.sneak then
				local lookdir = yaw-driver:get_look_horizontal()
				lookdir = math.deg(lookdir)
				lookdir = get_deg(lookdir)
				local vertlook =  math.deg(driver:get_look_vertical())
				if math.abs(vertlook) < 20 then
					if lookdir > 15 then
						cars.setlight(lights, "rightblinker", "toggle")
					elseif lookdir < -15 then
						cars.setlight(lights, "leftblinker", "toggle")
					else
						if self.cruise then
							self.cruise = nil
						else
							self.cruise = self.v
						end
						minetest.sound_play("lighton", {
							max_hear_distance = 6,
							gain = 1,
							object = self.object
						}, true)
					end
				end
			end
		end
		local carpitch = 0
		--VELOCITY MOVEMENT
		if self.ignition and max_speed > 0 then
			local newv = self.v
			if self.cruise then
				if ctrl.jump then
					newv = newv - def.braking*dtime*sign
					self.cruise = newv
					brakes = true
					slowing = true
				elseif ctrl.up then
					self.cruise = self.v + 4*dtime
				elseif ctrl.down then
					self.cruise = self.v - 4*dtime
					cars.setlight(lights, "brakelights", false)
				end
			else
				if ctrl.jump then
					newv = newv - def.braking*dtime*sign
					brakes = true
					slowing = true
				elseif ctrl.up then
					if sign >= 0 then
						newv = newv + def.acceleration*dtime*((max_speed-math.abs(self.v)+1)/max_speed)
					else
						if self.cruise then self.cruise = nil end
						newv = newv + def.braking*dtime
						brakes = true
						slowing = true
					end
				elseif ctrl.down then
					if self.cruise then self.cruise = nil end
					if sign <= 0 then
						newv = newv - def.acceleration*dtime*((max_speed-math.abs(self.v)+1)/max_speed)
					else
						newv = newv - def.braking*dtime
						brakes = true
						slowing = true
					end
				end
			end
			if node ~= "air" then
				carpitch = (newv - self.v)*.07
				self.v = newv
			end
			if self.cruise or (not ctrl.up and not ctrl.down) then
				if self.cruise and not ctrl.up and not ctrl.down and math.abs(self.cruise) < 1 then self.cruise = 0 end
				if self.cruise and self.cruise ~= 0 and math.abs(self.v) < math.abs(self.cruise) and node ~= "air" then
					self.v = self.v + def.acceleration*dtime*((max_speed-math.abs(self.v)+1)/max_speed)*get_sign(self.cruise)
					if self.v > self.cruise then self.v = self.cruise end
				elseif sign ~= 0 then
					self.v = self.v - def.coasting*dtime*get_sign(self.v)
					slowing = true
				end
			end
			cars.setlight(lights, "brakelights", brakes)
			if get_sign(self.v) ~= sign and sign ~= 0 then
				self.v = 0
				--cars.setlight(lights, "brakelights", false)
			end
			
		else
			local sign
			if self.v == 0 then sign = 0 else sign = get_sign(self.v) end
			if sign ~= 0 then
				self.v = self.v - def.coasting*dtime*sign
				if get_sign(self.v) ~= sign then
					self.v = 0
				end
			end
		end
		--ACCELERATION MOVEMENT
		--[[
		if ctrl.up then
			if sign >= 0 then
				accel = def.acceleration
			else
				accel = -def.braking
			end
		elseif ctrl.down then
			if sign <= 0 then
				accel = -def.acceleration
			else
				accel = def.braking
			end
		end
		if get_sign(self.v) ~= sign and sign ~= 0 or self.v < .1 then
			--accel = 0
		end
--]]
		local abs_v = math.abs(self.v)
		local maxwheelpos = 45*(8/(abs_v+8))
		local lastwheelpos = self.wheelpos
		local turnspeed = 50
		if self.cruise then turnspeed = 36 end
		if ctrl.left and (self.wheelpos <= 0 or self.cruise) then
			self.wheelpos = self.wheelpos-turnspeed*dtime*(4/(abs_v+4))
			if self.wheelpos < -1*maxwheelpos then
				self.wheelpos = -1*maxwheelpos
			end
		elseif ctrl.right and (self.wheelpos >= 0 or self.cruise) then
			self.wheelpos = self.wheelpos+turnspeed*dtime*(4/(abs_v+4))
			if self.wheelpos > maxwheelpos then
				self.wheelpos = maxwheelpos
			end
		else
			local sign = get_sign(self.wheelpos)
			local wheelreturnspeed = 50
			if self.cruise then
				wheelreturnspeed = math.abs(self.v)
				if wheelreturnspeed > 15 then wheelreturnspeed = 15 end
			end
				self.wheelpos = self.wheelpos - wheelreturnspeed*get_sign(self.wheelpos)*dtime
			if math.abs(self.wheelpos) < 2 or sign ~= get_sign(self.wheelpos) then
				self.wheelpos = 0
			end
		end
		if lights and (lights.leftblinker or lights.rightblinker) then
			if not self.maxwheelpos then self.maxwheelpos = self.wheelpos end
			if math.abs(self.wheelpos) > math.abs(self.maxwheelpos) then
				self.maxwheelpos = wheelpos
			end
			if self.maxwheelpos and math.abs(self.maxwheelpos) > 15 and (self.wheelpos == 0 or get_sign(self.wheelpos) ~= get_sign(self.maxwheelpos)) then
				cars.setlight(lights, "leftblinker", false)
				cars.setlight(lights, "rightblinker", false)
			end
		else
			self.maxwheelpos = nil
		end
		if animateTimer >= .08 then
			self.wheel.frontright:set_attach(self.object, "", def.wheel.frontright, {x=0,y=self.wheelpos,z=0})
			self.wheel.frontleft:set_attach(self.object, "", def.wheel.frontleft, {x=0,y=self.wheelpos,z=0})
			
			self.object:set_bone_position("steering", def.steeringwheel, {x=0,y=0,z=-self.wheelpos*8})
		end
		local carroll = 0
		if node ~= "air" then
			local axval = def.axisval or 10
			--self.object:setyaw(yaw - ((self.wheelpos/axval)*(self.v/axval)*dtime))
			carroll = yaw
			yaw = yaw - ((self.wheelpos/axval)*(self.v/axval)*dtime)
			carroll = (yaw - carroll)*.08*self.v
		end
		local rot = self.object:get_rotation()
		rot = vector.add(rot, {x=carpitch, y=0, z=carroll})
		rot = vector.multiply(rot, .5)
		self.object:set_rotation({x=rot.x, y=yaw, z=rot.z})

		if attachTimer >= 5 then
			if self.wheel.backright then self.wheel.backright:set_attach(self.object, "", {z=-11.75,y=2.5,x=-8.875}, {x=0,y=0,z=0}) end
			if self.wheel.backleft then self.wheel.backleft:set_attach(self.object, "", {z=-11.75,y=2.5,x=8.875}, {x=0,y=0,z=0}) end
			if self.lights then self.lights:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0}) end
		end
		self.lastctrl = ctrl
	else
		self.lastctrl = nil
		if math.abs(self.wheelpos) > 0 then
			self.wheelpos = 0
			self.wheel.frontright:set_attach(self.object, "", def.wheel.frontright, {x=0,y=self.wheelpos,z=0})
			self.wheel.frontleft:set_attach(self.object, "", def.wheel.frontleft, {x=0,y=self.wheelpos,z=0})
			if self.steeringwheel then self.steeringwheel:set_attach(self.object, "", def.steeringwheel, {x=0,y=0,z=-self.wheelpos*8}) end
			--self.object:setyaw(yaw - ((self.wheelpos/8)*(self.v/8)*dtime))
		end
		local sign
		if self.v == 0 then sign = 0 else sign = get_sign(self.v) end
		if sign ~= 0 then
			self.v = self.v - def.coasting*dtime*sign
			if get_sign(self.v) ~= sign then
				self.v = 0
			end
		end
	end
	for id, passengers in pairs (self.passengers) do
		local player = passengers.player
		if player then
			local playeryaw = player:get_look_horizontal()
			local offset = table.copy(passengers.offset)
			local x, z = rotateVector(offset.x, offset.z, yaw-playeryaw)
			offset.x = x
			offset.z = z
			player:set_eye_offset(offset, {x=0,y=10,z=-5})
			--[[if not minetest.line_of_sight(pos, vector.add(pos, vector.multiply(vector.rotate(passengers.loc, {x=0,y=yaw,z=0}), .1))) then
				detach(player)
			end--]]
		end
	end
	
	if attachTimer >= 5 then--removed an 'and false', forgot abt it, not sure how long it was there
		for id, passengers in pairs (self.passengers) do
			local player = passengers.player
			if player then
				player:set_attach(self.object, "",
					passengers.loc, {x = 0, y = 0, z = 0})
			end
		end
	end
	if self.v > max_speed then
		--self.v = max_speed
	elseif self.v < -1*max_speed/2 then
		self.v = -1*max_speed/2
	end
	if node ~= "air" and math.abs(self.v) > 1 and minetest.get_item_group(node, "water") > 0 then
		self.v = 1*get_sign(self.v)
	end
	local new_velo
	new_velo = get_velocity(self.v, (yaw - self.wheelpos/57.32), velocity)
	local force = vector.distance(velocity, new_velo)/dtime
	local maxforce
	if on_asphalt then
		maxforce = def.max_force or 20
	else
		maxforce = def.max_force_offroad or 1
	end
	if force > maxforce then
		force = force - maxforce
		factor = math.min(force*.04, .95)
		new_velo = vector.add(vector.multiply(new_velo, 1-factor), vector.multiply(velocity, factor))
		if self.skidsound then
			if self.last_on_asphalt == nil or on_asphalt == self.last_on_asphalt then
				minetest.sound_fade(self.skidsound, 20, factor)
			else
				minetest.sound_fade(self.skidsound, 10, 0)
				self.skidsound = nil
			end
		else
			local sound
			if on_asphalt then
				sound = "tyresound-asphaltskid"
			else
				sound = "tyresound-gravelskid"
			end
			self.skidsound = minetest.sound_play(sound, {
				max_hear_distance = 48,
				object = self.object,
				gain = factor,
				fade = 1,
				loop = true
			})
		end
	else
		if self.skidsound then
			minetest.sound_fade(self.skidsound, 10, 0)
			self.skidsound = nil
		end--]]
	end
	self.object:setvelocity(new_velo)
	--ACCELERATION TEST
	--[[if accel ~= 0 then
		self.object:setacceleration(get_velocity(accel, self.object:get_yaw(), {y=-10}))
	end--]]
	if math.abs(self.v) < .05 and math.abs(self.v) > 0 then
		self.object:setvelocity({x = 0, y = 0, z = 0})
		self.v = 0
		cars.setlight(lights, "brakelights", false)
		if self.wheelsound then
			minetest.sound_stop(self.wheelsound)
			self.wheelsound = nil
		end
		if self.windsound then
			minetest.sound_fade(self.windsound, 2, 0)
			self.windsound = nil
		end
		wheelspeed(self)
		return
	end
	if self.lastv and vector.length(self.lastv) == 0 and math.abs(self.v) > 0 then
		wheelspeed(self)
	end
	--[[set acceleration for replication
	if self.lastv then
		local accel = vector.subtract(self.lastv, new_velo)
		if self.v < 1 then
			accel = {x=0,y=0,z=0}
		end
		accel = vector.multiply(accel, 20)
		accel.y = -10
		self.object:setacceleration(accel)
	end--]]
	self.lastv = new_velo
	self.last_on_asphalt = on_asphalt
	--sound
	local abs_v = math.abs(self.v)
	--if abs_v > 0 and driver ~= nil then
	if self.ignition then
		if self.drill then
			self.drilltimer = (self.drilltimer or 0) + dtime
			if self.drilltimer >= 1 then
				self.drilltimer = 0
				local drilloffset = vector.rotate(def.drill[self.drill], {x=0,y=yaw,z=0})
				
				--[[local sparky = minetest.get_player_by_name("sparky")--to help find where the drilling offsets need to be
				local marker = sparky:hud_add({
					hud_elem_type = "waypoint",
					name = "start",
					number = 0xFF0000,
					world_pos = vector.add(pos, drilloffset)
				})
				minetest.after(5, function() sparky:hud_remove(marker) end, sparky, marker)--]]
				
				local drillpos = vector.round(vector.add(pos, drilloffset))
				local drillnode = minetest.get_node(drillpos)
				if drillnode.name ~= "air" then
					local posstring = minetest.pos_to_string(pos, 0)
					if not drilledblocks[posstring] or drilledblocks[posstring].name ~= drillnode.name then
						local health = minetest.get_node_group(drillnode.name, "strong")
						if health == 0 then health = 3 end--default 3 seconds to destroy non strong node
						drilledblocks[posstring] = {name = drillnode.name, health = health}
						
						--if police tools alarm block exists, trip any alarms within 32 blocks
						if police_add_alarm then
							local nodes = minetest.find_nodes_in_area(vector.subtract(drillpos, 32), vector.add(drillpos, 32), "policetools:alarm")
							for i, nodepos in pairs(nodes) do
								if vector.distance(drillpos, nodepos) <= 32 then
									police_add_alarm(nodepos)
								end
							end
						end
					end
					drilledblocks[posstring].last = os.time()
					drilledblocks[posstring].health = drilledblocks[posstring].health - 1
					if drilledblocks[posstring].health <= 0 then
						drilledblocks[posstring] = nil
						if default_tweaks and default_tweaks.exempt_node_dig then
							default_tweaks.exempt_node_dig(drillpos, drillnode, self.object)
						else
							drill_remove_node(drillpos, drillnode)
						end
					end
				end
			end
		end
		self.battery = math.min(self.battery + dtime*2, 600)
		if oil and def.gas_usage and not slowing then
			if self.v == 0 or self.cruise then--idle gas usage
				self.gas = self.gas - (def.gas_usage*dtime*.25)/60
			else--you are accelerating
				self.gas = self.gas - (def.gas_usage*dtime)/60
			end
		end
		self.timer1 = self.timer1 + dtime
		local rpm = 1
		for i, tab in pairs(def.rpmvalues) do
				if abs_v >= tab[1] then
					rpm = abs_v/tab[2]+tab[3]
					break
				end
		end
		pitch = rpm+.2
		if self.timer1 > .2/pitch-.05 then
				local gain = pitch
				if abs_v == 0 then
					gain = .15
				elseif slowing then
					gain = .2
				elseif self.cruise then
					gain = .25
				end
				minetest.sound_play(def.enginesound, {
					max_hear_distance = 48*gain,
					pitch = pitch,
					object = self.object,
					gain = gain,
				}, true)
			self.timer1 = 0
		end
	elseif self.drill or self.drillsound then
		minetest.sound_fade(self.drillsound, 10, 0)
		self.drill = nil
		self.drillsound = nil
		local prop = self.object:get_properties()
		prop.mesh = def.initial_properties.mesh
		self.object:set_properties(prop)
	end
	self.timer2 = self.timer2 + dtime
	local pitch = 1 + (abs_v/def.max_speed)*.6
	if self.timer2 > 2/pitch-.5 then
		if abs_v > .2 then
			if node ~= "air" then
				if on_asphalt then
					self.wheelsound = minetest.sound_play("tyresound-asphaltfade", {
						max_hear_distance = 48,
						object = self.object,
						pitch = pitch,
						gain = (abs_v/def.max_speed)*.2
					})
				else
					self.wheelsound = minetest.sound_play("tyresound-gravelfade", {
						max_hear_distance = 48,
						object = self.object,
						pitch = pitch,
						gain = .5 + (abs_v/def.max_speed)*2
					})

				
				end
			elseif self.wheelsound then
				minetest.sound_stop(self.wheelsound)
			end
			--[[self.windsound = minetest.sound_play("wind", {
				max_hear_distance = 10,
				object = self.object,
				pitch = 1 + (abs_v/def.max_speed)*.6,
				gain = 0 + (abs_v/def.max_speed)*4
			})--]]
		end
		self.timer2 = 0
	end
	if self.siren ~= nil then
		self.timer3 = self.timer3 + dtime
		if self.timer3 > (def.sirenlength or 2) then
			if type(self.siren) == "number" then
				minetest.sound_stop(self.siren)
			end
			self.siren = minetest.sound_play(def.siren, {
				max_hear_distance = 48,
				object = self.object,
				gain = 2
			})
			self.timer3 = 0
		end
	end
end

function car_rightclick(self, clicker, closeid)
	if not clicker or not clicker:is_player() then
		return
	end
	local name = clicker:get_player_name()
	if player_attached[name] and player_attached[name] ~= self then
		return
	end
	if not closeid then closeid = getClosest(clicker, self) end
	if not player_attached[name] then
		if self.locked then return end
		local i = 0
		--knockout support
		if knockout then
			local Cname = knockout.carrying[name]
			if Cname and minetest.get_player_by_name(Cname) and (knockout.downedplayers and not knockout.downedplayers[Cname]) then
				knockout.wake_up(Cname)
				minetest.after(.1, function() car_rightclick(self, minetest.get_player_by_name(Cname), closeid) end)
				return
			end
		end
		--medical support
		if medical then
			local draggedname = medical.is_dragging(name)
			if draggedname and minetest.get_player_by_name(draggedname) then
				medical.detach(draggedname, name)
				minetest.after(.1, function() car_rightclick(self, minetest.get_player_by_name(draggedname), closeid) end)
				return
			end
		end
		if DEBUG_TEXT then
			minetest.chat_send_all(tostring(closeid))
		end
		if closeid then
			if closeid == 0 then
				if self.trunklock == nil or clicker:get_wielded_item():get_meta():get_string("secret") == self.secret then
					--[[local yaw = self.object:get_yaw()
					local def = cars_registered_cars[self.name]
					local pos = self.object:get_pos()
					if not minetest.line_of_sight(pos, vector.add(pos, vector.multiply(vector.rotate(def.trunkloc, {x=0,y=yaw,z=0}), .1))) then
						return
					end--]]
					minetest.sound_play("opentrunk", {
						max_hear_distance = 24,
						gain = 1,
						object = self.object
					}, true)
					trunk_rightclick(self, clicker)
				end
				return
			end
			if not self.passengers[closeid].player then
				i = closeid
			end
		else
			while i <= #self.passengers do
				i = i + 1
				if not self.passengers[i].player then break end
			end
		end
		if i == 0 or i == #self.passengers+1 then return end
		self.passengers[i].player = clicker
		--add hud for driver
		if i == 1 then
			self.hud = clicker:hud_add({
				 hud_elem_type = "text",
				 position      = {x = 0.5, y = 0.8},
				 offset        = {x = 0,   y = 0},
				 text          = tostring(math.abs(math.floor(self.v*2.23694*10)/10)).." MPH",
				 alignment     = {x = 0, y = 0},  -- center aligned
				 scale         = {x = 100, y = 100}, -- covered later
				 number    = 0xFFFFFF,
			})
		end
		
		player_attached[name] = self
		--[[local obj = minetest.add_entity(self.object:get_pos(), "cars:seat")
		obj:set_attach(self.object, "", self.passengers[i].loc, {x = 0, y = 0, z = 0})
		clicker:set_attach(obj, "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
		clicker:set_eye_offset({x=0,y=-6,z=0}, {x=0,y=0,z=0})--]]
		clicker:set_attach(self.object, "",
			self.passengers[i].loc, self.passengers[i].rot or {x = 0, y = 0, z = 0})
		clicker:set_eye_offset(self.passengers[i].offset, {x=0,y=0,z=0})
		default.player_attached[name] = true
		minetest.after(.1, function()
			default.player_set_animation(clicker, "sit" , 30)
		end)
		clicker:set_look_horizontal(get_yaw(self.object:get_yaw()))
	elseif closeid ~= 0 then
		if closeid == 1 and self.passengers[1].player == clicker then
			driver_rightclick(self, clicker)
		else
			if not self.passengers[closeid].player then
				car_forms[name] = closeid
				minetest.show_formspec(name, "cars_form", seat_formspec(true))
			else
				minetest.show_formspec(name, "cars_form", seat_formspec())
			end
		end
	end
end

--car lockpicking
local carlockpicktbl = {}

local function pick_car(digger, obj)
	local car = obj:get_luaentity()
	local pos = obj:get_pos()
	local name = digger:get_player_name()
	local can_pick = true
	local tool_group = digger:get_wielded_item():get_tool_capabilities()
	if not minetest.check_player_privs(name, {lockpick=true}) then
		can_pick = false
		minetest.chat_send_player(name, "You do not have the lockpick priv.")
	end
	if can_pick then
		local wielditem = digger:get_wielded_item()
		local wieldlevel = tool_group.max_drop_level
		local rand = math.random(1,10)
		if rand == 1 or car.owner == name then
			car.locked = false
			minetest.sound_play("lock", {
				max_hear_distance = 32,
				gain = 1,
				object = obj
			}, true)
			minetest.chat_send_player(name, "You picked the lock!")
			minetest.log("action", name.." picked "..car.name.." with "..digger:get_wielded_item():get_name().." at "..minetest.pos_to_string(pos))
			if playercontrol_set_timer then
				local privs = minetest.get_player_privs(name)
				privs.lockpick = nil
				minetest.set_player_privs(name, privs)
				playercontrol_set_timer(name, "lockpick", 2*60)
			end
		elseif rand == 2 then
			wielditem:clear()
			digger:set_wielded_item(wieldeditem)
			minetest.chat_send_player(name, "Your lockpick broke!")
		else
			minetest.chat_send_player(name, "You failed to pick the lock.")
		end
		return false
	end
end

minetest.register_globalstep(function(dtime)
	for name, tbl in pairs(carlockpicktbl) do
		local player = minetest.get_player_by_name(name)
		if (os.clock()-tbl.last) > .25 or not player then
			carlockpicktbl[name] = nil
		else
			carlockpicktbl[name].timer = carlockpicktbl[name].timer + dtime
			if carlockpicktbl[name].timer > 6 then
				pick_car(player, carlockpicktbl[name].obj)
				carlockpicktbl[name] = nil
			end
		end
	end
end)

cars_registered_cars = {}
function cars_register_car(def)
	cars_registered_cars[def.name] = def
	minetest.register_entity(def.name, {
		initial_properties = def.initial_properties,
		trunkinv = {},
		key = true,
		owner = "",
		on_deactivate = function(self, removal)
			if self.drillsound then
				minetest.sound_fade(self.drillsound, 10, 0)
			end
			if removal then
				for id, wheel in pairs(self.wheel) do
					wheel:remove()
				end
				if self.lights then
					self.lights:remove()
				end
				if self.skidsound then
					minetest.sound_fade(self.skidsound, 5, 0)
				end
				if self.siren and type(self.siren) == "number" then
					minetest.sound_fade(self.siren, 10, 0)
				end
				for id, passengers in pairs (self.passengers) do
					local player = passengers.player
					if player then
						detach(player)
					end
				end
				if self.platenumber then
					cars.set_database_entry(self.platenumber.text, nil)
				end
			end
		end,
		on_death = function(self, killer)--i think i wont need this since hp is always kept at least 1hp till its removed by the death timer
			for id, wheel in pairs(self.wheel) do
				wheel:remove()
			end
			if self.lights then
				self.lights:remove()
			end
			if self.skidsound then
				minetest.sound_fade(self.skidsound, 5, 0)
			end
			if self.siren and type(self.siren) == "number" then
				minetest.sound_fade(self.siren, 10, 0)
			end
			for id, passengers in pairs (self.passengers) do
				local player = passengers.player
				if player then
					detach(player)
				end
			end
			if self.platenumber then
				cars.set_database_entry(self.platenumber.text, nil)
			end
		end,
		on_activate = function(self, staticdata)
			if not self.wheelpos then self.wheelpos = 0 end
			if not self.timer1 then self.timer1 = 0 end
			if not self.timer2 then self.timer2 = 0 end
			if not self.hp then self.hp = 20 end
			if not self.gas then self.gas = 0 end
			if not self.battery then self.battery = 600 end
			if not self.platenumber then
				self.platenumber = {}
			end
			self.passengers = table.copy(def.passengers)
			if staticdata then
				local deserialized = minetest.deserialize(staticdata)
				if deserialized then
					self.owner = deserialized.owner or ""
					self.secret = deserialized.secret
					self.locked = deserialized.locked
					self.trunkinv = deserializeContents(deserialized.trunk)
					self.key = deserialized.key
					self.hp = deserialized.hp or 20
					self.gas = deserialized.gas or 0
					self.battery = deserialized.battery or 600
					self.cruise = (deserialized.cruise and 0)
					self.color = deserialized.color
					self.trunklock = deserialized.trunklock
					self.text = deserialized.text
					self.textcolor = deserialized.textcolor
					self.deathtime = deserialized.deathtime
					if deserialized.plate then
						self.platenumber.text = deserialized.plate.text
					end
				elseif minetest.get_player_by_name(staticdata) then
					self.owner = staticdata
				end
			end
			if not self.secret then
				local random = math.random
				self.secret = string.format(
					"%04x%04x%04x%04x",
					random(2^16) - 1, random(2^16) - 1,
					random(2^16) - 1, random(2^16) - 1)
			end
			if not self.platenumber.text or self.platenumber.text == "" then
				self.platenumber.text = randomNumber(3).."-"..randomString(3)
				local color = "Unpainted"
				if self.color then
					color = cars_dyes[self.color][3]
				end
				cars.set_database_entry(self.platenumber.text, {color = color, owner = self.owner, desc = def.description})
			end
			updatetextures(self, def)
			self.object:setacceleration({x=0, y=-10, z=0})
			--self.object:set_armor_groups({immortal = 1})
			self.object:set_armor_groups({vehicle = 100})
			self.wheel = {}
			wheelspeed(self)
			local pos = self.object:get_pos()
			for index, wheel in pairs(def.wheel) do
				if not self.wheel[index] then
					self.wheel[index] = minetest.add_entity(pos, def.wheelname or "cars:wheel")
				end
				if self.wheel[index] then
					self.wheel[index]:set_attach(self.object, "", wheel, {x=0,y=0,z=0})
				end
			end
			if not self.lights and def.lights then
				self.lights = minetest.add_entity(pos, "cars:"..def.lights.."lights")
			end
			if self.lights then
				self.lights:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
			end
			if def.extension and def.extensionname and not self.extension then
				self.extension = minetest.add_entity(pos, def.extensionname)
			end
			if self.extension then
				self.extension:set_attach(self.object, "", def.extension, {x=0,y=0,z=0})
			end
			if self.hp < 1 then self.hp = 1 end
			self.object:set_hp(self.hp)
			local halfmax = (def.initial_properties.hp_max or 20)/2
			if self.hp < halfmax then
				local smoketex = "tnt_smoke.png"
				if self.hp == 1 then smoketex = "fire_basic_flame.png" end
				self.enginesmoke = minetest.add_particlespawner({
					amount = 1,
					time = 0,
					minpos = def.engineloc or {x=0,y=.6,z=2},
					maxpos = def.engineloc or {x=0,y=.6,z=2},
					minvel = {x=-.3, y=.6, z=-.3},
					maxvel = {x=.3, y=.8, z=.3},
					minexptime = 2,
					maxexptime = 3,
					minsize = 9,
					maxsize = 11,
					collisiondetection = true,
					attached = self.object,
					vertical = false,
					texture = smoketex,
				})
			end
		end,
		get_staticdata = function(self)
			return minetest.serialize({
				owner = self.owner,
				trunk = serializeContents(self.trunkinv),
				secret = self.secret,
				locked = self.locked,
				key = self.key,
				plate = self.platenumber,
				hp = self.hp,
				gas = self.gas,
				battery = self.battery,
				color = self.color,
				cruise = self.cruise,
				trunklock = self.trunklock,
				text = self.text,
				textcolor = self.textcolor,
				deathtime = self.deathtime
			})
		end,
		on_step = car_step,
		on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
			local name = puncher:get_player_name()
			if puncher ~= self.object and not tool_capabilities.damage_groups.vehicle then
				if puncher == self.passengers[1].player then
					minetest.sound_play(def.horn, {
						max_hear_distance = 48,
						gain = 8,
						object = self.object
					}, true)
					return true
				end
				local punchstack = puncher:get_wielded_item()
				local punchitem = punchstack:get_name()
				if oil and name and oil.fueling[name] then
					local data = oil.fueling[name]
					local obj = oil.fueling[name].obj
					local pos = oil.fueling[name].pos
					minetest.get_node_timer(pos):start(1)
					local meta = minetest.get_meta(pos)
					meta:set_string("name", name)
					if obj then
						local ent = obj:get_luaentity()
						if ent then
							ent.finishobj = self.object
							if def.gas_offset then
								ent.finishoffset = def.gas_offset
							end
						else
							oil.stopfuel(name)
						end
					end
				elseif holdingtowlines[name] and not self.towline then
					local ent = holdingtowlines[name]
					ent.finishobj = self.object
					local offset = vector.multiply(def.wheel.frontright, .1)
					offset.x = 0
					ent.finishoffset = offset
					ent.length = vector.distance(ent.start, self.object:get_pos()) + 4
					self.towline = ent
					holdingtowlines[name] = nil
				elseif (punchitem == "") and (time_from_last_punch >= tool_capabilities.full_punch_interval) and math.random(1,2) == 1 then
					local closeid = getClosest(puncher, self)
					if DEBUG_TEXT then
						minetest.chat_send_all(tostring(closeid))
					end
					if not closeid or closeid == 0 then return true end
					if self.passengers[closeid].player then
						detach(self.passengers[closeid].player)
					elseif cuffedplayers then
						local pos = self.object:get_pos()
						for name, val in pairs (cuffedplayers) do
							local player = minetest.get_player_by_name(name)
							if player and vector.distance(player:get_pos(), pos) < 2 then
								car_rightclick(self, player, closeid)
								break
							end
						end
					end
				elseif punchitem == made_key then
					local secret = puncher:get_wielded_item():get_meta():get_string("secret")
					if self.secret == secret then
						self.locked = not self.locked
						minetest.sound_play("lock", {
							max_hear_distance = 6,
							gain = 1,
							object = self.object
						}, true)
					end
				elseif punchitem == skel_key and (self.owner == name or (jobs and jobs.permissionstring(name, self.owner))) then
					local inv = minetest.get_inventory({type="player", name=name})
					-- update original itemstack
					punchstack:take_item()
					-- finish and return the new key
					local new_stack = ItemStack(made_key)
					local meta = new_stack:get_meta()
					local description = def.description
					if self.color then
						description = cars_dyes[self.color][3].." "..description
					end
					if self.platenumber and self.platenumber.text then
						description = description.." "..self.platenumber.text
					end
					meta:set_string("secret", self.secret)
					meta:set_string("description", string.format("Key to %s's %s", self.owner, description))

					if punchstack:get_count() == 0 then
						punchstack = new_stack
					else
						if inv:add_item("main", new_stack):get_count() > 0 then
							minetest.add_item(user:get_pos(), new_stack)
						end -- else: added to inventory successfully
					end
					minetest.after(0, function() puncher:set_wielded_item(punchstack) end)
				elseif not self.color and def.initial_properties.textures[3] ~= nil then
					local color = string.sub(punchitem, 5)
					if color and cars_dyes[color] and punchstack:get_count() >= (def.dyecost or 5) then
						self.color = color
						cars.set_database_entry(self.platenumber.text, {color = cars_dyes[color][3], owner = self.owner, desc = def.description})
						updatetextures(self, def)
						punchstack:take_item(def.dyecost or 5)
						minetest.after(0, function() puncher:set_wielded_item(punchstack) end)
					end
				elseif tool_capabilities.groupcaps and tool_capabilities.groupcaps.locked and tool_capabilities.groupcaps.locked.maxlevel and tool_capabilities.groupcaps.locked.maxlevel > 1 then
					if not carlockpicktbl[name] or carlockpicktbl[name].obj ~= self.object then
						carlockpicktbl[name] = {obj = self.object, last = os.clock(), timer = 0}
					else
						carlockpicktbl[name].last = os.clock()
					end
				end
				--[[
				elseif player_attached[name] ~= self then
					--minetest.chat_send_all("ow")
					return true
				else
					return true
				end
				return true--]]
			end
			if not tool_capabilities.damage_groups.vehicle then return true end
			if self.enginesmoke then
				minetest.delete_particlespawner(self.enginesmoke)
				self.enginesmoke = nil
			end
			local hp = self.object:get_hp() - tool_capabilities.damage_groups.vehicle
			self.hp = hp
			local halfmax = (def.initial_properties.hp_max or 20)/2
			if self.hp < halfmax then
				local smoketex = "tnt_smoke.png"
				if self.hp == 1 then smoketex = "fire_basic_flame.png" end
				self.enginesmoke = minetest.add_particlespawner({
					amount = 1,
					time = 0,
					minpos = def.engineloc or {x=0,y=.6,z=2},
					maxpos = def.engineloc or {x=0,y=.6,z=2},
					minvel = {x=-.3, y=.6, z=-.3},
					maxvel = {x=.3, y=.8, z=.3},
					minexptime = 2,
					maxexptime = 3,
					minsize = 9,
					maxsize = 11,
					collisiondetection = true,
					attached = self.object,
					vertical = false,
					texture = smoketex,
				})
			end
			if hp <= 1 then
				if not self.deathtime then
					self.deathtime = os.time()
				end
				if hp < 1 then
					self.hp = 1
					self.object:set_hp(self.hp)
					return true
				end
			end
			if self.deathtime and hp > 1 then
				self.deathtime = nil
			end
		end,
		on_rightclick = function(self, clicker)
			car_rightclick(self, clicker)
		end
	})
	minetest.register_craftitem(def.name, {
		description = def.description,
		inventory_image = def.inventory_image,
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return
			end
			local ent
			if minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "liquid") == 0 then
				pointed_thing.above.y = pointed_thing.above.y - 0.5
				ent = minetest.add_entity(pointed_thing.above, def.name, placer:get_player_name())
			end
			ent:setyaw(placer:get_look_yaw() - math.pi/2)
			itemstack:take_item()
			return itemstack
		end
	})
	if def.recipe then
		minetest.register_craft({
			output = def.name,
			recipe = def.recipe
		})
	end
	if def.lights then
		register_lightentity(def.lights)
	end
end

function cars_register_wheel(name, def)
	if not def then def = {} end
	for defname, val in pairs({
		hp_max = 1,
		physical = false,
		pointable = false,
		is_visible = true,
		visual = "mesh",
		mesh = "wheel.x",
		textures = {"car_dark_grey.png"},
		on_activate = function(self, staticdata, dtime_s)
			minetest.after(.1, function()
				if not self.object:get_attach() then
					self.object:remove()
				end
			end)
		end,})
	do
		if not def[defname] then def[defname] = val end
	end
	minetest.register_entity(name, def)
end

cars_register_wheel("cars:wheel")

function cars_register_extension(name, def)
	if not def then def = {} end
	for defname, val in pairs({
		hp_max = 1,
		physical = true,
		collisionbox = {-1, -0.05, -1, 1, 1.2, 1},
		visual = "sprite",
		visual_size = {x=1, y=1},
		textures = {"invisible.png"},
		is_visible = true,
		on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
			local parent = self.object:get_attach()
			if not parent then
				self.object:remove()
				return
			end
			parent:punch(puncher, time_from_last_punch, tool_capabilities, dir)
		end,
		on_rightclick = function(self, clicker)
			local parent = self.object:get_attach()
			if not parent then
				self.object:remove()
				return
			end
			local name = clicker:get_player_name()
			parent = parent:get_luaentity()
			if false and default.player_attached[name] and clicker:get_attach() and clicker:get_attach() == parent.object then
				for id, info in pairs(parent.passengers) do
					if info.player and name == info.player:get_player_name() then
						car_rightclick(parent, clicker, id)
					end
				end
			else
				car_rightclick(parent, clicker, getClosest(clicker, parent, 1))
			end
		end,
		on_activate = function(self, staticdata, dtime_s)
			minetest.after(.1, function()
				if not self.object:get_attach() then
					self.object:remove()
					return
				end
				self.object:set_armor_groups({immortal = 1})
			end)
		end,})
	do
		if not def[defname] then def[defname] = val end
	end
	minetest.register_entity(name, def)
end

minetest.register_on_leaveplayer(function(player)
	detach(player)
end)
minetest.register_on_dieplayer(function(player)
	detach(player)
end)

dofile(minetest.get_modpath("cars").."/car01.lua")
dofile(minetest.get_modpath("cars").."/newcars.lua")
dofile(minetest.get_modpath("cars").."/nodecraft.lua")
dofile(minetest.get_modpath("cars").."/welding.lua")
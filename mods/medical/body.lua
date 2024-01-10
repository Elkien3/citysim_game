--[[we use the actual player now
minetest.register_entity("medical:body", {
	hp_max = 1,
	physical = true,
	collide_with_objects = false,
	weight = 5,
	collisionbox = {-0.7, 0, -0.7, 0.7, .2, 0.7},
	visual = "mesh",
	mesh = "character.b3d",
	textures = {"character.png"},
	is_visible = true,
	makes_footstep_sound = false,
    automatic_rotate = false,
    on_activate = function(self, staticdata, dtime_s)
		if not staticdata or staticdata == "" then staticdata = "sparky" end--return end
		self.object:set_acceleration({x=0, y=-10, z=0})
		self.owner = staticdata
		self.object:set_animation({x=162,y=167}, 1)
		self.object:set_armor_groups({immortal = 1})
		self.object:set_yaw(math.random(-math.pi, math.pi)) --todo: have a set rotation value
		medical.init_injuries(self)
    end,
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if not puncher:is_player() then return end
		local name = puncher:get_player_name()
		if medical.timers[name] ~= nil then return end
		local wielditem = puncher:get_wielded_item()
		local wieldname = wielditem:get_name()
		local hitloc, local_hitloc = medical.gethitloc(self.object, puncher, tool_capabilities, dir)
		local hitlimb = medical.getlimb(self.object, puncher, tool_capabilities, dir, hitloc)
		--minetest.chat_send_all(hitlimb)
		if not puncher:get_player_control(puncher).sneak and medical.attachedtools[wieldname] and medical.attachedtools[wieldname](self, puncher, wielditem, hitloc, local_hitloc) then
		
		elseif medical.data[name].injuries and medical.data[name].injuries[hitlimb] then
			medical.injury_handle(self.owner, puncher, false, wieldname, hitlimb)--todo maybe make this return a value so if you punch it'll damage
		else
			return false
		end
		-- attach things
    end,
    on_rightclick = function(self, clicker)
		local name = clicker:get_player_name()
		if medical.timers[name] ~= nil then return end
		local wielditem = clicker:get_wielded_item()
		local wieldname = wielditem:get_name()
		local hitloc, local_hitloc = medical.gethitloc(self.object, clicker, nil, nil)
		local hitlimb = medical.getlimb(self.object, clicker, tool_capabilities, dir, hitloc)
		if not clicker:get_player_control(clicker).sneak and medical.usedtools[wieldname] and medical.usedtools[wieldname](self, clicker, wielditem, hitloc, local_hitloc) then
		
		elseif medical.data[name].injuries and medical.data[name].injuries[hitlimb] then
			medical.injury_handle(self.owner, clicker, true, wieldname, hitlimb)
		end
		-- use things
    end
})
--]]
if minetest.get_modpath("3d_armor") then
	local modeldef = table.copy(player_api.registered_models["3d_armor_character.b3d"])
	modeldef.animations.recumbantright = {x = 223,  y = 224}
	modeldef.animations.recumbantleft =  {x = 225,  y = 226}
	player_api.register_model("3d_armor_medical_character.b3d", modeldef)
	minetest.register_on_joinplayer(function(player)
		player_api.set_model(player, "3d_armor_medical_character.b3d")
		--default.player_set_model(player, "3d_armor_medical_character.b3d")
	end)
else
	local modeldef = table.copy(player_api.registered_models["character.b3d"])
	modeldef.animations.recumbantright = {x = 223,  y = 224}
	modeldef.animations.recumbantleft =  {x = 225,  y = 226}
	player_api.register_model("medical_character.b3d", modeldef)
	minetest.register_on_joinplayer(function(player)
		player_api.set_model(player, "medical_character.b3d")
		--default.player_set_model(player, "medical_character.b3d")
	end)
end
--[[player_api.registered_models["character.b3d"].animations.recumbantright = {x = 223,  y = 224}
player_api.registered_models["character.b3d"].animations.recumbantleft =  {x = 225,  y = 226}
if player_api.registered_models["3d_armor_character.b3d"] then
	player_api.registered_models["3d_armor_character.b3d"].animations.recumbantright = {x = 223,  y = 224}
	player_api.registered_models["3d_armor_character.b3d"].animations.recumbantleft =  {x = 225,  y = 226}
end--]]
local dragging_tbl = {}--indexed by dragger name, draggee name is value

function medical.is_dragging(name)
	return dragging_tbl[name]
end

function medical.detach(name, cname)
	if not cname then
		for cname2, name2 in pairs(dragging_tbl) do
			if name2 == name then
				cname = cname2
			end
		end
	end
	if not cname then return end
	local drag_player = minetest.get_player_by_name(name)
	local dragging_player = minetest.get_player_by_name(cname)
	if drag_player then
		drag_player:set_detach()
		if not default.player_attached[name] then
			minetest.add_entity(drag_player:get_pos(), "medical:unconsciousattach", name)
		end
		local draggeryaw = dragging_player:get_look_horizontal()
		draggeryaw = draggeryaw-math.pi
		if draggeryaw < -math.pi then dragger = draggeryaw+(2*math.pi) end
		drag_player:set_look_horizontal(draggeryaw)
	end
	dragging_tbl[cname] = nil
end

if beds then
	local original = beds.on_rightclick
	beds.on_rightclick = function(pos, player)
		local cname = player:get_player_name()
		local name = dragging_tbl[cname]
		local newplayer = player
		if name and minetest.get_player_by_name(name) then
			newplayer = minetest.get_player_by_name(name)
			default.player_attached[name] = true
			medical.detach(name, cname)
		end
		return original(pos, newplayer)
	end
end

controls.register_on_press(function(player, key)
	local name = player:get_player_name()
	if dragging_tbl[name] and key == "jump" then
		default.player_attached[dragging_tbl[name]] = nil
		medical.detach(dragging_tbl[name], name)
	end
end)

minetest.register_on_leaveplayer(function(player, timed_out)
	local name = player:get_player_name()
	for cname, sname in pairs(dragging_tbl) do
		if cname == name or sname == name then
			medical.detach(sname, cname)
		end
	end
end)

minetest.register_on_respawnplayer(function(player)
	local name = player:get_player_name()
	for cname, sname in pairs(dragging_tbl) do
		if cname == name or sname == name then
			medical.detach(sname, cname)
		end
	end
end)

minetest.register_on_punchplayer(function(player, clicker, time_from_last_punch, tool_capabilities, dir, damage)
	local name = player:get_player_name()
	local cname = clicker:get_player_name()
	if medical.timers[cname] ~= nil then return true end
	local wielditem = clicker:get_wielded_item()
	local wieldname = wielditem:get_name()
	local hitloc, local_hitloc = medical.gethitloc(player, clicker, tool_capabilities, dir)
	local hitlimb = medical.getlimb(player, clicker, tool_capabilities, dir, hitloc)
	--minetest.chat_send_all(hitlimb)
	if not clicker:get_player_control(clicker).sneak and medical.attachedtools[wieldname] and medical.attachedtools[wieldname](player, clicker, wielditem, hitloc, local_hitloc) then
	elseif medical.data[name].injuries and medical.data[name].injuries[hitlimb] then
		return medical.injury_handle(player, clicker, false, wieldname, hitlimb)
	else
		return false
	end
	return true
end)

minetest.register_on_rightclickplayer(function(player, clicker)
	local name = player:get_player_name()
	local cname = clicker:get_player_name()
	if medical.timers[cname] ~= nil then return end
	local wielditem = clicker:get_wielded_item()
	local wieldname = wielditem:get_name()
	
	if wieldname == "" and (medical.data[name].unconscious or (is_player_tased and is_player_tased(name))) and clicker:get_player_control().sneak then--use sneak to drag
		local isdragged = false
		for cname2, name2 in pairs(dragging_tbl) do
			if name == name2 then
				isdragged = true
				break
			end
		end
		if not isdragged then
			dragging_tbl[cname] = name
			player:set_attach(clicker, "", {x = 0, y = 0, z = 12}, {x = 0, y = 0, z = 0}, true)
			default.player_attached[name] = true
			player_api.set_animation(player, "lay")
		end
		return
	end
	
	local hitloc, local_hitloc = medical.gethitloc(player, clicker, nil, nil)
	local hitlimb = medical.getlimb(player, clicker, tool_capabilities, dir, hitloc)
	if not clicker:get_player_control(clicker).sneak and medical.usedtools[wieldname] and medical.usedtools[wieldname](player, clicker, wielditem, hitloc, local_hitloc) then
	
	elseif medical.data[name].injuries and medical.data[name].injuries[hitlimb] and medical.injury_handle(player, clicker, true, wieldname, hitlimb) then
		--lol nothin
	else
		if wieldname == "" and (medical.data[name].unconscious or (is_player_tased and is_player_tased(name))) then--inventory access
			local allowfunc = function(inv, listname, index, stack, player2, count)
				if not minetest.get_player_by_name(name) or (not medical.data[name] or not medical.data[name].unconscious) or vector.distance(player:get_pos(), clicker:get_pos()) > 10 then return 0 end
				if count then
					return count
				else
					return stack:get_count()
				end
			end
			local player_inv = minetest.get_inventory({type='player', name = name}) --InvRef
			local detached_inv = minetest.create_detached_inventory(name, {
				on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
					player_inv:set_list('main', inv:get_list('main'))
					player_inv:set_list('craft', inv:get_list('craft'))
				end,
				on_put = function(inv, listname, index, stack, player)
					player_inv:set_list('main', inv:get_list('main'))
					player_inv:set_list('craft', inv:get_list('craft'))
				end,
				on_take = function(inv, listname, index, stack, player)
					player_inv:set_list('main', inv:get_list('main'))
					player_inv:set_list('craft', inv:get_list('craft'))
				end,
				allow_move = allowfunc,
				allow_put = allowfunc,
				allow_take = function(inv, listname, index, stack, player2)
					local returnval = allowfunc(inv, listname, index, stack, player2, count)
					if returnval == 0 then return returnval end
					medical.data[name].owner = name
					if not bones_take_one or bones_take_one(medical.data[name], player2, stack) then
						return returnval
					end
					return 0
				end,
			}) --InvRef
			detached_inv:set_list('main', player_inv:get_list('main'))
			detached_inv:set_list('craft', player_inv:get_list('craft'))
			local formspec =
				'size[8,12]' ..
				'label[0,0;' .. name.."'s inventory]"..
				'list[detached:'.. name..';craft;3,0;3,3;]'..
				'list[detached:'.. name..';main;0,4;8,4;]'..
				"list[current_player;main;0,8;8,4;]"..
				"listring[]"
			if minetest.get_inventory({type="detached", name=name.."_armor"}) then
				formspec = formspec.."list[detached:"..name.."_armor;armor;0,0.5;2,3;]"
			end
			minetest.show_formspec(cname, 'medical:inventory', formspec)
		end
	end
end)

local set_animation = player_api.set_animation
player_api.set_animation = function(player, anim_name, speed)
	local collisionboxes = {lay = {-.3, 0, -0.3, 0.3, 1.2, 0.3}, sit = {-.3, 0, -.3, .3, 1.2, .3}}
	local selectionboxes = {lay = {-0.7, 0, -0.7, 0.7, .2, 0.7}, sit = {-.3, 0, -.3, .3, 1.2, .3}}
	local defaultbox = {-.3, 0, -.3, .3, 1.7, .3}
	collisionboxes.recumbantleft = collisionboxes.lay
	collisionboxes.recumbantright = collisionboxes.lay
	selectionboxes.recumbantleft = selectionboxes.lay
	selectionboxes.recumbantright = selectionboxes.lay
	if collisionboxes[anim_name] then
		player:set_properties({collisionbox = collisionboxes[anim_name], selectionbox = selectionboxes[anim_name]})
		local parent = player:get_attach()
		if parent and parent:get_luaentity() and parent:get_luaentity().name == "medical:unconsciousattach" then
			parent:set_properties({collisionbox = collisionboxes[anim_name], selectionbox = selectionboxes[anim_name]})
		end
	elseif table.concat(player:get_properties().collisionbox) ~= table.concat(defaultbox) then
		player:set_properties({collisionbox = defaultbox, selectionbox = defaultbox})
		local parent = player:get_attach()
		if parent and parent:get_luaentity() and parent:get_luaentity().name == "medical:unconsciousattach" then
			parent:set_properties({collisionbox = defaultbox, selectionbox = defaultbox})
		end
	end
	if speed == 0 then speed = 1 end--fix bug with character_anim not liking speed to be 0
	return set_animation(player, anim_name, speed)
end

default.player_set_animation = player_api.set_animation

local injuryrot = {Arm_Right = {x=180,y=0,z=0}, Arm_Left = {x=180,y=0,z=0}, Leg_Right = {x=180,y=0,z=0}, Leg_Left = {x=180,y=0,z=0},
	Back = {x=0,y=180,z=0}}
local injurypos = {Head = {x=0,y=3,z=-1.2}, Body = {x=0,y=3,z=-.1}, Back = {x=0,y=3,z=.1}}

function medical.add_injury_ent(player, bone, injury)
	local name = player:get_player_name()
	--local injurydef = medical.injuries[injury.name]
	local pos = player:get_pos()
	local obj = minetest.add_entity(pos, "medical:injury", minetest.serialize({owner = name, bone = bone, injury = injury}))
	local rot = injuryrot[bone] or {x=0,y=0,z=0}
	pos = injurypos[bone] or {x=0, y=2, z=0}
	if not medical.entities[name] then medical.entities[name] = {} end
	if medical.entities[name][bone] then
		medical.entities[name][bone]:remove()
	end
	medical.entities[name][bone] = obj
	if bone == "Back" then bone = "Body" end--just for attach
	obj:set_attach(player, bone, pos, rot)
	medical.effect_handle(player)
end
function medical.init_injuries(player)
	local name = player:get_player_name()
	local data = medical.data[name]
	if medical.data[name].injuries then
		for bone, injury in pairs (medical.data[name].injuries) do
			medical.add_injury_ent(player, bone, injury)
		end
	end
end

minetest.register_on_leaveplayer(function(player, timed_out)
	local name = player:get_player_name()
	if medical.entities[name] then
		for bone, obj in pairs(medical.entities[name]) do
			obj:remove()
		end
		medical.entities[name] = nil
	end
end)

local speedgun = {}

local function getspeed(player)
	local eye_offset = {x = 0, y = 1.45, z = 0}
	local dir = player:get_look_dir()
	local p1 = vector.add(player:get_pos(), eye_offset)
	local p2 = vector.add(p1, vector.multiply(dir, 200))
	local ray = minetest.raycast(p1, p2)
	local pointed = ray:next()
	if pointed and pointed.ref and pointed.ref == player then
		pointed = ray:next()
	end
	if pointed and pointed.type == "object" then
		local target = pointed.ref
		local v = target:get_velocity() or {x=0,y=0,z=0}
		if target:is_player() then
			v = target:get_player_velocity() or {x=0,y=0,z=0}
		end
		return vector.length(v)
	end
	return 0
end

local function dospeed(player, name)
	if not player or not player:is_player() then speedgun[name] = nil end
	if not name then speedgun[name] = nil end
	if not speedgun[name] then return end
	local speed = getspeed(player)
	if speed > speedgun[name] then
		speedgun[name] = speed
	end
	minetest.sound_play("speedgun", {
		object = player,
		max_hear_distance = 8,
		pitch = speed/60+.5,
		gain = .1
	})
	if player:get_player_control().LMB then
		minetest.after(.2, dospeed, player, name)
	else
		minetest.chat_send_player(name, "Speed gun reads "..tostring(math.floor(speedgun[name]*2.237*10)*.1).." MPH")
		speedgun[name] = nil
	end
end

minetest.register_tool('policetools:speedgun', {
	description = ('Speed Gun'),
	inventory_image = 'policetools_speedgun.png',
	on_use = function(stack, player, pointedThing)
		local name = player:get_player_name()
		speedgun[name] = getspeed(player)
		minetest.after(.1, dospeed, player, name)
	end,
})
minetest.register_craft({
	output = 'policetools:speedgun',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', ''},
		{'default:glass', 'mesecons_torch:mesecon_torch_on', 'default:steel_ingot'},
		{'dye:red', 'default:steel_ingot',''},
	}
})

if knockout or medical then
	local tasertbl = {}
	local is_tased = {}
	function is_player_tased(name)
		if not name then return end
		return is_tased[name] ~= nil
	end
	local probe = {
		initial_properties = {
			physical = true,
			pointable = false,
			visual = "sprite",
			textures = {"policetools_taser_prong.png"},
			visual_size = {x=.02, y=.02},
			collisionbox = {-0.01, -0.01, -0.01, 0.01, 0.01, 0.01}
		},
		on_step = function(self, dtime, moveresult)
			if not self.owner or not tasertbl[self.owner] or not minetest.get_player_by_name(self.owner) then self.object:remove() return end
			for i, coltbl in pairs(moveresult.collisions) do
				if coltbl.type == "object" then
					local target = coltbl.object
					if target:is_player() and target:get_armor_groups().fleshy == 100 then
						if tasertbl[self.owner].hit then
							if tasertbl[self.owner].hit == target then
								if math.random(math.ceil(vector.distance(target:get_pos(), minetest.get_player_by_name(self.owner):get_pos()))) ~= 1 then
									local droppedstack = minetest.item_drop(target:get_wielded_item(), target, target:get_pos())
									target:set_wielded_item(droppedstack or ItemStack())
									if knockout then
										knockout.knockout(target:get_player_name(), 7)
									else
										local tname = target:get_player_name()
										interacthandler.revoke(tname)
										is_tased[tname] = self.owner
										player_api.set_animation(target, "lay")
										target:set_eye_offset({x=0, y=-13, z=0}, {x=0, y=0, z=0})
										if not default.player_attached[tname] then
											minetest.add_entity(target:get_pos(), "medical:unconsciousattach", tname)
										end
										minetest.after(7, function()
											if is_tased[tname] and is_tased[tname] == self.owner then
												target:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
												is_tased[tname] = nil
												interacthandler.grant(tname)
												if target and target:get_player_name() then
													local parent = target:get_attach()
													if parent and parent:get_luaentity() and parent:get_luaentity().name == "medical:unconsciousattach" then
														parent:remove()
													else
														medical.detach(tname)
													end
												end
												player_api.set_animation(target, "stand")
											end
										end)
									end
								end
							end
						else
							tasertbl[self.owner].hit = target
						end
					end
				end
			end
			if vector.distance(self.object:get_pos(), minetest.get_player_by_name(self.owner):get_pos()) > 10 or moveresult.collides then
				self.object:remove()
			end
		end,
		on_activate = function(self, staticdata)
			if not staticdata or staticdata == "" then
				self.object:remove()
			else
				self.owner = staticdata
			end
		end
	}
	minetest.register_entity("policetools:taser_probe", probe)

	minetest.register_tool('policetools:taser', {
		description = ('Taser'),
		inventory_image = 'policetools_taser.png',
		on_use = function(stack, player, pointedThing)
			local name = player:get_player_name()
			local dir = player:get_look_dir()
			local yaw = player:get_look_horizontal()
			if tasertbl[name] then return end
			tasertbl[name] = {}
			
			local pos = player:get_pos()
			pos.y = pos.y + 1.45
			local offset = player:get_eye_offset()
			offset = vector.rotate(offset, {x=0,y=yaw, z=0})
			pos = vector.add(pos, offset)
			
			local pos1 = vector.add(pos, vector.multiply(dir, .1))
			local obj1 = minetest.add_entity(pos1, "policetools:taser_probe", name)
			local r = math.random
			local inaccuracy = .5
			if obj1 then
				local randvel = vector.multiply(vector.normalize({x=r(-100,100), y=r(-100,100), z=r(-100,100)}), inaccuracy)
				obj1:set_velocity(vector.add(vector.multiply(dir, 30), randvel))
				tasertbl[name].obj1 = obj1
			end
			
			local dir2 = vector.rotate(dir, {x=0,y=-yaw,z=0})
			dir2 = vector.rotate(dir2, {x=-.01,y=yaw,z=0})
			local pos2 = vector.add(pos, vector.multiply(dir2, .1))
			dir2 = vector.rotate(dir, {x=0,y=-yaw,z=0})
			dir2 = vector.rotate(dir2, {x=-.1,y=yaw,z=0})
			local obj2 = minetest.add_entity(pos2, "policetools:taser_probe", name)
			if obj2 then
				local r = math.random
				local randvel = vector.multiply(vector.normalize({x=r(-100,100), y=r(-100,100), z=r(-100,100)}), inaccuracy)
				obj2:set_velocity(vector.add(vector.multiply(dir2, 30), randvel))
				tasertbl[name].obj2 = obj2
			end
			minetest.sound_play("taserdeploy", {
				object = player,
			})
			minetest.after(5, function()
				if tasertbl[name].obj1 then
					tasertbl[name].obj1:remove()
				end
				if tasertbl[name].obj2 then
					tasertbl[name].obj2:remove()
				end
				tasertbl[name] = nil
			end)
			stack:replace("policetools:taser_empty")
			return stack
		end,
	})
	
	minetest.register_tool('policetools:taser_empty', {
		description = ('Taser (empty)'),
		inventory_image = 'policetools_taser_empty.png',
	})
	
	minetest.register_craftitem("policetools:taser_cartridge", {
		description = ('Taser Cartridge'),
		inventory_image = 'policetools_taser_cartridge.png',
		stack_max = 2,
	})
	
	local mat1 = "default:paper"
	local mat2 = "default:paper"
	if minetest.get_modpath("basic_materials") then
		mat1 = "basic_materials:plastic_sheet"
		mat2 = "basic_materials:copper_wire"
	end
	
	minetest.register_craft({
		output = 'policetools:taser_cartridge 2',
		recipe = {
			{'default:mese_crystal_fragment', mat2, 'default:mese_crystal_fragment'},
			{mat1, 'tnt:gunpowder', mat1},
			{'', mat1,''},
		},
		replacements = {{"basic_materials:copper_wire", "basic_materials:empty_spool"}},
	})
	if minetest.get_modpath("assembler") then
		minetest.register_craft({
			output = 'policetools:taser_empty',
			recipe = {
				{'', 'basic_materials:plastic_sheet', 'basic_materials:plastic_sheet', 'basic_materials:steel_bar'},
				{'basic_materials:plastic_sheet', 'default:copper_ingot', 'default:copper_ingot', ''},
				{'basic_materials:plastic_sheet', 'technic:battery', 'basic_materials:plastic_sheet', 'basic_materials:steel_bar'},
				{'basic_materials:plastic_sheet', 'technic:battery', 'basic_materials:plastic_sheet', ''},
			}
		})
	else
		minetest.register_craft({
			output = 'policetools:taser_empty',
			recipe = {
				{'', 'default:steel_ingot', 'default:copper_ingot'},
				{'default:steel_ingot', 'default:mese_crystal', 'default:copper_ingot'},
				{'default:steel_ingot', 'default:steel_ingot',''},
			}
		})
	end
	
	minetest.register_craft({
		output = 'policetools:taser',
		type = "shapeless",
		recipe = {'policetools:taser_empty', 'policetools:taser_cartridge'},
	})
	minetest.register_craft({
		output = 'policetools:taser_empty',
		type = "shapeless",
		recipe = {'policetools:taser'},
		replacements = {{'policetools:taser', 'policetools:taser_cartridge'}},
	})
end

if minetest.get_modpath("character_anim") and minetest.get_modpath("player_api") then
	policetools_handsup = {}
	local function can_handsup(name)
		local player = minetest.get_player_by_name(name)
		if not player then return false end
		local disallowed_anims = {["lay"] = true, ["recumbantleft"] = true, ["recumbantright"] = true}
		local control = player:get_player_control()
		if player
			and player:get_wielded_item():get_name() == ""
			and not disallowed_anims[player_api.get_animation(player).animation]
			and not control.RMB and not control.LMB and not control.aux1
		then return true
		else return false
		end
	end
	minetest.register_globalstep(function(dtime)
		for name, val in pairs(policetools_handsup) do
			if not can_handsup(name) then
				local player = minetest.get_player_by_name(name)
				if player then
					player:hud_set_flags({wielditem=true})
					minetest.chat_send_player(name, "You put your hands down.")
				end
				policetools_handsup[name] = nil
			end
		end
	end)
	local chatcommand =  {
        params = "",  -- Short parameter description
        description = "Put your hands up. (hands must be empty)",  -- Full description
        func = function(name, param)
			local player = minetest.get_player_by_name(name)
			if policetools_handsup[name] then
				policetools_handsup[name] = nil
				player:hud_set_flags({wielditem=true})
				return true, "You put your hands down."
			else
				if can_handsup(name) then
					policetools_handsup[name] = true
					player:hud_set_flags({wielditem=false})
					return true, "You put your hands up."
				else
					return true, "You cannot put your hands up at this time."
				end
			end
        end
    }
	minetest.register_chatcommand("handsup", chatcommand)
	minetest.register_chatcommand("hu", chatcommand)
	if unified_inventory then
		unified_inventory.register_button("policetools_handsup", {
			type = "image",
			image = "policetools_handsup.png",
			tooltip = "Put your hands up (hands must be empty)",
			action = function(player)
				local name = player:get_player_name()
				if policetools_handsup[name] then
					policetools_handsup[name] = nil
					player:hud_set_flags({wielditem=true})
					minetest.chat_send_player(name, "You put your hands down.")
				else
					if can_handsup(name) then
						policetools_handsup[name] = true
						player:hud_set_flags({wielditem=false})
						minetest.chat_send_player(name, "You put your hands up.")
					else
						minetest.chat_send_player(name, "You cannot put your hands up at this time.")
					end
				end
			end,
		})
	end
end

minetest.register_tool("policetools:baton", {
	description = "Baton",
	inventory_image = "policetools_baton.png",--https://www.tynker.com/minecraft/items/view/wood_sword/police-baton/5870bc8c1c36d1c7578b4569/
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.4, [3]=0.40}, uses=200, maxlevel=1},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
})
if minetest.get_modpath("basic_materials") then
	minetest.register_craft({
		output = 'policetools:baton',
		recipe = {
			{'', '', 'basic_materials:steel_bar'},
			{'', 'basic_materials:steel_bar', ''},
			{'basic_materials:steel_bar', 'dye:black','default:steel_ingot'},
		}
	})
else
	minetest.register_craft({
		output = 'policetools:baton',
		recipe = {
			{'', '', 'default:steel_ingot'},
			{'', 'default:steel_ingot', ''},
			{'default:steel_ingot', 'dye:black','default:steel_ingot'},
		}
	})
end

if jobs then
	dofile(minetest.get_modpath("policetools").."/computer.lua")
end
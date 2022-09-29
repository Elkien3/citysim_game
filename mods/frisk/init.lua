minetest.log('action', '[MOD] Frisk loading ...')
local frisk_version = "0.0.2"
local take_items = false
local modstorage = minetest.get_mod_storage()
local i18n --internationalization

local wassneaking = {}
local cuffdamage = minetest.deserialize(modstorage:get_string("cuffdamage")) or {}

if minetest.get_modpath("intllib") then
	i18n = intllib.Getter()
else
	i18n = function(s,a,...)
		a={a,...}
		local v = s:gsub("@(%d+)", function(n)
			return a[tonumber(n)]
		end)
		return v
	end
end

local function finishfrisk(player, pName, oldpos)
	local pPlayer = minetest.get_player_by_name(pName)
	local name = player:get_player_name()
	local pos = pPlayer:getpos()
	if pPlayer:get_attach() then
		pos = pPlayer:get_attach():getpos()
	end
	if vector.distance(pos, oldpos) > .1 then
		minetest.chat_send_player(pName, "You moved, frisk canceled.")
		minetest.chat_send_player(name, pName.." moved, frisk canceled.")
		return
	end
	local player_inv = minetest.get_inventory({type='player', name = pName}) --InvRef
	local detached_inv = minetest.create_detached_inventory(pName, {
	allow_move = function()
		return 0
	end,
	allow_put = function()
		return 0
	end,
	allow_take = function()
		return 0
	end,
	}) --InvRef
	if take_items then
		detached_inv = minetest.create_detached_inventory(pName, {
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
		})
	end	--InvRef
	detached_inv:set_list('main', player_inv:get_list('main'))
	detached_inv:set_list('craft', player_inv:get_list('craft'))
	local formspec =
		'size[8,12]' ..
		'label[0,0;' .. i18n("@1\'s inventory", pName) ..']'..
		'list[detached:'.. pName..';craft;3,0;3,3;]'..
		'list[detached:'.. pName..';main;0,4;8,4;]'..
		"list[current_player;main;0,8;8,4;]"
	minetest.show_formspec(player:get_player_name(), 'frisk:frisk', formspec)
	minetest.chat_send_player(pName, "You were frisked by "..name..".")
end

local function startfrisk(stack, player, pointedThing)
	local obj = pointedThing.ref
	if obj and pointedThing.type == "object" then
		local pName = obj:get_player_name()
		if pName ~= "" then
			local name = player:get_player_name()
			minetest.chat_send_player(pName, name.." is frisking you, move to cancel.")
			minetest.chat_send_player(name, "You are frisking "..pName..".")
			local oldpos = obj:getpos()
			if obj:get_attach() then
				oldpos = obj:get_attach():getpos()
			end
			minetest.after(8, finishfrisk, player, pName, oldpos)
		end
	end
end

minetest.register_privilege("frisk", "Player can check other players\' inventory.")

minetest.register_tool('frisk:screen', {
	description = i18n('Screening Device'),
	inventory_image = 'frisk_screen.png',
	range = 1,
	on_use = startfrisk,
})

--HANDCUFFS

cuffedplayers = minetest.deserialize(modstorage:get_string("cuffedplayers")) or {}
local hasshout = minetest.deserialize(modstorage:get_string("hasshout")) or {}
minetest.register_on_joinplayer(function(player)
	local playerName = player:get_player_name()
	if cuffedplayers[playerName] ~= nil then
		if interacthandler then
			interacthandler.revoke(playerName)
		end
		player:hud_set_flags({wielditem=false})
	end
end)

minetest.register_on_prejoinplayer(function(playerName, ip)
	if cuffedplayers[playerName] ~= nil then
		if not interacthandler then
			local privs = minetest.get_player_privs(playerName)
			privs.shout = nil
			privs.interact = nil
			minetest.set_player_privs(playerName, privs)
		end
	end
end)

local function finishcuff(player, pName, oldpos)
	local pPlayer = minetest.get_player_by_name(pName)
	local name = player:get_player_name()
	local pos = pPlayer:getpos()
	if pPlayer:get_attach() then
		pos = pPlayer:get_attach():getpos()
	end
	if vector.distance(pos, oldpos) > .1 then
		minetest.chat_send_player(pName, "You moved, cuff canceled.")
		minetest.chat_send_player(name, pName.." moved, cuff canceled.")
		local wearcalc
		if cuffdamage[pName] then
			wearcalc = cuffdamage[pName]/400*65535
		else
			wearcalc = 0
		end
		minetest.add_item(pPlayer:getpos(), {name="frisk:handcuffs", count=1, wear=wearcalc, metadata=""})
		cuffdamage[pName] = nil
		modstorage:set_string("cuffdamage", minetest.serialize(cuffdamage))
		return
	end
	if interacthandler then
		interacthandler.revoke(pName)
		cuffedplayers[pName] = true
	else
		local privs = minetest.get_player_privs(pName)
		
		--[[if privs.shout then
			hasshout[pName] = true
		else
			hasshout[pName] = false
		end
		privs.shout = nil
		modstorage:set_string("hasshout", minetest.serialize(hasshout))--]]
		
		if privs.interact then
			cuffedplayers[pName] = true
		else
			cuffedplayers[pName] = false
		end
		privs.interact = nil
		minetest.set_player_privs(pName, privs)
	end
	pPlayer:hud_set_flags({wielditem=false})
	modstorage:set_string("cuffedplayers", minetest.serialize(cuffedplayers))
	minetest.chat_send_player(pName, "You were cuffed.")
	minetest.chat_send_player(name, "You cuffed "..pName..".")
end

local function startcuff(stack, player, pointedThing)
	local obj = pointedThing.ref
	if obj and pointedThing.type == "object" then
		local pName = obj:get_player_name()
		if obj:get_luaentity() and obj:get_luaentity().name == "knockout:entity" then
			pName = obj:get_luaentity().grabbed_name
		end
		if pName ~= "" then
			if cuffedplayers[pName] == nil then
				local itemstack = player:get_wielded_item()
				if itemstack:get_name() == "frisk:handcuffs" then
					cuffdamage[pName] = itemstack:get_wear()/65535*400 or 0
					itemstack:take_item()
					local name = player:get_player_name()
					minetest.chat_send_player(pName, name.." is cuffing you, move to cancel.")
					minetest.chat_send_player(name, "You are cuffing "..pName..".")
					local oldpos = obj:getpos()
					if obj:get_attach() then
						oldpos = obj:get_attach():getpos()
					end
					minetest.after(6, finishcuff, player, pName, oldpos)
					minetest.sound_play("cuff", {
						pos = obj:getpos(),
						max_hear_distance = 10,
						gain = 1.0,
						object = obj
					})
					modstorage:set_string("cuffdamage", minetest.serialize(cuffdamage))
					return itemstack
				end
			else
				minetest.chat_send_player(pName, "Player already cuffed.")
			end
		end
	end
end

local function uncuff(stack, player, pointedThing)
	local obj = pointedThing.ref
	if obj and pointedThing.type == "object" then
		local pName = obj:get_player_name()
		if obj:get_luaentity() and obj:get_luaentity().name == "knockout:entity" then
			pName = obj:get_luaentity().grabbed_name
		end
		if pName ~= "" then
			if cuffedplayers[pName] ~= nil then
				if interacthandler then
					interacthandler.grant(pName)
				else
					local privs = minetest.get_player_privs(pName)
					if cuffedplayers[pName] == true then
						privs.interact = true
					else
						privs.interact = nil
					end
					
					--[[if hasshout[pName] == true then
						privs.shout = true
					else
						privs.shout = nil
					end
					hasshout[pName] = nil
					modstorage:set_string("hasshout", minetest.serialize(hasshout))--]]
					
					minetest.set_player_privs(pName, privs)
				end
				obj:hud_set_flags({wielditem=true})
				cuffedplayers[pName] = nil
				modstorage:set_string("cuffedplayers", minetest.serialize(cuffedplayers))
				local player_inv = player:get_inventory()
				local wearcalc
				if cuffdamage[pName] then
					wearcalc = cuffdamage[pName]/400*65535
				else
					wearcalc = 0
				end
				minetest.sound_play("uncuff", {
					pos = obj:getpos(),
					max_hear_distance = 10,
					gain = 1.0,
					object = obj
				})
				minetest.add_item(obj:getpos(), player_inv:add_item("main", {name="frisk:handcuffs", count=1, wear=wearcalc, metadata=""}))
				cuffdamage[pName] = nil
				modstorage:set_string("cuffdamage", minetest.serialize(cuffdamage))
			end
		end
	end
end

minetest.register_craft({
	output = 'frisk:screen',
	recipe = {
		{'', 'default:steel_ingot', ''},
		{'default:steel_ingot', 'default:glass', 'default:steel_ingot'},
		{'', 'default:steel_ingot',''},
	}
})

minetest.register_tool('frisk:handcuffs', {
	description = ('Handcuffs'),
	inventory_image = 'frisk_handcuffs.png',
	range = 2,
	on_use = startcuff,
})
minetest.register_craft({
	output = 'frisk:handcuffs',
	recipe = {
		{'', 'default:steel_ingot', ''},
		{'default:steel_ingot', 'default:bronze_ingot', 'default:steel_ingot'},
		{'', 'default:steel_ingot',''},
	}
})
minetest.register_tool('frisk:handcuff_key', {
	description = ('Handcuff Key'),
	inventory_image = 'frisk_handcuff_key.png',
	range = 1,
	on_use = uncuff,
})
minetest.register_craft({
	output = 'frisk:handcuff_key',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', ''},
		{'default:steel_ingot', '', ''},
		{'', '', ''},
	}
})
--player:set_bone_position(bone, bone_position[bone], rotation)
minetest.register_globalstep(function(dtime)
	for name in pairs(cuffedplayers) do
		local player = minetest.get_player_by_name(name)
		if player then
			if player:get_player_control().sneak then
				if wassneaking[name] == nil then
					wassneaking[name] = true
					if not cuffdamage[name] then
						cuffdamage[name] = 0
					end
					cuffdamage[name] = cuffdamage[name] + math.random(1,3)
					if math.random(1,5) == 1 then
						minetest.sound_play("wriggle", {
							pos = player:getpos(),
							max_hear_distance = 10,
							gain = 1.0,
							object = player
						})
					end
					if cuffdamage[name] >= 400 then
						if interacthandler then
							interacthandler.grant(name)
						else
							local privs = minetest.get_player_privs(name)
							if cuffedplayers[name] == true then
								privs.interact = true
							else
								privs.interact = nil
							end
							--[[if hasshout[name] == true then
								privs.shout = true
							else
								privs.shout = nil
							end
							hasshout[name] = nil
							modstorage:set_string("hasshout", minetest.serialize(hasshout))--]]
							minetest.set_player_privs(name, privs)
						end
						cuffdamage[name] = nil
						player:hud_set_flags({wielditem=true})
						minetest.sound_play("uncuff", {
							pos = player:getpos(),
							max_hear_distance = 10,
							gain = 1.0,
							object = player
						})
						cuffedplayers[name] = nil
						modstorage:set_string("cuffedplayers", minetest.serialize(cuffedplayers))
					end
					modstorage:set_string("cuffdamage", minetest.serialize(cuffdamage))
				end
			else
				if wassneaking[name] then
					wassneaking[name] = nil
				end
			end
		end
	end
end)

minetest.register_on_dieplayer(function(player)
	local pName = player:get_player_name()
	if cuffedplayers[pName] ~= nil then
		local privs = minetest.get_player_privs(pName)
		if cuffedplayers[pName] == true then
			privs.interact = true
		else
			privs.interact = nil
		end
		if hasshout[pName] == true then
			privs.shout = true
		else
			privs.shout = nil
		end
		hasshout[pName] = nil
		modstorage:set_string("hasshout", minetest.serialize(hasshout))
		
		minetest.set_player_privs(pName, privs)
		player:hud_set_flags({wielditem=true})
		cuffedplayers[pName] = nil
		modstorage:set_string("cuffedplayers", minetest.serialize(cuffedplayers))
		local player_inv = player:get_inventory()
		local wearcalc
		if cuffdamage[pName] then
			wearcalc = cuffdamage[pName]/400*65535
		else
			wearcalc = 0
		end
		minetest.add_item(player:getpos(), {name="frisk:handcuffs", count=1, wear=wearcalc, metadata=""})
		cuffdamage[pName] = nil
		modstorage:set_string("cuffdamage", minetest.serialize(cuffdamage))
	end
end)

--METAL DETECTORS

local function has_metal(player)
	local inv = player:get_inventory()
	for listname, list in pairs(inv:get_lists()) do
		for i, itemstack in pairs(list) do
			local name = itemstack:get_name()
			if minetest.get_item_group(name, "detectable_metal") > 0 then
				return true
			end
		end
	end
	return false
end

local function add_metal_group(itemname)
	local groups = {}
	if not minetest.registered_items[itemname] then return end 
	if minetest.registered_items[itemname].groups then groups = table.copy(minetest.registered_items[itemname].groups) end
	groups.detectable_metal = 1
	minetest.override_item(itemname, {
	   groups = groups,
	})
end
--[[
local metal_items_steel_nonweapon = {
	"3d_armor_stand:locked_armor_stand",
	"army:chainlink",
	"army:light",
	"basic_materials:chain_steel",
	"basic_materials:chainlink_steel",
	"basic_materials:gear_steel",
	"basic_materials:motor",
	"basic_materials:padlock",
	"basic_materials:steel_bar",
	"basic_materials:steel_wire",
	"bed_metal:bed_bottom",
}--]]
local metal_items_raw = {
	"default:steel_ingot",
	"default:iron_lump",
	"default:stone_with_iron",
	"technic:wrought_iron_dust",
	"default:steelblock",
	"stairs:stair_steelblock",
	"stairs:slab_steelblock",
	"technic:carbon_steel_ingot",
	"technic:cast_iron_ingot",
	"vessels:steel_bottle",
	"default:mese_crystal_fragment",
	"default:mese_crystal",
	"default:mese",
	"default:diamond",
	"default:diamondblock",
	"default:bronze_ingot",
	"default:bronzeblock",
	"stairs:stair_bronzeblock",
	"stairs:slab_bronzeblock",
	"default:copper_ingot",
	"default:copper_lump",
	"technic:copper_dust",
	"default:stone_with_copper",
	"moreores:mineral_mithril",
	"moreores:mithril_ingot",
	"moreores:mithril_lump",
	"technic:mithril_dust",
	"moreores:mithril_block",
	"moreores:mineral_silver",
	"moreores:silver_ingot",
	"moreores:silver_lump",
	"technic:silver_dust",
	"moreores:silver_block",
	"technic:composite_plate",
	"technic:copper_plate",
}
for i, itemname in pairs(metal_items_raw) do
	add_metal_group(itemname)
end

local metal_items_weapons = {
	"army:barbedwire",
	"default:axe_steel",
	"default:axe_mese",
	"default:axe_diamond",
	"default:axe_bronze",
	"default:pick_steel",
	"default:pick_mese",
	"default:pick_diamond",
	"default:pick_bronze",
	"default:sword_steel",
	"default:sword_mese",
	"default:sword_diamond",
	"default:sword_bronze",
	"drug_wars:machete_mese",
	"drug_wars:machete_steel",
	"frisk:handcuffs",
	"frisk:handcuff_key",
	"grenades_basic:flashbang",
	"grenades_basic:frag",
	"grenades_basic:smoke",
	"gun_lathe:gun_barrel_carbon_steel",
	"gun_lathe:gun_barrel_iron",
	"gun_lathe:gun_barrel_stainless_steel",
	"lockpicks:lockpick_copper",
	"lockpicks:lockpick_gold",
	"lockpicks:lockpick_mithril",
	"lockpicks:lockpick_silver",
	"lockpicks:lockpick_steel",
	"modern_armor:helmet_military",
	"modern_armor:helmet_swat",
	"modern_armor:vest_military",
	"modern_armor:vest_swat",
	"modern_armor:vest_police",
	"moreores:axe_mithril",
	"moreores:axe_silver",
	"moreores:pick_mithril",
	"moreores:pick_silver",
	"moreores:sword_mithril",
	"moreores:sword_silver",
	"shooter:flaregun",
	"shooter:grapple_gun",
	"shooter:grapple_hook",
	"shooter:rocket",
	"shooter:rocket_gun",
	"spriteguns:bullet_12",
	"spriteguns:bullet_45",
	"spriteguns:bullet_762",
	"spriteguns:coltarmy",
	"spriteguns:cz527",
	"spriteguns:mini14",
	"spriteguns:pardini",
	"spriteguns:remington870",
	"spriteguns:thompson",
	"spriteguns:mag_cz527",
	"spriteguns:mag_mini14",
	"spriteguns:mag_pardini",
	"spriteguns:mag_thompson",
	"technic:chernobylite_block",
	"technic:chernobylite_dust",
	"xdecor:baricade",
}
for i, itemname in pairs(metal_items_weapons) do
	add_metal_group(itemname)
end

local function finishmetaldetect(player, pName, oldpos)
	local pPlayer = minetest.get_player_by_name(pName)
	local name = player:get_player_name()
	local pos = pPlayer:getpos()
	if pPlayer:get_attach() then
		pos = pPlayer:get_attach():getpos()
	end
	if vector.distance(pos, oldpos) > .1 then
		minetest.chat_send_player(pName, "You moved, metal detection canceled.")
		minetest.chat_send_player(name, pName.." moved, metal detection canceled.")
		return
	end
	if has_metal(pPlayer) then
		minetest.chat_send_player(name, pName.." has metal detected.")
		minetest.sound_play("metal_detector_detected",{
			object = player,
		})
	else
		minetest.chat_send_player(name, pName.." had nothing detected.")
		minetest.sound_play("metal_detector_not_detected",{
			object = player,
		})
	end
	minetest.chat_send_player(pName, "You were metal detected by "..name..".")
end

local function startmetaldetect(stack, player, pointedThing)
	local obj = pointedThing.ref
	local name = player:get_player_name()
	if obj and pointedThing.type == "object" then
		local pName = obj:get_player_name()
		if pName ~= "" then
			minetest.chat_send_player(pName, name.." is checking you for metal, move to cancel.")
			minetest.chat_send_player(name, "You are checking "..pName.." for metal.")
			local oldpos = obj:getpos()
			if obj:get_attach() then
				oldpos = obj:get_attach():getpos()
			end
			minetest.after(1, finishmetaldetect, player, pName, oldpos)
		end
	elseif pointedThing.type == "node" then--searching for nodes that are detectable or inventory nodes with detectable metals in them
		if minetest.find_node_near(pointedThing.above, 5, "group:detectable_metal", true) then
			minetest.chat_send_player(name, "metal was detected nearby.")
			minetest.sound_play("metal_detector_detected",{
				object = player,
			})
			return
		end
		local nodes = minetest.find_nodes_with_meta(vector.subtract(pointedThing.above, 6), vector.add(pointedThing.above, 6))
		for i, nodepos in pairs(nodes) do
			if vector.distance(nodepos, pointedThing.above) <= 5 then
				local inv = minetest.get_inventory({type="node", pos=nodepos})
				if inv then
					for listname, listtbl in pairs(inv:get_lists()) do
						for i2 = 1, inv:get_size(listname) do
							local stack = inv:get_stack(listname, i2)
							if minetest.get_item_group(stack:get_name(), "detectable_metal") > 0 then
								minetest.chat_send_player(name, "metal was detected nearby.")
								minetest.sound_play("metal_detector_detected",{
									object = player,
								})
								return
							end
						end
					end
				end
			end
		end
		minetest.chat_send_player(name, "No metal was detected nearby.")
		minetest.sound_play("metal_detector_not_detected",{
			object = player,
		})
	end
end

minetest.register_tool('frisk:handheld_metal_detector', {
	description = i18n('Handeld Metal Detector'),
	inventory_image = 'frisk_screen.png',
	range = 1.5,
	on_use = startmetaldetect,
})

minetest.register_node("frisk:metal_detector", {
	description = "Metal Detector",
	tiles = {
		"default_silver_sandstone.png",
		"default_silver_sandstone.png",
		"default_silver_sandstone.png",
		"default_silver_sandstone.png",
		"default_silver_sandstone.png",
		"default_silver_sandstone.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, -0.375, 1.375, 0.5}, -- NodeBox1
			{0.375, -0.5, -0.5, 0.5, 1.375, 0.5}, -- NodeBox2
			{-0.5, 1.375, -0.5, 0.5, 1.5, 0.5}, -- NodeBox3
		}
	},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local metaldetected = false
		local name = clicker:get_player_name()
		for i, connectedplayer in pairs (minetest.get_connected_players()) do
			local plpos = vector.round(connectedplayer:get_pos())
			if vector.distance(plpos, pos) < .1 then
				if has_metal(connectedplayer) then
					metaldetected = true
				end
			end
		end
		if metaldetected then
			minetest.sound_play("metal_detector_detected",{
				pos = pos,
			})
			if name then
				minetest.chat_send_player(name, "Metal was detected.")
			end
		else
			minetest.sound_play("metal_detector_not_detected",{
				pos = pos,
			})
			if name then
				minetest.chat_send_player(name, "Nothing was detected.")
			end
		end
	end
})

local copperitem = "default:copper_ingot"
if minetest.get_modpath("technic") then
	copperitem = "technic:copper_coil"
end
minetest.register_craft({
	output = "frisk:metal_detector",
	recipe = {
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{copperitem,"",copperitem},
		{"default:steel_ingot","","default:steel_ingot"},
	}
})
minetest.register_craft({
	output = "frisk:handheld_metal_detector",
	recipe = {
		{copperitem},
		{copperitem},
		{"default:steel_ingot"},
	}
})

minetest.log('action', 'MOD: Frisk version ' .. frisk_version .. ' loaded.')

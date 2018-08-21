minetest.log('action', '[MOD] Frisk loading ...')
local frisk_version = "0.0.2"

local i18n --internationalization
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
	if (pPlayer:getpos().x ~= oldpos.x) or (pPlayer:getpos().y ~= oldpos.y) or (pPlayer:getpos().z ~= oldpos.z) then
		minetest.chat_send_player(pName, "You moved, frisk canceled.")
		minetest.chat_send_player(name, pName.." moved, fisk canceled.")
		return
	end
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
	local player_inv = minetest.get_inventory({type='player', name = pName}) --InvRef
	detached_inv:set_list('main', player_inv:get_list('main'))
	detached_inv:set_list('craft', player_inv:get_list('craft'))
	local formspec =
		'size[8,8]' ..
		'label[0,0;' .. i18n("@1\'s inventory", pName) ..']'..
		'list[detached:'.. pName..';craft;3,0;3,3;]'..
		'list[detached:'.. pName..';main;0,4;8,4;]'
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

minetest.register_craft({
	output = 'frisk:screen',
	recipe = {
		{'', 'default:steel_ingot', ''},
		{'default:steel_ingot', 'default:glass', 'default:steel_ingot'},
		{'', 'default:steel_ingot',''},
	}
})

minetest.log('action', 'MOD: Frisk version ' .. frisk_version .. ' loaded.')

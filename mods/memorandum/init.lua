-----------------------------------------------------------------------------------------------
local title     = "Memorandum"
local version   = "0.0.8"
local mname     = "memorandum"
-----------------------------------------------------------------------------------------------
--              { left  , bottom , front  ,  right ,  top   ,  back  }
local sheet =   { -1/2  , -1/2   , -1/2   , 1/2    , -7/16  ,  1/2  }
local info  =   '"'
local sign  =   '" Signed by '
            
minetest.register_craftitem(":default:paper", {
    description = "Paper",
    inventory_image = "default_paper.png",
    on_place = function(itemstack, placer, pointed_thing)
        local pt = pointed_thing
        local direction = minetest.dir_to_facedir(placer:get_look_dir())
        local there = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
        if minetest.env:get_node(there).name == "air" then
            minetest.add_node(there, {name="memorandum:letter_empty", param2=direction})
            itemstack:take_item()
            return itemstack
        end
    end,
})

minetest.register_node("memorandum:letter_empty", {
    drawtype = "nodebox",
    tiles = {"memorandum_letter_empty.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    walkable = false,
    node_box = {type = "fixed", fixed = sheet},
    groups = {snappy=3,dig_immediate=3,not_in_creative_inventory=1},
    sounds = default.node_sound_leaves_defaults(),
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string(
                    "formspec", 
                    "size[10,7]"..
                    "field[1,1;8.5,1;text; Write a Letter;${text}]"..
                    "field[1,3;4.25,1;signed; Sign Letter (optional);${signed}]"..
                    "button_exit[0.75,5;4.25,1;text,signed;Done]"..
                         "button_exit[0.75,6;4.25,1;exit;Exit]"
                )
        meta:set_string("infotext", info..'"')
    end,
    on_receive_fields = function(pos, formname, fields, sender)
        local meta = minetest.get_meta(pos)
        fields.text = fields.text
        fields.signed = fields.signed
        --[[print((sender:get_player_name() or "").." wrote \""..fields.text..
                "\" to paper at "..minetest.pos_to_string(pos))]]
        local direction = minetest.env:get_node(pos).param2
        if fields.text == nil then
            fields.text = ""
        end
        if fields.signed == nil then
            fields.signed = ""
        end
        if fields.text ~= "" then
            minetest.env:add_node(pos, {name="memorandum:letter_written", param2=direction})
        end
        meta:set_string("text", fields.text)
        meta:set_string("signed", "")
        meta:set_string("infotext", info..fields.text..'" Unsigned')
        if fields.signed ~= "" then
            meta:set_string("signed", fields.signed)
            meta:set_string("infotext", info..fields.text..sign..fields.signed)
        end
    end,
    on_dig = function(pos, node, digger)
        if digger:is_player() and digger:get_inventory() then
            digger:get_inventory():add_item("main", {name="default:paper", count=1, wear=0, metadata=""})
        end
        minetest.remove_node(pos)
    end,
})

minetest.register_craftitem("memorandum:letter", {
    description = "Letter",
    inventory_image = "default_paper.png^memorandum_letters.png",
    stack_max = 1,
    groups = {not_in_creative_inventory=1},
    on_use = function(itemstack, user, pointed_thing)
        local player = user:get_player_name()
        local text = itemstack:get_metadata()
        local scnt = string.sub (text, -2, -1)
        if scnt == "00" then
            mssg = string.sub (text, 1, -3)
            sgnd = ""
        elseif tonumber(scnt) == nil then -- to support previous versions
            mssg = string.sub (text, 37, -1)
            sgnd = ""
        else
            mssg = string.sub (text, 1, -scnt -3)
            sgnd = string.sub (text, -scnt-2, -3)
        end
        if scnt == "00" or tonumber(scnt) == nil then
            minetest.chat_send_player(player, info..mssg..'" Unsigned', false)
        else
            minetest.chat_send_player(player, info..mssg..sign..sgnd, false)
        end
    end,
    on_place = function(itemstack, placer, pointed_thing)
        local pt = pointed_thing
        local there = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
        local direction = minetest.dir_to_facedir(placer:get_look_dir())
        local meta = minetest.env:get_meta(there)
        local text = itemstack:get_metadata()
        local scnt = string.sub (text, -2, -1)
        if scnt == "00" then
            mssg = string.sub (text, 1, -3)
            sgnd = ""
        elseif tonumber(scnt) == nil then -- to support previous versions
            mssg = string.sub (text, 37, -1)
            sgnd = ""
        else
            mssg = string.sub (text, 1, -scnt -3)
            sgnd = string.sub (text, -scnt-2, -3)
        end
        if minetest.env:get_node(there).name == "air" then
            minetest.add_node(there, {name="memorandum:letter_written", param2=direction})
            if scnt == "00" or tonumber(scnt) == nil then
                meta:set_string("infotext", info..mssg..'" Unsigned')
            else
                meta:set_string("infotext", info..mssg..sign..sgnd)
            end
            meta:set_string("text", mssg)
            meta:set_string("signed", sgnd)
            itemstack:take_item()
            return itemstack
        end
    end,
})

minetest.register_node("memorandum:letter_written", {
    drawtype = "nodebox",
    tiles = {"memorandum_letter_empty.png^memorandum_letter_text.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    walkable = false,
    node_box = {type = "fixed", fixed = sheet},
    groups = {snappy=3,dig_immediate=3,not_in_creative_inventory=1},
    sounds = default.node_sound_leaves_defaults(),
    on_receive_fields = function(pos, formname, fields, sender)
        local item = sender:get_wielded_item()
        if item:get_name() == "memorandum:eraser" then
            local meta = minetest.get_meta(pos)
            fields.text = fields.text
            fields.signed = fields.signed
            if fields.text == nil then
                fields.text = ""
            end
            if fields.signed == nil then
                fields.signed = ""
            end
            --[[print((sender:get_player_name() or "").." wrote \""..fields.text..
                "\" to paper at "..minetest.pos_to_string(pos))]]
            local direction = minetest.env:get_node(pos).param2
            if fields.text == "" then
                minetest.env:add_node(pos, {name="memorandum:letter_empty", param2=direction})
            end
            meta:set_string("text", fields.text)
            meta:set_string("signed", "")
            meta:set_string("infotext", info..fields.text..'" Unsigned')
            if fields.signed ~= "" then
                meta:set_string("signed", fields.signed)
                meta:set_string("infotext", info..fields.text..sign..fields.signed)
            end
        end
    end,
    on_dig = function(pos, node, digger)
        if digger:is_player() and digger:get_inventory() then
            local meta = minetest.get_meta(pos)
            local text = meta:get_string("text")
            local signed = meta:get_string("signed")
            local signcount = string.len(signed)
            local item = digger:get_wielded_item()
            local inv = digger:get_inventory()
            if string.len(signed) < 10 then
                signcount = "0"..string.len(signed)
            end
            if signed == '" Unsigned' then
                signcount = "00"
            end
            if item:get_name() == "vessels:glass_bottle" then
                inv:remove_item("main", "vessels:glass_bottle")
                inv:add_item("main", {name="memorandum:message", count=1, wear=0, metadata=text..signed..signcount})
            else
                inv:add_item("main", {name="memorandum:letter", count=1, wear=0, metadata=text..signed..signcount})
            end
        end
        minetest.remove_node(pos)
    end,
})

local function eraser_wear(itemstack, user, pointed_thing, uses)
    itemstack:add_wear(65535/(uses-1))
    return itemstack
end

minetest.register_tool("memorandum:eraser", {
    description = "Eraser",
    inventory_image = "memorandum_eraser.png",
    wield_image = "memorandum_eraser.png^[transformR90",--^[transformFX",
    wield_scale = {x = 0.5, y = 0.5, z = 1},
    on_use = function(itemstack, user, pointed_thing)
        local pt = pointed_thing
        if pt and pt.under then
            local node = minetest.get_node(pt.under)
            local meta = minetest.get_meta(pt.under)
            local player = user:get_player_name()
            local signer = meta:get_string("signed")
            if string.find(node.name, "memorandum:letter_written") then
                if signer == player or signer == "" then
                    meta:set_string(
                        "formspec", 
                        "size[10,7]"..
                        "field[1,1;8.5,1;text; Edit Text;${text}]"..
                        "field[1,3;4.25,1;signed; Edit Signature;${signed}]"..
                        "button_exit[0.75,5;4.25,1;text,signed;Done]"
                    )
                    if not minetest.setting_getbool("creative_mode") then
                        return eraser_wear(itemstack, user, pointed_thing, 30)  
                    else
                        return {name="memorandum:eraser", count=1, wear=0, metadata=""}
                    end
                end
            end
        end
    end,
})

minetest.register_node("memorandum:message", {
	description = "Message in a Bottle",
	drawtype = "plantlike",
	tiles = {"vessels_glass_bottle.png^memorandum_message.png"},
	inventory_image = "vessels_glass_bottle_inv.png^memorandum_message.png",
	wield_image = "vessels_glass_bottle.png^memorandum_message.png",
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {-1/4, -1/2, -1/4, 1/4, 4/10, 1/4}
	},
	stack_max = 1,
	groups = {vessel=1,dig_immediate=3,attached_node=1,not_in_creative_inventory=1},
	--sounds = default.node_sound_glass_defaults(),
	on_use = function(itemstack, user, pointed_thing)
		local pt = pointed_thing
		if  pt.under then
			local meta = minetest.get_meta(pt.above)
			local text = itemstack:get_metadata()
			local scnt = string.sub (text, -2, -1)
			if scnt == "00" then
				mssg = string.sub (text, 1, -3)
				sgnd = ""
			elseif tonumber(scnt) == nil then -- to support previous versions
				mssg = string.sub (text, 37, -1)
				sgnd = ""
			else
				mssg = string.sub (text, 1, -scnt -3)
				sgnd = string.sub (text, -scnt-2, -3)
			end
			if  minetest.get_node(pt.above).name == "air" then
				minetest.add_node(pt.above, {name="memorandum:letter_written", param2=math.random(0,3)})
				if scnt == "00" or tonumber(scnt) == nil then
					meta:set_string("infotext", info..mssg..'" Unsigned')
				else
					meta:set_string("infotext", info..mssg..sign..sgnd)
				end
				meta:set_string("text", mssg)
				meta:set_string("signed", sgnd)
				itemstack:take_item()
				user:get_inventory():add_item("main", {name="vessels:glass_bottle", count=1, wear=0, metadata=""})
				return itemstack
			end
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local pt = pointed_thing
		local meta = minetest.get_meta(pt.above)
		local text = itemstack:get_metadata()
		local scnt = string.sub (text, -2, -1)
		if scnt == "00" then
			mssg = string.sub (text, 1, -3)
			sgnd = ""
		elseif tonumber(scnt) == nil then -- to support previous versions
			mssg = string.sub (text, 37, -1)
			sgnd = ""
		else
			mssg = string.sub (text, 1, -scnt -3)
			sgnd = string.sub (text, -scnt-2, -3)
		end
		if minetest.get_node(pt.above).name == "air" then
			minetest.add_node(pt.above, {name="memorandum:message"})
			meta:set_string("text", mssg)
			meta:set_string("signed", sgnd)
			itemstack:take_item()
			return itemstack
		end
	end,
	on_dig = function(pos, node, digger)
		if digger:is_player() and digger:get_inventory() then
			local meta = minetest.get_meta(pos)
			local text = meta:get_string("text")
			local signed = meta:get_string("signed")
			local signcount = string.len(signed)
			local item = digger:get_wielded_item()
			if string.len(signed) < 10 then
				signcount = "0"..string.len(signed)
			end
			if signed == '" Unsigned' then
				signcount = "00"
			end
			digger:get_inventory():add_item("main", {name="memorandum:message", count=1, wear=0, metadata=text..signed..signcount})
		end
		minetest.remove_node(pos)
	end,
})

if minetest.get_modpath("farming") ~= nil then
minetest.register_craft({
    type = "shapeless",
    output = "memorandum:eraser",
    recipe = {"farming:bread"},
})
end
if minetest.get_modpath("candles") ~= nil then
minetest.register_craft({
    type = "shapeless",
    output = "memorandum:eraser",
    recipe = {"candles:wax"},
})
end
if minetest.get_modpath("bees") ~= nil then
minetest.register_craft({
    type = "shapeless",
    output = "memorandum:eraser",
    recipe = {"bees:honey_comb"},
})
end
if minetest.get_modpath("technic") ~= nil then
minetest.register_craft({
    type = "shapeless",
    output = "memorandum:eraser",
    recipe = {"technic:raw_latex"},
})
end

--[[minetest.register_craft({
    type = "shapeless",
    output = "default:paper",
    recipe = {"memorandum:letter","memorandum:eraser"},
    replacements = {
        {"memorandum:eraser", "memorandum:eraser"}
    },
})]]
-----------------------------------------------------------------------------------------------
print("[Mod] "..title.." ["..version.."] ["..mname.."] Loaded...")
-----------------------------------------------------------------------------------------------

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

local function package_formspec(pos)
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
	local formspec =
		"size[8,9]" ..
		"list[nodemeta:" .. spos .. ";main;0,0.3;2,2.3;]" ..
		"list[current_player;main;0,4.85;8,1;]" ..
		"list[current_player;main;0,6.08;8,3;8]" ..
		"listring[nodemeta:" .. spos .. ";main]" ..
		"listring[current_player;main]" ..
		"field[3,0.5;3.5,1;addressee;Addressee;]" ..
		"label[0,-.2;Package your items]" ..
		"field[3,1.8;2.5,1;attn;Attn. (Optional);]" ..
		"button_exit[0.25,2.5;2,1;exit;Seal]"..
		default.get_hotbar_bg(0,4.85)
	return formspec
end

minetest.register_node("package:package", {
	description = "Cardboard box",
	stack_max = 1,
	drawtype = "nodebox",
	tiles = {
		'homedecor_cardbox_tb.png',
		'homedecor_cardbox_tb.png',
		'homedecor_cardbox_sides.png',
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.3125, 0.3125, 0, 0.3125},
		}
	},
	groups = { snappy = 3 },
	drop = "",
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if stack:get_name() == "package:package" then
			return 0
		end
		return stack:get_count()
	end,
	--[[on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 4)
	end,--]]
	on_receive_fields = function(pos, formname, fields, sender)
		local name = sender:get_player_name()
		if not name then return end
		local nodemeta = minetest.get_meta(pos)
		if fields.exit and fields.exit == "Seal" and nodemeta:get_string("addressee") == "" then
			if not fields.addressee or fields.addressee == "" or not minetest.player_exists(fields.addressee) then
				minetest.chat_send_player(name, "You must have an valid addressee to seal the box.")
				return
			end
			nodemeta:set_string("formspec", "")
			nodemeta:set_string("addressee", fields.addressee)
			nodemeta:set_string("sender", name)
			nodemeta:set_string("attn", fields.attn)
			nodemeta:set_string("description", "Cardboard box addressed to '"..fields.addressee.."' from '"..name.."' attn: "..fields.attn)
			nodemeta:set_string("infotext", "Cardboard box addressed to '"..fields.addressee.."' from '"..name.."' attn: "..fields.attn)
		elseif fields.attn and nodemeta:get_string("addressee") == "" then
			if fields.attn == "" then
				nodemeta:set_string("description", "Cardboard box")
				nodemeta:set_string("infotext", "Cardboard box")
			else
				nodemeta:set_string("description", "Cardboard box attn: "..fields.attn)
				nodemeta:set_string("infotext", "Cardboard box attn: "..fields.attn)
			end
		end
	end,
	on_dig = function(pos, node, digger)
		local item = ItemStack("package:package")
		local meta = item:get_meta()
		local nodemeta = minetest.get_meta(pos)
		local inv = nodemeta:get_inventory()
		meta:from_table(nodemeta:to_table())
		meta:set_string("inventory", serializeContents(inv:get_list("main")))
		meta:set_string("formspec", "")
		local player_inv = digger:get_inventory()
		minetest.add_item(pos, player_inv:add_item("main", item))
		if not minetest.dig_node(pos) then
			minetest.remove_node(pos)
		end
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = itemstack:get_meta()
		local nodemeta = minetest.get_meta(pos)
		nodemeta:from_table(meta:to_table())
		local inv = nodemeta:get_inventory()
		inv:set_size("main", 4)
		if nodemeta:get_string("description") == "" then
			nodemeta:set_string("infotext", "Cardboard box")
		else
			nodemeta:set_string("infotext", nodemeta:get_string("description"))
		end
		if meta:get_string("inventory") ~= "" then
			inv:set_list("main", deserializeContents(meta:get_string("inventory")))
		end
		if meta:get_string("addressee") == "" then
			nodemeta:set_string("formspec", package_formspec(pos))
		else
			nodemeta:set_string("formspec", "")
		end
	end,
	on_rightclick = function(pos, node, clicker)
		local nodemeta = minetest.get_meta(pos)
		local addressee = nodemeta:get_string("addressee")
		local name = clicker:get_player_name()
		if not name then return end
		if addressee ~= "" then
			if name == addressee or name == nodemeta:get_string("sender") then--todo allow post office supervisors or ceo to open packages
				nodemeta:set_string("formspec", package_formspec(pos))
				nodemeta:set_string("addressee", "")
				nodemeta:set_string("sender", "")
				nodemeta:set_string("attn", "")
				nodemeta:set_string("description", "")
				--todo: play opening sound
				nodemeta:set_string("infotext", "Cardboard box")
			end
		end
	end,
	groups = {snappy = 2, oddly_breakable_by_hand = 2},
})

minetest.register_craft({
    type = "shaped",
    output = "package:package",
    recipe = {
        {"default:paper", "default:paper", "default:paper"},
        {"default:paper", "", "default:paper"},
        {"default:paper", "default:paper", "default:paper"}
    }
})

--[[


local packagetable = {}


--[[
local function updateMeta(player, itemstack, inv, meta)
	local wield = player:get_wielded_item()
	minetest.chat_send_all(dump(itemstack:get_name()))
	minetest.chat_send_all(dump(wield:get_name()))
	if itemstack:get_name() ~= wield:get_name() then return end
	meta:set_string("item", serializeContents(inv:get_list("main")))
	player:set_wielded_item(itemstack)
end

minetest.register_craftitem("package:package_blank", {
    description = "Blank package",
    inventory_image = "package_package_blank.png",
    on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		local meta = itemstack:get_meta()
		local inventory = minetest.create_detached_inventory("package_"..name, {
			on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
				return updateMeta(user, itemstack, inv, meta)
			end,
			on_put = function(inv, listname, index, stack, player)
				return updateMeta(user, itemstack, inv, meta)
			end,
			on_take = function(inv, listname, index, stack, player)
				return updateMeta(user, itemstack, inv, meta)
			end,
		})
		inventory:set_size("main", 1)
		if meta:get_string("item") ~= "" then
			inventory:set_list("main", deserializeContents(meta:get_string("item")))
		end
        minetest.show_formspec(name, "package:input", 
            "size[8,7]" ..
            "field[2,0.5;3.5,1;addressee;Addressee;]" ..
            "label[0,0;Package your item]" ..
            "list[detached:package_"..name..";main;0.25,0.5;1,1;]" ..
            "field[3,1.8;2.5,1;attn;Attn. (Optional);]" ..
            "button_exit[0.25,1.5;2,1;exit;Seal]"..
			"list[current_player;main;0,3;8,4;]")
        return itemstack
    end
})

minetest.register_craftitem("package:package_sealed", {
    description = "Sealed package",
    inventory_image = "package_package_sealed.png",
    stack_max = 1,
    groups = {not_in_creative_inventory = 1},
    on_use = function(itemstack, user, pointed_thing)
        meta = itemstack:get_meta()
        if user:get_player_name() == meta:get_string("receiver") then
            open_env = ItemStack("package:package_blank")
            open_meta = open_env:get_meta()
            open_meta:set_string("sender", meta:get_string("sender"))
            open_meta:set_string("receiver", meta:get_string("receiver"))
            open_meta:set_string("item", meta:get_string("item"))
            local desc = ("Opened package\nTo: " .. meta:get_string("receiver") .. "\nFrom: " .. meta:get_string("sender"))
            open_meta:set_string("description", desc)
            if meta:get_string("attn") ~= "" then
                open_meta:set_string("attn", meta:get_string("attn"))
                desc = desc .. "\nAttn: " .. meta:get_string("attn")
                open_meta:set_string("description", desc)
            end
            return open_env
        end
        minetest.chat_send_player(user:get_player_name(), "The seal can only be opened by the addressee!")
        return itemstack
    end
})

minetest.register_craftitem("package:package_opened", {
    description = "Opened package",
    inventory_image = "package_package_opened.png",
    stack_max = 1,
    groups = {not_in_creative_inventory = 1},
    on_use = function(itemstack, user, pointed_thing)
        local meta = itemstack:get_meta()
        local sender = meta:get_string("sender")
        local receiver = meta:get_string("receiver")
        local item = meta:get_string("item")
        local attn = meta:get_string("attn") or ""
        local form = 
            "size[5,5]" ..
            "label[0,0;A letter from " .. sender .. " to " .. receiver
        if attn ~= "" then
            form = form .. "\nAttn: " .. attn
        end
        form = form .. "\n" .. item .. "]" .. "button_exit[0,4;2,1;exit;Close]"
        minetest.show_formspec(user:get_player_name(), "package:display", form)
    end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "package:input" or not minetest.is_player(player) then
        return false
    end
	local wielditem = player:get_wielded_item():get_name()
	local name = player:get_player_name()
	if wielditem ~= "package:package_blank" then return end
	minetest.chat_send_all(dump(packagetable[name]))
    if fields.addressee == "" or fields.addressee == nil then
        minetest.chat_send_player(name, "Please fill out all required fields.")
        return true
    end
	if not packagetable[name] or packagetable[name] == "" then
		minetest.chat_send_player(name, "Please put your item in the box.")
		return true
	end
    local inv = player:get_inventory()
    local letter = ItemStack('package:package_sealed')
    local blank = ItemStack('package:package_blank')
    local meta = letter:get_meta()

    meta:set_string("sender", name)
    meta:set_string("receiver", fields.addressee)
    meta:set_string("item", packagetable[name])
	packagetable[name] = nil

    local desc = ("Sealed Package\nTo: " .. fields.addressee .. "\nFrom: " .. name)
    meta:set_string("description", desc)

    if fields.attn ~= "" then
        meta:set_string("attn", fields.attn)
        desc = desc .. "\nAttn: " .. fields.attn
        meta:set_string("description", desc)
    end

    if inv:room_for_item("main", letter) and inv:contains_item("main", blank) then
        inv:add_item("main", letter)
        inv:remove_item("main", blank)
    else
        minetest.chat_send_player(name, "Unable to create letter! Check your inventory space.")
    end

    return true
end)

minetest.register_craft({
    type = "shaped",
    output = "package:package_blank 1",
    recipe = {
        {"", "", ""},
        {"default:paper", "default:paper", "default:paper"},
        {"default:paper", "default:paper", "default:paper"}
    }
})
--]]
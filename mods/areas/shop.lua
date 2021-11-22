local form_players = {}
local show_shop_formspec = function(pos, node, clicker, itemstack, pointed_thing)
	if not clicker or not clicker:is_player() then return end
	local name = clicker:get_player_name()
	form_players[name] = pos
	local meta = minetest.get_meta(pos)
	if name == meta:get_string("owner") then
		local form = "size[3,3.5]" ..
		"field[0.5,0.7;1,1;area;Area ID;"..minetest.formspec_escape(meta:get_int("area")).."]" ..
		"field[2,0.7;1,1;price;Price;"..minetest.formspec_escape(meta:get_int("price")).."]" ..
		"field[0.5,1.7;2.5,1;account;Money Recipient;"..minetest.formspec_escape(meta:get_string("account")).."]" ..
		"field[0.5,2.7;2.5,1;notes;Notes;"..minetest.formspec_escape(meta:get_string("notes")).."]"
		minetest.show_formspec(name, "areas:shop", form)
	else
		local form = "size[3,3.5]" ..
		"label[0.25,0.1;"..minetest.formspec_escape("Area: "..meta:get_int("area")).."]" ..
		"label[2,0.1;"..minetest.formspec_escape("Price: "..meta:get_int("price")).."]" ..
		"textarea[0.5,1;2.5,2;notes;Notes;"..minetest.formspec_escape(meta:get_string("notes")).."]"
		
		if not areas:isAreaOwner(meta:get_int("area"),  meta:get_string("owner")) then
			form = form.."button_exit[0.7,2.6;1.8,1;nobuy;Shop Invalid]"
		else
			form = form.."button_exit[0.7,2.6;1.8,1;buy;Buy]"
		end
		minetest.show_formspec(name, "areas:shop", form)
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "areas:shop" then return end
	local name = player:get_player_name()
	local pos = form_players[name]
	form_players[name] = nil
	if not pos then return end
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	local isowner = owner == name
	local area = meta:get_int("area")
	if fields.buy then
		if isowner then
			if math.random(10) == 1 then
				minetest.chat_send_player(name, "You cannot sell an area to yourself, silly.")
			else
				minetest.chat_send_player(name, "You cannot sell an area to yourself.")
			end
			return
		end
		area = tonumber(area)
		if not areas:isAreaOwner(area, owner) then
			minetest.chat_send_player(name, "Area "..area.." does not exist or is not owned by the seller.")
			return false
		end
		local recipient = owner
		if money3.user_exists(meta:get_string("account")) then
			recipient = meta:get_string("account")
		end
		local result = money3.transfer(name, recipient, meta:get_int("price"))
		if not result then
			areas.areas[area].owner = name
			areas:save()
			meta:from_table()
			meta:set_string("owner", name)
			meta:set_string("infotext", "Area Shop (owned by "..name..")")
			minetest.chat_send_player(name, "You successfully bought area ID "..area)
		else
			minetest.chat_send_player(name, result)
			return
		end
	elseif isowner then
		if fields.area and tonumber(fields.area) then
			local area = math.floor(tonumber(fields.area))
			if areas:isAreaOwner(area, name) then
				meta:set_int("area", area)
			end
		end
		if fields.price and tonumber(fields.price) then meta:set_int("price", math.floor(tonumber(fields.price))) end
		if fields.account and money3.user_exists(fields.account) then meta:set_string("account", fields.account) end
		if fields.notes then meta:set_string("notes", fields.notes) end
	end
end)

minetest.register_node("areas:shop",
{
	description = "Area Shop",
	paramtype2 = "facedir",
	tiles = {"areas_shop_top.png",
	        "areas_shop_top.png",
			"areas_shop_side.png",
			"areas_shop_side.png",
			"areas_shop_back.png",
			"areas_shop_front.png"},
	groups = {oddly_breakable_by_hand = 3},
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
		meta:set_string("infotext", "Area Shop (owned by "..meta:get_string("owner")..")")
	end,
	on_rightclick = show_shop_formspec
})

minetest.register_craft({
	type = "shapeless",
	output = "areas:shop",
	recipe = {"currency:shop", "group:book"},
})
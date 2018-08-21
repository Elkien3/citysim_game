-- Font: 04.jp.org

-- load characters map
local chars_file = io.open(minetest.get_modpath("signs").."/characters", "r")
local charmap = {}
local max_chars = 16
if not chars_file then
    print("[signs] E: character map file not found")
else
    while true do
        local char = chars_file:read("*l")
        if char == nil then
            break
        end
        local img = chars_file:read("*l")
        chars_file:read("*l")
        charmap[char] = img
    end
end

local signs = {
    {delta = {x = 0, y = 0, z = 0.399}, yaw = 0},
    {delta = {x = 0.399, y = 0, z = 0}, yaw = math.pi / -2},
    {delta = {x = 0, y = 0, z = -0.399}, yaw = math.pi},
    {delta = {x = -0.399, y = 0, z = 0}, yaw = math.pi / 2},
}

local signs_yard = {
    {delta = {x = 0, y = 0, z = -0.05}, yaw = 0},
    {delta = {x = -0.05, y = 0, z = 0}, yaw = math.pi / -2},
    {delta = {x = 0, y = 0, z = 0.05}, yaw = math.pi},
    {delta = {x = 0.05, y = 0, z = 0}, yaw = math.pi / 2},
}

local sign_groups = {choppy=2, dig_immediate=2}

local construct_sign = function(pos)
    local meta = minetest.env:get_meta(pos)
	meta:set_string("formspec", "field[text;;${text}]")
	meta:set_string("infotext", "")
end

local destruct_sign = function(pos)
    local objects = minetest.env:get_objects_inside_radius(pos, 0.5)
    for _, v in ipairs(objects) do
        if v:get_entity_name() == "signs:text" then
            v:remove()
        end
    end
end

local update_sign = function(pos, fields)
    local meta = minetest.env:get_meta(pos)
	if fields then
		meta:set_string("text", fields.text)
	end
    local text = meta:get_string("text")
    local objects = minetest.env:get_objects_inside_radius(pos, 0.5)
    for _, v in ipairs(objects) do
        if v:get_entity_name() == "signs:text" then
            v:set_properties({textures={generate_texture(create_lines(text))}})
			return
        end
    end
	
	-- if there is no entity
	local sign_info
	if minetest.env:get_node(pos).name == "signs:sign_yard_steel" then
		sign_info = signs_yard[minetest.env:get_node(pos).param2 + 1]
	elseif minetest.env:get_node(pos).name == "default:sign_wall_steel" then
		sign_info = signs[minetest.env:get_node(pos).param2 + 1]
	end
	if sign_info == nil then
		return
	end
	local text = minetest.env:add_entity({x = pos.x + sign_info.delta.x,
										y = pos.y + sign_info.delta.y,
										z = pos.z + sign_info.delta.z}, "signs:text")
	text:setyaw(sign_info.yaw)
end

minetest.register_node(":default:sign_wall_steel", {
    description = "Locked Sign",
    inventory_image = "signs_locked_inv.png",
    wield_image = "signs_locked_inv.png",
    node_placement_prediction = "",
    paramtype = "light",
	sunlight_propagates = true,
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = {type = "fixed", fixed = {-0.45, -0.15, 0.4, 0.45, 0.45, 0.498}},
    selection_box = {type = "fixed", fixed = {-0.45, -0.15, 0.4, 0.45, 0.45, 0.498}},
    tiles = {"signs_locked_top.png", "signs_locked_bottom.png", "signs_locked_side.png", "signs_locked_side.png", "signs_locked_back.png", "signs_locked_front.png"},
    groups = sign_groups,

    on_place = function(itemstack, placer, pointed_thing)
        local above = pointed_thing.above
        local under = pointed_thing.under
        local dir = {x = under.x - above.x,
                     y = under.y - above.y,
                     z = under.z - above.z}

        local wdir = minetest.dir_to_wallmounted(dir)

        local placer_pos = placer:getpos()
        if placer_pos then
            dir = {
                x = above.x - placer_pos.x,
                y = above.y - placer_pos.y,
                z = above.z - placer_pos.z
            }
        end

        local fdir = minetest.dir_to_facedir(dir)

        local sign_info
		
		if minetest.env:get_node(above).name == "air" then
		
        if wdir == 0 then
            --how would you add sign to ceiling?
            minetest.env:add_item(above, "default:sign_wall_steel")
			itemstack:take_item()
			return itemstack
        elseif wdir == 1 then
            minetest.env:add_node(above, {name = "signs:sign_yard_steel", param2 = fdir})
            sign_info = signs_yard[fdir + 1]
        else
            minetest.env:add_node(above, {name = "default:sign_wall_steel", param2 = fdir})
            sign_info = signs[fdir + 1]
        end

        local text = minetest.env:add_entity({x = above.x + sign_info.delta.x,
                                              y = above.y + sign_info.delta.y,
                                              z = above.z + sign_info.delta.z}, "signs:text")
        text:setyaw(sign_info.yaw)
		
		local meta = minetest.get_meta(above)
		local owner = placer:get_player_name()
		meta:set_string("owner", owner)
		meta:set_string("infotext", ("Locked sign (Owned by "..owner..")"))
		
		itemstack:take_item()
        return itemstack
		end
    end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local owner = meta:get_string("owner")
		return player:get_player_name() == owner or owner == ""
	end,
    on_construct = function(pos)
        construct_sign(pos)
    end,
    on_destruct = function(pos)
        destruct_sign(pos)
    end,
    on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos);
		local owner = meta:get_string("owner")
		if sender:get_player_name() == owner or owner == "" then		
			update_sign(pos, fields)
		end
    end,
	on_punch = function(pos, node, puncher)
		local meta = minetest.get_meta(pos);
		local owner = meta:get_string("owner")
		if puncher:get_player_name() == owner or owner == "" then		
			update_sign(pos, fields)
		end
	end,
})

minetest.register_node("signs:sign_yard_steel", {
    paramtype = "light",
	sunlight_propagates = true,
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = {type = "fixed", fixed = {
        {-0.45, -0.15, -0.049, 0.45, 0.45, 0.049},
        {-0.05, -0.5, -0.049, 0.05, -0.15, 0.049}
    }},
    selection_box = {type = "fixed", fixed = {-0.45, -0.15, -0.049, 0.45, 0.45, 0.049}},
    tiles = {"signs_locked_top.png", "signs_locked_bottom.png", "signs_locked_side.png", "signs_locked_side.png", "signs_locked_back.png", "signs_locked_front.png"},
    groups = {choppy=2, dig_immediate=2},
    drop = "default:sign_wall_steel",
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local owner = meta:get_string("owner")
		return player:get_player_name() == owner or owner == ""
	end,
    on_construct = function(pos)
        construct_sign(pos)
    end,
    on_destruct = function(pos)
        destruct_sign(pos)
    end,
    on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos);
		local owner = meta:get_string("owner")
		if sender:get_player_name() == owner or owner == "" then		
			update_sign(pos, fields)
		end
    end,
	on_punch = function(pos, node, puncher)
		local meta = minetest.get_meta(pos);
		local owner = meta:get_string("owner")
		if puncher:get_player_name() == owner or owner == "" then		
			update_sign(pos, fields)
		end
	end,
})

if minetest.setting_get("log_mods") then
	minetest.log("action", "locked signs loaded")
end

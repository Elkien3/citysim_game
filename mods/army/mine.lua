--Mine Mod

minetest.register_craft({
	output = "army:mine 2",
	recipe = {
		{"default:coal_lump", "default:gravel", "default:coal_lump"},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
	}
})

local countdown_time = 10

minetest.register_node("army:mine", {
	description	 = "Mine",
	drawtype = "nodebox",
	inventory_image	 = "army_mine_inv.png",
	tiles = {
		"army_mine_inactive_top.png", 
		"army_mine_base.png",
		"army_mine_inactive_side.png"
	},
	paramtype = "light",
	groups = {oddly_breakable_by_hand=2},
	node_box = {
		type = "fixed",
		fixed = {
		{-.25,-.5,-.25,.25,-.375,.25},
		}
	},
	on_punch = function (pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_int("Counting_Down", 1)
		meta:set_int("Time_Until_Activation", countdown_time)
	end,
})

minetest.register_node("army:active_mine", {
	drawtype = "nodebox",
	inventory_image	 = "army_mine_inv.png",
	tiles = {
		"army_mine_active_top.png", 
		"army_mine_base.png",
		"army_mine_active_side.png"
	},
	paramtype = "light",
	groups = {oddly_breakable_by_hand=2},
	node_box = {
		type = "fixed",
		fixed = {
		{-.25,-.5,-.25,.25,-.375,.25},
		}
	},
	on_punch = function (pos)
		local node_name = "army:active_mine"
		local self = "not_an_entity"
		local mine_damage = 1
		local detection_radius = 5
		explode(pos, node_name, self, mine_damage, detection_radius)
		local node = minetest.get_node(pos)
		node.name = ("fire:basic_flame")
		minetest.add_node(pos,node)
	end,
})
minetest.register_abm({
	nodenames = {"army:active_mine"},
	interval = 1,
	chance = 1,
	action = function(pos)
		local node_name = "army:active_mine"
		local self = "not_an_entity"
		local mine_damage = 1
		local detection_radius = 5
		explode(pos, node_name, self, mine_damage, detection_radius)
	end,
})

minetest.register_abm({
	nodenames = {"army:mine"},
	interval = 1,
	chance = 1,
	action = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_int("Counting_Down") == 1 then
			if meta:get_int("Time_Until_Activation")>0 then
				meta:set_int("Time_Until_Activation", meta:get_int("Time_Until_Activation")-1)
			else
				local node = minetest.get_node(pos)
				node.name = ("army:active_mine")
				minetest.add_node(pos,node)
			end
		end
	end,
})

local mine_damage=8
local detection_radius = 5

explode = function (pos, node_name, self, mine_damage, detection_radius)
	local distance_damaging = detection_radius
	local objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, detection_radius)
	for k, obj in pairs(objs) do
		while distance_damaging>0 do 
			local player_pos = obj:getpos()
			local node_name = node_name
	    	if check_if_path_clear(pos, node_name, player_pos) == true and obj:get_player_name()~="" then		
				obj:set_hp(obj:get_hp()-mine_damage)					
			end
			distance_damaging=distance_damaging - 1
			if obj:get_hp()<=0 then 
				obj:remove()
			end
		end
		if self == "not_an_entity" then
			add_fire(pos)
		else
			self.object:remove()
		end
		minetest.dig_node(pos)
	end
end

check_if_path_clear = function(pos, node_name, player_pos)
	local scanning = true
    local player_pos=player_pos
    local distance_scanning = 1
    local player_pos_x=player_pos.x-pos.x
    local player_pos_y=player_pos.y-pos.y
    local player_pos_z=player_pos.z-pos.z
    while  scanning==true do
	local node_being_scanned = {x=player_pos_x*distance_scanning + pos.x,y=player_pos_y*distance_scanning + pos.y,z=player_pos_z*distance_scanning + pos.z}
        if minetest.get_node(node_being_scanned).name == "air" or minetest.get_node(node_being_scanned).name == node_name then
            if distance_scanning > .3 then
                distance_scanning=distance_scanning-.1
                local node_being_scanned = {x=player_pos_x*distance_scanning + pos.x,y=player_pos_y*distance_scanning + pos.y,z=player_pos_z*distance_scanning + pos.z}
            else
				scanning=false
                return true
            end
        else
			scanning=false
            return false
        end
    end
end

add_fire = function(pos)
		local node = minetest.get_node(pos)
		node.name = ("fire:basic_flame")
		minetest.add_node(pos,node)
end

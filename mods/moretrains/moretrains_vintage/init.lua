local S
if minetest.get_modpath("intllib") then
    S = intllib.Getter()
else
    S = function(s,a,...)a={a,...}return s:gsub("@(%d+)",function(n)return a[tonumber(n)]end)end
end



advtrains.register_wagon("moretrains_draisine", {
	mesh="moretrains_draisine.b3d",
	textures = {"moretrains_vintage.png"},
	drives_on={default=true},
	max_speed=3,
	seats = {
		{
			name=S("Driver stand"),
			attach_offset={x=0, y=1, z=-8.7},
			view_offset={x=0, y=1.5, z=-1},
			group="dstand",
		},
		{
			name="1",
			attach_offset={x=0, y=1, z=8.7},
			view_offset={x=0, y=1.5, z=1},
			group="pass",
		},
	},
	seat_groups = {
		dstand={
			name = "Driver Stand",
			access_to = {"pass"},
			require_doors_open=true,
			driving_ctrl_access=true,
		},
		pass={
			name = "Passenger area",
			access_to = {"dstand"},
			require_doors_open=true,
		},
	},
	assign_to_seat_group = {"dstand", "pass"},
	visual_size = {x=1, y=1},
	wagon_span=1.06,
	is_locomotive=true,
	collisionbox = {-0.8,-0.5,-0.7, 0.8,2,0.7},
	custom_on_velocity_change=function(self, velocity)
		if self.old_anim_velocity~=advtrains.abs_ceil(velocity) then
			self.object:set_animation({x=1,y=80}, advtrains.abs_ceil(velocity)*14, 0, true)
			self.old_anim_velocity=advtrains.abs_ceil(velocity)
		end
	end,
	drops={"default:wood"},
}, S("Draisine"), "moretrains_draisine_inv.png")

--[[
advtrains.register_wagon("moretrains_minecart", {
	mesh="moretrains_minecart.b3d",
	textures = {"moretrains_vintage.png"},
	drives_on={default=true},
	max_speed=6,
	seats = {},
	visual_size = {x=1, y=1},
	wagon_span=1.06,
	collisionbox = {-0.8,-0.5,-0.7, 0.8,2,0.7},
	drops={"default:wood"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=1*4,
	},
}, S("Minecart"), "moretrains_minecart_inv.png")

advtrains.register_wagon("moretrains_minecart_loaded", {
	mesh="moretrains_minecart_loaded.b3d",
	textures = {"moretrains_vintage.png"},
	drives_on={default=true},
	max_speed=6,
	seats = {},
	visual_size = {x=1, y=1},
	wagon_span=1.06,
	collisionbox = {-0.8,-0.5,-0.7, 0.8,2,0.7},
	drops={"default:wood"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=1*4,
	},

}, S("Minecart (loaded)"), "moretrains_minecart_loaded_inv.png")


advtrains.register_wagon("moretrains_minecart_engine", {
	mesh="moretrains_minecart_engine.b3d",
	textures = {"moretrains_vintage.png"},
	drives_on={default=true},
	max_speed=6,
	seats = {
		{
			name=S("Driver stand"),
			attach_offset={x=0, y=2, z=5.5},
			view_offset={x=0, y=1.5, z=-1},
			group="dstand",
		},
		{
			name="1",
			attach_offset={x=0, y=2, z=0.5},
			view_offset={x=0, y=1.5, z=1},
			group="pass",
		},
	},
	seat_groups = {
		dstand={
			name = "Driver Stand",
			access_to = {"pass"},
			require_doors_open=true,
			driving_ctrl_access=true,
		},
		pass={
			name = "Passenger area",
			access_to = {"dstand"},
			require_doors_open=true,
		},
	},
	assign_to_seat_group = {"dstand", "pass"},
	
	visual_size = {x=1, y=1},
	wagon_span=1.06,
	is_locomotive=true,
	collisionbox = {-0.8,-0.5,-0.7, 0.8,2,0.7},
	drops={"default:wood"},
	
}, S("Minecart with Engine"), "moretrains_minecart_engine_inv.png")
--]]
minetest.register_craftitem("moretrains_vintage:item_draisine_lever", {
	description = S("lever for draisine"),
	inventory_image = "moretrains_item_lever.png"
})

minetest.register_craft({
	output = "moretrains_vintage:item_draisine_lever",
	recipe = {
		{"default:steel_ingot", "default:stick", "default:steel_ingot"},
		{"", "default:stick", ""},
		{"", "default:steel_ingot", ""},
	},
})

minetest.register_craft({
	output = 'advtrains:moretrains_draisine',
	recipe = {
		{'', 'moretrains_vintage:item_draisine_lever', ''},
		{'group:wood', 'group:wood', 'group:wood'},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})
--[[
minetest.register_craft({
	output = 'advtrains:moretrains_minecart',
	recipe = {
		{'group:wood', '', 'group:wood'},
		{'default:steel_ingot', 'group:wood', 'default:steel_ingot'},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})

minetest.register_craft({
	output = 'advtrains:moretrains_minecart_loaded',
	recipe = {
		{'group:wood', 'default:coalblock', 'group:wood'},
		{'default:steel_ingot', 'group:wood', 'default:steel_ingot'},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})

minetest.register_craft({
	output = 'advtrains:moretrains_minecart_engine',
	recipe = {
		{'group:wood', '', 'group:wood'},
		{'default:steel_ingot', 'group:wood', 'default:steel_ingot'},
		{'advtrains:wheel', 'default:steelblock', 'advtrains:wheel'},
	},
})

minetest.register_craft({
	output = "advtrains:moretrains_minecart_loaded",
	type = "shapeless",
	recipe = {"advtrains:moretrains_minecart", "default:coalblock"},
})

minetest.register_craft({
	output = "advtrains:moretrains_minecart_engine",
	type = "shapeless",
	recipe = {"advtrains:moretrains_minecart", "default:steelblock"},
})

--]]

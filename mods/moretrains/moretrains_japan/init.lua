local S
if minetest.get_modpath("intllib") then
    S = intllib.Getter()
else
    S = function(s,a,...)a={a,...}return s:gsub("@(%d+)",function(n)return a[tonumber(n)]end)end
end

advtrains.register_wagon("moretrains_engine_japan", {
	mesh="moretrains_japan_bullet_engine.b3d",
	textures = {"moretrains_engine_japan.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name=S("Driver stand"),
			attach_offset={x=1, y=1, z=0},
			view_offset={x=0, y=1.5, z=0},
			group="dstand",
		},
		{
			name="1",
			attach_offset={x=-4, y=-2, z=0},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=4, y=-2, z=0},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-4, y=-2, z=-8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=4, y=-2, z=-8},
			view_offset={x=0, y=-2, z=0},
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
	doors={
		open={
			[-1]={frames={x=0, y=10}, time=1},
			[1]={frames={x=20, y=30}, time=1}
		},
		close={
			[-1]={frames={x=10, y=20}, time=1},
			[1]={frames={x=30, y=40}, time=1}
		}
	},
	door_entry={-1.7},
	visual_size = {x=1, y=1},
	wagon_span=3.18,
	is_locomotive=true,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
	horn_sound = "moretrains_japan_horn",
}, S("Japanese Train Engine (moretrains)"), "moretrains_engine_japan_inv.png")

advtrains.register_wagon("moretrains_wagon_japan", {
	mesh="moretrains_japan_bullet_wagon.b3d",
	textures = {"moretrains_wagon_japan.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name="1",
			attach_offset={x=-4, y=-2, z=8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=4, y=-2, z=8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="1a",
			attach_offset={x=-4, y=-2, z=0},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="2a",
			attach_offset={x=4, y=-2, z=0},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-4, y=-2, z=-8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=4, y=8, z=-8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
	},
	seat_groups = {
		pass={
			name = "Passenger area",
			access_to = {},
			require_doors_open=true,
		},
	},
	assign_to_seat_group = {"pass"},
	doors={
		open={
			[-1]={frames={x=0, y=10}, time=1},
			[1]={frames={x=20, y=30}, time=1}
		},
		close={
			[-1]={frames={x=10, y=20}, time=1},
			[1]={frames={x=30, y=40}, time=1}
		}
	},
	door_entry={-1.7, 1.7},
	visual_size = {x=1, y=1},
	wagon_span=3.0,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
}, S("Japanese Train Wagon (moretrains)"), "moretrains_wagon_japan_inv.png")

minetest.register_craft({
	output = 'advtrains:moretrains_wagon_japan',
	recipe = {
		{'default:steelblock', 'default:steel_ingot', 'default:steelblock'},
		{'default:glass', 'dye:green', 'default:glass'},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})

minetest.register_craft({
	output = 'advtrains:moretrains_engine_japan',
	recipe = {
		{'default:steelblock', 'default:steelblock', ''},
		{'default:glass', 'dye:green', 'default:glass'},
		{'advtrains:wheel', 'advtrains:wheel', 'advtrains:wheel'},
	},
})


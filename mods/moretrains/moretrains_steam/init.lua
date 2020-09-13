local S
if minetest.get_modpath("intllib") then
    S = intllib.Getter()
else
    S = function(s,a,...)a={a,...}return s:gsub("@(%d+)",function(n)return a[tonumber(n)]end)end
end

-- length of the steam engine loop sound
local SND_LOOP_LEN = 5

advtrains.register_wagon("moretrains_steam_train", {
	mesh="moretrains_steam_train.b3d",
	textures = {"moretrains_steam_train.png"},
	is_locomotive=true,
	drives_on={default=true},
	max_speed=11,
	seats = {
		{
			name=S("Driver Stand (left)"),
			attach_offset={x=-5, y=0, z=-15},
			view_offset={x=0, y=6, z=0},
			group = "dstand",
		},
		{
			name=S("Driver Stand (right)"),
			attach_offset={x=5, y=0, z=-15},
			view_offset={x=0, y=6, z=0},
			group = "dstand",
		},
	},
	seat_groups = {
		dstand={
			name = "Driver Stand",
			driving_ctrl_access=true,
			access_to = {},
		},
	},
	assign_to_seat_group = {"dstand"},
	visual_size = {x=1, y=1},
	wagon_span=2.567,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	custom_on_velocity_change=function(self, velocity)
		if self.old_anim_velocity~=advtrains.abs_ceil(velocity) then
			self.object:set_animation({x=1,y=80}, advtrains.abs_ceil(velocity)*22, 0, true)
			self.old_anim_velocity=advtrains.abs_ceil(velocity)
		end
	end,
	custom_on_step=function(self, dtime)
		if self:train().velocity > 0 then -- First make sure that the train isn't standing
			if not self.sound_loop_tmr or self.sound_loop_tmr <= 0 then
				-- start the sound if it was never started or has expired
				self.sound_loop_handle = minetest.sound_play({name="advtrains_steam_loop", gain=2}, {object=self.object})
				self.sound_loop_tmr = SND_LOOP_LEN
			end
			--decrease the sound timer
			self.sound_loop_tmr = self.sound_loop_tmr - dtime
		else
			-- If the train is standing, the sound will be stopped in some time. We do not need to interfere with it.
			self.sound_loop_tmr = nil
		end
	end,
	custom_on_activate = function(self, staticdata_table, dtime_s)
		minetest.add_particlespawner({
			amount = 10,
			time = 0,
		--  ^ If time is 0 has infinite lifespan and spawns the amount on a per-second base
			minpos = {x=0, y=2.15, z=1.95},
			maxpos = {x=0, y=2.2, z=1.9},
			minvel = {x=-0.2, y=1.8, z=-0.2},
			maxvel = {x=0.2, y=2, z=0.2},
			minacc = {x=0, y=-0.1, z=0},
			maxacc = {x=0, y=-0.3, z=0},
			minexptime = 2,
			maxexptime = 4,
			minsize = 1,
			maxsize = 5,
		--  ^ The particle's properties are random values in between the bounds:
		--  ^ minpos/maxpos, minvel/maxvel (velocity), minacc/maxacc (acceleration),
		--  ^ minsize/maxsize, minexptime/maxexptime (expirationtime)
			collisiondetection = true,
		--  ^ collisiondetection: if true uses collision detection
			vertical = false,
		--  ^ vertical: if true faces player using y axis only
			texture = "smoke_puff.png",
		--  ^ Uses texture (string)
			attached = self.object,
		})
	end,
	drops={"default:steelblock 1"},
	horn_sound = "advtrains_steam_whistle",
}, S("Steam Train #1"), "moretrains_steam_train_inv.png")

advtrains.register_wagon("moretrains_tender", {
	mesh="moretrains_steam_tender.b3d",
	textures = {"moretrains_steam_tender.png"},
	drives_on={default=true},
	max_speed=30,
	seats = {},
	visual_size = {x=1, y=1},
	wagon_span=1.667,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock 1"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=1*8,
	},
}, S("Tender #1"), "moretrains_steam_tender_inv.png")



minetest.register_craft({
	output = 'advtrains:moretrains_steam_train',
	recipe = {
		{'', '', 'advtrains:chimney'},
		{'advtrains:driver_cab', 'dye:blue', 'advtrains:boiler'},
		{'advtrains:wheel', 'advtrains:wheel', 'advtrains:wheel'},
	},
})

minetest.register_craft({
	output = 'advtrains:moretrains_tender',
	recipe = {
		{'default:steel_ingot', 'default:coalblock', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})


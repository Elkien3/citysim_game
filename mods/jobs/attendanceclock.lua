jobs.punches = minetest.deserialize(jobs.storage:get_string("punches")) or {}
local context = {}
local punch_tick = 5 -- in seconds
local grace_period = 5 -- in minutes
local loglength = 7 -- in days
jobs.punchlogs = minetest.deserialize(jobs.storage:get_string("punchlogs")) or {}

local function get_table_length(tbl)
	local i = 0
	for index, val in pairs(tbl) do
		i = i + 1
	end
	return i
end

for jobname, table in pairs(jobs.punchlogs) do
	local currenttime = os.time()
	for time, message in pairs(table) do
		if currenttime-time > loglength*24*60*60 then
			jobs.punchlogs[jobname][time] = nil
		end
	end
	if get_table_length(jobs.punchlogs[jobname]) == 0 then
		jobs.punchlogs[jobname] = nil
	end
	jobs.storage:set_string("punchlogs", minetest.serialize(jobs.punchlogs))
end

local function employee_form(punchedin, name, jobname, radius, maxshift)
	local rank = jobs.players[name][jobname]
	local pay = jobs.list[jobname].pay
	if pay then pay = pay[rank] end
	if not pay then pay = "not set up." else pay = pay.."/hr" end
	local form =
		"size[5,3]" ..
		"label[.5,0.5;you are "..minetest.formspec_escape(rank).." in '"..minetest.formspec_escape(jobname).."'\\, wage is "..pay.."]" ..
		"label[.5,2;max shift: "..maxshift.." hr]" ..
		"label[.5,2.5;radius: "..radius.."]"
		if punchedin then
			local amount = jobs.round(jobs.punches[name].amount, 2)
			form = form.."button_exit[.5,1;1.5,1;punch;Punch Out]" ..
				"label[2.5,1.2;current shift: "..amount.."]"
		else
			form = form.."button_exit[.5,1;1.5,1;punch;Punch In]"
		end
	return form
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "jobs_attendanceclock" then
        return
    end
    if fields.punch then
		local name = player:get_player_name()
        jobs.punch(name, context[name])
		context[name] = nil
    end
end)

function jobs.punch(name, pos)
	if not name or not pos then return end
	local meta = minetest.env:get_meta(pos)
	if not meta then return end
	local jobname = meta:get_string("jobname")
	if jobname == "" or not jobs.list[jobname] then return end
	if not jobs.list[jobname].pay then return end
	if jobs.punches[name] and jobs.punches[name].jobname == jobname then
		local amount = jobs.round(jobs.punches[name].amount, 2)
		local result = money3.transfer(":"..jobname, name, amount)
		if not result then --transferred without an error
			local message = name.." ("..jobs.players[name][jobname]..") was payed "..amount
			if not jobs.punchlogs[jobname] then jobs.punchlogs[jobname] = {} end
			if jobs.punchlogs[jobname][os.time()] then
				i = os.time()
				while jobs.punchlogs[jobname][i] ~= nil do
					i = i + 1
				end
				jobs.punchlogs[jobname][i] = message
			else
				jobs.punchlogs[jobname][os.time()] = message
			end
			jobs.storage:set_string("punchlogs", minetest.serialize(jobs.punchlogs))
		end
		minetest.chat_send_player(name, result or "You got payed "..amount)
		jobs.punches[name] = nil
	--elseif jobs.list[jobname].ceo == name then
	--	minetest.chat_send_player(name, "You cannot punch into a job you own.")
	--	punches[name] = nil
	else
		jobs.punches[name] = {}
		jobs.punches[name].jobname = jobname
		jobs.punches[name].amount = 0
		jobs.punches[name].pos = pos
		local maxshift = tonumber(meta:get_string("maxshift"))
		if maxshift and maxshift > 0 then
			jobs.punches[name].shifttime = maxshift*60*60
		end
		local radius = tonumber(meta:get_string("radius"))
		if radius and radius > 0 then
			jobs.punches[name].dist = radius
		end
		minetest.chat_send_player(name, "Punched into '"..jobname.."'")
	end
	jobs.storage:set_string("punches", minetest.serialize(jobs.punches))
end

local function update_punches()
	for name, data in pairs(jobs.punches) do
		local jobname = data.jobname
		if not jobname or not jobs.list[jobname] then jobs.punches[name] = nil return end
		local pos = data.pos
		local player = minetest.get_player_by_name(name)
		if data.dist then
			if player and vector.distance(pos, player:getpos()) > data.dist then
				jobs.punch(name, pos)
				return
			end
		end
		if not jobs.players[name][jobname] then jobs.punches[name] = nil return end
		if not jobs.list[jobname].pay then jobs.punches[name] = nil return end
		if not jobs.list[jobname].pay[jobs.players[name][jobname]] then jobs.punches[name] = nil return end
		local pay = jobs.list[jobname].pay[jobs.players[name][jobname]]
		if player then--todo check if player is inactive/afk
			if data.inactivetime then data.inactivetime = nil end
			data.amount = data.amount + (punch_tick*(pay/60/60))
			if data.shifttime then
				data.shifttime = data.shifttime - punch_tick
				if data.shifttime <= 0 then
					jobs.punch(name, pos)
					return
				end
			end
		else
			if not data.inactivetime then data.inactivetime = 0 end
			data.inactivetime = data.inactivetime + punch_tick
			if data.inactivetime > grace_period*60 then
				jobs.punch(name, pos)
			end
		end
	end
	jobs.storage:set_string("punches", minetest.serialize(jobs.punches))
	minetest.after(punch_tick, update_punches)
end
update_punches()

local setup_form =
    "size[5,5]" ..
    "label[0.5,0.25;Attendance Clock Setup]" ..
    "field[0.5,1.5;4.5,1;jobname;Job Name;]" ..
    "field_close_on_enter[jobname;false]" ..
    "field[0.5,2.5;4.5,1;radius;Auto punch out distance. (0 to disable);0]" ..
    "field_close_on_enter[radius;false]" ..
    "field[0.5,3.5;4.5,1;maxshift;Maximum shift length (in hours, 0 to disable);4]" ..
    "field_close_on_enter[maxshift;false]" ..
    "button_exit[3,4;2,1;accept;Accept]"

minetest.register_node("jobs:clock", {
	description = "Attendance Clock",
	tiles = {
		"jobs_clock_side.png",
		"jobs_clock_side.png",
		"jobs_clock_side.png",
		"jobs_clock_side.png",
		"jobs_clock_side.png",
		"jobs_clock_front.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = true,
	inventory_image = "jobs_clock_front.png",
	node_box = {
		type = "fixed",
		fixed = { -5/16, -6/16, 5/16, 5/16, 2/16, 7/16 }
	},
	digiline = 
	{
		receptor={},
	},
	groups = {oddly_breakable_by_hand = 3},
	sounds = default.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local meta = minetest.env:get_meta(pos)
		if meta:get_string("formspec") ~= "" then return end
		local name = clicker:get_player_name()
		if not name or not meta then return end
		local jobname = meta:get_string("jobname")
		if not jobname or not jobs.list[jobname] then
			meta:set_string("formspec", setup_form)
		end
		if not jobs.players[name] or not jobs.players[name][jobname] then return end
		
		context[name] = pos
		local punchedin = false
		if jobs.punches[name] and jobs.punches[name].jobname and jobs.punches[name].jobname == jobname then punchedin = true end
		minetest.show_formspec(name, "jobs_attendanceclock", employee_form(punchedin, name, jobname, meta:get_string("radius"), meta:get_string("maxshift")))
	end,
	on_construct = function(pos, placer, itemstack, pointed_thing)	--Initialize some variables (local per instance)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("infotext", "Attendance Clock not set up.")
		meta:set_string("formspec", setup_form)
	end,
	on_receive_fields = function(pos, formname, fields, player)
        local meta = minetest.env:get_meta(pos)
		local name = player:get_player_name()
		if not name or not meta then return end
		if fields.jobname and jobs.list[fields.jobname] and fields.radius and tonumber(fields.radius) and fields.maxshift and tonumber(fields.maxshift) then
			meta:set_string("jobname", fields.jobname)
			meta:set_string("radius", fields.radius)
			meta:set_string("maxshift", fields.maxshift)
			meta:set_string("formspec", nil)
			meta:set_string("infotext", "Attendance Clock for '"..fields.jobname.."'")
		end
    end
})

if minetest.get_modpath("mesecons_button") and minetest.get_modpath("mesecons_luacontroller") and minetest.get_modpath("ontime_clocks") then
	minetest.register_craft({
		recipe = {
			{"ontime_clocks:green_digital", "mesecons_luacontroller:luacontroller0000"},
			{"mesecons_button:button_off", "mesecons_button:button_off"},
		},
		output = "jobs:clock 3"
	})
else
	minetest.register_craft({
		recipe = {
			{"default:glass", "default:sign_wall_steel"},
			{"default:mese_crystal_fragment", "default:mese_crystal_fragment"},
		},
		output = "jobs:clock 3"
	})
end
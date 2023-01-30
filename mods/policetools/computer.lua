local policejobname = minetest.settings:get("jobs.police_job_name")
local alarm_discord_channel = minetest.settings:get("alarm_discord_channel")
local alarm_discord_role = minetest.settings:get("alarm_discord_role")
if not policejobname or policejobname == "" then policejobname = "Police" end
local storage = minetest.get_mod_storage()
local form_table = {}

local approvals = minetest.deserialize(storage:get_string("approvals")) or {}
local warrants = minetest.deserialize(storage:get_string("warrants")) or {}
local citations = minetest.deserialize(storage:get_string("citations")) or {}
local alarms = minetest.deserialize(storage:get_string("alarms")) or {}

local function esc(s)
	return string.gsub(string.gsub(tostring(s),
			"%^", "\\^"), ":", "\\:")
end

local function get_custom_skin(name)--copied/edited code from charactercreation
	local sd = charactercreation_getskin(name)
	local skin
	if spood_get_effect then
		local speed, sideeffect = spood_get_effect(name)
		local opacity = math.min(sideeffect*25, 255)--if you take 10 spood at once youll get full overlay
		skin = "((skin"..sd.skintype..".png^(spoodcharacteroverlay.png^[opacity:"..opacity.."))^[multiply:#"..sd.skincolor..")"
	else
		skin = "(skin"..sd.skintype..".png^[multiply:#"..sd.skincolor..")"
	end
	local eyes = "eye"..sd.eyetype..".png^(eye"..sd.eyetype.."color.png^[multiply:#"..sd.eyecolor..")"
	local face = "(face"..sd.facetype..".png^[multiply:#"..sd.facecolor..")"
	local hair = "(hair"..sd.hairtype..".png^[multiply:#"..sd.haircolor..")"
	local h = sd.height or 100
	local w = sd.width or 100
	return skin.."^"..eyes.."^"..face.."^"..hair, h, w
end

local function get_police_rank(name)
	local coc = jobs.chainofcommand--{intern = 1, employee = 2, supervisor = 3, ceo = 4}
	local rank = jobs.getrank(name, policejobname)
	if rank then
		rank = coc[rank]
	else
		rank = 0
	end
	return rank
end

local function is_police(name)
	return get_police_rank(name) > 0
end

local function is_recruit(name)
	return get_police_rank(name) == 1
end

local function get_laws_string()
	local str = ""
	if laws then
		for i, tbl in pairs(laws) do
			if tbl.name then
				if str == "" then
					str = tbl.name
				else
					str = str..","..tbl.name
				end
			end
		end
	end
	return str
end

local function get_time_string(timeint)
	local timeago = os.time()-timeint
	
	--t is type, d is divide value, a is accuracy
	local timetbl = {{t = "day", d = 86400, a = .01}, {t = "hour", d = 3600, a = .01}, {t = "minute", d = 60, a = .1}, {t = "second", d = 1, a = 1}}
	
	for i, tbl in pairs(timetbl) do
		if timeago >= tbl.d then
			local var = math.floor((timeago/tbl.d)/tbl.a)*tbl.a
			if var == 1 then
				return var.." "..(tbl.t)
			else
				return var.." "..(tbl.t).."s"
			end
		end
	end
	return "0 seconds"
end

local cars_list = {}
if cars then
	for carname, def in pairs(cars_registered_cars) do
		table.insert(cars_list, carname)
	end
end

local function tbl_length(tbl)
	i = 0
	for index, val in pairs(tbl) do
		i = i + 1
	end
	return i
end

local function fix_approval_ids(name, id, is_citation)
	local save = false
	for appid, apptbl in pairs(approvals) do
		if apptbl.id and apptbl.subject == name and ((apptbl.fine and is_citation) or (not apptbl.fine and not is_citation)) then
			if id < apptbl.id then
				approvals[appid].id = approvals[appid].id - 1
				save = true
			end
		end
	end
	if save then
		storage:set_string("approvals", minetest.serialize(approvals))
	end
end

local pages = {}
function pages.main(name)--todo new activity indicators
	local form = "size[10,8]" ..
	"button[0.5,0.5;2,1;warrants;Warrants]" ..
	"button[0.5,1.25;2,1;citations;Citations]" ..
	"button[0.5,2;2,1;alarms;Alarms]" ..
	"button[0.5,2.75;2,1;namelookup;Name Lookup]" ..
	"button[0.5,3.5;2,1;carlookup;Car Lookup]"
	if get_police_rank(name) > 1 then
		form = form.."button[0.5,4.25;2,1;approvals;Approvals]"
	end
	return form
end

function pages.add_warrant(name)
	if not is_police(name) then return "" end
	local name_default = form_table[name].name or ""
	local form = "dropdown[6,1;3,1;lawname;"..get_laws_string()..";1]" ..
	"field[3,1.2;3.5,1;name;Insert Name;"..minetest.formspec_escape(name_default).."]" ..
	"button[6,2;1,1;finish;Finish]" ..
	"button[3,2;3,1;finishadd;Finish and Add Another]" ..
	"label[6,0.6;Insert Law]"
	return form
end

function pages.add_citation(name)
	if not is_police(name) then return "" end
	local name_default = form_table[name].name or ""
	local form = "dropdown[6,1;3,1;lawname;"..get_laws_string()..";1]" ..
	"field[3,1.2;3.5,1;name;Insert Name;"..minetest.formspec_escape(name_default).."]" ..
	"button[6,3.25;1,1;finish;Finish]" ..
	"button[3,3.25;3,1;finishadd;Finish and Add Another]" ..
	"label[6,0.6;Insert Law]" ..
	"field[3,2.5;3.5,1;fine;Fine Amount;]"
	return form
end

function pages.warrants(name)
	local form = "scrollbaroptions[max="..((tbl_length(warrants)-8)*12 ).."]"..
	"scrollbar[9.5,0.125;0.3,7;vertical;scroll;0"..
	"]scroll_container[3.5,.5;8.5,8;scroll;vertical;.1]"
	local y = 0
	for name2, tbl in pairs(warrants) do
		local infostring = ""
		for i, tbl2 in pairs(tbl) do
			if not tbl2.cleartime then--cleartime means it was deleted
				if infostring == "" then
					infostring = name2..": "..tbl2.law
				else
					infostring = infostring..", "..tbl2.law
				end
			end
		end
		if infostring ~= "" then
			form = form.."field[0,"..tostring(y+0.3)..";6,1;warrantinfo:"..name2..";;"..minetest.formspec_escape(infostring).."]" ..
			"field_close_on_enter[warrantinfo:"..name2..";false]" ..
			"button[5.5,"..tostring(y)..";1,1;goto:"..name2..";\\[   \\]]"
			y = y + 1
		end
	end
	form = form.."scroll_container_end[]"
	if is_police(name) then
		form = form.."button[2.5,7.25;2,1;add_warrant;Add Warrant]"
	end
	return form
end

function pages.citations(name)
	local form = "scrollbaroptions[max="..((tbl_length(citations)-8)*12 ).."]"..
	"scrollbar[9.5,0.125;0.3,7;vertical;scroll;0"..
	"]scroll_container[3.5,.5;8.5,8;scroll;vertical;.1]"
	local y = 0
	for name2, tbl in pairs(citations) do
		local infostring = name2..": "
		for i, tbl2 in pairs(tbl) do
			if i ~= 1 then
				infostring = infostring..", "
			end
			infostring = infostring..tbl2.law..":"..tbl2.fine
		end
		form = form.."field[0,"..tostring(y+0.3)..";6,1;citationinfo:"..name2..";;"..minetest.formspec_escape(infostring).."]" ..
		"field_close_on_enter[citationinfo:"..name2..";false]" ..
		"button[5.5,"..tostring(y)..";1,1;goto:"..name2..";\\[   \\]]"
		y = y + 1
	end
	form = form.."scroll_container_end[]"
	if is_police(name) then
		form = form.."button[2.5,7.25;2,1;add_citation;Add Citation]"
	end
	return form
end

function pages.alarms(name)
	local form = "scrollbaroptions[max="..((tbl_length(alarms)-8)*12 ).."]"..
	"scrollbar[9.5,0.125;0.3,7;vertical;scroll;0"..
	"]scroll_container[3.5,.5;8.5,8;scroll;vertical;.1]"
	local y = 0
	for id, tbl in pairs(alarms) do--active
		if not tbl.clearer then
			local infostring = string.format("owner: %s, %s ago, loc: %s, desc: %s", tbl.owner, get_time_string(tbl.time), minetest.pos_to_string(tbl.loc), tbl.desc)
			form = form.."field[0,"..tostring(y+0.3)..";6,1;alarminfo:"..id..";;"..minetest.formspec_escape(infostring).."]" ..
			"field_close_on_enter[alarminfo:"..id..";false]" ..
			"button[5.5,"..tostring(y)..";1,1;clear:"..id..";Clear]"
			y = y + 1
		end
	end
	local savealarm = false
	for id, tbl in pairs(alarms) do--recently cleared
		if tbl.cleartime and (os.time()-tbl.cleartime)/3600 > 48 then--cleared more than 48 hrs ago, delete the alarm
			table.remove(alarms, id)
			savealarm = true
		elseif tbl.clearer then
			local infostring = string.format("owner: %s, %s ago, loc: %s, desc: %s, cleared by %s %s ago", tbl.owner, get_time_string(tbl.time), minetest.pos_to_string(tbl.loc), tbl.desc, tbl.clearer, get_time_string(tbl.cleartime))
			form = form.."field[0,"..tostring(y+0.3)..";6,1;alarminfo:"..id..";;"..minetest.formspec_escape(infostring).."]" ..
			"field_close_on_enter[alarminfo:"..id..";false]"
			y = y + 1
		end
	end
	if savealarm then
		storage:set_string("alarms", minetest.serialize(alarms))
	end
	form = form.."scroll_container_end[]"
	return form
end

function pages.approvals(name)
	local form = "scrollbaroptions[max="..((#approvals-3.5)*24).."]"..
	"scrollbar[9.5,0.125;0.3,7;vertical;scroll;0"..
	"]scroll_container[3.5,.5;8.5,8;scroll;vertical;.1]"
	local y = 0
	for i, info in pairs(approvals) do
		local infostring
		local labelstring
		if info.fine then
			if info.clearer then
				infostring = string.format("Law: %s, Issuer: %s, Clearer: %s Fine: %s, minrank: %s", info.law, info.issuer, info.clearer, info.fine, info.minrank)
				labelstring = "Clear Citation for '"..(info.subject).."'"
			else
				infostring = string.format("Law: %s, Issuer: %s, Fine: %s, minrank: %s", info.law, info.issuer, info.fine, info.minrank)
				labelstring = "Citation for '"..(info.subject).."'"
			end
		else
			if info.clearer then
				infostring = string.format("Law: %s, Issuer: %s, Clearer: %s, minrank: %s", info.law, info.issuer, info.clearer, info.minrank)
				labelstring = "Clear Warrant for '"..(info.subject).."'"
			else
				infostring = string.format("Law: %s, Issuer: %s, minrank: %s", info.law, info.issuer, info.minrank)
				labelstring = "Warrant for '"..(info.subject).."'"
			end
		end
		form = form.."field[0,"..(0.5+y)..";6.5,1;citationinfo:"..tostring(i)..";"..minetest.formspec_escape(labelstring)..";"..minetest.formspec_escape(infostring).."]" ..
		"field_close_on_enter[citationinfo:"..tostring(i)..";false]" ..
		"button[1.5,"..(1+y)..";1.5,1;approve:"..tostring(i)..";Approve]" ..
		"button[3,"..(1+y)..";1.5,1;reject:"..tostring(i)..";Reject]" ..
		"button[4.5,"..(1+y)..";1.5,1;escalate:"..tostring(i)..";Escalate]"
		y = y + 2
	end
	form = form.."scroll_container_end[]"
	return form
end

function pages.namelookup(name)
	return "field[3,2;6,1;namesearch;Enter name to look up;]" ..
    "field_close_on_enter[namesearch;false]"
end

function pages.playerfile(name)
	local tbl = form_table[name]
	if not tbl.name then tbl.error = "No Name" show_police_formspec(name) return end
	local name2 = tbl.name
	local pltex = "character.png"
	local height
	local weight
	if charactercreation_getskin then
		local h
		local w
		pltex, h, w = get_custom_skin(name2)
		local meters = (h/100)*1.75
		local feet = math.floor(meters*3.281)
		local inches = math.floor(((meters*3.281)-feet)*12+.5)
		height = feet.." ft "..inches.." in ("..math.floor(meters*100).." cm)"
		weight = (h/100)^2*(w/100)^2*150
		weight = math.floor(weight).." lbs ("..math.floor(weight/2.205).." kg)"
	end
	local activewarrants = ""
	local inactivewarrants = ""
	if warrants[name2] then
		for i, tbl2 in pairs(warrants[name2]) do
			if not tbl2.cleartime then--cleartime means it was deleted
				if activewarrants == "" then
					activewarrants = tbl2.law
				else
					activewarrants = activewarrants..", "..tbl2.law
				end
			else
				if inactivewarrants == "" then
					inactivewarrants = tbl2.law
				else
					inactivewarrants = inactivewarrants..", "..tbl2.law
				end
			end
		end
	end
	local vehiclestr = ""
	if cars then
		for plate, carinfo in pairs(cars.get_database()) do
			if carinfo.owner == name2 then
				if vehiclestr == "" then
					vehiclestr = string.format("%s: %s %s", plate, carinfo.color, carinfo.desc)
				else
					vehiclestr = vehiclestr..", "..string.format("%s: %s %s", plate, carinfo.color, carinfo.desc)
				end
			end
		end
	end
	local citationstr = ""
	if citations[name2] then
		for i, tbl2 in pairs(citations[name2]) do
			if citationstr == "" then
				citationstr = tbl2.law
			else
				citationstr = citationstr..", "..tbl2.law
			end
		end
	end
	local licensestr = ""
	if get_player_licenses then
		for i, licensename in pairs(get_player_licenses(name2)) do
			if licensestr ~= "" then
				licensestr = licensestr..", "
			end
			licensestr = licensestr..licensename
		end
	end
	local bioeditor = storage:get_string("bioeditor:"..name2)
	local bio =	storage:get_string("bio:"..name2)
	local form = "scrollbaroptions[max="..((7)*12).."]"..
	"scrollbar[9.5,0.125;0.3,7;vertical;scroll;0"..
	"]scroll_container[3.5,.5;8.5,8;scroll;vertical;.1]"..
	"model[0,0;4,4;mugshot_mesh;character.b3d;"..minetest.formspec_escape(pltex)..";0,180;false;true]"..
	"label[3,0.5;"..minetest.formspec_escape("name: "..name2).."]" ..
	"field[0,4.25;6,1;activewarrants;Active Warrants;"..minetest.formspec_escape(activewarrants).."]" ..
	"field_close_on_enter[activewarrants;false]" ..
	"button[5.5,3.95;1,1;playerwarrants:"..name2..";\\[   \\]]"..
	"field[0,5.25;6,1;inactivewarrants;Inactive Warrants;"..minetest.formspec_escape(inactivewarrants).."]" ..
	"field_close_on_enter[inactivewarrants;false]" ..
	"button[5.5,4.95;1,1;playerwarrants:"..name2..";\\[   \\]]"..
	"field[0,6.25;6,1;citationinfo;Citations;"..minetest.formspec_escape(citationstr).."]" ..
	"field_close_on_enter[citationinfo;false]" ..
	"button[5.5,5.95;1,1;playercitations:"..name2..";\\[   \\]]"..
	"field[0,7.25;6,1;vehicleinfo;Vehicles;"..minetest.formspec_escape(vehiclestr).."]" ..
	"field_close_on_enter[vehicleinfo;false]" ..
	"field[0,8.25;6,1;licenseinfo;Licenses;"..minetest.formspec_escape(licensestr).."]" ..
	"field_close_on_enter[licenseinfo;false]" ..
	"textarea[0,9.5;6,4;bio;Bio (last updated by "..minetest.formspec_escape(bioeditor)..", 512 max characters);"..minetest.formspec_escape(bio).."]"
	if height and weight then
		form = form.."label[3,1.5;"..minetest.formspec_escape("height: "..height).."]" ..
		"label[3,2.5;"..minetest.formspec_escape("weight: "..weight).."]"
	end
	if get_police_rank(name) > 1 then
		form = form.."button[4,13;1.5,1;biosave;Save Bio]"
	end
	form = form.."scroll_container_end[]"
	return form
end

pages.carlookup = function(name)
    local cartypes = ""
    for i, carname in pairs(cars_list) do
        cartypes = cartypes..","..minetest.formspec_escape(cars_registered_cars[carname].description)
    end
	
	local cars_dyes = {"Unpainted", "White", "Grey", "Dark Grey", "Black", "Violet", "Blue", "Cyan", "Dark Green", "Green", "Yellow", "Brown", "Orange", "Red", "Magenta", "Pink"}

    local carcolors = ""
    for i, val in pairs(cars_dyes) do
        carcolors = carcolors..","..minetest.formspec_escape(val)
    end

    local searchresults = ""
	if form_table[name].results then
		for i, item in pairs(form_table[name].results) do
			if i ~= 1 then searchresults = searchresults.."," end
			searchresults = searchresults .. minetest.formspec_escape(item)
		end
	end
	
	local function get_car_index(item)
		if not item then return 1 end
		for i, val in pairs(cars_list) do
			if cars_registered_cars[val].description == item then return i+1 end
		end
		return 1
	end
	local function get_color_index(item)
		if not item then return 1 end
		for i, val in pairs(cars_dyes) do
			if val == item then return i+1 end
		end
		return 1
	end
	
	local fieldtbl = form_table[name].fields or {}
	local platedefault = fieldtbl.platelookup or ""
	local warrantonly = fieldtbl.warrantonly or "false"
	local form = "dropdown[3,2;2,1;cartype;"..cartypes..";"..get_car_index(fieldtbl.cartype).."]" ..
	"dropdown[5,2;2,1;carcolor;"..carcolors..";"..get_color_index(fieldtbl.carcolor).."]" ..
	"field[3.25,1;2,1;platelookup;Plate Lookup;"..platedefault.."]" ..
	"field_close_on_enter[platelookup;false]" ..
	"checkbox[3,2.6;warrantonly;Only show owners with active/inactive warrants;"..warrantonly.."]" ..
	"textlist[3,3.5;6,4;searchresults;"..searchresults.."]" ..
	"label[2.95,1.6;Search]"

    return form
end

--when a warrant/citation is deleted, approval ids can get messed up.

function pages.playerwarrants(name)
	local plwarrants = warrants[form_table[name].name]
	if not plwarrants then return "" end
	local form = "scrollbaroptions[max="..((#plwarrants-8)*12 ).."]"..
	"scrollbar[9.5,0.125;0.3,7;vertical;scroll;0"..
	"]scroll_container[3.5,.5;8.5,8;scroll;vertical;.1]"
	local y = 0
	for id, tbl in pairs(plwarrants) do--active
		if not tbl.clearer then
			local infostring = string.format("Warrant: %s, issued by %s, approved by %s %s ago", tbl.law, tbl.issuer, tbl.approver, get_time_string(tbl.issuetime))
			form = form.."field[0,"..tostring(y+0.3)..";6,1;warrantinfo:"..id..";;"..minetest.formspec_escape(infostring).."]" ..
			"field_close_on_enter[warrantinfo:"..id..";false]"
			if is_police(name) then
				form = form.."button[5.5,"..tostring(y)..";1,1;clear:"..id..";Clear]"
			end
			y = y + 1
		end
	end
	local savewarrants = false
	for id, tbl in pairs(plwarrants) do--recently cleared
		if tbl.cleartime and (os.time()-tbl.cleartime)/86400 > 60 then--warrant was cleared more than 60 days ago, remove.
			table.remove(plwarrants, id)
			fix_approval_ids(form_table[name].name, id, false)
			savewarrants = true
		elseif tbl.clearer then
			local infostring = string.format("Warrant: %s, issued by %s, approved by %s %s ago, cleared by %s and approved by %s %s ago.", tbl.law, tbl.issuer, tbl.approver, get_time_string(tbl.issuetime), tbl.clearer, tbl.clearapprover, get_time_string(tbl.cleartime))
			form = form.."field[0,"..tostring(y+0.3)..";6,1;warrantinfo:"..id..";;"..minetest.formspec_escape(infostring).."]" ..
			"field_close_on_enter[warrantinfo:"..id..";false]"
			y = y + 1
		end
	end
	if savewarrants then
		storage:set_string("warrants", minetest.serialize(warrants))
	end
	form = form.."scroll_container_end[]"
	return form
end

function pages.playercitations(name)
	local plcitations = citations[form_table[name].name]
	if not plcitations then return "" end
	local form = "scrollbaroptions[max="..((#plcitations-8)*12 ).."]"..
	"scrollbar[9.5,0.125;0.3,7;vertical;scroll;0"..
	"]scroll_container[3.5,.5;8.5,8;scroll;vertical;.1]"
	local y = 0
	for id, tbl in pairs(plcitations) do--active
		if not tbl.clearer then
			local infostring = string.format("Citation: %s, issued by %s, fine amount: %s, approved by %s %s ago", tbl.law, tbl.issuer, tbl.fine, tbl.approver, get_time_string(tbl.issuetime))
			form = form.."field[0,"..tostring(y+0.3)..";6,1;citationinfo:"..id..";;"..minetest.formspec_escape(infostring).."]" ..
			"field_close_on_enter[citationinfo:"..id..";false]"
			if is_police(name) then
				form = form.."button[5.5,"..tostring(y)..";1,1;clear:"..id..";Clear]"
			end
			y = y + 1
		end
	end
	form = form.."scroll_container_end[]"
	return form
end

function show_police_formspec(name)
	if not form_table[name] then form_table[name] = {["page"] = "warrants"} end
	form_table[name].quit = nil
	local form = pages.main(name)
	if form_table[name].page and pages[form_table[name].page] then
		form = form..pages[form_table[name].page](name)
	end
	if form_table[name].error then
		form = form.."label[0.5,6;"..minetest.formspec_escape("Error: "..form_table[name].error).."]"
	end
	minetest.show_formspec(name, "policetools:computer", form)
end

local function is_law(lawname)
	for i, tbl in pairs(laws) do
		if tbl.name and tbl.name == lawname then
			return true
		end
	end
	return false
end

function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

local function update_form(pagename, playername)--function to update the forms of all players on a certain page
	for name, tbl in pairs(form_table) do
		if tbl.page == pagename and (not playername or playername == tbl.name) and not tbl.quit then
			minetest.after(0, show_police_formspec, name)
		end
	end
end

searchblacklist = {["Jackhammer Vehicle"] = true, ["Tow Truck"] = true}--table of names that do not show up in seaches, only plate lookups

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "policetools:computer" then return end
	local name = player:get_player_name()
	if not name then return true end
	local tbl = form_table[name]
	if not tbl then return true end
	--minetest.chat_send_all(dump(fields))
	local rank = get_police_rank(name)
	for pagename, func in pairs(pages) do
		if fields[pagename] and (pagename ~= "approvals" or rank > 1) then
			form_table[name] = {["page"] = pagename}
			show_police_formspec(name)
			return
		end
	end
	if fields.quit then
		form_table[name].quit = true
	end
	if tbl.page == "approvals" then
		for fieldname, fieldval in pairs(fields) do
			local splittbl = split(fieldname, ":")
			local button
			local id
			if not splittbl or #splittbl ~= 2 then goto next end
			button = splittbl[1]
			id = tonumber(splittbl[2])
			if button ~= "approve" and button ~= "reject" and button ~= "escalate" then goto next end
			local apptbl = approvals[id]
			if not apptbl then tbl.error = "No active approvals" show_police_formspec(name) return end
			if rank < apptbl.minrank then tbl.error = "Rank too low" show_police_formspec(name) return end
			if (rank ~= 4 and button ~= "escalate") and (apptbl.issuer == name or apptbl.subject == name) then tbl.error = "Self approve/reject" show_police_formspec(name) return end--only allow chief to self approve/reject, allow people to escalate their own approval requests.
			if button == "approve" then
				if apptbl.fine then
					update_form("citations")
					update_form("playercitations", apptbl.subject)
				else
					update_form("warrants")
					update_form("playerwarrants", apptbl.subject)
				end
				update_form("playerfile", apptbl.subject)
				if apptbl.clearer then--its a warrant or citation clear request
					if apptbl.fine then
						table.remove(citations[apptbl.subject], apptbl.id)
						if #citations[apptbl.subject] == 0 then
							citations[apptbl.subject] = nil
						end
						fix_approval_ids(apptbl.subject, apptbl.id, true)
						storage:set_string("citations", minetest.serialize(citations))
					else
						warrants[apptbl.subject][apptbl.id].clearer = apptbl.clearer
						warrants[apptbl.subject][apptbl.id].clearapprover = name
						warrants[apptbl.subject][apptbl.id].cleartime = os.time()
						storage:set_string("warrants", minetest.serialize(warrants))
					end
				else
					local newtbl = table.copy(apptbl)
					newtbl.approver = name
					newtbl.issuetime = os.time()
					if apptbl.fine then--citation
						if not citations[apptbl.subject] then citations[apptbl.subject] = {} end
						table.insert(citations[apptbl.subject], newtbl)
						storage:set_string("citations", minetest.serialize(citations))
					else--warrant
						if not warrants[apptbl.subject] then warrants[apptbl.subject] = {} end
						table.insert(warrants[apptbl.subject], newtbl)
						storage:set_string("warrants", minetest.serialize(warrants))
					end
				end
				table.remove(approvals, id)
			elseif button == "reject" then
				table.remove(approvals, id)
			else--escalate
				apptbl.minrank = math.min(apptbl.minrank+1, 4)
			end
			update_form("approvals")
			storage:set_string("approvals", minetest.serialize(approvals))
			tbl.error = nil
			--show_police_formspec(name)
			if true then return end
			::next::
		end
	elseif (fields.finish or fields.finishadd) and (tbl.page == "add_citation" or tbl.page == "add_warrant") then
		local minrank = 2--officers can approve by default
		if not fields.name or not minetest.player_exists(fields.name) then tbl.error = "Invalid Player" goto skip end
		if not fields.lawname or not is_law(fields.lawname) then tbl.error = "Invalid Law" goto skip end
		if tbl.page == "add_citation" then
			if not fields.fine or not tonumber(fields.fine) or tonumber(fields.fine) < 1 then tbl.error = "Invalid Fine" goto skip end
		else
			fields.fine = nil
		end
		
		if is_police(fields.name) then
			minrank = math.min((get_police_rank(fields.name) + 1), 4)--if against another officer, automatically escalate to rank above.
			--chief is the only one able to dismiss their own warrants/citations. room for corruption? yes but oh well. They can still be manually reported and arrested by order of city council.
		end
		table.insert(approvals, {law = fields.lawname, fine = (fields.fine and tonumber(fields.fine)), issuer = name, subject = fields.name, minrank = minrank})
		storage:set_string("approvals", minetest.serialize(approvals))
		
		if fields.finishadd then
			form_table[name].name = fields.name
		else
			if tbl.page == "add_citation" then
				form_table[name] = {["page"] = "citations"}
			else
				form_table[name] = {["page"] = "warrants"}
			end
		end
		::skip::
		show_police_formspec(name)
	elseif tbl.page == "namelookup" and fields.key_enter_field == "namesearch" and minetest.player_exists(fields.namesearch) then
		form_table[name] = {page = "playerfile",name=fields.namesearch}
		show_police_formspec(name)
	elseif tbl.page == "playerfile" then
		if fields.biosave and rank > 1 and name~=tbl.name then
			storage:set_string("bioeditor:"..tbl.name, name)
			storage:set_string("bio:"..tbl.name, string.sub(fields.bio, 1, 512))--512 characters max
			show_police_formspec(name)
			return
		else
			for fieldname, fieldval in pairs(fields) do
				local splittbl = split(fieldname, ":")
				if splittbl and #splittbl == 2 then
					local button = splittbl[1]
					local name2 = splittbl[2]
					if (button == "playerwarrants" or button == "playercitations") and minetest.player_exists(name2) then
						form_table[name] = {page = button,name=name2}
						show_police_formspec(name)
						break
					end
				end
			end
			return
		end
	elseif tbl.page == "warrants" or tbl.page == "citations" then
		for fieldname, fieldval in pairs(fields) do
			local splittbl = split(fieldname, ":")
			if splittbl and #splittbl == 2 then
				local button = splittbl[1]
				local name2 = splittbl[2]
				if button == "goto" and minetest.player_exists(name2) then
					form_table[name] = {page = "playerfile",name=name2}
					show_police_formspec(name)
					break
				end
			end
		end
	elseif tbl.page == "alarms" then
		for fieldname, fieldval in pairs(fields) do
			local splittbl = split(fieldname, ":")
			if splittbl and #splittbl == 2 then
				local button = splittbl[1]
				local id = tonumber(splittbl[2])
				if rank > 0 and button == "clear" and alarms[id] then
					alarms[id].clearer = name
					alarms[id].cleartime = os.time()
					storage:set_string("alarms", minetest.serialize(alarms))
					show_police_formspec(name)
					break
				end
			end
		end
	elseif cars and tbl.page == "carlookup" then
		local searchtbl = minetest.explode_textlist_event(fields.searchresults)
		if searchtbl and searchtbl.type == "DCL" then
			local clickedtbl = split(tbl.results[searchtbl.index], " ")
			local owner = clickedtbl[#clickedtbl]--last word
			if minetest.player_exists(owner) then
				form_table[name] = {page = "playerfile",name=owner}
				show_police_formspec(name)
				return
			end
		end
		local cardb = cars.get_database()
		if not tbl.fields then tbl.fields = {} end
		for i, fieldname in pairs({"platelookup", "warrantonly", "cartype", "carcolor"}) do
			if fields[fieldname] ~= nil then
				tbl.fields[fieldname] = fields[fieldname]
			else
				fields[fieldname] = tbl.fields[fieldname]
			end
		end
		if fields.platelookup then--dont care about case or if the - is put in
			fields.platelookup = string.upper(fields.platelookup)
			if not string.find(fields.platelookup, "-") and #fields.platelookup == 6 then
				fields.platelookup = string.sub(fields.platelookup,1,3).."-"..string.sub(fields.platelookup,4)
			end
		end
		if fields.key_enter_field == "platelookup" and #fields.platelookup == 7 then
			if cardb[fields.platelookup] then
				local carinfo = cardb[fields.platelookup]
				tbl.results = {string.format("%s: %s %s owned by %s", fields.platelookup, carinfo.color, carinfo.desc, carinfo.owner)}
				show_police_formspec(name)
				return
			end
			tbl.results = nil
			show_police_formspec(name)
			return
		else
			tbl.results = {}
			for plate, info in pairs(cardb) do
				if not searchblacklist[info.desc]
					and (not fields.platelookup or fields.platelookup == "" or string.find(plate, fields.platelookup))
					and (not fields.warrantonly or fields.warrantonly == "" or fields.warrantonly == "false" or warrants[info.owner])
					and (not fields.cartype or fields.cartype == "" or fields.cartype == info.desc)
					and (not fields.carcolor or fields.carcolor == "" or fields.carcolor == info.color)
				then
					table.insert(tbl.results, string.format("%s: %s %s owned by %s", plate, info.color, info.desc, info.owner))
				end
			end
			show_police_formspec(name)
			return
		end
	elseif (tbl.page == "playerwarrants" or tbl.page == "playercitations") and tbl.name then
		local pltbl
		if tbl.page == "playercitations" then
			pltbl = citations[tbl.name]
		else
			pltbl = warrants[tbl.name]
		end
		if pltbl then
			for fieldname, fieldval in pairs(fields) do
				local splittbl = split(fieldname, ":")
				if splittbl and #splittbl == 2 then
					local button = splittbl[1]
					local id = tonumber(splittbl[2])
					if rank > 0 and button == "clear" and pltbl[id] then
						local minrank = 2
						if is_police(tbl.name) then
							minrank = math.min((get_police_rank(tbl.name) + 1), 4)
						end
						table.insert(approvals, {law = pltbl[id].law, id = id, issuer = pltbl[id].issuer, fine = pltbl[id].fine, clearer = name, subject = tbl.name, minrank = minrank})
						storage:set_string("approvals", minetest.serialize(approvals))
						show_police_formspec(name)
						break
					end
				end
			end
		end
	end
end)

minetest.register_on_leaveplayer(function(player, timed_out)
	form_table[player:get_player_name()] = nil
end)

--[[
minetest.register_chatcommand("police", {
	params = "<none>",
	description = "Show Police Computer",
	privs = {},
	func = function(name, param)
		show_police_formspec(name)
	end
})

minetest.register_chatcommand("testalarm", {
	params = "<none>",
	description = "Add an alarm to the system",
	privs = {},
	func = function(name, param)
		local loc = vector.round(minetest.get_player_by_name(name):get_pos())
		table.insert(alarms, {owner = name, time = os.time(), loc = loc, desc = param})
	end
})
--]]

minetest.register_node("policetools:computer", {--using homedecor television
	description = "Police Computer",
	tiles = { 'homedecor_television_top.png',
		  'homedecor_television_bottom.png',
		  'homedecor_television_left.png^[transformFX',
		  'homedecor_television_left.png',
		  'homedecor_television_back.png',
		  'homedecor_television_front.png',
	},
	light_source = 2,
	groups = { snappy = 1 },
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if clicker:is_player() then
			show_police_formspec(clicker:get_player_name())
		end
	end
})

minetest.register_craft( {
	output = "policetools:computer",
	recipe = {
		{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
		{ "basic_materials:plastic_sheet", "default:glass", "basic_materials:plastic_sheet" },
		{ "basic_materials:ic", "basic_materials:energy_crystal_simple", "basic_materials:ic" },
	},
})

--alarm block

--[[
alarm block: description, owner
goes off if given mesecon signal or drill machine is drilling nearby
if an alarm from the same location already exists and was not cleared do not create another
--]]
local alarm_form_table = {}
function police_add_alarm(pos)
	local node = minetest.get_node(pos)
	if node.name ~= "policetools:alarm" then return end
	local meta = minetest.get_meta(pos)
	if not meta then return end
	local owner = meta:get_string("owner")
	local desc = meta:get_string("desc")
	if owner == "" or desc == "" then return end
	for i, alarmtbl in pairs(alarms) do--if an alarm already exists at that location then simply update it instead of making a new one
		if vector.equals(alarmtbl.loc, pos) and not alarmtbl.clearer then
			alarms[i].time = os.time()
			return
		end
	end
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if is_police(name) then
			minetest.chat_send_player(name, "[policetools] An alarm has gone off!")
		end
	end
	if discord and discord.send then
		local id = alarm_discord_channel
		local role = alarm_discord_role
		if id == "" then id = nil end
		if role == "" then
			discord.send("[policetools] An alarm has gone off!", id)
		else
			discord.send("[policetools] An alarm has gone off! <@&"..role..">", id)
		end
	end
	table.insert(alarms, {owner = owner, time = os.time(), loc = pos, desc = desc})
end
minetest.register_on_joinplayer(function(player, last_login)
	local name = player:get_player_name()
	local have_alarms = false
	for id, tbl in pairs(alarms) do--active
		if not tbl.clearer then
			have_alarms = true
			break
		end
	end
	if have_alarms and is_police(name) then
		minetest.chat_send_player(name, "[policetools] There are active alarms in police computer!")
	end
end)
if minetest.get_modpath("mesecons_pressureplates") then
	minetest.register_node("policetools:alarm", {
		description = "Alarm Block",
		tiles = {
			"mesecons_wireless_metal.png",
			"mesecons_wireless_metal.png",
			"mesecons_wireless_transmitter_off.png"
		},
		groups = { snappy = 3 },
		sounds = default.node_sound_wood_defaults(),
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			if not placer:is_player() then return end
			local name = placer:get_player_name()
			local meta = minetest.get_meta(pos)
			meta:set_string("owner", name)
			meta:set_string("infotext", "Owned by "..name)
		end,
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			if clicker:is_player() then
				local name = clicker:get_player_name()
				local meta = minetest.get_meta(pos)
				local owner = meta:get_string("owner")
				if name == owner then
					local form = "size[7,2]field[1,1;6,1;desc;Alarm Description (no description will disable the alarm);"..minetest.formspec_escape(meta:get_string("desc")).."]"
					minetest.show_formspec(name, "policetools:alarmblock", form)
					alarm_form_table[name] = pos
				end
			end
		end,
		mesecons = {effector = {
			action_on = police_add_alarm,
			rules = mesecon.rules.pplate
		}}
	})

	minetest.register_on_player_receive_fields(function(player, formname, fields)
		if formname == "policetools:alarmblock" then
			local name = player:get_player_name()
			local pos = alarm_form_table[name]
			if not pos then return true end
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string("owner")
			if owner ~= name then return true end
			if fields.key_enter_field == "desc" then
				meta:set_string("desc", fields.desc)
			end
			alarm_form_table[name] = nil
			return true
		end
	end)

	minetest.register_craft( {
		output = "policetools:alarm",
		recipe = {
			{ "basic_materials:plastic_sheet", "default:glass" },
			{ "basic_materials:ic", "basic_materials:energy_crystal_simple"},
		},
	})
end

--citation paying/viewing

minetest.register_chatcommand("citations", {
	params = "<none/citationid/payall>",
	description = "Show or pay your citations",
	privs = {},
	func = function(name, param)
		if param == "" then
			local str = ""
			if citations[name] then
				for i, tbl in pairs(citations[name]) do
					if str ~= "" then
						str = str..", "
					end
					str = str..string.format("%s: %s %s", i, tbl.law, tbl.fine)
				end
				return true, str
			else
				return true, "No citations to pay"
			end
		else
			local function paycitation(id)
				local amount = citations[name][id].fine
				if money3.dec(name, amount) then
					return false, "You do not have enough money in your account."
				else
					taxes.add(amount)
					table.remove(citations[name], id)
					if #citations[name] == 0 then
						citations[name] = nil
					end
					fix_approval_ids(name, id, true)
					storage:set_string("citations", minetest.serialize(citations))
					return true, "Paid "..amount
				end
			end
			if param == "payall" then
				if citations[name] then
					local str = ""
					while citations[name] ~= nil do
						local result, resultstr = paycitation(1)--I think its goofing up since its doing for while also table.remove
						if str ~= "" then
							str = str.."\n"
						end
						str = str..resultstr
						if result ~= true then
							return false, str
						end
					end
					update_form("citations")
					update_form("playerfile", name)
					update_form("playercitations", name)
					return true, str.."\nAll citations paid!"
				else
					return false, "No citations to pay"
				end
			elseif tonumber(param) and (citations[name] and citations[name][tonumber(param)]) then
				local result, resultstr = paycitation(tonumber(param))
				if result == true then
					update_form("citations")
					update_form("playerfile", name)
					update_form("playercitations", name)
				end
				return result, resultstr
			else
				return false, "Invalid input"
			end
		end
	end
})
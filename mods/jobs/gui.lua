jobs.form = {}
--[[
function generate_form()

    local form = "" ..
    "size[8,8]" ..
    "label[0.25,0.25;Job Main]" ..
    "field[0.5,1.25;2,1;filtername;Filter by name;]" ..
    "field_close_on_enter[filtername;false]" ..
    "field[2.5,1.25;2,1;filterpay;Filter by pay;]" ..
    "field_close_on_enter[filterpay;false]" ..
    "checkbox[0.25,1.65;noinvite;no invite needed;false]" ..
    "checkbox[0.25,2.1;featuredonly;featured only;false]" ..
    "dropdown[2.25,2.1;1.85,1;sortby;activity,pay,members,old to new,new to old;1]" ..
    "label[2.25,1.75;Sort By:]" ..
    ""

    return form
end

local form =
	"size[8,8]" ..
	"label[0.25,0.25;Job Main]" ..
	"scrollbar[3.5,2;0.3,6;vertical;alljobs;0]" ..
	"scroll_container[.5,3;4,6;alljobs;vertical;.01]"
	local i = 0
	for jobname, data in pairs(jobs.list) do
		form = form.."button[0,"..i..";3,0;"..jobname..";"..jobname.."]"
		i = i + .65
	end
	form = form.."scroll_container_end[]"..
	"scrollbar[7,2;0.3,6;vertical;yourjobs;0]" ..
	"scroll_container[5,3;4,6;yourjobs;vertical;.01]"
	i = 0--]]
	--[[for jobname, rank in pairs(jobs.players["spark"]) do
		form = form.."button[0,"..i..";3,0;"..jobname..";"..jobname.."]"
		i = i + .65
	end--]]
	--[[
	form = form.."scroll_container_end[]"..
	"label[5,0.5;Your Jobs]" ..
	"label[1.5,0.5;All Jobs]" ..
	--generate_form()..
	""--]]
jobs.form.main = "size[5,1]label[0,0.25;GUI is not completed, please do /jobs help]"--form

--JOB MESSAGE BOARD
local max_msg = tonumber(minetest.settings:get("jobs.max_messages") or "64")
--jobs.list[jobname].messages = {announcements = {}, internal = {}, external = {}, supervisor = {}}

local function msg_perm(name, jobname, channel, sending)
	if not name or not jobname or not channel or not jobs.list[jobname] then return false end
	if not minetest.player_exists(name) then return false end
	if sending and jobs.list[jobname].muted and jobs.list[jobname].muted[name] then return false end
	if channel == "external" then return true end
	local coc = jobs.chainofcommand--{intern = 1, employee = 2, supervisor = 3, ceo = 4}
	local rank = jobs.getrank(name, jobname)
	if rank then
		rank = coc[rank]
	else
		rank = 0
	end
	if channel == "announcements" and (not sending or rank > 2) then return true end
	if channel == "supervisor" and not rank > 2 then return false end
	if rank == 0 then return false end
	return true
end

local function get_msg_sender(msg)
	local newmsg = string.sub(msg,(string.find(msg, ") ")+2),-1)--take off the date/time
	newmsg = string.sub(newmsg,1,(string.find(newmsg, ":")-1))--take off everything after ':' in 'Elkien: hello this is a message'
	--minetest.chat_send_all(newmsg)
	return newmsg
end

local form_table = {}

local function remove_message(jobname, channel, msgid)
	local msgtbl = jobs.list[jobname].messages[channel]
	table.remove(msgtbl, msgid)
	for name, tbl in pairs(form_table) do
		if tbl.job == jobname and tbl.page == channel then
			if tbl.message then
				if tbl.message == msgid then--if looking at a message when its deleted, change player view
					tbl.message = nil
				elseif tbl.message > msgid then--if looking at message when table is changed, change message id to compensate
					tbl.message = tbl.message - 1
				end
			end
		end
		if not tbl.message then
			minetest.show_formspec(name, "jobs_gui", job_message_form(name))
		end
	end
	jobs.save()
end

function jobs.new_message(name, msg, jobname, channel)
	if not name or not msg or not jobname or not channel or not jobs.list[jobname] then return end
	if channel ~= "announcements" and channel ~= "internal" and channel ~= "external" and channel ~= "supervisor" then return end
	if not msg_perm(name, jobname, channel, true) then return end
	if not jobs.list[jobname].messages then jobs.list[jobname].messages = {} end
	if not jobs.list[jobname].messages[channel] then jobs.list[jobname].messages[channel] = {} end
	local msgtbl = jobs.list[jobname].messages[channel]
	local newmsg = "("..string.sub(os.date("%c"), 1, -7)..") "..name..": "..msg --should be syntaxed '(10/02/22 10:11) Elkien: Hello my name is Elkien'
	table.insert(msgtbl, newmsg)
	if max_msg ~= 0 and #msgtbl > max_msg then--remove old messages unless disabled with '0'
		while #msgtbl > max_msg do
			remove_message(jobname, channel, 1)
		end
	end
	for name2, tbl in pairs(form_table) do
		if tbl.job == jobname and tbl.page == channel then
			minetest.show_formspec(name2, "jobs_gui", job_message_form(name2))
		end
	end
	for name2, rank2 in pairs(jobs.list[jobname].employees) do
		if minetest.get_player_by_name(name2) and name2 ~= name then
			minetest.chat_send_player(name2, minetest.colorize("#ff9415", "<"..name.."> ("..jobname..":"..channel..") "..msg))
		end
	end--todo keep track of unread messages
	jobs.save()
end

local function get_rank_num(name, jobname)
	local coc = jobs.chainofcommand--{intern = 1, employee = 2, supervisor = 3, ceo = 4}
	local rank = jobs.getrank(name, jobname)
	if rank then
		rank = coc[rank]
	else
		rank = 0
	end
	return rank
end

--form_table["Elkien"] = {page = "announcements", message = messageid, job = jobname}
function job_message_form(name)
	local jobtbl = jobs.players[name]
	local tbl = form_table[name]
	if not tbl then
		form_table[name] = {page = "announcements"}
		tbl = form_table[name]
	end
	
	local joblist_item_str = ""
	local joblist_selected = 1
	local joblist_num = 1
	if jobtbl then
		for jobname, rank in pairs(jobtbl) do
			if joblist_item_str ~= "" then joblist_item_str = joblist_item_str.."," end
			joblist_item_str = joblist_item_str .. minetest.formspec_escape(jobname)
			if not tbl.job then tbl.job = jobname end
			if tbl.job == jobname then
				joblist_selected = joblist_num
			end
			joblist_num = joblist_num + 1
		end
	end
	
	joblist_num = nil
	
    local chatlist_item_str = ""
	local chatlist_selected_id = 1
	local messagearea_default = ""
	if tbl.job and jobs.list[tbl.job] and jobs.list[tbl.job].messages and jobs.list[tbl.job].messages[tbl.page] then
		if tbl.message then
			messagearea_default = jobs.list[tbl.job].messages[tbl.page][tbl.message] or ""
		else
			chatlist_selected_id = #jobs.list[tbl.job].messages[tbl.page]
		end
		for i, chat in pairs(jobs.list[tbl.job].messages[tbl.page]) do
			if i ~= 1 then chatlist_item_str = chatlist_item_str.."," end
			chatlist_item_str = chatlist_item_str .. minetest.formspec_escape(chat)
		end
	end
	
	local rank = get_rank_num(name, tbl.job)
	
	local buttonlbl = {announcements = "Announcements", external = "External", internal = "Internal", supervisor = "Supervisor"}
	buttonlbl[tbl.page] = minetest.formspec_escape("["..buttonlbl[tbl.page].."]")
	
    local form = "" ..
    "size[15,9]" ..
    "button[0.1,1.5;2,1;announcements;"..buttonlbl.announcements.."]" ..
    "button[0.1,2.5;2,1;external;"..buttonlbl.external.."]" ..
	"dropdown[1,0.6;4,1;joblist;"..joblist_item_str..";"..tostring(joblist_selected).."]" ..
    "field[8,0.9;3,1;jobsearch;Go to Job;]" ..
	"field_close_on_enter[jobsearch;false]"..
    "label[5,0.7;* = new messages]"
	if tbl.message then
		form = form.."textarea[2.3,1.5;12.7,7;messagearea;;"..minetest.formspec_escape(messagearea_default).."]" ..
		"button[12,7.7;2,1;back;Back]"
		local msg
		local sender
		local senderrank
		if jobs.list[tbl.job] and jobs.list[tbl.job].messages and jobs.list[tbl.job].messages[tbl.page] then
			msg = jobs.list[tbl.job].messages[tbl.page][tbl.message]
		end
		if msg then
			sender = get_msg_sender(msg)
			senderrank = get_rank_num(sender, tbl.job)
			if sender == name or (rank > 2 and rank > senderrank) then
				form = form.."button[3,7.7;2,1;delete;Delete Message]"
				if sender ~= name then
					form = form.."button[5,7.7;2,1;mute;Mute Player]"
				end
			end
		end
	else
		form = form.."textlist[2,1.5;12.5,6;chatlist;"..chatlist_item_str..";"..chatlist_selected_id.."]" ..
		"field[2.3,8;12.7,1;chatinput;;]"..
		"field_close_on_enter[chatinput;false]"
	end
	if rank > 0 then
		form = form.."button[0.1,3.5;2,1;internal;"..buttonlbl.internal.."]"
	end
	if rank > 2 then
		form = form.."button[0.1,4.5;2,1;supervisor;"..buttonlbl.supervisor.."]"
	end

    return form
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "jobs_gui" then return end
	local name = player:get_player_name()
	if not name then return true end
	local tbl = form_table[name]
	if not tbl then return true end
	
	--minetest.chat_send_all(dump(fields))

	local rank = get_rank_num(name, tbl.job)
	
	if fields.back and tbl.message then
		tbl.message = nil
		minetest.show_formspec(name, "jobs_gui", job_message_form(name))
		return true
	end
	if tbl.message then	
		local msg
		if jobs.list[tbl.job] and jobs.list[tbl.job].messages and jobs.list[tbl.job].messages[tbl.page] then
			msg = jobs.list[tbl.job].messages[tbl.page][tbl.message]
		end
		if msg and (fields.mute or fields.delete) then
			local name2 = get_msg_sender(msg)
			local rank2 = get_rank_num(name2, tbl.job)
			if name ~= name2 and rank <= rank2 then return true end--dont allow supervisors to delete messages or mute ceo or other supervisors
			if fields.mute and rank > 2 then
				if not jobs.list[tbl.job].muted then
					jobs.list[tbl.job].muted = {}
				end
				jobs.list[tbl.job].muted[name2] = true
			elseif fields.delete then
				remove_message(tbl.job, tbl.page, tbl.message)
			end
			tbl.message = nil
			minetest.show_formspec(name, "jobs_gui", job_message_form(name))
			jobs.save()
			return true
		end
	end
	if rank > 2 and fields.supervisor then
		tbl.message = nil
		tbl.page = "supervisor"
		minetest.show_formspec(name, "jobs_gui", job_message_form(name))
		return true
	end
	if rank > 0 and fields.internal then
		tbl.message = nil
		tbl.page = "internal"
		minetest.show_formspec(name, "jobs_gui", job_message_form(name))
		return true
	else
		if fields.announcements then
			tbl.message = nil
			tbl.page = "announcements"
			minetest.show_formspec(name, "jobs_gui", job_message_form(name))
			return true
		elseif fields.external then
			tbl.message = nil
			tbl.page = "external"
			minetest.show_formspec(name, "jobs_gui", job_message_form(name))
			return true
		end
	end
	if fields.key_enter_field and fields.key_enter_field == "chatinput" then
		jobs.new_message(name, fields.chatinput, tbl.job, tbl.page)
	elseif fields.key_enter_field and fields.key_enter_field == "jobsearch" then
		if jobs.list[fields.jobsearch] then
			tbl.message = nil
			tbl.page = "announcements"
			tbl.job = fields.jobsearch
			minetest.show_formspec(name, "jobs_gui", job_message_form(name))
			return true
		end
	elseif fields.joblist ~= tbl.job then
		if jobs.list[fields.joblist] then
			tbl.message = nil
			tbl.page = "announcements"
			tbl.job = fields.joblist
			minetest.show_formspec(name, "jobs_gui", job_message_form(name))
			return true
		end
	elseif fields.chatlist then
		local expl = minetest.explode_textlist_event(fields.chatlist)
		if expl.type == "DCL" then
			tbl.message = tonumber(expl.index)
			minetest.show_formspec(name, "jobs_gui", job_message_form(name))
		end
		return true
	end
end)
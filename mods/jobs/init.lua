jobs = {}
jobs.storage = minetest.get_mod_storage()
jobs.list = minetest.deserialize(jobs.storage:get_string("list")) or {}
jobs.players = {}
jobs.commands = {}
jobs.nosavecommands = {}

local MAX_OWNEDJOBS = 3

local settings = minetest.settings

local path = minetest.get_modpath(minetest.get_current_modname())
dofile(path .. "/helpers.lua")

for jobname, data in pairs(jobs.list) do
	if not jobs.players[data.ceo] then jobs.players[data.ceo] = {} end
	jobs.players[data.ceo][jobname] = "ceo"
	for name, rank in pairs(data.employees) do
		if not jobs.players[name] then jobs.players[name] = {} end
		jobs.players[name][jobname] = rank
	end
end

dofile(path .. "/gui.lua")
dofile(path .. "/attendanceclock.lua")

jobs.save = function()
	jobs.storage:set_string("list", minetest.serialize(jobs.list))
end

minetest.register_chatcommand("jobs", {
    privs = {
        interact = true,
    },
    func = function(name, param)
		if not param or param == "" then minetest.show_formspec(name, "jobs_form_main", jobs.form.main) return end--return false, "No input." end
        param = jobs.split(param)
		if not param[1] then return false, "No input." end
		if not jobs.commands[param[1]] then return false, "'"..param[1].."' is not a valid command." end
		local result, message = jobs.commands[param[1]](name, param)
		if result == true and not jobs.nosavecommands[param[1]] then jobs.save() end
		return result, message
    end
})

function jobs.help(name, command)
	local string = "Command list:"
	for name, _ in pairs(jobs.commands) do
		string = string.." "..name
	end
	return true, string
end
jobs.commands["help"] = function(name, param)
	return jobs.help(name, param[2])
end
jobs.nosavecommands["help"] = true

jobs.chainofcommand = {intern = 1, employee = 2, supervisor = 3, ceo = 4}
function jobs.getrank(name, jobname, rank)
	if not name or not jobname then return end
	if not jobs.list[jobname] then return end
	if not jobs.players[name] then return false end
	if not jobs.players[name][jobname] then return false end
	if rank then
		return jobs.players[name][jobname] == rank
	else
		return jobs.players[name][jobname]
	end
end

function jobs.ownedjobs(name, newname)
	if not newname then newname = name end
	if not jobs.players[newname] then return 0, "No entry for '"..newname.."'." end
	local i = 0
	local string = ""
	for jobname, rank in pairs(jobs.players[newname]) do
		if rank == "ceo" then
			i = i + 1
			string = string.." "..jobname..","
		end
	end
	if i == 0 then string = "'"..newname.."' does not own any jobs." else
		string = string:sub(1, -2)
	end
	if i == 1 then string = " job:"..string else string = " jobs:"..string end
	return i, string
end
jobs.commands["ownedjobs"] = function(name, param)
	local number, string = jobs.ownedjobs(name, param[2])
	if number == 0 then
		return true, string
	end
	return true, "'"..param[2].."' owns "..number..string
end
jobs.nosavecommands["ownedjobs"] = true

function jobs.create(name, jobname)
	if not jobname then return false, "No Job name given." end
	if jobs.list[jobname] then return false, "Job '"..jobname.."' already exists." end
	if jobs.ownedjobs(name) >= MAX_OWNEDJOBS then return false, "You already own the max amount of jobs." end
	jobs.list[jobname] = {}
	jobs.list[jobname].ceo = name
	jobs.list[jobname].employees = {}
	jobs.list[jobname].employees[name] = "ceo"
	jobs.list[jobname].open = settings:get("jobs_open") or -1
	jobs.list[jobname].defaultrank = "intern"
	if not jobs.players[name] then jobs.players[name] = {} end
	jobs.players[name][jobname] = "ceo"
	return true, "Job '"..jobname.."' succesfully created."
end
jobs.commands["create"] = function(name, param)
	return jobs.create(name, param[2])
end

function jobs.remove(name, jobname)
	if not jobname then return false, "No Job name given." end
	if not jobs.list[jobname] then return false, "The job '"..jobname.."' does not exist." end
	if jobs.list[jobname].ceo ~= name then return false, "You are not the CEO of '"..jobname.."'." end
	for employee, data in pairs(jobs.list[jobname].employees) do
		if jobs.players[employee] then
			jobs.players[employee][jobname] = nil
		end
	end
	jobs.list[jobname] = nil
	return true, "Job '"..jobname.."' succesfully removed."
end
jobs.commands["remove"] = function(name, param)
	return jobs.remove(name, param[2])
end

function jobs.listall()
	local string = ""
	local i = 0
	for name, _ in pairs(jobs.list) do
		i = i + 1
		string = string.." "..name
	end
	if i == 1 then
		return true, i.." job:"..string
	else
		return true, i.." jobs: "..string
	end
end
jobs.commands["list"] = function(name, param)
	return jobs.listall()
end
jobs.nosavecommands["list"] = true

function jobs.open(name, jobname, val)
	if not jobname then return false, "No Job name given." end
	if not jobs.list[jobname] then return false, "The job '"..jobname.."' does not exist." end
	if not val then return true, "'"..jobname.."' is open to players with "..jobs.list[jobname].open.." hours of playtime. (-1 is never)" end
	if jobs.chainofcommand[jobs.getrank(name, jobname)] < 3 then return false, "You are neither the CEO nor a supervisor of '"..jobname..".'" end
	if not tonumber(val) then return false, "Enter in hours how much playtime is required before joining without invite is possible. -1 for never, 0 for always." end
	jobs.list[jobname].open = tonumber(val)
	return true, "'"..jobname.."' is now open to players with "..val.." hours of playtime (-1 for never)"
end
jobs.commands["open"] = function(name, param)
	return jobs.open(name, param[2], param[3])
end

function jobs.invite(name, newname, jobname)
	if not jobname then return false, "No Job name given." end
	if not jobs.list[jobname] then return false, "The job '"..jobname.."' does not exist." end
	if not newname then return false, "No playername was given." end
	if jobs.chainofcommand[jobs.getrank(name, jobname)] < 3 then return false, "You are neither the CEO nor a supervisor of '"..jobname..".'" end
	if not minetest.player_exists(newname) then return false, "Player '"..newname.."' does not exist." end
	if jobs.list[jobname].employees[newname] then return false, "Player '"..newname.."' is already in '"..jobname.."'." end
	if jobs.list[jobname].applications and jobs.list[jobname].applications[newname] then
		jobs.list[jobname].employees[newname] = jobs.list[jobname].defaultrank
		if not jobs.players[newname] then jobs.players[newname] = {} end
		jobs.players[newname][jobname] = jobs.list[jobname].defaultrank
		return true, "Player '"..newname.."' is now '"..jobs.players[newname][jobname].."' in '"..jobname.."'."
	else
		if not jobs.list[jobname].invites then jobs.list[jobname].invites = {} end
		jobs.list[jobname].invites[newname] = name
		return true, "Player '"..newname.."' was invited to "..jobname.."'."
	end
end
jobs.commands["invite"] = function(name, param)
	return jobs.invite(name, param[2], param[3])
end

function jobs.fire(name, newname, jobname)
	if not jobname then return false, "No Job name given." end
	if not jobs.list[jobname] then return false, "The job '"..jobname.."' does not exist." end
	if not newname then return false, "No playername was given." end
	if not minetest.player_exists(newname) then return false, "Player '"..newname.."' does not exist." end
	if not jobs.list[jobname].employees[newname] then return false, "Player '"..newname.."' is not in '"..jobname.."'." end
	if not jobs.list[jobname].employees[name] then return false, "You are not in '"..jobname.."'." end
	if jobs.list[jobname].ceo ~= name and jobs.chainofcommand[jobs.getrank(name, jobname)] <= jobs.chainofcommand[jobs.getrank(newname, jobname)] then
		return false, "You cannot fire '"..newname.."' ("..jobs.getrank(newname, jobname)..") as a "..jobs.getrank(name, jobname).."."
	end
	jobs.list[jobname].employees[newname] = nil
	jobs.players[newname][jobname] = nil
	return true, "Fired '"..newname.."' from '"..jobname.."'."
end
jobs.commands["fire"] = function(name, param)
	return jobs.fire(name, param[2], param[3])
end

function jobs.apply(name, jobname)
	if not jobname then return false, "No Job name given." end
	if not jobs.list[jobname] then return false, "The job '"..jobname.."' does not exist." end
	if jobs.list[jobname].employees[name] then return false, "You are already in '"..jobname.."'." end
	if (jobs.list[jobname].invites and jobs.list[jobname].invites[name]) or (jobs.list[jobname].open ~= -1 and jobs.list[jobname].open <= jobs.getplaytime(name)) then
		jobs.list[jobname].employees[name] = jobs.list[jobname].defaultrank
		if not jobs.players[name] then jobs.players[name] = {} end
		jobs.players[name][jobname] = jobs.list[jobname].defaultrank
		return true, "You are now "..jobs.players[name][jobname].." in '"..jobname.."'."
	else
		if not jobs.list[jobname].applications then jobs.list[jobname].applications = {} end
		jobs.list[jobname].applications[name] = true
		return true, "You applied to '"..jobname.."'."
	end
end
jobs.commands["apply"] = function(name, param)
	return jobs.apply(name, param[2])
end

function jobs.quit(name, jobname)
	if not jobname then return false, "No Job name given." end
	if not jobs.list[jobname] then return false, "The job '"..jobname.."' does not exist." end
	if not jobs.list[jobname].employees[name] then return false, "You aren't in '"..jobname.."'." end
	if jobs.list[jobname].ceo == name then return false, "You cannot quit as ceo, you have to remove the job or transfer it to someone else." end
	jobs.list[jobname].employees[name] = nil
	jobs.players[name][jobname] = nil
	return true, "You quit '"..jobname.."'."
end
jobs.commands["quit"] = function(name, param)
	return jobs.quit(name, param[2])
end

function jobs.setrank(name, newname, newrank, jobname)
	if not jobname then return false, "No Job name given." end
	if not jobs.list[jobname] then return false, "The job '"..jobname.."' does not exist." end
	if not newname then return false, "No playername was given." end
	if not minetest.player_exists(newname) then return false, "Player '"..newname.."' does not exist." end
	if not jobs.list[jobname].employees[newname] then return false, "Player '"..newname.."' is not in '"..jobname.."'." end
	if newname == jobs.list[jobname].ceo then return false, "You cannot set the rank of the ceo." end
	if not jobs.chainofcommand[newrank] then return false, "'"..newrank.."' is not a valid rank. valid ranks: supervisor, employee, intern." end
	if newrank == "ceo" and jobs.getrank(name, jobname) == "ceo" then return false, "Use /jobs transfer '"..jobname.." "..newname.."' to transfer ownership." end
	if not jobs.list[jobname].employees[name] then return false, "You are not in '"..jobname.."'." end
	if jobs.list[jobname].ceo ~= name and jobs.chainofcommand[jobs.getrank(name, jobname)] <= jobs.chainofcommand[jobs.getrank(newname, jobname)] then
		return false, "You cannot set '"..newname.."' ("..jobs.getrank(newname, jobname)..") to '"..newrank.."' as a "..jobs.getrank(name, jobname).."."
	end
	if jobs.list[jobname].ceo ~= name and jobs.chainofcommand[jobs.getrank(name, jobname)] <= jobs.chainofcommand[newrank] then
		return false, "You cannot set '"..newname.."' ("..jobs.getrank(newname, jobname)..") to '"..newrank.."' as a "..jobs.getrank(name, jobname).."."
	end
	jobs.list[jobname].employees[newname] = newrank
	jobs.players[newname][jobname] = newrank
	return true, "Set '"..newname.."' to "..newrank.." in "..jobname.."."
end
jobs.commands["setrank"] = function(name, param)
	return jobs.setrank(name, param[2], param[3], param[4])
end

function jobs.getjobinfo(name, jobname)
	if not jobname then return false, "No Job name given." end
	if not jobs.list[jobname] then return false, "The job '"..jobname.."' does not exist." end
	local string = jobname..": ceo "..jobs.list[jobname].ceo
	for name, rank in pairs(jobs.list[jobname].employees) do
		if rank ~= "ceo" then
			string = string..", "..rank.." "..name
		end
	end
	return true, string
end
jobs.commands["job"] = function(name, param)
	return jobs.getjobinfo(name, param[2])
end
jobs.nosavecommands["job"] = true

function jobs.getplayerinfo(name, newname, jobname)
	if not newname then newname = name end
	if not minetest.player_exists(newname) then return false, "Player '"..newname.."' does not exist." end
	if jobname then
		if jobs.players[newname][jobname] then
			return true, "'"..newname.."' is "..jobs.players[newname][jobname].." in '"..jobname.."'."
		else return false, "'"..newname.."' is not in '"..jobname.."'." end
	end
	local string = newname..": "
	for jobname, rank in pairs(jobs.players[newname]) do
		if string ~= newname..": " then
			string = string..", "
		end
		string = string..jobname.." ("..rank..")"
	end
	return true, string
end
jobs.commands["player"] = function(name, param)
	return jobs.getplayerinfo(name, param[2], param[3])
end
jobs.nosavecommands["player"] = true

function jobs.transfer(name, jobname, newname)
	if not jobname then return false, "No Job name given." end
	if not jobs.list[jobname] then return false, "The job '"..jobname.."' does not exist." end
	if not newname then return false, "No playername was given." end
	if not minetest.player_exists(newname) then return false, "Player '"..newname.."' does not exist." end
	if not jobs.list[jobname].employees[newname] then return false, "Player '"..newname.."' is not in '"..jobname.."'." end
	if jobs.ownedjobs(newname) >= MAX_OWNEDJOBS then return false, "'"..newname.."' already owns the max amount of jobs." end
	if jobs.list[jobname].ceo ~= name then return false, "You are not the CEO of '"..jobname.."'." end
	jobs.list[jobname].ceo = newname
	jobs.list[jobname].employees[newname] = "ceo"
	jobs.players[newname][jobname] = "ceo"
	jobs.list[jobname].employees[name] = "supervisor"
	jobs.players[name][jobname] = "supervisor"
	return true, "Job '"..jobname.."' was transferred to "..newname.."."
end
jobs.commands["transfer"] = function(name, param)
	return jobs.transfer(name, param[2], param[3])
end

function jobs.description(name, jobname, val)
	if not jobname then return false, "No Job name given." end
	if not jobs.list[jobname] then return false, "The job '"..jobname.."' does not exist." end
	if not val or val == "" then
		if jobs.list[jobname].description then
			return true, jobname..": "..jobs.list[jobname].description
		else
			return false, "'"..jobname.."' has no description."
		end
	end
	if jobs.list[jobname].ceo ~= name then return false, "You are not the CEO of '"..jobname..".'" end
	jobs.list[jobname].description = val
	return true, "'"..jobname.."' is now '"..val.."'."
end
jobs.commands["description"] = function(name, param)
	local desc = ""
	for index, string in pairs(param) do
		if index > 2 then
			desc = desc..string.." "
		end
	end
	desc = desc:sub(1, -2)
	return jobs.description(name, param[2], desc)
end

function jobs.setpay(name, jobname, rank, val)
	if not jobname then return false, "No Job name given." end
	if not jobs.list[jobname] then return false, "The job '"..jobname.."' does not exist." end
	if not rank then
		if not jobs.list[jobname].pay then return false, "'"..jobname.."' has no automatic pay set up." end
		local string = "Pay for each rank:"
		for rankname, pay in pairs(jobs.list[jobname].pay) do
			string = string.." "..rankname..":"..pay
		end
		return true, string
	end
	if rank == "ceo" or not jobs.chainofcommand[rank] then return false, "'"..rank.."' is not a valid rank. valid ranks: supervisor, employee, intern." end
	if jobs.list[jobname].ceo ~= name then return false, "You are not the CEO of '"..jobname..".'" end
	if not val then val = 0 end
	if not jobs.list[jobname].pay then jobs.list[jobname].pay = {} end
	jobs.list[jobname].pay[rank] = val
	return true, ""..rank.." in '"..jobname.."' is now payed "..val.."/hr."
end
jobs.commands["pay"] = function(name, param)
	return jobs.setpay(name, param[2], param[3], param[4])
end

function jobs.checkpaylog(name, jobname, newname)
	if not jobs.punchlogs then return false, "Logs are not enabled." end
	if not jobname then return false, "No Job name given." end
	if not jobs.list[jobname] then return false, "The job '"..jobname.."' does not exist." end
	if not jobs.list[jobname].employees[name] then return false, "You are not in '"..jobname.."'." end
	if jobs.chainofcommand[jobs.getrank(name, jobname)] < 3 then return false, "You are not a supervisor or ceo." end
	if newname then
		local string = "Payment logs for '"..newname.."' in '"..jobname.."'"
		local temp = {}
		for time, message in pairs(jobs.punchlogs[jobname]) do
			local logname = jobs.split(message)
			if logname[1] == newname then
				table.insert(temp, time)
			end
		end
		table.sort(temp)
		for i, time in pairs(temp) do
			local message = jobs.punchlogs[jobname][time]
			string = string.."\n"..os.date("%c", time)..": "..message
		end
		return true, string
	else
		local string = "Payment logs for '"..jobname.."'"
		local temp = {}
		for time in pairs(jobs.punchlogs[jobname]) do
			table.insert(temp, time)
		end
		table.sort(temp)
		for i, time in pairs(temp) do
			local message = jobs.punchlogs[jobname][time]
			string = string.."\n"..os.date("%c", time)..": "..message
		end
		return true, string
	end
end
jobs.commands["paylog"] = function(name, param)
	return jobs.checkpaylog(name, param[2], param[3])
end
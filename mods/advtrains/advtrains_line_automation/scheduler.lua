-- scheduler.lua
-- Implementation of a Railway time schedule queue
-- In contrast to the LuaATC interrupt queue, this one can handle many different
-- event receivers. This is done by registering a callback with the scheduler

local ln = advtrains.lines
local sched = {}

local UNITS_THRESH = 10
local MAX_PER_ITER = 10

local callbacks = {}

-- Register a handler callback to handle scheduler items.
-- e - a handler identifier (corresponds to "handler" in enqueue() )
-- func - a function(evtdata) to be executed when a schedule item expires
--        evtdata - arbitrary data that has been passed into enqueue()
function sched.register_callback(e, func)
	callbacks[e] = func
end

--[[
{
	t = <railway time in seconds>
	e = <handler callback>
	d = <data table>
	u = <unit identifier>
}
The "unit identifier" is there to prevent schedule overflows. It can be, for example, the position hash
of a node or a train ID. If the number of schedules for a unit exceeds UNITS_THRESH, further schedules are
blocked.
]]--
local queue = {}

local units_cnt = {}

function sched.load(data)
	if data then
		for i,elem in ipairs(data) do
			table.insert(queue, elem)
			units_cnt[elem.u] = (units_cnt[elem.u] or 0) + 1
		end
		atlog("[lines][scheduler] Loaded the schedule queue,",#data,"items.")
	end
end
function sched.save()
	return queue
end

function sched.run()
	local ctime = ln.rwt.get_time()
	local cnt = 0
	local ucn, elem
	while cnt <= MAX_PER_ITER do
		elem = queue[1]
		if elem and elem.t <= ctime then
			table.remove(queue, 1)
			if callbacks[elem.e] then
				-- run it
				callbacks[elem.e](elem.d)
			else
				atwarn("[lines][scheduler] No callback to handle schedule",elem)
			end
			cnt=cnt+1
			ucn = units_cnt[elem.u]
			if ucn and ucn>0 then
				units_cnt[elem.u] = ucn - 1
			end
		else
			break
		end
	end
end

-- Enqueue a new scheduled item to be executed at "rwtime"
-- handler: a string identifying the handler to use (registered with sched.register_callback())
-- evtdata: Arbitrary Lua data to be passed to the handler callback
-- unitid: An arbitrary string uniquely identifying the thing that is issuing this enqueue.
--    used to prevent expotentially growing "scheduler bombs"
-- unitlim: Custom override for UNITS_THRESH (see there)
function sched.enqueue(rwtime, handler, evtdata, unitid, unitlim)
	local qtime = ln.rwt.to_secs(rwtime)
	assert(type(handler)=="string")
	assert(type(unitid)=="string")
	assert(type(unitlim)=="number")
	
	local cnt=1
	local ucn, elem
	
	ucn = (units_cnt[unitid] or 0)
	local ulim=(unitlim or UNITS_THRESH)
	if ucn >= ulim then
		atlog("[lines][scheduler] discarding enqueue for",handler,"(limit",ulim,") because unit",unitid,"has already",ucn,"schedules enqueued")
		return false
	end
	
	while true do
		elem = queue[cnt]
		if not elem or elem.t > qtime then
			table.insert(queue, cnt, {
					t=qtime,
					e=handler,
					d=evtdata,
					u=unitid,
				})
			units_cnt[unitid] = ucn + 1
			return true
		end
		cnt = cnt+1
	end
end

-- See enqueue(). Same meaning, except that rwtime is relative to now.
function sched.enqueue_in(rwtime, handler, evtdata, unitid, unitlim)
	local ctime = ln.rwt.get_time()
	sched.enqueue(ctime + rwtime, handler, evtdata, unitid, unitlim)
end

-- Discards all schedules for unit "unitid" (removes them from the queue)
function sched.discard_all(unitid)
	local i = 1
	while i<=#queue do
		if queue[i].u == unitid then
			table.remove(queue,i)
		else
			i=i+1
		end
	end
	units_cnt[unitid] = 0
end

ln.sched = sched

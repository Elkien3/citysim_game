-- railwaytime.lua
-- Advtrains uses a desynchronized time for train movement. Everything is counted relative to this time counter.
-- The advtrains-internal time is in no way synchronized to the real-life time, due to:
-- - Lag
-- - Server stops/restarts
-- However, this means that implementing a "timetable" system using the "real time" is not practical. Therefore,
-- we introduce a custom time system, the RWT(Railway Time), which has nothing to do with RLT(Real-Life Time)
-- RWT has a time cycle of 1 hour. This should be sufficient for most train lines that will ever be built in Minetest.
-- A RWT looks like this:    37;25
-- The ; is to distinguish it from a normal RLT (which has colons e.g. 12:34:56). Left number is minutes, right number is seconds.
-- The minimum RWT is 00;00, the maximum is 59;59.
-- It is OK to leave one places out at either end, esp. when writing relative times, such as:
-- 43;3   22;0   2;30   0;10  ;10
-- Those places are then filled with zeroes. Indeed, ";" would be valid for 00;00 .

-- There is an "adapt mode", which was proposed by gpcf, and results in RWT automatically adapting itself to real-world time.
-- It works by shifting the minute/second after the realtime minute/second, adjusting the cycle value as needed.

-- Using negative times is discouraged. If you need a negative time, you may insert a minus (-) ONLY in the "c" place

--[[
1;23;45 = {
	s=45,
	m=23,
	c=1, -- Cycle(~hour), not displayed most time
}

Railway times can exist in 3 forms:
- as table (see above)
- as string (like "12;34")
- as number (of seconds)

Forms are automagically converted as needed by the converter functions to_*
To be sure a rwt is in the required form, explicitly use a converter.

]]

local rwt = {}

--Time Stamp (Seconds since start of world)
local e_time = 0
local e_has_loaded = false

local setting_rwt_real = minetest.settings:get("advtrains_lines_rwt_realtime")
if setting_rwt_real=="" then
	setting_rwt_real = "independent"
end

local e_last_epoch -- last real-time timestamp

-- Advance RWT to match minute/second to the current real-world time
-- only accounts for the minute/second part, leaves hour/cycle untouched
local function adapt_real_time()
	local datetab = os.date("*t")
	local real_sectotal = 60*datetab.min + datetab.sec
	
	local rwttab = rwt.now()
	local rwt_sectotal = 60*rwttab.m + rwttab.s
	
	--calculate the difference and take it %3600 (seconds/hour) to always move forward
	local secsfwd = (real_sectotal - rwt_sectotal) % 3600
	
	atlog("[lines][rwt] Skipping",secsfwd,"seconds forward to sync rwt (",rwt.to_string(rwttab),") to real time (",os.date("%H:%M:%S"),")")
	
	e_time = e_time + secsfwd
end

function rwt.set_time(t)
	e_time = t or 0
	if setting_rwt_real == "adapt_real" then
		adapt_real_time()
	end
	atlog("[lines][rwt] Initialized railway time: ",rwt.to_string(e_time))
	e_last_epoch = os.time()
	
	e_has_loaded = true
end

function rwt.get_time()
	return e_time
end

function rwt.step(dt)
	if not e_has_loaded then
		rwt.set_time(0)
	end

	if setting_rwt_real=="independent" then
		-- Regular stepping with dtime
		e_time = e_time + dt		
	else
		-- advance with real-world time
		local diff = os.time() - e_last_epoch
		e_last_epoch = os.time()
		
		if diff>0 then
			e_time = e_time + diff
		end
	end
end

function rwt.now()
	return rwt.to_table(e_time)
end

function rwt.new(c, m, s)
	return {
		c = c or 0,
		m = m or 0,
		s = s or 0
	}
end
function rwt.copy(rwtime)
	local rwtimet = rwt.to_table(rwtime)
	return {
		c = rwtimet.c or 0,
		m = rwtimet.m or 0,
		s = rwtimet.s or 0
	}
end

function rwt.to_table(rwtime)
	if type(rwtime) == "table" then
		return rwtime
	elseif type(rwtime) == "string" then
		return rwt.parse(rwtime)
	elseif type(rwtime) == "number" then
		local res = {}
		local seconds = atfloor(rwtime)
		res.s = seconds % 60
		local minutes = atfloor(seconds/60)
		res.m = minutes % 60
		res.c = atfloor(minutes/60)
		return res
	end
end

function rwt.to_secs(rwtime, c_over)
	local res = rwtime
	if type(rwtime) == "string" then
		res = rwt.parse(rwtime)
	elseif type(rwtime) == "number" then
		return rwtime
	end
	if type(res)=="table" then
		return (c_over or res.c)*60*60 + res.m*60 + res.s
	end
end

function rwt.to_string(rwtime_p, no_cycle)
	local rwtime = rwt.to_table(rwtime_p)
	if rwtime.c~=0 and not no_cycle then
		return string.format("%d;%02d;%02d", rwtime.c, rwtime.m, rwtime.s)
	else
		return string.format("%02d;%02d", rwtime.m, rwtime.s)
	end
end

---

local function v_n(str, cpl)
	if not str then return nil end
	if str == "" then
		return 0
	end
	local n = tonumber(str)
	if not cpl and (n<0 or n>59) then
		return nil
	end
	return n
end

function rwt.parse(str)
	--atdebug("parse",str)
	--3-value form
	local str_c, str_m, str_s = string.match(str, "^(%-?%d?%d?);(%d%d);(%d?%d?)$")
	if str_c and str_m and str_s then
		--atdebug("3v",str_c, str_m, str_s)
		local c, m, s = v_n(str_c, true), v_n(str_m), v_n(str_s)
		if c and m and s then
			return rwt.new(c,m,s)
		end
	end
	--2-value form
	local str_m, str_s = string.match(str, "^(%d?%d?);(%d?%d?)$")
	if str_m and str_s then
		--atdebug("2v",str_m, str_s)
		local m, s = v_n(str_m), v_n(str_s)
		if m and s then
			return rwt.new(0,m,s)
		end
	end
end

---

function rwt.add(t1, t2)
	local t1s = rwt.to_secs(t1)
	local t2s = rwt.to_secs(t2)
	return rwt.to_table(t1s + t2s)
end

-- How many seconds FROM t1 TO t2
function rwt.diff(t1, t2)
	local t1s = rwt.to_secs(t1)
	local t2s = rwt.to_secs(t2)
	return t2s - t1s
end

-- Subtract t2 from t1 (inverted argument order compared to diff())
function rwt.sub(t1, t2)
	return rwt.to_table(rwt.diff(t2, t1))
end

-- Adjusts t2 by thresh and then returns time from t1 to t2
function rwt.adj_diff(t1, t2, thresh)
	local newc = rwt.adjust_cycle(t2, thresh, t1)
	local t1s = rwt.to_secs(t1)
	local t2s = rwt.to_secs(t2, newc)
	return t1s - t2s
end



-- Threshold values
-- "reftime" is the time to which this is made relative and defaults to now.
rwt.CA_FUTURE	= 60*60 - 1		-- Selected so that time lies at or in the future of reftime (at nearest point in time)
rwt.CA_FUTURES	= 60*60 		-- Same, except when times are equal, advances one full cycle
rwt.CA_PAST		= 0				-- Selected so that time lies at or in the past of reftime
rwt.CA_PASTS	= -1	 		-- Same, except when times are equal, goes back one full cycle
rwt.CA_CENTER	= 30*60			-- If time is within past 30 minutes of reftime, selected as past, else selected as future.

-- Adjusts the "cycle" value of a railway time to be in some relation to reftime.
-- Returns new cycle
function rwt.adjust_cycle(rwtime, reftime_p, thresh)
	local reftime = reftime_p or rwt.now()
	
	local reftimes = rwt.to_secs(reftime)
	
	local rwtimes = rwt.to_secs(rwtime, 0)
	local timeres = reftimes + thresh - rwtimes
	local cycles = atfloor(timeres / (60*60))

	return cycles
end

function rwt.adjust(rwtime, reftime, thresh)
	local cp = rwt.copy(rwtime)
	cp.c = rwt.adjust_cycle(rwtime, reftime, thresh)
	return cp
end

-- Useful for departure times: returns time (in seconds)
-- until the next (adjusted FUTURE) occurence of deptime is reached
-- in this case, rwtime is used as reftime and deptime should lie in the future of rwtime
-- rwtime defaults to NOW
function rwt.get_time_until(deptime, rwtime_p)
	local rwtime = rwtime_p or rwt.now()
	return rwt.adj_diff(rwtime, deptime, rwt.CA_FUTURE)
end


-- Helper functions for handling "repeating times" (rpt)
-- Those are generic declarations for time intervals like "every 5 minutes", with an optional offset
-- ( /02;00-00;45 in timetable syntax

-- Get the time (in seconds) until the next time this rpt occurs
function rwt.time_to_next_rpt(rwtime, rpt_interval, rpt_offset)
	local rpti_s   = rwt.to_secs(rpt_interval)
	
	return (rpti_s - rwt.time_from_last_rpt(rwtime, rpti_s, rpt_offset)) % rpti_s
	-- Modulo is just there to clip a false value of rpti_s to 0
end


-- Get the time (in seconds) since the last time this rpt occured
function rwt.time_from_last_rpt(rwtime, rpt_interval, rpt_offset)
	local rwtime_s = rwt.to_secs(rwtime)
	local rpti_s   = rwt.to_secs(rpt_interval)
	local rpto_s   = rwt.to_secs(rpt_offset)
	
	return ((rwtime_s - rpto_s) % rpti_s)
end

-- From rwtime, get the next time that is divisible by rpt_interval offset by rpt_offset
function rwt.next_rpt(rwtime, rpt_interval, rpt_offset)
	local rwtime_s = rwt.to_secs(rwtime)
	local rpti_s   = rwt.to_secs(rpt_interval)
	local time_from_last = rwt.time_from_last_rpt(rwtime_s, rpti_s, rpt_offset)
	
	local res_s = rwtime_s - time_from_last + rpti_s
	
	return rwt.to_table(res_s)
end

-- from rwtime, get the last time that this rpt matched (which is actually just next_rpt - rpt_offset
function rwt.last_rpt(rwtime, rpt_interval, rpt_offset)
	local rwtime_s = rwt.to_sec(rwtime)
	local rpti_s   = rwt.to_sec(rpt_interval)
	local time_from_last = rwt.time_from_last_rpt(rwtime, rpt_interval, rpt_offset)
	
	local res_s = rwtime_s - time_from_last
	
	return rwt.to_table(res_s)
end


advtrains.lines.rwt = rwt

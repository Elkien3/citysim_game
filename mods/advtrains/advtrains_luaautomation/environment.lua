-------------
-- lua sandboxed environment

-- function to cross out functions and userdata.
-- modified from dump()
function atlatc.remove_invalid_data(o, nested)
	if o==nil then return nil end
	local valid_dt={["nil"]=true, boolean=true, number=true, string=true}
	if type(o) ~= "table" then
		--check valid data type
		if not valid_dt[type(o)] then
			return nil
		end
		return o
	end
	-- Contains table -> true/nil of currently nested tables
	nested = nested or {}
	if nested[o] then
		return nil
	end
	nested[o] = true
	for k, v in pairs(o) do
		v = atlatc.remove_invalid_data(v, nested)
	end
	nested[o] = nil
	return o
end


local env_proto={
	load = function(self, envname, data)
		self.name=envname
		self.sdata=data.sdata and atlatc.remove_invalid_data(data.sdata) or {}
		self.fdata={}
		self.init_code=data.init_code or ""
		self.step_code=data.step_code or ""
	end,
	save = function(self)
		-- throw any function values out of the sdata table
		self.sdata = atlatc.remove_invalid_data(self.sdata)
		return {sdata = self.sdata, init_code=self.init_code, step_code=self.step_code}
	end,
}

--Environment
--Code modified from mesecons_luacontroller (credit goes to Jeija and mesecons contributors)

local safe_globals = {
	"assert", "error", "ipairs", "next", "pairs", "select",
	"tonumber", "tostring", "type", "unpack", "_VERSION"
}

--print is actually minetest.chat_send_all()
--using advtrains.print_concat_table because it's cool
local function safe_print(t, ...)
	local str=advtrains.print_concat_table({t, ...})
	minetest.log("action", "[atlatc] "..str)
	minetest.chat_send_all(str)
end

local function safe_date(f, t)
	if not f then
		-- fall back to old behavior
		return(os.date("*t",os.time()))
	else
		--pass parameters
		return os.date(f,t)
	end
end

-- string.rep(str, n) with a high value for n can be used to DoS
-- the server. Therefore, limit max. length of generated string.
local function safe_string_rep(str, n)
	if #str * n > 2000 then
		debug.sethook() -- Clear hook
		error("string.rep: string length overflow", 2)
	end

	return string.rep(str, n)
end

-- string.find with a pattern can be used to DoS the server.
-- Therefore, limit string.find to patternless matching.
-- Note: Disabled security since there are enough security leaks and this would be unneccessary anyway to DoS the server
local function safe_string_find(...)
	--if (select(4, ...)) ~= true then
	--	debug.sethook() -- Clear hook
	--	error("string.find: 'plain' (fourth parameter) must always be true for security reasons.")
	--end

	return string.find(...)
end

local mp=minetest.get_modpath("advtrains_luaautomation")

local static_env = {
	--core LUA functions
	print = safe_print,
	string = {
		byte = string.byte,
		char = string.char,
		format = string.format,
		len = string.len,
		lower = string.lower,
		upper = string.upper,
		rep = safe_string_rep,
		reverse = string.reverse,
		sub = string.sub,
		find = safe_string_find,
	},
	math = {
		abs = math.abs,
		acos = math.acos,
		asin = math.asin,
		atan = math.atan,
		atan2 = math.atan2,
		ceil = math.ceil,
		cos = math.cos,
		cosh = math.cosh,
		deg = math.deg,
		exp = math.exp,
		floor = math.floor,
		fmod = math.fmod,
		frexp = math.frexp,
		huge = math.huge,
		ldexp = math.ldexp,
		log = math.log,
		log10 = math.log10,
		max = math.max,
		min = math.min,
		modf = math.modf,
		pi = math.pi,
		pow = math.pow,
		rad = math.rad,
		random = math.random,
		sin = math.sin,
		sinh = math.sinh,
		sqrt = math.sqrt,
		tan = math.tan,
		tanh = math.tanh,
	},
	table = {
		concat = table.concat,
		insert = table.insert,
		maxn = table.maxn,
		remove = table.remove,
		sort = table.sort,
	},
	os = {
		clock = os.clock,
		difftime = os.difftime,
		time = os.time,
		date = safe_date,
	},
	POS = function(x,y,z) return {x=x, y=y, z=z} end,
	getstate = advtrains.getstate,
	setstate = advtrains.setstate,
	is_passive = advtrains.is_passive,
	--interrupts are handled per node, position unknown. (same goes for digilines)
	--however external interrupts can be set here.
	interrupt_pos = function(parpos, imesg)
		local pos=atlatc.pcnaming.resolve_pos(parpos)
		atlatc.interrupt.add(0, pos, {type="ext_int", ext_int=true, message=imesg})
	end,
}

-- If interlocking is present, enable route setting functions
if advtrains.interlocking then
	local function gen_checks(signal, route_name, noroutesearch)
		assertt(route_name, "string")
		local pos = atlatc.pcnaming.resolve_pos(signal)
		local sigd = advtrains.interlocking.db.get_sigd_for_signal(pos)
		if not sigd then
			error("There's no signal at "..minetest.pos_to_string(pos))
		end
		local tcbs = advtrains.interlocking.db.get_tcbs(sigd)
		if not tcbs then
			error("Inconsistent configuration, no tcbs for signal at "..minetest.pos_to_string(pos))
		end
		
		local routeid, route
		if not noroutesearch then
			for routeidt, routet in ipairs(tcbs.routes) do
				if routet.name == route_name then
					routeid = routeidt
					route = routet
					break
				end
			end
			if not route then
				error("No route called "..route_name.." at "..minetest.pos_to_string(pos))
			end
		end
		return pos, sigd, tcbs, routeid, route
	end


	static_env.can_set_route = function(signal, route_name)
		local pos, sigd, tcbs, routeid, route = gen_checks(signal, route_name)
		-- if route is already set on signal, return whether it's committed
		if tcbs.routeset == routeid then
			return tcbs.route_committed
		end
		-- actually try setting route (parameter 'true' designates try-run
		local ok = advtrains.interlocking.route.set_route(sigd, route, true)
		return ok
	end
	static_env.set_route = function(signal, route_name)
		local pos, sigd, tcbs, routeid, route = gen_checks(signal, route_name)
		return advtrains.interlocking.route.update_route(sigd, tcbs, routeid)
	end
	static_env.cancel_route = function(signal)
		local pos, sigd, tcbs, routeid, route = gen_checks(signal, "", true)
		return advtrains.interlocking.route.update_route(sigd, tcbs, nil, true)
	end
	static_env.get_aspect = function(signal)
		local pos = atlatc.pcnaming.resolve_pos(signal)
		return advtrains.interlocking.signal_get_aspect(pos)
	end
	static_env.set_aspect = function(signal, asp)
		local pos = atlatc.pcnaming.resolve_pos(signal)
		return advtrains.interlocking.signal_set_aspect(pos)
	end
end

-- Lines-specific:
if advtrains.lines then
	local atlrwt = advtrains.lines.rwt
	static_env.rwt = {
		now = atlrwt.now,
		new = atlrwt.new,
		copy = atlrwt.copy,
		to_table = atlrwt.to_table,
		to_secs = atlrwt.to_secs,
		to_string = atlrwt.to_string,
		add = atlrwt.add,
		diff = atlrwt.diff,
		sub = atlrwt.sub,
		adj_diff = atlrwt.adj_diff,
		adjust_cycle = atlrwt.adjust_cycle,
		adjust = atlrwt.adjust,
		to_string = atlrwt.to_string,
		get_time_until = atlrwt.get_time_until,
		next_rpt = atlrwt.next_rpt,
		last_rpt = atlrwt.last_rpt,
		time_from_last_rpt = atlrwt.time_from_last_rpt,
		time_to_next_rpt = atlrwt.time_to_next_rpt,
	}
end

for _, name in pairs(safe_globals) do
	static_env[name] = _G[name]
end


--The environment all code calls get is a table that has set static_env as metatable.
--In general, every variable is local to a single code chunk, but kept persistent over code re-runs. Data is also saved, but functions and userdata and circular references are removed
--Init code and step code's environments are not saved
-- S - Table that can contain any save data global to the environment. Will be saved statically. Can't contain functions or userdata or circular references.
-- F - Table global to the environment, can contain volatile data that is deleted when server quits.
--     The init code should populate this table with functions and other definitions.

local proxy_env={}
--proxy_env gets a new metatable in every run, but is the shared environment of all functions ever defined.

-- returns: true, fenv if successful; nil, error if error 
function env_proto:execute_code(localenv, code, evtdata, customfct)
	local metatbl ={
		__index = function(t, i)
			if i=="S" then
				return self.sdata
			elseif i=="F" then
				return self.fdata
			elseif i=="event" then
				return evtdata
			elseif customfct and customfct[i] then
				return customfct[i]
			elseif localenv and localenv[i] then
				return localenv[i]
			end
			return static_env[i]
		end,
		__newindex = function(t, i, v)
			if i=="S" or i=="F" or i=="event" or (customfct and customfct[i]) or static_env[i] then
				debug.sethook()
				error("Trying to overwrite environment contents")
			end
			localenv[i]=v
		end,
	}
	setmetatable(proxy_env, metatbl)
	local fun, err=loadstring(code)
	if not fun then
		return false, err
	end
	
	setfenv(fun, proxy_env)
	local succ, data = pcall(fun)
	if succ then
		data=localenv
	end
	return succ, data
end

function env_proto:run_initcode()
	if self.init_code and self.init_code~="" then
		local old_fdata=self.fdata
		self.fdata = {}
		atprint("[atlatc]Running initialization code for environment '"..self.name.."'")
		local succ, err = self:execute_code({}, self.init_code, {type="init", init=true})
		if not succ then
			atwarn("[atlatc]Executing InitCode for '"..self.name.."' failed:"..err)
			self.init_err=err
			if old_fdata then
				self.fdata=old_fdata
				atwarn("[atlatc]The 'F' table has been restored to the previous state.")
			end
		end
	end
end
function env_proto:run_stepcode()
	if self.step_code and self.step_code~="" then
		local succ, err = self:execute_code({}, self.step_code, nil, {})
		if not succ then
			--TODO
		end
	end
end

--- class interface

function atlatc.env_new(name)
	local newenv={
		name=name,
		init_code="",
		step_code="",
		sdata={}
	}
	setmetatable(newenv, {__index=env_proto})
	return newenv
end
function atlatc.env_load(name, data)
	local newenv={}
	setmetatable(newenv, {__index=env_proto})
	newenv:load(name, data)
	return newenv
end

function atlatc.run_initcode()
	for envname, env in pairs(atlatc.envs) do
		env:run_initcode()
	end
end
function atlatc.run_stepcode()
	for envname, env in pairs(atlatc.envs) do
		env:run_stepcode()
	end
end





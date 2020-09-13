-- ars.lua
-- automatic routesetting

--[[
	The "ARS table" and its effects:
	Every route has (or can have) an associated ARS table. This can either be
	ars = { [n] = {ln="<line>"}/{rc="<routingcode>"}/{c="<a comment>"} }
	a list of rules involving either line or routingcode matchers (or comments, those are ignored)
	The first matching rule determines the route to set.
	- or -
	ars = {default = true}
	this means that all trains that no other rule matches on should use this route
	
	Compound ("and") conjunctions are not supported (--TODO should they?)
	
	For editing, those tables are transformed into lines in a text area:
	{ln=...} -> LN ...
	{rc=...} -> RC ...
	{c=...}  -> #...
	{default=true} -> *
	See also route_ui.lua
]]

local il = advtrains.interlocking

-- The ARS data are saved in a table format, but are entered in text format. Utility functions to transform between both.
function il.ars_to_text(arstab)
	if not arstab then
		return ""
	end
	
	local txt = {}

	for i, arsent in ipairs(arstab) do
		local n = ""
		if arsent.n then
			n = "!"
		end
		if arsent.ln then
			txt[#txt+1] = n.."LN "..arsent.ln
		elseif arsent.rc then
			txt[#txt+1] = n.."RC "..arsent.rc
		elseif arsent.c then
			txt[#txt+1] = "#"..arsent.c
		end
	end
	
	if arstab.default then
		return "*\n" .. table.concat(txt, "\n")
	end
	return table.concat(txt, "\n")
end

function il.text_to_ars(t)
	if t=="" then
		return nil
	elseif t=="*" then
		return {default=true}
	end
	local arstab = {}
	for line in string.gmatch(t, "[^\r\n]+") do
		if line=="*" then
			arstab.default = true
		else
			local c, v = string.match(line, "^(...?)%s(.*)$")
			if c and v then
				local n = nil
				if string.sub(c,1,1) == "!" then
					n = true
					c = string.sub(c,2)
				end
				local tt=string.upper(c)
				if tt=="LN" then
					arstab[#arstab+1] = {ln=v, n=n}
				elseif tt=="RC" then
					arstab[#arstab+1] = {rc=v, n=n}
				end
			else
				local ct = string.match(line, "^#(.*)$")
				if ct then arstab[#arstab+1] = {c = ct} end
			end
		end
	end
	return arstab
end

local function find_rtematch(routes, train)
	local default
	for rteid, route in ipairs(routes) do
		if route.ars then
			if route.ars.default then
				default = rteid
			else
				if il.ars_check_rule_match(route.ars, train) then
					return rteid
				end
			end
		end
	end
	return default
end

-- Checks whether ARS rule explicitly matches. This does not take into account the "default" field, since a wider context is required for this.
-- Returns the rule number that matched, or nil if nothing matched
function il.ars_check_rule_match(ars, train)
		if not ars then
			return nil
		end
		local line = train.line
		local routingcode = train.routingcode
		for arskey, arsent in ipairs(ars) do
			--atdebug(arsent, line, routingcode)
			if arsent.n then
				-- rule is inverse...
				if arsent.ln and (not line or arsent.ln ~= line) then
					return arskey
				elseif arsent.rc and (not routingcode or not string.find(" "..routingcode.." ", " "..arsent.rc.." ", nil, true)) then
					return arskey
				end
				return nil
			end
				
			if arsent.ln and line and arsent.ln == line then
				return arskey
			elseif arsent.rc and routingcode and string.find(" "..routingcode.." ", " "..arsent.rc.." ", nil, true) then
				return arskey
			end
		end
		return nil
end

function advtrains.interlocking.ars_check(sigd, train)
	local tcbs = il.db.get_tcbs(sigd)
	if not tcbs or not tcbs.routes then return end
	
	if tcbs.ars_disabled then
		-- No-ARS mode of signal.
		-- ignore...
		return
	end
	
	if tcbs.routeset then
		-- ARS is not in effect when a route is already set
		-- just "punch" routesetting, just in case callback got lost.
		minetest.after(0, il.route.update_route, sigd, tcbs, nil, nil)
		return
	end
	
	local rteid = find_rtematch(tcbs.routes, train)
	if rteid then
		--delay routesetting, it should not occur inside train step
		-- using after here is OK because that gets called on every path recalculation
		minetest.after(0, il.route.update_route, sigd, tcbs, rteid, nil)
	end
end

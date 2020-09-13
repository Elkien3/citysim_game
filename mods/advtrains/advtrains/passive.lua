-- passive.lua
-- API to passive components, as described in passive_api.txt of advtrains_luaautomation
-- This has been moved to the advtrains core in turn with the interlocking system,
-- to prevent a dependency on luaautomation.

local deprecation_warned = {}

function advtrains.getstate(parpos, pnode)
	local pos
	if atlatc then
		pos = atlatc.pcnaming.resolve_pos(parpos)
	else
		pos = advtrains.round_vector_floor_y(parpos)
	end
	if type(pos)~="table" or (not pos.x or not pos.y or not pos.z) then
		debug.sethook()
		error("Invalid position supplied to getstate")
	end
	local node=pnode or advtrains.ndb.get_node(pos)
	local ndef=minetest.registered_nodes[node.name]
	local st
	if ndef and ndef.advtrains and ndef.advtrains.getstate then
		 st=ndef.advtrains.getstate
	elseif ndef and ndef.luaautomation and ndef.luaautomation.getstate then
		if not deprecation_warned[node.name] then
			minetest.log("warning", node.name.." uses deprecated definition of ATLATC functions in the 'luaautomation' field. Please move them to the 'advtrains' field!")
		end
		st=ndef.luaautomation.getstate
	else
		return nil
	end
	if type(st)=="function" then
		return st(pos, node)
	else
		return st
	end
end

function advtrains.setstate(parpos, newstate, pnode)
	local pos
	if atlatc then
		pos = atlatc.pcnaming.resolve_pos(parpos)
	else
		pos = advtrains.round_vector_floor_y(parpos)
	end
	if type(pos)~="table" or (not pos.x or not pos.y or not pos.z) then
		debug.sethook()
		error("Invalid position supplied to getstate")
	end
	local node=pnode or advtrains.ndb.get_node(pos)
	local ndef=minetest.registered_nodes[node.name]
	local st
	if ndef and ndef.advtrains and ndef.advtrains.setstate then
		 st=ndef.advtrains.setstate
	elseif ndef and ndef.luaautomation and ndef.luaautomation.setstate then
		if not deprecation_warned[node.name] then
			minetest.log("warning", node.name.." uses deprecated definition of ATLATC functions in the 'luaautomation' field. Please move them to the 'advtrains' field!")
		end
		st=ndef.luaautomation.setstate
	else
		return nil
	end
	
	if advtrains.get_train_at_pos(pos) then
		return false
	end
	
	if advtrains.interlocking and advtrains.interlocking.route.has_route_lock(minetest.pos_to_string(pos)) then
		return false
	end
	
	st(pos, node, newstate)
	return true
end

function advtrains.is_passive(parpos, pnode)
	local pos
	if atlatc then
		pos = atlatc.pcnaming.resolve_pos(parpos)
	else
		pos = advtrains.round_vector_floor_y(parpos)
	end
	if type(pos)~="table" or (not pos.x or not pos.y or not pos.z) then
		debug.sethook()
		error("Invalid position supplied to getstate")
	end
	local node=pnode or advtrains.ndb.get_node(pos)
	local ndef=minetest.registered_nodes[node.name]
	if ndef and ndef.advtrains and ndef.advtrains.getstate then
		return true
	elseif ndef and ndef.luaautomation and ndef.luaautomation.getstate then
		if not deprecation_warned[node.name] then
			minetest.log("warning", node.name.." uses deprecated definition of ATLATC functions in the 'luaautomation' field. Please move them to the 'advtrains' field!")
		end
		return true
	else
		return false
	end
end

-- switches a node back to fallback state, if defined. Doesn't support pcnaming.
function advtrains.set_fallback_state(pos, pnode)
	local node=pnode or advtrains.ndb.get_node(pos)
	local ndef=minetest.registered_nodes[node.name]
	local st
	if ndef and ndef.advtrains and ndef.advtrains.setstate
			and ndef.advtrains.fallback_state then
		if advtrains.get_train_at_pos(pos) then
			return false
		end
		
		if advtrains.interlocking and advtrains.interlocking.route.has_route_lock(minetest.pos_to_string(pos)) then
			return false
		end
		
		ndef.advtrains.setstate(pos, node, ndef.advtrains.fallback_state)
		return true
	end
	
	
end

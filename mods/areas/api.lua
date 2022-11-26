local hudHandlers = {}

areas.registered_on_adds = {}
areas.registered_on_removes = {}
areas.registered_on_moves = {}

function areas:registerOnAdd(func)
	table.insert(areas.registered_on_adds, func)
end

function areas:registerOnRemove(func)
	table.insert(areas.registered_on_removes, func)
end

function areas:registerOnMove(func)
	table.insert(areas.registered_on_moves, func)
end

--- Adds a function as a HUD handler, it will be able to add items to the Areas HUD element.
function areas:registerHudHandler(handler)
	table.insert(hudHandlers, handler)
end

function areas:getExternalHudEntries(pos)
	local areas = {}
	for _, func in pairs(hudHandlers) do
		func(pos, areas)
	end
	return areas
end

--- Returns a list of areas that include the provided position.
function areas:getAreasAtPos(pos)
	local res = {}

	if self.store then
		local a = self.store:get_areas_for_pos(pos, false, true)
		for store_id, store_area in pairs(a) do
			local id = tonumber(store_area.data)
			res[id] = self.areas[id]
		end
	else
		local px, py, pz = pos.x, pos.y, pos.z
		for id, area in pairs(self.areas) do
			local ap1, ap2 = area.pos1, area.pos2
			if
					(px >= ap1.x and px <= ap2.x) and
					(py >= ap1.y and py <= ap2.y) and
					(pz >= ap1.z and pz <= ap2.z) then
				res[id] = area
			end
		end
	end
	return res
end

--- Returns areas that intersect with the passed area.
function areas:getAreasIntersectingArea(pos1, pos2)
	local res = {}
	if self.store then
		local a = self.store:get_areas_in_area(pos1, pos2,
				true, false, true)
		for store_id, store_area in pairs(a) do
			local id = tonumber(store_area.data)
			res[id] = self.areas[id]
		end
	else
		self:sortPos(pos1, pos2)
		local p1x, p1y, p1z = pos1.x, pos1.y, pos1.z
		local p2x, p2y, p2z = pos2.x, pos2.y, pos2.z
		for id, area in pairs(self.areas) do
			local ap1, ap2 = area.pos1, area.pos2
			if
					(ap1.x <= p2x and ap2.x >= p1x) and
					(ap1.y <= p2y and ap2.y >= p1y) and
					(ap1.z <= p2z and ap2.z >= p1z) then
				-- Found an intersecting area.
				res[id] = area
			end
		end
	end
	return res
end

-- Checks if the area is unprotected or owned by you
function areas:canInteract(pos, name)
	if minetest.check_player_privs(name, self.adminPrivs) then
		return true
	end
	local owned = false
	for _, area in pairs(self:getAreasAtPos(pos)) do
		if area.owner == name or area.open then
			return true
		elseif jobs and jobs.permissionstring(name, area.owner) then
			return true
		elseif areas.factions_available and area.faction_open then
			if (factions.version or 0) < 2 then
				local faction_name = factions.get_player_faction(name)
				if faction_name then
					for _, fname in ipairs(area.faction_open or {}) do
						if faction_name == fname then
							return true
						end
					end
				end
			else
				for _, fname in ipairs(area.faction_open or {}) do
					if factions.player_is_in_faction(fname, name) then
						return true
					end
				end
			end
		end
		owned = true
	end
	return not owned
end

-- Returns a table (list) of all players that own an area
function areas:getNodeOwners(pos)
	local owners = {}
	for _, area in pairs(self:getAreasAtPos(pos)) do
		table.insert(owners, area.owner)
	end
	return owners
end

--- Checks if the area intersects with an area that the player can't interact in.
-- Note that this fails and returns false when the specified area is fully
-- owned by the player, but with multiple protection zones, none of which
-- cover the entire checked area.
-- @param name (optional) Player name. If not specified checks for any intersecting areas.
-- @param allow_open Whether open areas should be counted as if they didn't exist.
-- @return Boolean indicating whether the player can interact in that area.
-- @return Un-owned intersecting area ID, if found.
function areas:canInteractInArea(pos1, pos2, name, allow_open)
	if name and minetest.check_player_privs(name, self.adminPrivs) then
		return true
	end
	self:sortPos(pos1, pos2)

	-- Intersecting non-owned area ID, if found.
	local blocking_area = nil

	local areas = self:getAreasIntersectingArea(pos1, pos2)
	for id, area in pairs(areas) do
		-- First check for a fully enclosing owned area.
		-- A little optimization: isAreaOwner isn't necessary
		-- here since we're iterating over all relevant areas.
		if area.owner == name and
				self:isSubarea(pos1, pos2, id) then
			return true
		end

		-- Then check for intersecting non-owned (blocking) areas.
		-- We don't bother with this check if we've already found a
		-- blocking area, as the check is somewhat expensive.
		-- The area blocks if the area is closed or open areas aren't
		-- acceptable to the caller, and the area isn't owned.
		-- Note: We can't return directly here, because there might be
		-- an exclosing owned area that we haven't gotten to yet.
		if not blocking_area and
				(not allow_open or not area.open) and
				(not name or not self:isAreaOwner(id, name)) then
			blocking_area = id
		end
	end

	if blocking_area then
		return false, blocking_area
	end

	-- There are no intersecting areas or they are only partially
	-- intersecting areas and they are all owned by the player.
	return true
end

local function get_area(area)
	local length = (math.abs(area.pos2.x - area.pos1.x))--+1)
	local width = (math.abs(area.pos2.z - area.pos1.z))--+1)
	return length*width
end

local function is_equal(area1, area2)
	return vector.equals(area1.pos1, area2.pos1) and vector.equals(area1.pos2, area2.pos2)
end

local function get_intersect(area1, area2)
	local a1p1, a1p2 = area1.pos1, area1.pos2
	local a2p1, a2p2 = area2.pos1, area2.pos2
	if
		(a1p1.x < a2p2.x and a1p2.x > a2p1.x) and
		(a1p1.y <= a2p2.y and a1p2.y >= a2p1.y) and
		(a1p1.z < a2p2.z and a1p2.z > a2p1.z) then
		local newarea = {}
		--minetest.chat_send_all("intersect")
		newarea.pos1 = {x=math.max(a1p1.x,a2p1.x), y=math.max(a1p1.y,a2p1.y), z=math.max(a1p1.z,a2p1.z)}
		newarea.pos2 = {x=math.min(a1p2.x,a2p2.x), y=math.min(a1p2.y,a2p2.y), z=math.min(a1p2.z,a2p2.z)}
		newarea.pos1, newarea.pos2 = areas:sortPos(newarea.pos1, newarea.pos2)
		return newarea
	end
end

--Im using the Inclusion-Exclusion method
local function inclusionExclusion(areatbl, include)
	if include == nil then include = true end
	local totalarea = 0
	local intersecttbl = {}
	local temparealist = table.copy(areatbl)
	for i, area in pairs(areatbl) do
		if include then
			totalarea = totalarea+get_area(area)
		else
			totalarea = totalarea-get_area(area)
		end
		for i2, area2 in pairs(temparealist) do
			if i~=i2 then
				local intersect = get_intersect(area, area2)
				if intersect then
					table.insert(intersecttbl, intersect)
				end
			end
		end
	end
	for i, area in pairs(intersecttbl) do
		for i2, area2 in pairs(intersecttbl) do
			if i~=i2 and is_equal(area, area2) then
				table.remove(intersecttbl, i2)
				--minetest.chat_send_all("duplicate intersect detected")
			end
		end
	end
	if #intersecttbl > 0 then
		totalarea = totalarea+inclusionExclusion(intersecttbl, (not include))
	end
	
	return totalarea
end

function areas:get_player_total_area(playername, arealist)
	local areatbl = {}
	local tax_exempt = minetest.deserialize(minetest.settings:get_string("tax_exemptions")) or {}
	--local t1 = minetest.get_us_time()
	for id, area in pairs(arealist or self.areas) do--area finding loop
		if not area.parent
		and (area.owner == playername or
			(jobs and (jobs.list[jobs.split(area.owner, ":")[1]] or {ceo = ""}).ceo == playername and not tax_exempt[jobs.split(area.owner, ":")[1]]))
		then
			for id2, area2 in pairs(areas:getAreasIntersectingArea(area.pos1, area.pos2)) do
				if id2 ~= id and self:isSubarea(area.pos1, area.pos2, id2) and (area2.parent and area2.parent~=id) then
					goto next
				end
			end
			local temparea = table.copy(area)
			temparea.pos1 = vector.subtract(temparea.pos1, 1)--doing this so i can act as though the position goes down the side of the node instead of the middle
			temparea.pos1.y = 0
			temparea.pos2.y = 0
			table.insert(areatbl, temparea)
			::next::
		end
	end
	local result = inclusionExclusion(areatbl)
	--minetest.chat_send_all(string.format("elapsed time: %g ms", (minetest.get_us_time() - t1) / 1000))
	return result
end
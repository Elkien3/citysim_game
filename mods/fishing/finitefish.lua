local max_fish = 8--maximum amount of fish in an area
local area_size = 64 --data should be reset if you change this 
local update_time = 60--time in minutes to see if fishes should be updated, and update if so
local update_days = 7--time in minetest days the update should take place
local search_size = area_size--how far a fish will travel to get caught by you
local storage = minetest.get_mod_storage()
local growth_per_update = 1.1--what to multiply the amount of fish by each update
local spring_growth = 1.2--how much more to grow in spring
local fish_areas = minetest.deserialize(storage:get_string("fish_areas")) or {}
local move_percent = 0.2--the percent of fish in an area that leave to the adjacent areas

local function update()
	local days = minetest.get_day_count()
	local last_update = tonumber(storage:get_string("last_update"))
	if not last_update or days-last_update > update_days then
		--local move_amounts = {}
		for hash, amount in pairs(fish_areas) do
			amount = amount*growth_per_update
			if seasons_getseason and seasons_getseason(days) == "Spring" then--extra population growth in spring
				amount = amount*spring_growth
			end
			--move_amounts[hash] = amount*move_percent
			amount = math.floor(amount +1.5)
			if amount > max_fish then--remove the area if it has the max fish
				fish_areas[hash] = nil
			else
				fish_areas[hash] = amount
			end
		end
		--[[for hash, amount in pairs(fish_areas) do --not going to use this yet, its having fish move from one area to another, so overfishing on one area can cause fish population to decrease farther out.
			local pos = minetest.get_position_from_hash(hash)
			for i, pos2 in pairs({x=-1,y=0,z=0}, {x=1,y=0,z=0}, {x=0,y=0,z=-1}, {x=0,y=0,z=1}) do
				local hash2 = minetest.hash_node_position(vector.add(pos, pos2))
				if fish_areas[hash2] then
					local moveamount = math.floor(move_amounts[hash]/4+.5)
					if fish_areas[hash2].amount + moveamount > max_fish then
						moveamount = max_fish-fish_areas[hash2].amount
					end
					fish_areas[hash2].amount = fish_areas[hash2].amount+moveamount
					amount = amount - moveamount
				end
			end
		end--]]
		last_update = days
		storage:set_string("fish_areas", minetest.serialize(fish_areas))
		storage:set_string("last_update", days)
	end
	minetest.after(update_time*60, update)
end
minetest.after(10, update)

local function interpolate(x,y,alpha) --simple linear interpolation
	local difference=y-x
	local progress=alpha*difference
	local result=progress+x
	return result
end

local function getBilinearValue(value00,value10,value01,value11,xProgress,yProgress)
	local top=interpolate(value00,value10,xProgress) --get progress across line A
	local bottom=interpolate(value01,value11,yProgress) --get line B progress
	local middle=interpolate(top,bottom,yProgress) --get progress of line going
	return middle                              --between point A and point B
end

fishing_setting.get_fish_time = function(pos, val)
	pos.y = 0
	local area_pos = vector.divide(pos, area_size)
	local totalfish
	
	local fl = math.floor
	local ci = math.ceil
	local hs = minetest.hash_node_position
	
	local pos00 = {x=fl(area_pos.x), y=0, z=fl(area_pos.z)}
	local pos10 = {x=ci(area_pos.x), y=0, z=fl(area_pos.z)}
	local pos01 = {x=fl(area_pos.x), y=0, z=ci(area_pos.z)}
	local pos11 = {x=ci(area_pos.x), y=0, z=ci(area_pos.z)}
	
	local val00 = fish_areas[hs(pos00)] or max_fish
	local val10 = fish_areas[hs(pos10)] or max_fish
	local val01 = fish_areas[hs(pos01)] or max_fish
	local val11 = fish_areas[hs(pos11)] or max_fish
	
	local relpos = vector.subtract(area_pos, pos00)
	
	totalfish = getBilinearValue(val00, val10, val01, val11, relpos.x, relpos.z)
	
	if totalfish <= 0 then--no divide by 0 plz
		totalfish = .00000000001
	end
	
	return val*(max_fish/totalfish)
end

fishing_setting.take_fish = function(pos)
	pos.y = 0
	local area_pos = vector.divide(pos, area_size)
	
	local fl = math.floor
	local ci = math.ceil
	local hs = minetest.hash_node_position
	
	local postbl = {
		{x=fl(area_pos.x), y=0, z=fl(area_pos.z)},
		{x=ci(area_pos.x), y=0, z=fl(area_pos.z)},
		{x=fl(area_pos.x), y=0, z=ci(area_pos.z)},
		{x=ci(area_pos.x), y=0, z=ci(area_pos.z)}
	}
	
	local takefromindex
	
	--[['take from biggest' method
	local maxamount = 0
	for i, pos2 in pairs(postbl) do
		local hash = hs(pos2)
		local amount = (fish_areas[hash] or max_fish)
		if amount > maxamount then
			maxamount = amount
			takefromindex = hash
		end
	end--]]
	
	--'pick semi-randomly with the closest with the most fish being the most likely' method
	local totalfish = 0
	local totaldistfactor = 0
	for i, pos2 in pairs(postbl) do
		local hash = hs(pos2)
		local amount = (fish_areas[hash] or max_fish)
		local distfactor = 1.414-vector.distance(area_pos, pos2)
		totalfish = totalfish + amount
		totaldistfactor = totaldistfactor + distfactor
	end
	local factors = {}
	local totalfactor = 0
	for i, pos2 in pairs(postbl) do
		local hash = hs(pos2)
		local amount = (fish_areas[hash] or max_fish)
		local fishfactor = amount/totalfish
		local distfactor = 1.414-vector.distance(area_pos, pos2)
		distfactor = distfactor/totaldistfactor
		factors[hash] = distfactor*fishfactor
		totalfactor = totalfactor + factors[hash]
	end
	for hash, factor in pairs(factors) do
		factors[hash] = factors[hash]/totalfactor
	end
	
	local rand = math.random(1000)/1000
	totalfactor = 0
	for hash, factor in pairs(factors) do
		totalfactor = totalfactor + factor
		if rand <= totalfactor then
			takefromindex = hash
			break
		end
	end

	if takefromindex then
		if not fish_areas[takefromindex] then fish_areas[takefromindex] = max_fish end
		fish_areas[takefromindex] = fish_areas[takefromindex]-1
		storage:set_string("fish_areas", minetest.serialize(fish_areas))
		return true
	else
		return false
	end
end


--[[--decided not to make it too just fancy yet, this is to make it so the max number of fish in an area is changed by how much is a suitable habitat.
local habitatbiomeids = {}
local skip_size = 8
local function get_area_habitat_factor(areapos)
	local pos = vector.multiply(areapos, area_size)
	local pos1 = vector.subtract(areapos, area_size/2)
	pos1.y = 0
	local habitats = 0
	local i = 0
	for z = 0, area_size/skip_size do
		for x = 0, area_size/skip_size do
			local checkpos = {x=x*skip_size, y=0, z=z*skip_size}
			local id = minetest.get_biome_data(vector.add(checkpos, pos1)).biome
			i = i + 1
			if habitatbiomeids[id] then
				habitats = habitats + 1
			end
		end
	end
	return habitats/i
end--]]
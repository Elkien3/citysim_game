--
--Helper funtions
--
function mokapi.drop_velocity(obj)
	obj:set_velocity({
		x = math.random(-10, 10) / 9,
		y = 6,
		z = math.random(-10, 10) / 9,
	})
end

function mokapi.drop_object(obj)
	if obj and obj:get_luaentity() then
		mokapi.drop_velocity(obj)
	elseif obj then
		obj:remove() -- item does not exist
	end
end

--
--Functions
--
function mokapi.drop_item(self, item, num)
	if not item then
		return
	end
	if not num then
		num = 1
	end
	local pos
	if type(self) == 'table' then --entity
		pos = self.object:get_pos()
	else --player
		pos = self:get_pos()
	end
	local obj = minetest.add_item(pos, ItemStack(item .. " " .. num))
	mokapi.drop_object(obj)
end

function mokapi.drop_items(self, killed_by_player)
	if not self.drops or #self.drops == 0 then 	-- check for nil or no drops
		return
	end
	if self.child then -- no drops for child mobs
		return
	end
	local obj, item, num
	local pos = self.object:get_pos()
	for n = 1, #self.drops do
		if math.random(1, self.drops[n].chance) == 1 then
			num = math.random(self.drops[n].min or 0, self.drops[n].max or 1)
			item = self.drops[n].name
			if killed_by_player then	-- only drop rare items (drops.min=0) if killed by player
				obj = minetest.add_item(pos, ItemStack(item .. " " .. num))
			elseif self.drops[n].min ~= 0 then
				obj = minetest.add_item(pos, ItemStack(item .. " " .. num))
			end
			mokapi.drop_object(obj)
		end
	end
	self.drops = {}
end

function mokapi.node_drop_items(pos)
	local meta = minetest.get_meta(pos)
	if not meta then
		return
	end
	local drops= minetest.deserialize(meta:get_string("drops"))
	if not drops or #drops == 0 then -- check for nil or no drops
		return
	end
	local obj, item, num
	for n = 1, #drops do
		if math.random(1, drops[n].chance) == 1 then
			num = math.random(drops[n].min or 0, drops[n].max or 1)
			item = drops[n].name
			if drops[n].min ~= 0 then
				obj = minetest.add_item(pos, ItemStack(item .. " " .. num))
			end
			mokapi.drop_object(obj)
		end
	end
end

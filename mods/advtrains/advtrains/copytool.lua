--clipboard = {trainlen = number, [n] = {type = string, flipped = bool, }

-- Yaw is in radians. There are 2pi rad in a circle. North is the 0 point and the angle increases anticlockwise.
-- 4.712389 = 1.5pi; sin(1.5pi) = -1
-- 7.853981 = 2.5pi; sin(2.5pi) = 1

minetest.register_tool("advtrains:copytool", {
	description = attrans("Train copy/paste tool\n\nLeft-click: copy train\nRight-click: paste train"),
	inventory_image = "advtrains_copytool.png",
	wield_image = "advtrains_copytool.png",
	stack_max = 1,
	-- Paste: Take the clipboard and the player yaw, and attempt to place a new train in the world.
	-- The front of the train is used as the start of the new train and it proceeds backwards from
	-- the direction of travel.
	on_place = function(itemstack, placer, pointed_thing)
			return advtrains.pcall(function()
				if ((not pointed_thing.type == "node") or (not placer.get_player_name)) then
					return
				end
				local pname = placer:get_player_name()

				local node=minetest.get_node_or_nil(pointed_thing.under)
				if not node then atprint("[advtrains]Ignore at placer position") return itemstack end
				local nodename=node.name
				if(not advtrains.is_track_and_drives_on(nodename, {default=true})) then
					atprint("no track here, not placing.")
					return itemstack
				end
				if not minetest.check_player_privs(placer, {train_operator = true }) then
					minetest.chat_send_player(pname, "You don't have the train_operator privilege.")
					return itemstack
				end
				if not minetest.check_player_privs(placer, {train_admin = true }) and minetest.is_protected(pointed_thing.under, placer:get_player_name()) then
					return itemstack
				end
				local tconns=advtrains.get_track_connections(node.name, node.param2)
				local yaw = placer:get_look_horizontal()
				local plconnid = advtrains.yawToClosestConn(yaw, tconns)

				local prevpos = advtrains.get_adjacent_rail(pointed_thing.under, tconns, plconnid, {default=true})
				if not prevpos then
					minetest.chat_send_player(pname, "The track you are trying to place the wagon on is not long enough!")
					return
				end

				local meta = itemstack:get_meta()
				if not meta then
					minetest.chat_send_player(pname, attrans("The clipboard couldn't access the metadata. Paste failed."))
				return
				end
				local clipboard = meta:get_string("clipboard")
				if (clipboard == "") then
					minetest.chat_send_player(pname, "The clipboard is empty.");
					return
				end
				clipboard = minetest.deserialize(clipboard)
				if (clipboard.wagons == nil) then
					minetest.chat_send_player(pname, "The clipboard is empty.");
					return
				end

				local wagons = {}
				local n = 1
				for _, wagonProto in pairs(clipboard.wagons) do
					local wagon = advtrains.create_wagon(wagonProto.type, pname)
					advtrains.wagons[wagon].wagon_flipped = wagonProto.wagon_flipped
					wagons[n] = wagon
					n = n + 1
				end

				local id=advtrains.create_new_train_at(pointed_thing.under, plconnid, 0, wagons)
				local train = advtrains.trains[id]
				train.off_track = train.end_index<train.path_trk_b
				if (train.off_track) then
					minetest.chat_send_player(pname, "Back of train would end up off track, cancelling.")
					advtrains.remove_train(id)
					return
				end
				train.text_outside = clipboard.text_outside
				train.text_inside = clipboard.text_inside
				train.routingcode = clipboard.routingcode
				train.line = clipboard.line

				return
			end)
		end,
	-- Copy: Take the pointed-at train and put it on the clipboard
	on_use = function(itemstack, user, pointed_thing)
		if not user:get_player_name() then return end
		if (pointed_thing.type ~= "object") then return end

		local le = pointed_thing.ref:get_luaentity()
		if (le == nil) then
			minetest.chat_send_player(user:get_player_name(), "No such lua entity!")
			return
		end

		local wagon = advtrains.wagons[le.id]
		if (not (le.id and advtrains.wagons[le.id])) then
			minetest.chat_send_player(user:get_player_name(), string.format("No such wagon: %s", le.id))
			return
		end

		local train = advtrains.trains[wagon.train_id]
		if (not train) then
			minetest.chat_send_player(user:get_player_name(), string.format("No such train: %s", wagon.train_id))
			return
		end

		-- Record the train length. The paste operation should require this much free space.
		local clipboard = {
			trainlen = math.ceil(train.trainlen),
			text_outside = train.text_outside,
			text_inside = train.text_inside,
			routingcode = train.routingcode,
			line = train.line,
			wagons = {}
		}
		local trainLength = math.ceil(train.trainlen)

		local n = 1
		for _, wagonid in pairs(train.trainparts) do
			local wagon = advtrains.wagons[wagonid]
			clipboard.wagons[n] = {
				wagon_flipped = wagon.wagon_flipped,
				type = wagon.type
			}
			n = n + 1
		end
		

		local function flip_clipboard(wagon_clipboard)
			local flipped = {}
			local numWagons = #wagon_clipboard
			for k, v in ipairs(wagon_clipboard) do
				local otherSide = (numWagons-k)+1
				flipped[otherSide] = v
				local wagon = flipped[otherSide]
				wagon.wagon_flipped = not wagon.wagon_flipped
			end
			return flipped
		end

		local function is_loco(wagon_id)
			local wagon = advtrains.wagons[wagon_id]
			if (not wagon) then return false end
			local wagon_proto = advtrains.wagon_prototypes[wagon.type or wagon.entity_name]
			if wagon_proto and wagon_proto.is_locomotive then
				return true
			end
			return false
		end

		-- Decide on a new 'front of train' and possibly flip the train.
		-- Locomotive on one end = loco-hauled, that end is front;
		-- if (advtrains.wagons[train.trainparts[1]].is_locomotive) then -- do nothing, train is already in right order
		local numWagons = #train.trainparts
		local backLoco = train.trainparts[numWagons]
		backLoco = is_loco(backLoco)
		local frontLoco = train.trainparts[1]
		frontLoco = is_loco(frontLoco)
		if ((backLoco) and (not frontLoco)) then
			clipboard.wagons = flip_clipboard(clipboard.wagons)
			--minetest.chat_send_player(user:get_player_name(), "Flipped train: Loco-hauled")
		end
		-- locomotives on both ends = train is push-pull / multi-unit, has no front, do nothing
		-- no locomotives on ends = rake of wagons, front is end closest to where player copied.
		if ((not frontLoco) and (not backLoco)) then

			if (wagon.pos_in_trainparts / numWagons > 0.5) then -- towards the end of the rain
				clipboard.wagons = flip_clipboard(clipboard.wagons)
				--minetest.chat_send_player(user:get_player_name(), "Flipped train: Rake")
			end
		end
		
		local meta = itemstack:get_meta()
		if not meta then
			minetest.chat_send_player(pname, attrans("The clipboard couldn't access the metadata. Copy failed."))
			return
		end
		meta:set_string("clipboard", minetest.serialize(clipboard))
		minetest.chat_send_player(user:get_player_name(), attrans("Train copied!"))
		return itemstack
	end
})
local S = minetest.get_translator("vote")
local votesneeded = tonumber(minetest.settings:get("vote_areas_needed")) or 3
minetest.register_privilege("vote_area", {
	description = "Can start vote to do a admin area change."
})

minetest.register_chatcommand("vote_recursive_remove_areas", {
	params = "<name>",
	description = "Start a vote to recursivley remove areas under the given ID.",
	privs = {
		vote_area = true,
	},
	func = function(name, param)
		param = param:trim()
		if param == "" then
			return false, S("Invalid usage, see /help @1.", "recursive_remove_areas")
		end
		
		local id = tonumber(param)
		if not areas.areas[id] then
			return false, S("Area does not exist.")
		end

		return vote.new_vote(name, {
			description = "Recursively remove area " .. param .. " "..areas.areas[id].name..".",
			help = "/yes,  /no  or  /abstain",
			name = name,
			duration = 20,
			perc_needed = 0,

			can_vote = function(self, pname)
				return minetest.check_player_privs(pname,{vote_area = true})
			end,

			on_result = function(self, result, results)
				local yes = results.yes or {}
				if #yes >= votesneeded then
					areas:remove(id, true)
					areas:save()
					minetest.chat_send_all(S("Removed area @1 and it's sub areas. (@2/@3)", id, #yes, votesneeded))
				else
					minetest.chat_send_all(S("Vote to remove area @1 and it's sub areas failed. (@2/@3)", id, #yes, votesneeded))
				end
			end,

			on_vote = function(self, voter, value)
				minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
						self.description .. "'")
			end
		})
	end
})

minetest.register_chatcommand("vote_remove_area", {
	params = "<name>",
	description = "Start a vote to remove the area with the given ID.",
	privs = {
		vote_area = true,
	},
	func = function(name, param)
		param = param:trim()
		if param == "" then
			return false, S("Invalid usage, see /help @1.", "remove_area")
		end
		local id = tonumber(param)
		if not areas.areas[id] then
			return false, S("Area does not exist.")
		end

		return vote.new_vote(name, {
			description = "Remove area " .. param .. " "..areas.areas[id].name,
			help = "/yes,  /no  or  /abstain",
			name = name,
			duration = 20,
			perc_needed = 0,

			can_vote = function(self, pname)
				return minetest.check_player_privs(pname,{vote_area = true})
			end,

			on_result = function(self, result, results)
				local yes = results.yes or {}
				if #yes >= votesneeded then
					areas:remove(id)
					areas:save()
					minetest.chat_send_all(S("Removed area @1. (@2/@3)", id, #yes, votesneeded))
				else
					minetest.chat_send_all(S("Vote to remove area @1 failed. (@2/@3)", id, #yes, votesneeded))
				end
			end,

			on_vote = function(self, voter, value)
				minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
						self.description .. "'")
			end
		})
	end
})

minetest.register_chatcommand("vote_protect", {
	params = "<name>",
	description = "Start a vote protect the given area with admin privs.",
	privs = {
		vote_area = true,
	},
	func = function(name, param)
		param = param:trim()
		if param == "" then
			return false, S("Invalid usage, see /help @1.", "protect")
		end
		local pos1, pos2 = areas:getPos(name)
		if not (pos1 and pos2) then
			return false, S("You need to select an area first.")
		end
		
		return vote.new_vote(name, {
			description = "Protect area " ..param..
				" "..minetest.pos_to_string(pos1)..
				" "  ..minetest.pos_to_string(pos2),
			help = "/yes,  /no  or  /abstain",
			name = name,
			duration = 20,
			perc_needed = 0,

			can_vote = function(self, pname)
				return minetest.check_player_privs(pname,{vote_area = true})
			end,

			on_result = function(self, result, results)
				local yes = results.yes or {}
				if #yes >= votesneeded then
					local id = areas:add(name, param, pos1, pos2, nil)
					areas:save()
					minetest.chat_send_all(S("Area protected. ID: @1. (@2/@3)", id, #yes, votesneeded))
				else
					minetest.chat_send_all(S("Vote protect area '@1' failed. (@2/@3)", param, #yes, votesneeded))
				end
			end,

			on_vote = function(self, voter, value)
				minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
						self.description .. "'")
			end
		})
	end
})
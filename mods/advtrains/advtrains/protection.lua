-- advtrains
-- protection.lua: privileges and rail protection, and some helpers


-- Privileges to control TRAIN DRIVING/COUPLING
minetest.register_privilege("train_operator", {
	description = "Without this privilege, a player can't do anything about trains, neither place or remove them nor drive or couple them (but he can build tracks if he has track_builder)",
	give_to_singleplayer= true,
});

minetest.register_privilege("train_admin", {
	description = "Player may drive, place or remove any trains from/to anywhere, regardless of owner, whitelist or protection",
	give_to_singleplayer= true,
});

-- Privileges to control TRACK BUILDING
minetest.register_privilege("track_builder", {
	description = "Player can place and/or dig rails not protected from him. If he also has protection_bypass, he can place/dig any rails",
	give_to_singleplayer= true,
});

-- Privileges to control OPERATING TURNOUTS/SIGNALS
minetest.register_privilege("railway_operator", {
	description = "Player can operate turnouts and signals not protected from him. If he also has protection_bypass, he can operate any turnouts/signals",
	give_to_singleplayer= true,
});

-- there is a configuration option "allow_build_only_owner". If this is active, a player having track_builder can only build rails and operate signals/turnouts in an area explicitly belonging to him
-- (checked using a dummy player called "*dummy*" (which is not an allowed player name))


-- Protection ranges
local npr_r = tonumber(minetest.settings:get("advtrains_prot_range_side")) or 1
local npr_vr = tonumber(minetest.settings:get("advtrains_prot_range_up")) or 3
local npr_vrd = tonumber(minetest.settings:get("advtrains_prot_range_down")) or 1

local boo = minetest.settings:get_bool("advtrains_allow_build_to_owner")

--[[
Protection/privilege concept:
Tracks:
	Protected 1 node all around a rail and 4 nodes upward (maybe make this dynamically determined by the rail...)
	if track_builder privilege:
		if not protected from* player:
			if allow_build_only_owner:
				if unprotected:
					deny
			else:
				allow
	deny
Wagons in general:
	Players can only place/destroy wagons if they have train_operator
Wagon driving controls:
	The former seat_access tables are unnecessary, instead there is a whitelist for the driving stands
	on player trying to access a driver stand:
	if is owner or is on whitelist:
		allow
	else:
		deny
Wagon coupling:
	Derived from the privileges for driving stands. The whitelist is shared (and also settable on non-driverstand wagons)
	for each of the two bordering wagons:
		if is owner or is on whitelist:
			allow

*"protected from" means the player is not allowed to do things, while "protected by" means that the player is (one of) the owner(s) of this area

]]--

-- temporarily prevent scanning for neighboring rail nodes recursively
local nocheck

local old_is_protected = minetest.is_protected

-- Check if the node we are about to check is in the range of a track that is protected from a player
minetest.is_protected = function(pos, pname)
	
	-- old_is_protected:
	-- If an earlier callback decided that pos is protected, we wouldn't have been called
	-- if a later callback decides it, get that here.
	-- this effectively puts this function into a final-choice position
	local oprot = old_is_protected(pos, pname)
	if oprot then
		return true
	end
	
	if nocheck or pname=="" then
		return false
	end
	
	-- Special exception: to allow seamless rail connections between 2 separately protected
	-- networks, rails itself are not affected by the radius setting. So, if the node here is
	-- a rail, we skip the check and just use check_track_protection on same pos.
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "advtrains_track") > 0 then
		-- by here, we know that no other protection callback has this protected, we can safely pass "false".
		-- hope this doesn't lead to bugs!
		return not advtrains.check_track_protection(pos, pname, nil, false)
	end
	
	local nodes = minetest.find_nodes_in_area(
		{x = pos.x - npr_r, y = pos.y - npr_vr, z = pos.z - npr_r},
		{x = pos.x + npr_r, y = pos.y + npr_vrd, z = pos.z + npr_r},
		{"group:advtrains_track"})
	for _,npos in ipairs(nodes) do
		if not advtrains.check_track_protection(npos, pname, pos) then
			return true
		end
	end
	nocheck=false
	return false
end

-- Check whether the player is permitted to modify this track
-- Shall be called only for nodes that are or are about to become tracks.
-- The range check from is_track_near_protected is disabled here.
-- this splits in 1. track_builder privilege and 2. is_protected
-- also respects the allow_build_to_owner property.
--WARN: true means here that the action is allowed!
function advtrains.check_track_protection(pos, pname, near, prot_p)
	-- Parameter "near" is an optional position, the original node that the player
	-- was about to affect, while "pos" represents the checked rail node
	-- if "near" is not set, pos is the same node.
	local nears = near and "near " or ""
	local apos = near or pos
	
	-- note that having protection_bypass implicitly implies having track_builder, because else it would be possible to dig rails
	-- (only checked by is_protected, which is not respected) but not place them.
	-- We won't impose restrictions on protection_bypass owners.
	if minetest.check_player_privs(pname, {protection_bypass = true}) then
		return true
	end
	
	nocheck = true
	local priv = minetest.check_player_privs(pname, {track_builder = true})
	
	-- note: is_protected above already checks the is_protected value against the current player, so checking it again is useless.
	local prot = prot_p
	if prot==nil then
		 prot = advtrains.is_protected(pos, pname)
	end
	local dprot = minetest.is_protected(pos, "*dummy*")
	nocheck = false
	
	--atdebug("CTP: ",pos,pname,near,prot_p,"priv=",priv,"prot=",prot,"dprot=",dprot)
	
	if not priv and (not boo or prot or not dprot) then
		minetest.chat_send_player(pname, "You are not allowed to build "..nears.."tracks without track_builder privilege")
		minetest.log("action", pname.." tried to modify terrain "..nears.."track at "..minetest.pos_to_string(apos).." but is not permitted to (no privilege)")
		return false
	end
	if prot then
		minetest.chat_send_player(pname, "You are not allowed to build "..nears.."tracks at protected position!")
		minetest.record_protection_violation(pos, pname)
		minetest.log("action", pname.." tried to modify "..nears.."track at "..minetest.pos_to_string(apos).." but position is protected!")
		return false
	end
	return true
end

--WARN: true means here that the action is allowed!
function advtrains.check_driving_couple_protection(pname, owner, whitelist)
	if minetest.check_player_privs(pname, {train_admin = true}) then
		return true
	end
	if not minetest.check_player_privs(pname, {train_operator = true}) then
		return false
	end
	if not owner or owner == pname then
		return true
	end
	if whitelist and string.find(" "..whitelist.." ", " "..pname.." ", nil, true) then
		return true
	end
	return false
end
function advtrains.check_turnout_signal_protection(pos, pname)
	nocheck=true
	if not minetest.check_player_privs(pname, {railway_operator = true}) then
		if boo and not advtrains.is_protected(pos, pname) and minetest.is_protected(pos, "*dummy*") then
			nocheck=false
			return true
		else
			minetest.chat_send_player(pname, "You are not allowed to operate turnouts and signals (missing railway_operator privilege)")
			minetest.log("action", pname.." tried to operate turnout/signal at "..minetest.pos_to_string(pos).." but does not have railway_operator")
			nocheck=false
			return false
		end
	end
	if advtrains.is_protected(pos, pname) then
		minetest.record_protection_violation(pos, pname)
		nocheck=false
		return false
	end
	nocheck=false
	return true
end

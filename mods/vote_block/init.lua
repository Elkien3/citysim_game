-- Adds a voting machine

vote_block={user={},
}

vote_block.percent = function(n, t)
	return math.floor((((n/t)*100)*100)+0.5)/100
end

vote_block.receive_fields=function(player,fields)
	-- If unconfigured, and owner is submiting, then set as configured, and finalize
	-- If configured, check to see if votes are changeable, and if player has already voted.
	local pos=vote_block.user[player:get_player_name()]
	if not pos then return end -- I think this will work?
	local meta=minetest.get_meta(pos)
	
	if fields.save or fields.submit then
		-- SAVE DATA CODE GOES HERE ONCE I CAN FIGURE IT OUT
		meta:set_string("question", minetest.formspec_escape(fields.question))
		meta:set_string("option1", minetest.formspec_escape(fields.option1))
		meta:set_string("option2", minetest.formspec_escape(fields.option2))
		meta:set_string("option3", minetest.formspec_escape(fields.option3))
		meta:set_string("option4", minetest.formspec_escape(fields.option4))
		meta:set_string("option5", minetest.formspec_escape(fields.option5))
		if fields.submit then
			meta:set_int("ready", 1);
			meta:set_string("infotext", meta:get_string("question").." (owned by "..meta:get_string("owner")..")");
		end
	elseif fields.vote and fields.exitvote then
		if string.find(meta:get_string("log"), string.gsub(player:get_player_name()..", ", "%-", "%%%-")) then 
			return
		else
			if fields.vote==meta:get_string("option1") then meta:set_int("r1", meta:get_int("r1")+1) 
			elseif fields.vote==meta:get_string("option2") then meta:set_int("r2", meta:get_int("r2")+1) 
			elseif fields.vote==meta:get_string("option3") then meta:set_int("r3", meta:get_int("r3")+1) 
			elseif fields.vote==meta:get_string("option4") then meta:set_int("r4", meta:get_int("r4")+1) 
			elseif fields.vote==meta:get_string("option5") then meta:set_int("r5", meta:get_int("r5")+1) end
			meta:set_string("log", meta:get_string("log")..player:get_player_name()..", ")
		end
	end
	if fields.quit then
		vote_block.user[player:get_player_name()]=nil
	end
end



minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form=="vote_block.showform" and minetest.check_player_privs(player:get_player_name(),{vote = true}) then
		vote_block.receive_fields(player,pressed)
		print("Player "..player:get_player_name().." submitted fields "..dump(pressed))
	end
end)

-- Show form
vote_block.showform=function(pos,player)
	local meta=minetest.get_meta(pos)
	local gui=""
	local spos=pos.x .. "," .. pos.y .. "," .. pos.z
	local owner=meta:get_string("owner")==player:get_player_name()
	local ready=meta:get_int("ready")==1
	vote_block.user[player:get_player_name()]=pos
	--if minetest.check_player_privs(player:get_player_name(), {protection_bypass=true}) then owner=true end
	if owner and not ready then
		gui=""
		.."size[8,10] "
		.."field[question;Question;"..meta:get_string("question").."] "
		.."field[option1;option1;"..meta:get_string("option1").."] "
		.."field[option2;option2;"..meta:get_string("option2").."] "
		.."field[option3;option3;"..meta:get_string("option3").."] "
		.."field[option4;option4;"..meta:get_string("option4").."] "
		.."field[option5;option5;"..meta:get_string("option5").."] "
		.."button_exit[2.9,9;2,1;save;Save] "
		.."button_exit[4.9,9;2,1;submit;Submit]"
	elseif string.find(meta:get_string("log"), string.gsub(player:get_player_name()..", ", "%-", "%%%-")) then
		local total = meta:get_int("r1")+meta:get_int("r2")+meta:get_int("r3")+meta:get_int("r4")+meta:get_int("r5")
		gui=""
		.."size[8,3]"
		.."label[0,0.2;"..meta:get_string("question").."]"
		local p = 1
		for i = 1, 5, 1 do
			if not (meta:get_string("option"..i) == "") then gui=gui.."label[0,"..(0.5*p+.2)..";"..meta:get_string("option"..i).." ("..meta:get_int("r"..i).." votes, "..vote_block.percent(meta:get_int("r"..i),total).."%)]" p=p+1 end
		end
		gui=gui.."button_exit[5.6,2;2,1;exit;Close]"
	elseif ready then
		gui=""
		.."size[8,3]"
		.."label[0,0.2;"..meta:get_string("question").."]"
		.."dropdown[0,1;8, 0.8;vote;"
		for i = 1, 5, 1 do
			if not (meta:get_string("option"..i) == "") then gui=gui..meta:get_string("option"..i)..","  end
		end
		gui = gui:sub(1, -2) -- Remove last comma
		gui=gui..";0]button_exit[5.6,2;2,1;exitvote;Vote]"
	else
		gui=""
		.."size[8,3]"
		.."label[0,0.2;This voting machine is not ready yet.]"
	end
	minetest.after((0.1), function(gui)
		return minetest.show_formspec(player:get_player_name(), "vote_block.showform",gui)
	end, gui)
end

-- Node
minetest.register_node("vote_block:poll", {
	description = "Vote Box",
	tiles = {"vote_front_a.png"},
	wield_image = "vote_wi.png",
	inventory_image = "vote_wi.png",
	groups = {choppy = 2, oddly_breakable_by_hand = 1,},
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.375,-0.3125,0.4375,0.375,0.25,0.5}},
	paramtype2="facedir",
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 10,
after_place_node = function(pos, placer)
	local meta = minetest.get_meta(pos)
	meta:set_string("owner",          placer:get_player_name() );
	meta:set_string("infotext",       "Unconfigured Vote Box. (owned by "..placer:get_player_name()..")");
	meta:set_string("question",   "Type your question here.");
	meta:set_int("ready",   0);
	meta:set_int("r1",   0);
	meta:set_int("r2",   0);
	meta:set_int("r3",   0);
	meta:set_int("r4",   0);
	meta:set_int("r5",   0);
	meta:set_string("option1",   "O 1");
	meta:set_string("option2",   "O 2");
	meta:set_string("option3",   "O 3");
	meta:set_string("option4",   "O 4");
	meta:set_string("option5",   "O 5");
	meta:set_string("log",   "");
	end,
on_construct = function(pos)
		local meta=minetest.get_meta(pos)
	end,
on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.check_player_privs(player:get_player_name(),{vote = true}) then
			vote_block.showform(pos,player)
		else
			minetest.chat_send_player(player:get_player_name(), "Must have the vote priv to vote.")
		end
	end,
can_dig = function(pos, player)
		local meta=minetest.get_meta(pos)
		local inv=meta:get_inventory()
		if meta:get_string("owner")==player:get_player_name() or minetest.check_player_privs(player:get_player_name(), {protection_bypass=true}) then
			return true
		end
	end,
})

-- Craft
minetest.register_craft({
	output = "vote_block:poll",
	recipe = {
		{"default:chest_locked", "default:paper", "default:chest_locked"},
		{"default:sign_wall_wood", "default:paper", "default:sign_wall_wood"},
		{"default:sign_wall_wood", "default:paper", "default:sign_wall_wood"},
	}
})

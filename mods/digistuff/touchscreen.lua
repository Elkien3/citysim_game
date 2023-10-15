digistuff.update_ts_formspec = function (pos)
	local meta = minetest.get_meta(pos)
	local fs = "size[10,8]"..
		"background[0,0;0,0;digistuff_ts_bg.png;true]"
	if meta:get_int("realcoordinates") > 0 then
		fs = fs.."real_coordinates[true]"
	end
	if meta:get_int("init") == 0 then
		fs = fs.."field[3.75,3;3,1;channel;Channel;]"..
		"button_exit[4,3.75;2,1;save;Save]"
	elseif minetest.get_node(pos).name == "digistuff:advtouchscreen" then
		fs = fs.."label[0,0;No data received yet]"
	else
		local data = minetest.deserialize(meta:get_string("data")) or {}
		for _,field in pairs(data) do
			if field.type == "image" then
				fs = fs..string.format("image[%s,%s;%s,%s;%s]",field.X,field.Y,field.W,field.H,field.texture_name)
			elseif field.type == "field" then
				fs = fs..string.format("field[%s,%s;%s,%s;%s;%s;%s]",field.X,field.Y,field.W,field.H,field.name,field.label,field.default)
			elseif field.type == "pwdfield" then
				fs = fs..string.format("pwdfield[%s,%s;%s,%s;%s;%s]",field.X,field.Y,field.W,field.H,field.name,field.label)
			elseif field.type == "textarea" then
				fs = fs..string.format("textarea[%s,%s;%s,%s;%s;%s;%s]",field.X,field.Y,field.W,field.H,field.name,field.label,field.default)
			elseif field.type == "label" then
				fs = fs..string.format("label[%s,%s;%s]",field.X,field.Y,field.label)
			elseif field.type == "vertlabel" then
				fs = fs..string.format("vertlabel[%s,%s;%s]",field.X,field.Y,field.label)
			elseif field.type == "button" then
				fs = fs..string.format("button[%s,%s;%s,%s;%s;%s]",field.X,field.Y,field.W,field.H,field.name,field.label)
			elseif field.type == "button_exit" then
				fs = fs..string.format("button_exit[%s,%s;%s,%s;%s;%s]",field.X,field.Y,field.W,field.H,field.name,field.label)
			elseif field.type == "image_button" then
				fs = fs..string.format("image_button[%s,%s;%s,%s;%s;%s;%s]",field.X,field.Y,field.W,field.H,field.image,field.name,field.label)
			elseif field.type == "image_button_exit" then
				fs = fs..string.format("image_button_exit[%s,%s;%s,%s;%s;%s;%s]",field.X,field.Y,field.W,field.H,field.image,field.name,field.label)
			elseif field.type == "dropdown" then
				local choices = ""
				for _,i in ipairs(field.choices) do
					if type(i) == "string" then
						choices = choices..minetest.formspec_escape(i)..","
					end
				end
				choices = string.sub(choices,1,-2)
				fs = fs..string.format("dropdown[%s,%s;%s,%s;%s;%s;%s]",field.X,field.Y,field.W,field.H,field.name,choices,field.selected_id)
			elseif field.type == "textlist" then
				local listelements = ""
				for _,i in ipairs(field.listelements) do
					if type(i) == "string" then
						listelements = listelements..minetest.formspec_escape(i)..","
					end
				end
				listelements = string.sub(listelements,1,-2)
				fs = fs..string.format("textlist[%s,%s;%s,%s;%s;%s;%s;%s]",field.X,field.Y,field.W,field.H,field.name,listelements,field.selected_id,field.transparent)
			end
		end
	end
	meta:set_string("formspec",fs)
end

digistuff.ts_on_receive_fields = function (pos, formname, fields, sender)
	local meta = minetest.get_meta(pos)
	local setchan = meta:get_string("channel")
	local playername = sender:get_player_name()
	local locked = meta:get_int("locked") == 1
	local can_bypass = minetest.check_player_privs(playername,{protection_bypass=true})
	local is_protected = minetest.is_protected(pos,playername)
	if (locked and is_protected) and not can_bypass then
		minetest.record_protection_violation(pos,playername)
		minetest.chat_send_player(playername,"You are not authorized to use this screen.")
		return
	end
	local init = meta:get_int("init") == 1
	if not init then
		if fields.save then
			meta:set_string("channel",fields.channel)
			meta:set_int("init",1)
			digistuff.update_ts_formspec(pos)
		end
	else
		fields.clicker = sender:get_player_name()
		digiline:receptor_send(pos, digiline.rules.default, setchan, fields)
	end
end

digistuff.process_command = function (meta, data, msg)
	if msg.command == "clear" then
		data = {}
	elseif msg.command == "realcoordinates" then
		meta:set_int("realcoordinates",msg.enabled and 1 or 0)
	elseif msg.command == "addimage" then
		for _,i in pairs({"X","Y","W","H"}) do
			if not msg[i] or type(msg[i]) ~= "number" then
				return
			end
		end
		if not msg.texture_name or type(msg.texture_name) ~= "string" then
			return	
		end
		local field = {type="image",X=msg.X,Y=msg.Y,W=msg.W,H=msg.H,texture_name=minetest.formspec_escape(msg.texture_name)}
		table.insert(data,field)
	elseif msg.command == "addfield" then
		for _,i in pairs({"X","Y","W","H"}) do
			if not msg[i] or type(msg[i]) ~= "number" then
				return
			end
		end
		for _,i in pairs({"name","label","default"}) do
			if not msg[i] or type(msg[i]) ~= "string" then
				return
			end
		end
		local field = {type="field",X=msg.X,Y=msg.Y,W=msg.W,H=msg.H,name=minetest.formspec_escape(msg.name),label=minetest.formspec_escape(msg.label),default=minetest.formspec_escape(msg.default)}
		table.insert(data,field)
	elseif msg.command == "addpwdfield" then
		for _,i in pairs({"X","Y","W","H"}) do
			if not msg[i] or type(msg[i]) ~= "number" then
				return
			end
		end
		for _,i in pairs({"name","label"}) do
			if not msg[i] or type(msg[i]) ~= "string" then
				return
			end
		end
		local field = {type="pwdfield",X=msg.X,Y=msg.Y,W=msg.W,H=msg.H,name=minetest.formspec_escape(msg.name),label=minetest.formspec_escape(msg.label)}
		table.insert(data,field)
	elseif msg.command == "addtextarea" then
		for _,i in pairs({"X","Y","W","H"}) do
			if not msg[i] or type(msg[i]) ~= "number" then
				return
			end
		end
		for _,i in pairs({"name","label","default"}) do
			if not msg[i] or type(msg[i]) ~= "string" then
				return
			end
		end
		local field = {type="textarea",X=msg.X,Y=msg.Y,W=msg.W,H=msg.H,name=minetest.formspec_escape(msg.name),label=minetest.formspec_escape(msg.label),default=minetest.formspec_escape(msg.default)}
		table.insert(data,field)
	elseif msg.command == "addlabel" then
		for _,i in pairs({"X","Y"}) do
			if not msg[i] or type(msg[i]) ~= "number" then
				return
			end
		end
		if not msg.label or type(msg.label) ~= "string" then
			return	
		end
		local field = {type="label",X=msg.X,Y=msg.Y,label=minetest.formspec_escape(msg.label)}
		table.insert(data,field)
	elseif msg.command == "addvertlabel" then
		for _,i in pairs({"X","Y"}) do
			if not msg[i] or type(msg[i]) ~= "number" then
				return
			end
		end
		if not msg.label or type(msg.label) ~= "string" then
			return	
		end
		local field = {type="vertlabel",X=msg.X,Y=msg.Y,label=minetest.formspec_escape(msg.label)}
		table.insert(data,field)
	elseif msg.command == "addbutton" then
		for _,i in pairs({"X","Y","W","H"}) do
			if not msg[i] or type(msg[i]) ~= "number" then
				return
			end
		end
		for _,i in pairs({"name","label"}) do
			if not msg[i] or type(msg[i]) ~= "string" then
				return
			end
		end
		local field = {type="button",X=msg.X,Y=msg.Y,W=msg.W,H=msg.H,name=minetest.formspec_escape(msg.name),label=minetest.formspec_escape(msg.label)}
		table.insert(data,field)
	elseif msg.command == "addbutton_exit" then
		for _,i in pairs({"X","Y","W","H"}) do
			if not msg[i] or type(msg[i]) ~= "number" then
				return
			end
		end
		for _,i in pairs({"name","label"}) do
			if not msg[i] or type(msg[i]) ~= "string" then
				return
			end
		end
		local field = {type="button_exit",X=msg.X,Y=msg.Y,W=msg.W,H=msg.H,name=minetest.formspec_escape(msg.name),label=minetest.formspec_escape(msg.label)}
		table.insert(data,field)
	elseif msg.command == "addimage_button" then
		for _,i in pairs({"X","Y","W","H"}) do
			if not msg[i] or type(msg[i]) ~= "number" then
				return
			end
		end
		for _,i in pairs({"image","name","label"}) do
			if not msg[i] or type(msg[i]) ~= "string" then
				return
			end
		end
		local field = {type="image_button",X=msg.X,Y=msg.Y,W=msg.W,H=msg.H,image=minetest.formspec_escape(msg.image),name=minetest.formspec_escape(msg.name),label=minetest.formspec_escape(msg.label)}
		table.insert(data,field)
	elseif msg.command == "addimage_button_exit" then
		for _,i in pairs({"X","Y","W","H"}) do
			if not msg[i] or type(msg[i]) ~= "number" then
				return
			end
		end
		for _,i in pairs({"image","name","label"}) do
			if not msg[i] or type(msg[i]) ~= "string" then
				return
			end
		end
		local field = {type="image_button_exit",X=msg.X,Y=msg.Y,W=msg.W,H=msg.H,image=minetest.formspec_escape(msg.image),name=minetest.formspec_escape(msg.name),label=minetest.formspec_escape(msg.label)}
		table.insert(data,field)
	elseif msg.command == "adddropdown" then
		for _,i in pairs({"X","Y","W","H","selected_id"}) do
			if not msg[i] or type(msg[i]) ~= "number" then
				return
			end
		end
		if not msg.name or type(msg.name) ~= "string" then
			return
		end
		if not msg.choices or type(msg.choices) ~= "table" or #msg.choices < 1 then
			return
		end
		local field = {type="dropdown",X=msg.X,Y=msg.Y,W=msg.W,H=msg.H,name=minetest.formspec_escape(msg.name),selected_id=msg.selected_id,choices=msg.choices}
		table.insert(data,field)
	elseif msg.command == "addtextlist" then
		for _,i in pairs({"X","Y","W","H","selected_id"}) do
			if not msg[i] or type(msg[i]) ~= "number" then
				return
			end
		end
		if not msg.name or type(msg.name) ~= "string" then
			return
		end
		if not msg.listelements or type(msg.listelements) ~= "table" or #msg.listelements < 1 then
			return
		end
		if not msg.transparent or type(msg.transparent) ~= "boolean" then
			msg.transparent = false
		end
		local field = {type="textlist",X=msg.X,Y=msg.Y,W=msg.W,H=msg.H,name=minetest.formspec_escape(msg.name),selected_id=msg.selected_id,listelements=msg.listelements,transparent=msg.transparent}
		table.insert(data,field)
	elseif msg.command == "lock" then
		meta:set_int("locked",1)
	elseif msg.command == "unlock" then
		meta:set_int("locked",0)
	end
	return data
end

digistuff.ts_on_digiline_receive = function (pos, node, channel, msg)
	local meta = minetest.get_meta(pos)
	local setchan = meta:get_string("channel")
	if channel ~= setchan then return end
	if node.name == "digistuff:advtouchscreen" then
		if type(msg) == "string" then meta:set_string("formspec",msg) end
	else
		if type(msg) ~= "table" then return end
		local data = minetest.deserialize(meta:get_string("data")) or {}
		if msg.command then
			data = digistuff.process_command(meta,data,msg)
		else
			for _,i in ipairs(msg) do
				if type(i) == "table" and i.command then
					data = digistuff.process_command(meta,data,i) or data
				end
			end
		end
		meta:set_string("data",minetest.serialize(data))
		digistuff.update_ts_formspec(pos)
	end
end

minetest.register_node("digistuff:touchscreen", {
	description = "Digilines Touchscreen",
	groups = {cracky=3},
	on_construct = function(pos)
		digistuff.update_ts_formspec(pos,true)
	end,
	drawtype = "nodebox",
	tiles = {
		"digistuff_panel_back.png",
		"digistuff_panel_back.png",
		"digistuff_panel_back.png",
		"digistuff_panel_back.png",
		"digistuff_panel_back.png",
		"digistuff_ts_front.png"
		},
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, 0.4, 0.5, 0.5, 0.5 }
		}
    	},
    	_digistuff_channelcopier_fieldname = "channel",
	_digistuff_channelcopier_onset = function(pos)
		minetest.get_meta(pos):set_int("init",1)
		digistuff.update_ts_formspec(pos)
	end,
	on_receive_fields = digistuff.ts_on_receive_fields,
	digiline = 
	{
		receptor = {},
		effector = {
			action = digistuff.ts_on_digiline_receive
		},
	},
})

minetest.register_node("digistuff:advtouchscreen", {
	description = "Advanced Digilines Touchscreen",
	groups = {cracky=3},
	on_construct = function(pos)
		digistuff.update_ts_formspec(pos,true)
	end,
	drawtype = "nodebox",
	tiles = {
		"digistuff_panel_back.png",
		"digistuff_panel_back.png",
		"digistuff_panel_back.png",
		"digistuff_panel_back.png",
		"digistuff_panel_back.png",
		"digistuff_advts_front.png"
		},
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, 0.4, 0.5, 0.5, 0.5 }
		}
    	},
    	_digistuff_channelcopier_fieldname = "channel",
	_digistuff_channelcopier_onset = function(pos)
		minetest.get_meta(pos):set_int("init",1)
		digistuff.update_ts_formspec(pos)
	end,
	on_receive_fields = digistuff.ts_on_receive_fields,
	digiline = 
	{
		receptor = {},
		effector = {
			action = digistuff.ts_on_digiline_receive
		},
	},
})

minetest.register_craft({
	output = "digistuff:touchscreen",
	recipe = {
		{"mesecons_luacontroller:luacontroller0000","default:glass","default:glass"},
		{"default:glass","digilines:lcd","default:glass"},
		{"default:glass","default:glass","default:glass"}
	}
})

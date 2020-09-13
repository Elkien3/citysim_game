--pcnaming.lua
--a.k.a Passive component naming
--Allows to assign names to passive components, so they can be called like:
--setstate("iamasignal", "green")
atlatc.pcnaming={name_map={}}
function atlatc.pcnaming.load(stuff)
	if type(stuff)=="table" then
		atlatc.pcnaming.name_map=stuff
	end
end
function atlatc.pcnaming.save()
	return atlatc.pcnaming.name_map
end

function atlatc.pcnaming.resolve_pos(pos, func_name)
	if type(pos)=="string" then
		local e = atlatc.pcnaming.name_map[pos]
		if e then return e end
	elseif type(pos)=="table" and pos.x and pos.y and pos.z then
		return pos
	end
	error("Invalid position supplied to " .. (func_name or "???")..": " .. dump(pos))
end

minetest.register_craftitem("advtrains_luaautomation:pcnaming",{
	description = attrans("Passive Component Naming Tool\n\nRight-click to name a passive component."),
	groups = {cracky=1}, -- key=name, value=rating; rating=1..3.
	inventory_image = "atlatc_pcnaming.png",
	wield_image = "atlatc_pcnaming.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		local pname = placer:get_player_name()
		if not pname then
			return
		end
		if not minetest.check_player_privs(pname, {atlatc=true}) then
			minetest.chat_send_player(pname, "Missing privilege: atlatc")
			return
		end
		if pointed_thing.type=="node" then
			local pos=pointed_thing.under
			if advtrains.is_protected(pos, pname) then
				minetest.record_protection_violation(pos, pname)
				return
			end
			local node = advtrains.ndb.get_node(pos)
			if node.name and (minetest.get_item_group(node.name, "advtrains_signal")>0 or advtrains.is_passive(pos)) then
				--look if this one already has a name
				local pn=""
				for name, npos in pairs(atlatc.pcnaming.name_map) do
					if vector.equals(npos, pos) then
						pn=name
					end
				end
				minetest.show_formspec(pname, "atlatc_naming_"..minetest.pos_to_string(pos), "field[pn;Set name of component (empty to clear);"..minetest.formspec_escape(pn).."]")
			end
		end
	end,
})
minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pts=string.match(formname, "^atlatc_naming_(.+)")
	if pts then
		local pos=minetest.string_to_pos(pts)
		if fields.pn then
			--first remove all occurences
			for name, npos in pairs(atlatc.pcnaming.name_map) do
				if vector.equals(npos, pos) then
					atlatc.pcnaming.name_map[name]=nil
				end
			end
			if fields.pn~="" then
				atlatc.pcnaming.name_map[fields.pn]=pos
			end
		end
	end
end)

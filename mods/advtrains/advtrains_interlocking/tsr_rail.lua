-- tsr_rail.lua
-- Point speed restriction rails
-- Simple rail whose only purpose is to place a TSR on the position, as a temporary solution until the timetable system covers everything.
-- This code resembles the code in lines/stoprail.lua

local function updateform(pos)
	local meta = minetest.get_meta(pos)
	local pe = advtrains.encode_pos(pos)
	local npr = advtrains.interlocking.npr_rails[pe] or 2
	
	meta:set_string("infotext", "Point speed restriction: "..npr)
	meta:set_string("formspec", "field[npr;Set point speed restriction:;"..npr.."]")
end


local adefunc = function(def, preset, suffix, rotation)
		return {
			after_place_node=function(pos)
				updateform(pos)
			end,
			after_dig_node=function(pos)
				local pe = advtrains.encode_pos(pos)
				advtrains.interlocking.npr_rails[pe] = nil
			end,
			on_receive_fields = function(pos, formname, fields, player)
				if fields.npr then
					local pe = advtrains.encode_pos(pos)
					advtrains.interlocking.npr_rails[pe] = tonumber(fields.npr)
					updateform(pos)
				end
			end,
			advtrains = {
				on_train_approach = function(pos,train_id, train, index)
					if train.path_cn[index] == 1 then
						local pe = advtrains.encode_pos(pos)
						local npr = advtrains.interlocking.npr_rails[pe] or 2
						advtrains.lzb_add_checkpoint(train, index, npr, nil)
					end
				end,
			},
		}
end


if minetest.get_modpath("advtrains_train_track") ~= nil then
	advtrains.register_tracks("default", {
		nodename_prefix="advtrains_interlocking:dtrack_npr",
		texture_prefix="advtrains_dtrack_npr",
		models_prefix="advtrains_dtrack",
		models_suffix=".b3d",
		shared_texture="advtrains_dtrack_shared_npr.png",
		description="Point Speed Restriction Rail",
		formats={},
		get_additional_definiton = adefunc,
	}, advtrains.trackpresets.t_30deg_straightonly)
end
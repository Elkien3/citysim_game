-- Interlocking counterpart of LZB, which has been moved into the core...
-- Registers LZB callback for signal management.

--[[
usage of lzbdata:
{
	travsht = boolean indicating whether the train will be a shunt move at "trav"
	travspd = speed restriction at end of traverser
	travwspd = warning speed res.t
}
]]

local SHUNT_SPEED_MAX = advtrains.SHUNT_SPEED_MAX

local il = advtrains.interlocking

local function get_over_function(speed, shunt)
	return function(pos, id, train, index, speed, lzbdata)
		if speed == 0 and minetest.settings:get_bool("at_il_force_lzb_halt") then
			atwarn(id,"overrun LZB 0 restriction (red signal) ",pos)
			-- Set train 1 index backward. Hope this does not lead to bugs...
			train.index = index - 0.5
			train.velocity = 0
			train.ctrl.lzb = 0
			minetest.after(0, advtrains.invalidate_path, id)
		else
			train.speed_restriction = speed
			train.is_shunt = shunt
		end
	end
end

advtrains.tnc_register_on_approach(function(pos, id, train, index, lzbdata)

	--atdebug(id,"IL ApprC",pos,index,lzbdata)
	--train.debug = advtrains.print_concat_table({train.is_shunt,"|",index,"|",lzbdata})

	local pts = advtrains.roundfloorpts(pos)
	local cn  = train.path_cn[index]
	local travsht = lzbdata.travsht
	
	if travsht==nil then
		travsht = train.is_shunt
	end
	
	local travspd = lzbdata.travspd
	local travwspd = lzbdata.travwspd
	
	-- check for signal
	local asp, spos = il.db.get_ip_signal_asp(pts, cn)
	
	-- do ARS if needed
	if spos then
		--atdebug(id,"IL Spos (ARS)",spos,asp)
		local sigd = il.db.get_sigd_for_signal(spos)
		if sigd then
			il.ars_check(sigd, train)
		end
	end
	--atdebug("trav: ",pos, cn, asp, spos, "travsht=", lzb.travsht)
	local lspd
	if asp then
		--atdebug(id,"IL Signal",spos,asp)
		local nspd = 0
		--interpreting aspect and determining speed to proceed
		if travsht then
			--shunt move
			if asp.shunt.free then
				nspd = SHUNT_SPEED_MAX
			elseif asp.shunt.proceed_as_main and asp.main.free then
				nspd = asp.main.speed
				travsht = false
			end
		else
			--train move
			if asp.main.free then
				nspd = asp.main.speed
			elseif asp.shunt.free then
				nspd = SHUNT_SPEED_MAX
				travsht = true
			end
		end
		-- nspd can now be: 1. !=0: new speed restriction, 2. =0: stop here or 3. nil: keep travspd
		if nspd then
			if nspd == -1 then
				travspd = nil
			else
				travspd = nspd
			end
		end
		
		local nwspd = asp.info.w_speed
		if nwspd then
			if nwspd == -1 then
				travwspd = nil
			else
				travwspd = nwspd
			end
		end
		--atdebug("ns,wns,ts,wts", nspd, nwspd, travspd, travwspd)
		lspd = travspd
		if travwspd and (not lspd or lspd>travwspd) then
			lspd = travwspd
		end
		
		local udata = {signal_pos = spos}
		local callback = get_over_function(lspd, travsht)
		advtrains.lzb_add_checkpoint(train, index, lspd, callback, udata)
	end
	lzbdata.travsht = travsht
	lzbdata.travspd = travspd
	lzbdata.travwspd = travwspd
end)

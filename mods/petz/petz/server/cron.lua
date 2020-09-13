local modname = ...

--Server Cron Calls
if petz.settings.clear_mobs_time > 0 then
	mokapi.cron_clear(petz.settings.clear_mobs_time, modname)
end

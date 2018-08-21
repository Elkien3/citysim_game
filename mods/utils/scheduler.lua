--[[
Copyright (c) 2014, Robert 'Bobby' Zenz
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]


--- The Scheduler allows you to easily schedule functions for execution. Under
-- the hood it used minetest.register_on_globalstep to schedule functions.
scheduler = {
	--- If more time has elapsed than the interval of the scheduled function,
	-- the function will be run as many times as necessary to catch up.
	OVERSHOOT_POLICY_CATCH_UP = 1,
	
	--- If more time has elpased than the interval of the scheduled function,
	-- the function will still only be run once.
	OVERSHOOT_POLICY_RUN_ONCE = 2,
	
	--- The table of functions for immediate execution.
	immediate_functions = {},
	
	--- If the scheduler has been initialized.
	initialized = false,
	
	-- The table of scheduled functions.
	scheduled_functions = {}
}


--- Initializes the scheduler.
--
-- Note that the client should never need to call this function.
function scheduler.init()
	if not scheduler.initialized then
		minetest.register_globalstep(scheduler.step)
	end
end

--- Schedules the given function.
--
-- @param name The name of the function.
-- @param interval The interval in which to run the function. A value of zero
--                 will make the function run on every global step,
--                 the overshoot policy will have no effect in that case.
-- @param run_function The function to execute.
-- @param overshoot_policy Optional. The overshoot policy. Defaults to
--                         scheduler.OVERSHOOT_POLICY_RUN_ONCE.
function scheduler.schedule(name, interval, run_function, overshoot_policy)
	scheduler.scheduled_functions[name] = {
		interval = interval,
		overshoot_policy = overshoot_policy or scheduler.OVERSHOOT_POLICY_RUN_ONCE,
		run_function = run_function,
		timer = 0
	}
	
	if not scheduler.initialized then
		scheduler.init()
	end
end

--- The step function that is registered with minetest.register_on_globalstep.
--
-- Note that the client should never call this function as it might mess up
-- the scheduled functions.
--
-- @param since_last_call The elapsed time since the last call.
function scheduler.step(since_last_call)
	for name, scheduled in pairs(scheduler.scheduled_functions) do
		if scheduled.interval > 0 then
			scheduled.timer = scheduled.timer + since_last_call
			
			if scheduled.timer >= scheduled.interval then
				scheduled.run_function()
				
				local additional_runs = math.floor(scheduled.timer / scheduled.interval) - 1
				
				if scheduled.overshoot_policy == scheduler.OVERSHOOT_POLICY_CATCH_UP then
					for counter = 1, additional_runs, 1 do
						scheduled.run_function()
					end
				end
				
				scheduled.timer = 0
			end
		else
			scheduled.run_function()
		end
	end
end

--- Unschedules/Removes the function with the given name.
--
-- @param name The name of the function to unschedule.
function scheduler.unschedule(name)
	scheduler.scheduled_functions[name] = nil
end


local min_lag = 1 -- in seconds
local min_times = 10 -- has to occur 10x
local times = 0
minetest.register_globalstep(function(lag)
    if lag < min_lag then
        times = 0
    else
        times = times + 1
        if times >= min_times then
            minetest.request_shutdown("Server shutting down due to high latency (lag).")
        end
    end
end)

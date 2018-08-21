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


-- Get the base path.
local base_path = minetest.get_modpath(minetest.get_current_modname())

-- Instance utils
dofile(base_path .. "/arraymanipulator.lua")
dofile(base_path .. "/blockedcache.lua")
dofile(base_path .. "/color.lua")
dofile(base_path .. "/directmapmanipulator.lua")
dofile(base_path .. "/list.lua")
dofile(base_path .. "/mapmanipulator.lua")
dofile(base_path .. "/noisemanager.lua")

-- Static utils
dofile(base_path .. "/arrayutil.lua")
dofile(base_path .. "/blockutil.lua")
dofile(base_path .. "/constants.lua")
dofile(base_path .. "/entityutil.lua")
dofile(base_path .. "/facedirutil.lua")
dofile(base_path .. "/fisheryates.lua")
dofile(base_path .. "/interpolate.lua")
dofile(base_path .. "/inventoryutil.lua")
dofile(base_path .. "/itemutil.lua")
dofile(base_path .. "/log.lua")
dofile(base_path .. "/mathutil.lua")
dofile(base_path .. "/minetestex.lua")
dofile(base_path .. "/numberutil.lua")
dofile(base_path .. "/nodeutil.lua")
dofile(base_path .. "/objectrefutil.lua")
dofile(base_path .. "/pathutil.lua")
dofile(base_path .. "/posutil.lua")
dofile(base_path .. "/random.lua")
dofile(base_path .. "/rotationutil.lua")
dofile(base_path .. "/scheduler.lua")
dofile(base_path .. "/settings.lua")
dofile(base_path .. "/stopwatch.lua")
dofile(base_path .. "/stringutil.lua")
dofile(base_path .. "/tableutil.lua")
dofile(base_path .. "/tango.lua")
dofile(base_path .. "/textureutil.lua")
dofile(base_path .. "/transform.lua")
dofile(base_path .. "/wallmountedutil.lua")


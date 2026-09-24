--[[
    Object UUIDs — Assigns a persistent UUID to every object in Minetest.
    Copyright © 2023, Silver Sandstone <@SilverSandstone@craftodon.social>

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
]]


--- Object UUIDs.
-- @module init


--- The API table.
objectuuids = {};

--- The namespace for player UUIDs.
objectuuids.USERNAME_UUID_NAMESPACE = 'be6fc4b5-a602-449c-af05-55755c8c518b';

--- Low-level mapping from objects to UUIDs. Note that object references in this table may be invalid.
objectuuids.object_uuids = setmetatable({}, {__mode = 'k'});

--- Low-level mapping from UUIDs to objects. Note that object references in this table may be invalid.
objectuuids.objects_by_uuid = setmetatable({}, {__mode = 'v'});


local modpath = minetest.get_modpath(minetest.get_current_modname());
dofile(modpath .. '/util.lua');
dofile(modpath .. '/patches.lua');
dofile(modpath .. '/internal.lua');
dofile(modpath .. '/api.lua');

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


--- Generic utility functions.
-- @module util


objectuuids.util = {};


objectuuids.util.UUID_REGEX = ('^%s*[{]?(xxxxxxxx)[-]?(xxxx)[-]?(xxxx)[-]?(xxxx)[-]?(xxxxxxxxxxxx)[}]?%s*$'):gsub('x', '[0-9A-Fa-f]');


local function noop()
end;


--- Applies a patch to an entity definition.
-- @param def     [table] The entity definition table. Modified in-place.
-- @param patches [table] A table of functions. Each function receives the original function as its first argument.
function objectuuids.util.patch_entity_def(def, patches)
    for key, patch in pairs(patches) do
        local old_func = def[key] or noop;
        def[key] = function(...)
            return patch(old_func, ...);
        end;
    end;
end;


--- Canonicalises and validates a UUID.
-- @param uuid [string] A UUID, in lenient form.
-- @return     [string] The same UUID, in strict form.
function objectuuids.util.canonicalise_uuid(uuid)
    local aaaaaaaa, bbbb, cccc, dddd, eeeeeeeeeeee = string.match(uuid, objectuuids.util.UUID_REGEX);
    if not aaaaaaaa then
        error(('Invalid UUID: %q.'):format(uuid));
    end;
    return ('%s-%s-%s-%s-%s'):format(aaaaaaaa, bbbb, cccc, dddd, eeeeeeeeeeee):lower();
end;


--- Returns a random number between 0 and upper (inclusive) using a high-quality random number generator.
-- @param upper [integer] The upper bound. Preferably a Mersenne number.
-- @return      [integer] An integer in (0..upper).
local secure_rng = SecureRandom();
function objectuuids.util.secure_random(upper)
    local range = 1;
    local value = 0;
    while range <= upper do
        value = value * 256 + secure_rng:next_bytes(1):byte();
        range = range * 256;
    end;
    return value % (upper + 1);
end;


--- Generates a version 4 (random) UUID.
-- @param random [function|nil] Overrides the random number generator.
-- @return       [string]       A UUID.
function objectuuids.util.generate_uuid4(random)
    if not random then
        random = objectuuids.util.secure_random;
    end;
    local time_low  = random(0xFFFFFFFF);
    local time_mid  = random(0xFFFF);
    local time_high = random(0x0FFF) + 0x4000;
    local clock_seq = random(0x3FFF) + 0x8000;
    local node_id   = random(0xFFFFFFFFFFFF);
    return ('%08x-%04x-%04x-%04x-%012x'):format(time_low, time_mid, time_high, clock_seq, node_id);
end;


--- Generates a version 5 (SHA-1) UUID.
-- @param namespace [string] The namespace UUID.
-- @param name      [string] The string to hash.
-- @return          [string] A UUID.
function objectuuids.util.generate_uuid5(namespace, name)
    local ns_bytes = objectuuids.util.uuid_to_bytes(namespace);
    local hash = minetest.sha1(ns_bytes .. name);
    local aaaaaaaa, bbbb, cccc, dddd, eeeeeeeeeeee = hash:sub(1, 32):match(objectuuids.util.UUID_REGEX);
    cccc = '5' .. cccc:sub(2);
    dddd = ('%04x'):format(0x8000 + tonumber(dddd, '16') % 0x4000);
    return ('%s-%s-%s-%s-%s'):format(aaaaaaaa, bbbb, cccc, dddd, eeeeeeeeeeee);
end;


--- Converts a UUID to a packed binary representation.
-- @param uuid [string] A UUID.
-- @return     [string] The same UUID in binary form.
function objectuuids.util.uuid_to_bytes(uuid)
    local bytes = {};
    for hex in uuid:gmatch('[0-9A-Fa-f][0-9A-Fa-f]') do
        bytes[#bytes + 1] = tonumber(hex, 16);
    end;
    return string.char((table.unpack or unpack)(bytes));
end;

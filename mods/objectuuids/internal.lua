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


--- Internal functions.
-- @module internal


local WS_PREFIX = ' \t';
local WS_SUFFIX = '\t ';

local DASH_POSITIONS = {[8] = true, [12] = true, [16] = true, [20] = true};

local HEX_TO_WS_MAPPING =
{
    ['0'] = '    ';
    ['1'] = '   \t';
    ['2'] = '  \t ';
    ['3'] = '  \t\t';
    ['4'] = ' \t  ';
    ['5'] = ' \t \t';
    ['6'] = ' \t\t ';
    ['7'] = ' \t\t\t';
    ['8'] = '\t   ';
    ['9'] = '\t  \t';
    ['a'] = '\t \t ';
    ['b'] = '\t \t\t';
    ['c'] = '\t\t  ';
    ['d'] = '\t\t \t';
    ['e'] = '\t\t\t ';
    ['f'] = '\t\t\t\t';
    ['-'] = '';
};

local WS_TO_HEX_MAPPING =
{
    ['    ']     = '0';
    ['   \t']    = '1';
    ['  \t ']    = '2';
    ['  \t\t']   = '3';
    [' \t  ']    = '4';
    [' \t \t']   = '5';
    [' \t\t ']   = '6';
    [' \t\t\t']  = '7';
    ['\t   ']    = '8';
    ['\t  \t']   = '9';
    ['\t \t ']   = 'a';
    ['\t \t\t']  = 'b';
    ['\t\t  ']   = 'c';
    ['\t\t \t']  = 'd';
    ['\t\t\t ']  = 'e';
    ['\t\t\t\t'] = 'f';
};


objectuuids.EMBED_REGEX = ('^(.*)%s(%s)%s$'):format(WS_PREFIX, string.rep('[ \t]', 128), WS_SUFFIX);


--- Converts a UUID to whitespace format.
-- @param uuid [string] The UUID the convert.
-- @return     [string] The UUID in whitespace format.
function objectuuids.uuid_to_whitespace(uuid)
    return uuid:gsub('.', HEX_TO_WS_MAPPING);
end;


--- Converts a UUID from whitespace format.
-- @param whitespace [string] The UUID to convert, in whitespace format.
-- @return           [string] The UUID.
function objectuuids.whitespace_to_uuid(whitespace)
    local result = {};
    local index = 1;
    for match in whitespace:gmatch('[ \t][ \t][ \t][ \t]') do
        local char = WS_TO_HEX_MAPPING[match];
        if not char then
            return nil;
        end;
        result[#result + 1] = char;
        if DASH_POSITIONS[index] then
            result[#result + 1] = '-';
        end;
        index = index + 1;
    end;

    if index ~= 33 then
        return nil; -- The whitespace is the wrong length to be a UUID.
    end;
    return table.concat(result);
end;


--- Embeds a UUID into an entity's Lua or JSON data.
-- @param staticdata [string|nil] The data to embed the UUID into.
-- @param uuid       [string]     The UUID to embed.
-- @return           [string]     The data with the UUID embedded.
function objectuuids.embed_uuid_in_staticdata(staticdata, uuid)
    return (staticdata or '') .. WS_PREFIX .. objectuuids.uuid_to_whitespace(uuid) .. WS_SUFFIX;
end;


--- Extracts an embedded UUID from an entity's Lua or JSON data.
-- @param staticdata [string]     The data with the UUID embedded.
-- @return           [string|nil] The embedded UUID, if any.
-- @return           [string]     The original staticdata.
function objectuuids.extract_uuid_from_staticdata(staticdata)
    staticdata = staticdata or '';
    local base, whitespace = string.match(staticdata, objectuuids.EMBED_REGEX);
    if not base then
        return nil, staticdata;
    end;

    return objectuuids.whitespace_to_uuid(whitespace), base;
end;


--- Assigns a UUID to any player who joins.
-- @param player [ObjectRef] The player who joined.
-- @param dtime  [number]    Ignored.
function objectuuids.on_joinplayer(player, dtime)
    local uuid = objectuuids.get_uuid_for_username(player:get_player_name());
    objectuuids.set_uuid(player, uuid);
end;
minetest.register_on_joinplayer(objectuuids.on_joinplayer);

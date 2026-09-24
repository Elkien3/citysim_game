--[[
    Leads — Adds leads for transporting animals to Luanti.
    Copyright © 2023-2025, Silver Sandstone <@SilverSandstone@craftodon.social>

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


leads.util = {};

leads.util.rng = PcgRandom(0x4C656164);

local has_objectuuids = core.get_modpath('objectuuids') ~= nil;


--- Checks if the object is a mob.
-- @param object [ObjectRef] The object to check.
-- @return       [boolean]   true if the object is a mob.
function leads.util.is_mob(object)
    local entity = object:get_luaentity();
    if not entity then
        return false;
    end;

    -- Explicitly marked as an animal:
    local result = entity._leads_is_mob or entity._leads_is_animal;
    if result ~= nil then
        return result;
    end;

    -- Mobs (Redo) and Repixture:
    if entity.health then
        return true;
    end;

    -- Creatura:
    if entity._creatura_mob then
        return true;
    end;

    -- Exile:
    if entity.hp and (entity.max_health or entity.max_hp) then
        return true;
    end;

    return false;
end;

leads.util.is_animal = leads.util.is_mob; -- Deprecated alias.


--- Tiles a texture to the specified size.
-- @param texture    [string]  The texture to tile.
-- @param src_width  [integer] The input texture's width.
-- @param src_height [integer] The input texture's height.
-- @param out_width  [integer] The resulting texture's width.
-- @param out_height [integer] The resulting texture's height.
-- @return           [string]  A texture string.
function leads.util.tile_texture(texture, src_width, src_height, out_width, out_height)
    texture = leads.util.escape_texture(('(%s)^[resize:%dx%d'):format(texture, src_width, src_height));
    local parts = {'[combine:', out_width, 'x', out_height};
    local y = 0;
    while y < out_height do
        local x = 0;
        while x < out_width do
            table.insert(parts, (':%d,0=%s'):format(x, texture));
            x = x + src_width;
        end;
        y = y + src_height;
    end;
    return table.concat(parts, '');
end;


--- Escapes a texture for use with [combine.
-- @param texture [string] A texture string.
-- @return        [string] An escaped texture string.
function leads.util.escape_texture(texture)
    return string.gsub(texture, '[\\^:]', function(char) return '\\' .. char; end);
end;


--- Serialises the identity (not the state) of an object reference.
-- @param obj [ObjectRef|nil] The object to serialise.
-- @return    [table|nil]     A table identifying the object, or nil if the reference is invalid.
function leads.util.serialise_objref(obj)
    if not obj then
        return nil;
    end;

    local result = {pos = obj:get_pos()};

    if has_objectuuids then
        result.uuid = objectuuids.get_uuid(obj);
    end;

    if core.is_player(obj) then
        result.player_name = obj:get_player_name();
    else
        local entity = obj:get_luaentity();
        if not entity then
            return nil;
        end;
        result.name = entity.name;
    end;

    return result;
end;


--- Deserialises an object ID previously returned from `serialise_objref()`, trying to identify the original object.
-- @param id [table|nil]     A table identifying an object.
-- @return   [ObjectRef|nil] An object matching the ID, or nil if no such object was found.
function leads.util.deserialise_objref(id)
    if not id then
        return nil;
    end;

    -- Objects are identified by UUID where possible:
    if has_objectuuids and id.uuid then
        return objectuuids.get_object_by_uuid(id.uuid);
    end;

    -- Without UUIDs, players are identified by name:
    if id.player_name then
        return core.get_player_by_name(id.player_name);
    end;

    -- Luanti doesn't provide any way to persistently identify Lua entities,
    -- so the best we can do is look for an entity with the correct name near
    -- the saved position.
    if not id.pos then
        return nil;
    end;
    local pos = vector.new(id.pos);

    local range = 3;
    local range_min = pos:offset(-range, -range, -range);
    local range_max = pos:offset( range,  range,  range);
    local objects = core.get_objects_in_area(range_min, range_max);
    local best_object = nil;
    local best_distance = math.huge;
    for __, object in ipairs(objects) do
        local entity = object:get_luaentity();
        if entity and (id.name == nil or entity.name == id.name) then
            local distance = object:get_pos():distance(pos);
            if distance <= 0.0 then
                return object;
            elseif distance < best_distance and (distance < 0.01 or not leads.is_immobile(object)) then
                best_distance = distance;
                best_object = object;
            end;
        end;
    end;

    return best_object;
end;


--- Checks if two objrefs refer to the same object, which may be a player or entity.
-- @param obj1 [ObjectRef|nil] The first object to compare.
-- @param obj2 [ObjectRef|nil] The second object to compare.
-- @return     [boolean]       true if obj1 and obj2 reference the same object.
function leads.util.is_same_object(obj1, obj2)
    if not (obj1 and obj2) then
        return false;
    end;

    local obj1_is_player = core.is_player(obj1);
    local obj2_is_player = core.is_player(obj2);
    if obj1_is_player ~= obj2_is_player then
        return false;
    end;

    if obj1_is_player then
        return obj1:get_player_name() == obj2:get_player_name();
    else
        return obj1:get_luaentity() == obj2:get_luaentity();
    end;
end;


--- Returns the relative attachment position for the specified object.
-- @param object [ObjectRef|nil] The player or entity to check.
-- @return       [vector]        The attachment offset as a vector relative to the object's origin.
function leads.util.get_attach_offset(object)
    if not object then
        return vector.zero();
    end;

    -- Attachment offset override:
    local entity = object:get_luaentity();
    if entity then
        local offset = entity._leads_attach_offset or leads.custom_attach_offsets[entity.name];
        if type(offset) == 'number' then
            return vector.new(0, offset, 0);
        elseif offset then
            return offset;
        end;
    end;

    -- Fallback to the centre of the object's hitbox:
    local properties = object:get_properties();
    if not properties then
        return vector.zero();
    end;
    local hitbox = (properties.physical and properties.collisionbox) or (properties.pointable and properties.selectionbox) or {};
    local bottom = hitbox[2] or 0;
    local top    = hitbox[5] or 0;
    return vector.new(0, (bottom + top) / 2, 0);
end;


--- Finds the first item available for crafting.
-- @param ... [string]     Any number of prefixed node/item IDs.
-- @return    [string|nil] One of the specified IDs, or nil.
function leads.util.first_available_item(...)
    for __, name in ipairs{...} do
        if name == '' or string.match(name, '^group:.*') or core.registered_items[name] then
            return name;
        end;
    end;
    return nil;
end;


--- Returns a string describing an object, for debugging.
-- @param object [ObjectRef] An object reference.
-- @return       [string]    A string describing the object.
function leads.util.describe_object(object)
    if core.is_player(object) then
        return ('[Player %q]'):format(object:get_player_name());
    end;

    local entity = object:get_luaentity();
    if entity then
        return ('[LuaEntity %q]'):format(entity.name);
    end;

    return '[Unknown object]';
end;


--- Prevents the player from interacting for some time.
-- @param name [string] The name of the player.
-- @param time [number] How long to block interactions, in seconds.
function leads.util.block_player_interaction(name, time)
    local function _callback()
        leads.interaction_blockers[name] = nil;
    end;

    local old_timer = leads.interaction_blockers[name];
    if old_timer then
        old_timer:cancel();
    end;

    leads.interaction_blockers[name] = core.after(time, _callback);
end;


--- Figures out the type of an object.
-- @param object [ObjectRef]  The object to check.
-- @return       [ObjectType] The type of the object.
function leads.util.get_object_type(object)
    -- Check player:
    if core.is_player(object) then
        return leads.ObjectType.PLAYER;
    end;

    -- Get entity:
    local entity = object:get_luaentity();
    if not entity then
        return leads.ObjectType.OTHER;
    end;

    -- Custom type override:
    local override = entity._leads_type or leads.custom_object_types[entity.name];
    if override then
        return override;
    end;

    -- Get entity definition:
    local def = core.registered_entities[entity.name];
    if not def then
        return leads.ObjectType.OTHER;
    end;

    -- Check Creatura (assumed to be animals):
    if entity._creatura_mob then
        return leads.ObjectType.ANIMAL;
    end;

    -- Check Mobs API type:
    if def.type == 'animal' then
        return leads.ObjectType.ANIMAL;
    elseif def.type == 'monster' then
        return leads.ObjectType.MONSTER;
    elseif def.type == 'npc' then
        return leads.ObjectType.NPC;
    end;

    return leads.ObjectType.OTHER;
end;


--- Gets the owner of an object.
-- @param object [ObjectRef] The object to check.
-- @return       [string]    The owner's name, or '' for unowned.
function leads.util.get_object_owner(object)
    local entity = object:get_luaentity();
    if not entity then
        return '';
    end;

    return entity.owner or '';
end;


--- Calculates the mass of a player or entity.
-- @param object [ObjectRef] The object to check.
-- @return       [number]    The object's mass, in an abstract unit.
function leads.util.get_object_mass(object)
    local entity = object:get_luaentity();

    local mass = entity and entity._leads_mass;
    if mass then
        return mass;
    end;

    local density = entity and entity._leads_density or 1;
    local properties = object:get_properties() or {};
    local hitbox = properties.collisionbox or properties.selectionbox;
    if not hitbox then
        return density;
    end;

    local width  = math.abs(hitbox[4] - hitbox[1]);
    local height = math.abs(hitbox[5] - hitbox[2]);
    local depth  = math.abs(hitbox[6] - hitbox[3]);
    return width * height * depth * density;
end;


--- Clamps a value within the specified range.
-- @param value [number] The value to clamp.
-- @param min   [number] The lower bound.
-- @param max   [number] The upper bound.
-- @return      [number] A number between lower and upper.
function leads.util.clamp(value, min, max)
    if value < min then
        return min;
    elseif value > max then
        return max;
    else
        return value;
    end;
end;

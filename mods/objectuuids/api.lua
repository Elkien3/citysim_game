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


--- Public API functions.
-- @module api


--- Gets the UUID of the specified object.
-- @param objref [ObjectRef|LuaEntity] The object to get the UUID of.
-- @return       [string]              The object's UUID.
function objectuuids.get_uuid(objref)
    objref = (objref.name and objref.object) or objref;
    return objectuuids.object_uuids[objref];
end;


--- Finds the object with the specified UUID.
-- @param uuid [string]        The object's UUID, in lenient form.
-- @return     [ObjectRef|nil] The object associated with the UUID, or nil if it's unavailable.
function objectuuids.get_object_by_uuid(uuid)
    uuid = objectuuids.util.canonicalise_uuid(uuid);
    local objref = objectuuids.objects_by_uuid[uuid];
    if objref and objref:get_pos() then
        return objref;
    end;
    return nil;
end;


--- Sets the UUID of the specified object.
-- @param objref [ObjectRef|LuaEntity] The object to change the UUID of.
-- @param uuid   [string]              The new UUID, in lenient form.
function objectuuids.set_uuid(objref, uuid)
    objref = (objref.name and objref.object) or objref;
    local old_uuid = objectuuids.get_uuid(objref);
    if old_uuid then
        objectuuids.objects_by_uuid[old_uuid] = nil;
    end;

    uuid = objectuuids.util.canonicalise_uuid(uuid);
    objectuuids.objects_by_uuid[uuid] = objref;
    objectuuids.object_uuids[objref] = uuid;
end;


--- Spawns an entity with its UUID already set.
-- @param pos        [vector]        Where to spawn the entity.
-- @param name       [string]        The name of the entity type.
-- @param uuid       [string]        The UUID to assign to the object.
-- @param staticdata [string|nil]    The initial state of the entity.
-- @return           [ObjectRef|nil] The spawned object, or nil on failure.
function objectuuids.add_entity_with_uuid(pos, name, uuid, staticdata)
    uuid = objectuuids.util.canonicalise_uuid(uuid);
    staticdata = objectuuids.embed_uuid_in_staticdata(staticdata, uuid);
    return minetest.add_entity(pos, name, staticdata);
end;


--- Calculates the UUID that would be used for a player with the specified name.
-- The player is not required to have ever been in the world.
-- @param name [string] The player's username.
-- @return     [string] The player's UUID.
function objectuuids.get_uuid_for_username(name)
    return objectuuids.util.generate_uuid5(objectuuids.USERNAME_UUID_NAMESPACE, name);
end;

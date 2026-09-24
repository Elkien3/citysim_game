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


--- Entity definition patches.
-- @module patches


--- Entity definition patch table.
objectuuids.patches = {};

--- Patches entity activation to load or generate its UUID.
function objectuuids.patches.on_activate(old_func, self, staticdata, ...)
    local uuid, staticdata = objectuuids.extract_uuid_from_staticdata(staticdata);
    if not uuid then
        uuid = objectuuids.util.generate_uuid4();
    end;
    objectuuids.object_uuids[self.object] = uuid;
    objectuuids.objects_by_uuid[uuid] = self.object;

    return old_func(self, staticdata, ...);
end;

--- Patches entity serialisation to save its UUID.
function objectuuids.patches.get_staticdata(old_func, self, ...)
    local staticdata = old_func(self, ...);
    local uuid = objectuuids.get_uuid(self.object);
    return objectuuids.embed_uuid_in_staticdata(staticdata, uuid);
end;


-- Apply patches to existing entity definitions:
for name, def in pairs(minetest.registered_entities) do
    objectuuids.util.patch_entity_def(def, objectuuids.patches);
end;

-- Apply patches to future entity definitions:
local old_register_entity = minetest.register_entity;
function minetest.register_entity(name, def)
    objectuuids.util.patch_entity_def(def, objectuuids.patches);
    old_register_entity(name, def);
end;

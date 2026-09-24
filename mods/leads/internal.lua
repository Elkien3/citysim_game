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


--- Internal functions and overrides.
-- @module internal


leads.interaction_blockers = {};


function leads._apply_item_patches(name, def)
    local old_on_place = def.on_place;
    local old_on_secondary_use = def.on_secondary_use;

    local overrides = {};

    function overrides.on_place(itemstack, placer, pointed_thing, ...)
        -- Try knotting the placer's held lead:
        if placer and not placer:get_player_control().sneak then
            local node = pointed_thing.under and core.get_node_or_nil(pointed_thing.under);
            if node and leads.is_knottable(node.name) then
                if leads.knot(placer, pointed_thing.under) then
                    return nil;
                end;
            end;
        end;

        -- Fallback to the item's old on_place function:
        return (old_on_place or core.item_place)(itemstack, placer, pointed_thing, ...);
    end;

    function overrides.on_secondary_use(itemstack, user, pointed_thing, ...)
        local object = pointed_thing and pointed_thing.ref;
        local keys = user:get_player_control();

        -- If the player is holding a knotted lead, tie it to the object instead:
        if user and object and leads.is_leashable(object) and not leads.is_immobile(object) and not keys.sneak then
            for lead in leads.find_connected_leads(user, true, false) do
                local lead_entity = lead:get_luaentity();
                local follower = lead_entity:get_follower();
                if follower and leads.is_immobile(follower) then
                    lead_entity:reverse(); -- Reverse the lead so the knot becomes the leader.
                    if lead_entity:set_follower(object) then
                        return nil;
                    end;
                end;
            end;
        end;

        -- Hold Aux1 to leash an animal to another animal:
        if object and keys.aux1 and leads.is_leashable(object) then
            for lead in leads.find_connected_leads(user, true, false) do
                if lead:get_luaentity():set_leader(object) then
                    return nil;
                end;
            end;
        end;

        return (old_on_secondary_use or core.item_secondary_use)(itemstack, user, pointed_thing, ...);
    end;

    core.override_item(name, overrides);
end;


local old_is_protected = core.is_protected;
function core.is_protected(pos, name)
    if leads.interaction_blockers[name] then
        return true;
    end;
    return old_is_protected(pos, name);
end;


core.register_on_mods_loaded(
function()
    for name, def in pairs(core.registered_items) do
        leads._apply_item_patches(name, def);
    end;
end);


core.register_on_dieplayer(
function(player, reason)
    for lead in leads.find_connected_leads(player, true, true) do
        lead:get_luaentity():break_lead();
    end;
end);

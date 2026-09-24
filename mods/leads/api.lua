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


--- Public API functions.
-- @module api


local S = leads.S;


--- An enumerator of object types.
leads.ObjectType =
{
    PLAYER  = 'player';
    ANIMAL  = 'animal';
    MONSTER = 'monster';
    NPC     = 'npc';
    VEHICLE = 'vehicle';
    OTHER   = 'other';
};


--- Overrides the leashable property of entities.
leads.custom_leashable_entities =
{
    ['boats:boat']  = true;
};

--- Overrides the object type of entities.
leads.custom_object_types =
{
    ['boats:boat'] = leads.ObjectType.VEHICLE;
};

--- Overrides the knottable property of nodes.
leads.custom_knottable_nodes =
{
    ['ferns:fern_trunk']                    = true;
    ['ethereal:bamboo']                     = true;
    ['bambooforest:bamboo']                 = true;
    ['advtrains:signal_off']                = true;
    ['advtrains:signal_on']                 = true;
    ['advtrains:retrosignal_off']           = true;
    ['advtrains:retrosignal_on']            = true;
    ['nodes_nature:mahal']                  = true;
    ['hades_furniture:binding_rusty_bars']  = true;
    ['pride_flags:lower_mast']              = true;
};

--- Overrides the lead attachment offset of entities.
leads.custom_attach_offsets =
{
    ['mobs_animal:bunny']   = -0.2;
    ['mobs_animal:chicken'] = -0.4;
    ['mobs_animal:kitten']  =  0.0;
    ['mobs_animal:rat']     = -0.9;
    ['mobs_mc:axolotl']     =  0.1;
    ['mobs_mc:cat']         =  0.2;
};

--- A table of sound effects for lead events.
leads.sounds =
{
    attach  = {name = 'leads_attach',  gain = 0.5,  pitch = 0.75, description = S'Lead attached'};
    remove  = {name = 'leads_remove',  gain = 0.5,  pitch = 0.75, description = S'Lead removed'};
    stretch = {name = 'leads_stretch', gain = 0.25, pitch = 1.25, description = S'Lead stretches', duration = 2.5};
    snap    = {name = 'leads_break',   gain = 0.75,               description = S'Lead snaps'};
};


local weak_key_mt = {__mode = 'k'};
local leads_by_connector_mt =
{
    __mode = 'k';
    __index = function(self, key)
        local result = setmetatable({}, weak_key_mt);
        self[key] = result;
        return result;
    end;
};
leads.leads_by_connector = setmetatable({}, leads_by_connector_mt);


--- Creates a lead between two objects.
-- @param leader   [ObjectRef]            The leader object.
-- @param follower [ObjectRef]            The follower object.
-- @param item     [string|ItemStack|nil] The lead item, if any.
-- @return         [ObjectRef|nil]        The lead object, or nil on failure.
-- @return         [string|nil]           A string describing the error, or nil on success.
function leads.add_lead(leader, follower, item)
    if leads.util.is_same_object(leader, follower) then
        return nil, S'You cannot leash something to itself.';
    end;

    item = ItemStack(item);
    local item_def = item:get_definition();

    local l_pos = leader:get_pos();
    local f_pos = follower:get_pos();

    if leads.settings.debug then
        core.log(debug.traceback(('[Leads] Connecting L:%s to F:%s.'):format(leads.util.describe_object(leader), leads.util.describe_object(follower))));
    end;

    local centre = (l_pos + f_pos) / 2;

    local object = core.add_entity(centre, 'leads:lead');
    if not object then
        return nil, S'Failed to create lead.';
    end;

    local entity = object:get_luaentity();
    entity.leader   = leader;
    entity.follower = follower;
    entity:set_item(item);
    entity:update_visuals();
    entity:update_objref_ids();
    entity:notify_connector_added(leader,   true);
    entity:notify_connector_added(follower, false);
    core.sound_play(leads.sounds.attach, {pos = centre}, true);
    return object, nil;
end;

leads.connect_objects = leads.add_lead; -- Deprecated alias.


--- Checks if the object can be attached to a lead.
-- @param object [ObjectRef] The object to check.
-- @return       [boolean]   true if the object can be attached to a lead.
function leads.is_leashable(object)
    -- All entities allowed in settings:
    if leads.settings.allow_leash_all then
        return true;
    end;

    -- Check setting for type:
    local obj_type = leads.util.get_object_type(object);
    if not leads.settings['allow_leash_' .. obj_type] then
        return false;
    end;

    -- Get entity:
    local entity = object:get_luaentity();
    if not entity then
        return obj_type == leads.ObjectType.PLAYER;
    end;

    -- Custom leashable:
    local leashable = entity._leads_leashable or leads.custom_leashable_entities[entity.name];
    if leashable ~= nil then
        return leashable;
    end;

    -- Mobs:
    return leads.util.is_mob(object);
end;


--- Checks if the node can have lead knots tied to it.
-- @param name [string]  The name of a node.
-- @return     [boolean] true if the node is knottable.
function leads.is_knottable(name)
    local def = core.registered_nodes[name];
    if not def then
        return false;
    end;

    -- Custom knottable:
    local knottable = def._leads_knottable or leads.custom_knottable_nodes[name];
    if knottable ~= nil then
        return knottable;
    end;

    -- Fence:
    if def.drawtype == 'fencelike' or (core.get_item_group(name, 'fence') > 0 and not (name:match('.*:fence_rail_.*') or name:match('.*:gate_.*'))) then
        return true;
    end;

    -- Mese post:
    if name:match('.*:mese_post_.*') then
        return true;
    end;

    -- Lord of the Test fences:
    -- (These aren't in group:fence due to a bug.)
    if name:match('^lottblocks:fence_.*') then
        return true;
    end;

    return false;
end;


--- Finds a lead connected to the specified leader.
-- If there are multiple matching leads, one is chosen arbitrarily.
-- @param leader [ObjectRef]     The player or entity to find leads connected to.
-- @return       [ObjectRef|nil] The lead, if any.
function leads.find_lead_by_leader(leader)
    local iter = leads.find_connected_leads(leader, true, false);
    local lead = iter();
    return lead;
end;


--- Finds leads connected to the specified object.
-- @param connector       [ObjectRef] The player or entity to find leads connected to.
-- @param accept_leader   [boolean]   Find leads where the specified object is the leader.
-- @param accept_follower [boolean]   Find leads where the specified object is the follower.
-- @return                [function]  An iterator of (lead: ObjectRef, is_leader: boolean).
function leads.find_connected_leads(connector, accept_leader, accept_follower)
    local lead;
    local set = leads.leads_by_connector[connector];

    local function _next()
        lead = next(set, lead);
        if not lead then
            return nil, nil;
        end;

        local entity = lead:get_luaentity();
        if not entity then
            return _next();
        end;

        if accept_leader and entity.leader and leads.util.is_same_object(entity.leader, connector) then
            return lead, true;
        elseif accept_follower and entity.follower and leads.util.is_same_object(entity.follower, connector) then
            return lead, false;
        end;
        return _next();
    end;

    return _next;
end;


--- Ties the leader's lead to a post.
-- @param leader [ObjectRef]     The leader whose lead to tie.
-- @param pos    [vector]        Where to tie the knot.
-- @return       [ObjectRef|nil] The knot object, or nil on failure.
function leads.knot(leader, pos)
    pos = vector.round(pos);

    -- Check protection:
    if leads.settings.respect_protection and not core.check_player_privs(leader, 'protection_bypass') then
        local name = leader and leader:get_player_name() or '';
        if core.is_protected(pos, name) then
            core.record_protection_violation(pos, name);
            return nil;
        end;
    end;

    -- Find a lead attached to the player:
    local lead = leads.find_lead_by_leader(leader);
    if not lead then
        return nil;
    end;

    -- Create a knot:
    local knot = leads.add_knot(pos);
    if not knot then
        return nil;
    end;

    -- Play sound:
    core.sound_play(leads.sounds.attach, {pos = pos}, true);

    -- Attach the lead to the knot:
    lead:get_luaentity():set_leader(knot);
    return knot;
end;


--- Adds a knot on a fence post, or finds an existing one.
-- @param pos [vector]        Where to tie the knot.
-- @return    [ObjectRef|nil] A new or existing knot, or nil if creating the knot failed.
function leads.add_knot(pos)
    pos = pos:round();

    for __, object in ipairs(core.get_objects_in_area(pos, pos)) do
        local entity = object:get_luaentity();
        if entity and entity.name == 'leads:knot' then
            return object;
        end;
    end;

    return core.add_entity(pos, 'leads:knot');
end;


--- Checks if the specified object is immobile (cannot be moved with a lead).
-- @param object [ObjectRef|nil] The object to check.
-- @return       [boolean]       true if the object is immobile.
function leads.is_immobile(object)
    local entity = object and object:get_luaentity();
    return entity and entity._leads_immobile or false;
end;


--- Checks if the player is allowed to leash the object, according to ownership and mod settings.
-- @param object [ObjectRef|nil]        The object to check.
-- @param player [ObjectRef|string|nil] The player trying to leash the object.
-- @return       [boolean]              true if the player is allowed to leash the object.
function leads.allowed_to_leash(object, player)
    local name = '';
    if player == nil then
        name = '';
    elseif type(player) == 'string' then
        name = player;
    else
        name = player:get_player_name() or '';
    end;

    -- Players with the 'protection_bypass' privilege can bypass protection and ownership:
    if core.check_player_privs(name, 'protection_bypass') then
        return true;
    end;

    -- Players can always leash their own animals:
    local owner = leads.util.get_object_owner(object);
    if owner == name then
        return true;
    end;

    -- Players can't leash anything else in protected areas if protection support is enabled:
    if leads.settings.respect_protection then
        local pos = object:get_pos():round();
        if core.is_protected(pos, name) then
            core.record_protection_violation(pos, name);
            return false;
        end;
    end;

    -- Otherwise, use the appropriate setting:
    if owner == '' then
        return leads.settings.allow_leash_unowned or not leads.util.is_mob(object);
    else
        return leads.settings.allow_leash_owned_other;
    end;
end;


--- Implements lead item use.
-- @param itemstack     [ItemStack]     The player's held item.
-- @param user          [ObjectRef]     The player using the lead.
-- @param pointed_thing [PointedThing]  The pointed-thing.
-- @param is_punch      [boolean]       true if the interaction is a punch.
-- @return              [ItemStack|nil] The leftover itemstack, or nil for no change.
function leads.on_lead_interact(itemstack, user, pointed_thing, is_punch)
    local function _message(message)
        if leads.settings.chat_messages then
            core.chat_send_player(user:get_player_name(), message);
        end;
    end;


    if pointed_thing.under then
        -- Clicking on a node:
        local pos = pointed_thing.under;
        local node = core.get_node(pos);
        if not leads.is_knottable(node.name) then
            return nil;
        end;

        -- Check protection:
        if leads.settings.respect_protection and not core.check_player_privs(user, 'protection_bypass') then
            local name = user and user:get_player_name() or '';
            if core.is_protected(pos, name) then
                core.record_protection_violation(pos, name);
                return nil;
            end;
        end;

        -- Create new lead with knot:
        local knot = leads.add_knot(pos);
        if not knot then
            return nil;
        end;
        leads.connect_objects(user, knot, itemstack:peek_item());

    else
        -- Clicking on an object:
        local object = pointed_thing.ref;
        if not object then
            return nil;
        end;

        -- Try the entity's custom lead interact callback:
        local entity = object:get_luaentity();
        if entity and entity._leads_on_interact then
            local override, result = entity:_leads_on_interact(itemstack, user, pointed_thing, is_punch);
            if override then
                return result;
            end;
        end;

        -- The player right-clicked on a knot — try knotting their lead before making a new one:
        if entity and entity.name == 'leads:knot' then
            if leads.knot(user, object:get_pos()) then
                return nil;
            end;
        end;

        -- Make sure the object is leashable:
        if not leads.is_leashable(object) then
            _message(S'You cannot leash this.');
            return nil;
        end;

        -- Make sure the player is allowed to leash the object:
        if not leads.allowed_to_leash(object, user) then
            _message(S'You do not own this.');
            return nil;
        end;

        -- Create the lead:
        local lead, message = leads.add_lead(user, pointed_thing.ref, itemstack:peek_item());
        if not lead then
            _message(message);
            return nil;
        end;
    end;

    -- Consume the lead item:
    if not (core.is_player(user) and core.is_creative_enabled(user:get_player_name())) then
        itemstack:take_item(1);
    end;
    return itemstack;
end;


--- The `on_secondary_use`/`on_rightclick` handler for lead items.
-- @param itemstack     [ItemStack]     The player's held item.
-- @param user          [ObjectRef]     The player using the lead.
-- @param pointed_thing [PointedThing]  The pointed-thing.
-- @return              [ItemStack|nil] The leftover itemstack, or nil for no change.
function leads.on_lead_use(itemstack, user, pointed_thing)
    local result = leads.on_lead_interact(itemstack, user, pointed_thing, false);
    if (not result) and pointed_thing.under then
        -- Fallback to the node's right-click handler:
        local node = core.get_node(pointed_thing.under);
        local def = core.registered_nodes[node.name] or {};
        return def.on_rightclick and def.on_rightclick(pointed_thing.under, node, user, itemstack, pointed_thing) or nil;
    end;
    return result;
end;


--- The `on_use` handler for lead items.
-- @param itemstack     [ItemStack]     The player's held item.
-- @param user          [ObjectRef]     The player using the lead.
-- @param pointed_thing [PointedThing]  The pointed-thing.
-- @return              [ItemStack|nil] The leftover itemstack, or nil for no change.
function leads.on_lead_punch(itemstack, user, pointed_thing)
    return leads.on_lead_interact(itemstack, user, pointed_thing, true);
end;

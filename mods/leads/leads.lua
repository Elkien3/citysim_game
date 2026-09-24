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


--- Lead entity definition.
-- @module leads


local S = leads.S;


leads.SLACK_MODELS =
{
    [0] = 'leads_lead.obj',
    'leads_lead_slack1.obj',
    'leads_lead_slack2.obj',
    'leads_lead_slack3.obj',
    'leads_lead_slack4.obj',
    'leads_lead_slack5.obj',
    'leads_lead_slack6.obj',
    'leads_lead_slack7.obj',
    'leads_lead_slack8.obj',
    'leads_lead_slack9.obj',
    'leads_lead_slack10.obj',
    'leads_lead_slack11.obj',
    'leads_lead_slack12.obj',
};

leads.STRETCH_SOUND_INTERVAL = 2.0;

if leads.settings.drop_mode == 'drop' then
    leads.DROP_ITEM = true;
elseif leads.settings.drop_mode == 'give' then
    leads.DROP_ITEM = false;
else
    leads.DROP_ITEM = (core.get_modpath('mcl_core') or core.get_modpath('rp_default') or core.get_modpath('item_drop')) ~= nil;
end;


--- The main lead entity.
-- @type LeadEntity
leads.LeadEntity = {};

leads.LeadEntity.description = S'Lead';
leads.LeadEntity._leads_immobile = true;

leads.LeadEntity.initial_properties =
{
    visual       = 'mesh';
    mesh         = 'leads_lead.obj';
    textures     = {leads.DEFAULT_LEAD_TEXTURE};
    physical     = false;
    selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5};
};

--- Spawns or unloads a lead.
function leads.LeadEntity:on_activate(staticdata, dtime_s)
    self.current_length = 0.24;
    self.max_length = leads.settings.lead_length;
    self.rotation = vector.zero();
    self.leader_attach_offset = vector.zero();
    self.follower_attach_offset = vector.zero();
    self.sound_timer = 0.0;
    self.item = ItemStack();
    self.texture = leads.DEFAULT_LEAD_TEXTURE;
    self.strength = leads.settings.lead_strength;
    self.breaking = 0.0;

    local data = core.deserialize(staticdata);
    if data then
        self:load_from_data(data);
    end;

    self.object:set_armor_groups{fleshy = 0};
end;

--- Initialises the lead's state from a table.
function leads.LeadEntity:load_from_data(data)
    self.max_length = data.max_length or self.max_length;
    self.leader_id = data.leader_id or {};
    self.follower_id = data.follower_id or {};
    self.leader_attach_offset = data.leader_attach_offset or self.leader_attach_offset;
    self.follower_attach_offset = data.follower_attach_offset or self.follower_attach_offset;

    self.leader_id.pos = vector.new(self.leader_id.pos);
    self.follower_id.pos = vector.new(self.follower_id.pos);

    if data.item then
        self:set_item(data.item);
    end;

    self:update_visuals();
end;

--- Sets the lead's item, updating relevant properties.
function leads.LeadEntity:set_item(item)
    item = ItemStack(item);
    self.item = item;
    local def = item:get_definition();

    self.strength = def._leads_strength or leads.settings.lead_strength;
    self.max_length = def._leads_length or leads.settings.lead_length;
    self.texture = def._leads_texture or leads.DEFAULT_LEAD_TEXTURE;

    if not leads.settings.dynamic_textures then
        self.object:set_properties{textures = {self.texture}};
    end;
end;

--- Steps the knot.
function leads.LeadEntity:on_step(dtime)
    self:_update_connectors();
    local success, pos, offset = self:step_physics(dtime);
    if success then
        self.current_length = leads.util.clamp(offset:length(), 0.25, 256);
        self.rotation = offset:dir_to_rotation();
        self.object:move_to(pos, true);
        self:update_visuals();
    end;
end;

--- Simulates the lead's physics.
-- @param dtime [number]     The time elapsed since the last tick, in seconds.
-- @return      [boolean]    true if the lead is functioning correctly, or false if it should break.
-- @return      [vector|nil] The centre position of the lead, or nil on failure.
-- @return      [vector|nil] The offset between the leader and the follower, or nil on failure.
function leads.LeadEntity:step_physics(dtime)
    dtime = math.min(dtime, 0.125);

    local l_pos = self.leader_pos;
    local f_pos = self.follower_pos;
    if not (l_pos and f_pos) then
        self:break_lead();
        return false, nil, nil;
    end;

    l_pos = l_pos + self.leader_attach_offset;
    f_pos = f_pos + self.follower_attach_offset;

    local pull_distance = self.max_length;
    local break_distance = pull_distance * 2;
    local distance = l_pos:distance(f_pos);
    if distance > break_distance then
        -- Lead is too long, break:
        local overextension = distance - break_distance;
        self.breaking = self.breaking + overextension * dtime;
        if self.breaking > self.strength then
            self:break_lead(nil, true);
            return false, nil, nil;
        end;
    else
        self.breaking = 0.0;
    end;

    local pos = (f_pos + l_pos) / 2;
    if self.leader and self.follower and distance > pull_distance then
        local base_force;

        local function _pull_connector(connector, this_pos, other_pos)
            if leads.is_immobile(connector) then
                return;
            end;

            if not base_force then
                base_force = (distance - pull_distance) * leads.settings.pull_force / pull_distance;
            end;

            local force = base_force / math.sqrt(leads.util.get_object_mass(connector));
            local pull_direction = (other_pos - this_pos):normalize();
            connector:add_velocity(pull_direction * dtime * force ^ 1.5);
        end;

        -- Pull follower:
        _pull_connector(self.follower, f_pos, l_pos);

        -- Pull leader if symmetrical mode is enabled:
        if leads.settings.symmetrical then
            _pull_connector(self.leader, l_pos, f_pos);
        end;

        -- Play stretching sound:
        self.sound_timer = self.sound_timer + dtime;
        if self.sound_timer >= leads.STRETCH_SOUND_INTERVAL then
            self.sound_timer = self.sound_timer - leads.STRETCH_SOUND_INTERVAL;
            if leads.util.rng:next(0, 8) == 0 then
                core.sound_play(leads.sounds.stretch, {pos = pos}, true);
            end;
        end;
    end;
    return true, pos, f_pos - l_pos;
end;

--- Updates the connector references and stored positions.
-- @local
function leads.LeadEntity:_update_connectors()
    local function _get_pos(key)
        local object = self[key];
        local pos = object and object:get_pos();
        local id = self[key .. '_id'];
        if not pos then
            pos = id.pos;
            if not pos then
                return nil;
            end;

            local object = leads.util.deserialise_objref(id);
            if object then
                pos = object:get_pos();
                self[key] = object;
                self[key .. '_attach_offset'] = leads.util.get_attach_offset(object);
                leads.leads_by_connector[object][self.object] = true;
            else
                -- The object reference is invalid, and deserialising the
                -- object failed. This could mean that the object has been
                -- removed and the lead should break, or it could mean that
                -- the object's mapblock has been unloaded, and the lead
                -- should just wait until it gets loaded again. We can figure
                -- out which one by checking if the mapblock is active.
                if core.compare_block_status(pos, 'active') then
                    return nil;
                end;
            end;
        end;
        id.pos = pos or id.pos;
        return pos;
    end;

    self.leader_pos   = _get_pos('leader');
    self.follower_pos = _get_pos('follower');
end;

--- Handles the lead being punched.
function leads.LeadEntity:on_punch(puncher, time_from_last_punch, tool_capabilities, dir, damage)
    local name = puncher and puncher:get_player_name() or '';

    -- Check protection:
    local is_protected, protected_pos = self:is_protected(name);
    if is_protected then
        core.record_protection_violation(protected_pos, name);
        return true;
    end;

    -- Break the lead:
    self:break_lead(puncher);

    -- Block the player's interaction for a moment to prevent accidentally breaking the node behind the lead:
    if name ~= '' then
        leads.util.block_player_interaction(name, 0.25);
    end;

    return true;
end;

--- Handles the lead being interacted with while holding a lead item.
function leads.LeadEntity:_leads_on_interact(itemstack, user, pointed_thing, is_punch)
    if is_punch then
        self:on_punch(user);
        return true, nil;
    end;
    return false, nil;
end;

--- Handles the lead being ‘killed’.
function leads.LeadEntity:on_death(killer)
    self:break_lead(killer);
end;

--- Returns the lead's state as a table.
function leads.LeadEntity:get_staticdata()
    local data = {};
    data.item = self.item:to_string();
    data.max_length = self.max_length;
    data.leader_id = self.leader_id;
    data.follower_id = self.follower_id;
    data.leader_attach_offset = self.leader_attach_offset;
    data.follower_attach_offset = self.follower_attach_offset;
    return core.serialize(data);
end;

--- Breaks the lead, possibly giving/dropping an item.
-- @param breaker [ObjectRef|nil] The object breaking the lead.
-- @param snap    [boolean|nil]   true if the lead is breaking due to tension.
function leads.LeadEntity:break_lead(breaker, snap)
    if leads.settings.debug then
        core.log(debug.traceback(('[Leads] Breaking lead %s at %s.'):format(self, self.object:get_pos())));
    end;

    -- Notify leader and follower:
    self:notify_connector_removed(self.leader,   true);
    self:notify_connector_removed(self.follower, false);

    -- Give or drop item:
    if not self.item:is_empty() then
        local owner = breaker;
        if not core.is_player(owner) then
            owner = self.leader;
        end;
        local pos = self.object:get_pos();
        local item = self.item;
        if not leads.DROP_ITEM then
            local inventory = core.is_player(owner) and owner:get_inventory();
            if inventory then
                if core.is_creative_enabled(owner) and inventory:contains_item('main', item, true) then
                    item = ItemStack();
                else
                    item = inventory:add_item('main', item);
                end;
            end;
        end;
        core.add_item(pos, item);
    end;

    -- Play sound:
    if snap then
        core.sound_play(leads.sounds.snap, {pos = self.object:get_pos()}, true);
    else
        core.sound_play(leads.sounds.remove, {pos = self.object:get_pos()}, true);
    end;

    -- Remove lead:
    self.object:remove();
    self.item = ItemStack();
end;

--- Checks if either end of the lead is in an area protected from the specified player.
-- If protection support is disabled, this always returns false.
-- @param player [string|ObjectRef] A player object or username.
-- @return       [boolean]          true if the player is not allowed to break the lead due to protection.
-- @return       [vector|nil]       The protected position, if any.
function leads.LeadEntity:is_protected(player)
    if not leads.settings.respect_protection then
        return false, nil; -- Protection support is disabled.
    end;

    local name;
    if type(player) == 'string' then
        name = player;
    else
        name = player:get_player_name();
    end;
    name = name or '';

    if core.check_player_privs(name, 'protection_bypass') then
        return false, nil; -- The player is exempt from protection.
    end;

    if name == self.leader_id.player_name then
        return false, nil; -- The player is holding the lead.
    end;
    
    for __, connector_id in ipairs{self.leader_id, self.follower_id} do
        if connector_id and connector_id.pos then
            local pos = vector.round(connector_id.pos);
            if core.is_protected(pos, name) then
                return true, pos; -- An end of the lead is in a protected area.
            end;
        end;
    end;

    return false, nil;
end;

--- Updates the visual properties of the lead to show its current state.
function leads.LeadEntity:update_visuals()
    local SCALE = 8;

    if self.current_length == self.old_length then
        return;
    end;
    self.old_length = self.current_length;

    local properties = {visual_size = vector.new(1, 1, self.current_length)};
    local selbox_offset = 0;
    -- Dynamic textures:
    if leads.settings.dynamic_textures then
        local texture = leads.util.tile_texture(self.texture, 96 * SCALE, 2 * SCALE, math.floor(self.current_length * 16 * SCALE), 2 * SCALE);
        properties.textures = {texture};
    elseif self.texture ~= self.old_texture then
        self.old_texture = self.texture;
        properties.textures = {self.texture};
    end;
    -- Slack model:
    if leads.settings.enable_slack then
        if self.leader_pos and self.follower_pos then
            local slack, mesh = self:get_slack();
            properties.mesh = mesh;
            selbox_offset = selbox_offset - slack / 12;
        end;
    end;
    -- Selection box:
    if leads.settings.rotate_selection_box then
        properties.selectionbox = {-0.0625, -0.0625 + selbox_offset, -self.current_length / 2,
                                    0.0625,  0.0625 + selbox_offset,  self.current_length / 2, rotate = true};
    end;
    self.object:set_properties(properties);
    self.object:set_rotation(self.rotation);
end;

--- Calculates the slack value and chooses a model to represent it.
-- @return [number] The current slack value.
-- @return [string] A model name.
function leads.LeadEntity:get_slack()
    local span = self.follower_pos - self.leader_pos;
    local slack = 0.5 + 1 - span:length() / self.max_length;

    -- Scale the slack by how horizontal the lead is, otherwise it would droop sideways when vertical.
    slack = slack * (1 - math.abs(span:normalize().y));

    slack = leads.util.clamp(slack, 0.0, 1.0)
    local model_index = math.floor(slack * #leads.SLACK_MODELS);
    return slack, leads.SLACK_MODELS[model_index];
end;

--- Updates the connector IDs to reflect the current connectors.
function leads.LeadEntity:update_objref_ids()
    self.leader_id   = leads.util.serialise_objref(self.leader)   or self.leader_id;
    self.follower_id = leads.util.serialise_objref(self.follower) or self.follower_id;
    self:update_attach_offsets();
end;

--- Updates the attachment offsets to reflect the current connectors' properties.
function leads.LeadEntity:update_attach_offsets()
    self.leader_attach_offset   = leads.util.get_attach_offset(self.leader)   or self.leader_attach_offset;
    self.follower_attach_offset = leads.util.get_attach_offset(self.follower) or self.follower_attach_offset;
end;

--- Transfers this lead to a new leader.
-- @param leader [ObjectRef] The new leader object.
-- @return       [boolean]   true on success.
function leads.LeadEntity:set_leader(leader)
    return self:set_connector(leader, true);
end;

--- Transfers this lead to a new follower.
-- @param follower [ObjectRef] The new follower object.
-- @return         [boolean]   true on success.
function leads.LeadEntity:set_follower(follower)
    return self:set_connector(follower, false);
end;

--- Transfers this lead to a new leader or follower.
-- @param object    [ObjectRef] The new connector.
-- @param is_leader [boolean]   true to set the leader, false to set the follower.
-- @return          [boolean]   true on success.
function leads.LeadEntity:set_connector(object, is_leader)
    if (self.leader   and leads.util.is_same_object(object, self.leader)) or
       (self.follower and leads.util.is_same_object(object, self.follower)) then
        return false;
    end;

    local key = is_leader and 'leader' or 'follower';
    local old_object = self[key];
    self:notify_connector_removed(old_object, is_leader);
    self[key] = object;
    self:notify_connector_added(object, is_leader);
    self:update_objref_ids();
    return true;
end;

--- Reverses the direction of the lead, swapping the leader and follower.
function leads.LeadEntity:reverse()
    self.leader,    self.follower    = self.follower,    self.leader;
    self.leader_id, self.follower_id = self.follower_id, self.leader_id;
end;

--- Notifies the connector that this lead has been added.
-- @param object    [ObjectRef|nil] The connector to notify.
-- @param is_leader [boolean]       true if the connector is the leader.
function leads.LeadEntity:notify_connector_added(object, is_leader)
    if not object then
        return;
    end;

    leads.leads_by_connector[object][self.object] = true;

    local entity = object:get_luaentity();
    if entity and entity._leads_lead_add then
        entity:_leads_lead_add(self, is_leader or false);
    end;
end;

--- Notifies the connector that this lead has been removed.
-- @param object    [ObjectRef|nil] The connector to notify.
-- @param is_leader [boolean]       true if the connector was the leader.
function leads.LeadEntity:notify_connector_removed(object, is_leader)
    if not object then
        return;
    end;

    leads.leads_by_connector[object][self.object] = nil;

    local entity = object:get_luaentity();
    if entity and entity._leads_lead_remove then
        entity:_leads_lead_remove(self, is_leader or false);
    end;
end;

--- Gets the lead's leader if it's loaded.
-- @return [ObjectRef|nil] The leader object.
function leads.LeadEntity:get_leader()
    if self.leader and self.leader:get_pos() then
        return self.leader;
    end;
    return nil;
end;

--- Gets the lead's follower if it's loaded.
-- @return [ObjectRef|nil] The follower object.
function leads.LeadEntity:get_follower()
    if self.leader and self.follower:get_pos() then
        return self.follower;
    end;
    return nil;
end;

core.register_entity('leads:lead', leads.LeadEntity);

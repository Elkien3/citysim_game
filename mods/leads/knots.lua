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


--- Knot entity definition.
-- @module knots


local S = leads.S;


--- Ties a lead to a post.
-- @type KnotEntity
leads.KnotEntity = {};

leads.KnotEntity.description = S'Lead Knot';
leads.KnotEntity._leads_immobile  = true;
leads.KnotEntity._leads_leashable = true;

leads.KnotEntity.initial_properties =
{
    visual          = 'mesh';
    visual_size     = vector.new(10, 10, 10);
    mesh            = 'leads_lead_knot.obj';
    textures        = {'leads_lead_knot.png'};
    physical        = false;
    selectionbox    = {-3/16, -4/16, -3/16, 3/16, 4/16, 3/16};
};

--- Spawns or loads a knot.
function leads.KnotEntity:on_activate(staticdata, dtime_s)
    self.num_connections = 0;

    local data = core.deserialize(staticdata);
    if data then
        self.num_connections = data.num_connections or 0;
    end;

    self.object:set_armor_groups{fleshy = 0};
end;

--- Steps the knot.
function leads.KnotEntity:on_step(dtime, moveresult)
    if self.num_connections <= 0 then
        self.object:remove();
        return;
    end;

    local node = core.get_node(self.object:get_pos());
    if not leads.is_knottable(node.name) then
        self.object:remove();
        return;
    end;
end;

--- Returns the knot's state as a table.
function leads.KnotEntity:get_staticdata()
    local data = {num_connections = self.num_connections};
    return core.serialize(data);
end;

--- Handles the knot being punched.
function leads.KnotEntity:on_punch(puncher, time_from_last_punch, tool_capabilities, dir, damage)
    -- Check protection:
    if leads.settings.respect_protection and core.is_player(puncher) and not core.check_player_privs(puncher, 'protection_bypass') then
        local pos = self.object:get_pos():round();
        local name = puncher and puncher:get_player_name() or '';
        if core.is_protected(pos, name) then
            core.record_protection_violation(pos, name);
            return true;
        end;
    end;

    -- Check if the puncher is holding Shift, and get a list of leads if necessary:
    local break_leads = puncher and puncher:get_player_control().sneak;
    local connected_leads;
    if break_leads then
        connected_leads = {};
        for lead in leads.find_connected_leads(self.object, true, true) do
            table.insert(connected_leads, lead);
        end;
    else
        core.sound_play(leads.sounds.remove, {pos = self.object:get_pos()}, true);
    end;

    -- Transfer all connected leads to the puncher:
    if puncher then
        self:transfer_leads(puncher);
    end;

    -- Remove leads if holding Shift:
    if break_leads then
        for __, lead in ipairs(connected_leads) do
            lead:get_luaentity():break_lead(puncher);
        end;
    end;

    -- Prevent the player from breaking the post:
    local name = puncher and puncher:get_player_name();
    if name and name ~= '' then
        leads.util.block_player_interaction(name, 0.25);
    end;

    -- Remove this knot:
    self.object:remove();
    return true;
end;

--- Handles the knot being right-clicked.
function leads.KnotEntity:on_rightclick(clicker)
    local pos = self.object:get_pos();
    leads.knot(clicker, pos);
end;

--- Handles the knot being interacted with while holding a lead item.
function leads.KnotEntity:_leads_on_interact(itemstack, user, pointed_thing, is_punch)
    if is_punch then
        self:on_punch(user);
        return true, nil;
    end;
    return false, nil;
end;

--- Transfers all leads attached to this knot to another object.
-- @param leader [ObjectRef] The new leader.
function leads.KnotEntity:transfer_leads(leader)
    for lead, is_leader in leads.find_connected_leads(self.object, true, true) do
        local entity = lead:get_luaentity();
        if not is_leader then
            entity:reverse();
        end;
        entity:set_leader(leader);
    end;
end;

--- Called when a lead is added.
function leads.KnotEntity:_leads_lead_add(lead, is_leader)
    self.num_connections = self.num_connections + 1;
end;

--- Called when a lead is removed.
function leads.KnotEntity:_leads_lead_remove(lead, is_leader)
    self.num_connections = self.num_connections - 1;
end;

core.register_entity('leads:knot', leads.KnotEntity);

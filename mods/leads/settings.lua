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


--- Mod settings.
-- @module settings


local function get_n(key, default)
    return tonumber(core.settings:get(key)) or default;
end;

local function get_b(key, default)
    return core.settings:get_bool(key, default);
end;

local function get_s(key, default)
    return core.settings:get(key) or default;
end;


--- Mod settings.
leads.settings =
{
    lead_length             = get_n('leads.lead_length',                8);
    lead_strength           = get_n('leads.lead_strength',              4);
    chat_messages           = get_b('leads.chat_messages',              false);
    drop_mode               = get_s('leads.drop_mode',                  'auto');
    symmetrical             = get_b('leads.symmetrical',                false);
    -- Visuals:
    dynamic_textures        = get_b('leads.dynamic_textures',           true);
    rotate_selection_box    = get_b('leads.rotate_selection_box',       true);
    enable_slack            = get_b('leads.enable_slack',               true);
    -- Protection and ownership:
    respect_protection      = get_b('leads.respect_protection',         true);
    allow_leash_unowned     = get_b('leads.allow_leash_unowned',        true);
    allow_leash_owned_other = get_b('leads.allow_leash_owned_other',    true);
    -- Object types:
    allow_leash_player      = get_b('leads.allow_leash_player',         true);
    allow_leash_animal      = get_b('leads.allow_leash_animal',         true);
    allow_leash_monster     = get_b('leads.allow_leash_monster',        true);
    allow_leash_npc         = get_b('leads.allow_leash_npc',            true);
    allow_leash_vehicle     = get_b('leads.allow_leash_vehicle',        true);
    allow_leash_other       = get_b('leads.allow_leash_other',          true);
    -- Advanced:
    allow_leash_all         = get_b('leads.allow_leash_all',            false);
    pull_force              = get_n('leads.pull_force',                 15);
    debug                   = get_b('leads.debug',                      false);
};

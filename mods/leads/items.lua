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


--- Item definitions.
-- @module items


local S = leads.S;


core.register_craftitem('leads:lead',
{
    description          = S'Lead';
    inventory_image      = 'leads_lead_inv.png';
    groups               = {leads_lead = 1};
    on_use               = leads.on_lead_punch;
    on_secondary_use     = leads.on_lead_use;
    on_place             = leads.on_lead_use;
    _leads_length        = leads.settings.lead_length;
    _leads_texture       = leads.DEFAULT_LEAD_TEXTURE;
    _doc_items_longdesc  = S'Leads can be used for moving and tethering animals. They can also be attached between two fences for decoration.';
    _doc_items_usagehelp = S'Right-click on an animal or fence to attach a lead. Punch the lead to release it, or right-click on a fence to tether it.';
});


local rope = leads.util.first_available_item('xdecor:rope', 'farming:string', 'mcl_mobitems:string', 'rp_default:rope', 'hades_farming:cotton', 'nodes_nature:chalin');
local glue = leads.util.first_available_item('mesecons_materials:glue', 'mcl_mobitems:slimeball', 'mobs_mc:slimeball', 'rp_default:fiber')              or rope;
core.register_craft(
{
    output = 'leads:lead';
    recipe =
    {
        {'xdecor:rope', 'xdecor:rope', ''},
        {'xdecor:rope', glue, ''},
        {'',   '', 'xdecor:rope'},
    };
});


if core.get_modpath('doc_identifier') then
    doc.sub.identifier.register_object('leads:lead', 'craftitems', 'leads:lead');
    doc.sub.identifier.register_object('leads:knot', 'craftitems', 'leads:lead');
end;

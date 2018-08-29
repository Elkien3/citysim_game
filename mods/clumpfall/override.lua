--[[
   Copyright 2018 Noodlemire

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
--]]

local blacklist = {"walking_light:light", "technic:light"}

clumpfall.override = {} --global override variable

--[[
Description:
    Overrides the on_dig event of the given node in such a way that it adds the provided function to on_dig, without deleting the old on_dig method
Parameters:
    nodename: The internal name of the node that will be overridden
    new_on_dig: The name of the function that will be called in addition to nodename's usual on_dig event
Returns: 
    Nothing
--]]
function clumpfall.override.add_dig_event(nodename, new_on_dig)
    --Store the old on_dig event for later use
    local old_on_dig = minetest.registered_nodes[nodename].on_dig
    --Create a function that calls both the old and new on_dig methods
    local master_on_dig = function(pos, node, player)
        --Call the old on_dig function if there is one set
        if old_on_dig ~= nil then 
            old_on_dig(pos, node, player)
        end

        --Then, call the new on_punch method
        new_on_dig(pos, node, player)
    end

    --Override the given node with the combination of old and new on_dig functions
	if blacklist[nodename] == nil then
		minetest.override_item(nodename, {on_dig = master_on_dig})
	end
end

--[[
Description:
    Overrides the after_place_node event of the given node in such a way that it adds the provided function to after_place_node, without deleting the old after_place_node method
Parameters:
    nodename: The internal name of the node that will be overridden
    new_after_place: The name of the function that will be called in addition to nodename's usual after_place_node event
Returns: 
    Nothing
--]]
function clumpfall.override.add_after_place_event(nodename, new_after_place)
    --Store the old after_place_node event for later use
    local old_after_place = minetest.registered_nodes[nodename].after_place_node
    --Create a function that calls both the old and new after_place_node methods
    local master_after_place = function(pos, itemstack, placer, pointed_thing)
        --Call the old after_place_node function if there is one set
        if old_after_place ~= nil then 
            old_after_place(pos, itemstack, placer, pointed_thing)
        end

        --Then, call the new on_punch method
        new_after_place(pos, itemstack, placer, pointed_thing)
    end

    --Override the given node with the combination of old and new after_place_node functions
    minetest.override_item(nodename, {after_place_node = master_after_place})
end

--[[
Description:
    Overrides the on_punch event of the given node in such a way that it adds the provided function to on_punch, without deleting the old on_punch method
Parameters:
    nodename: The internal name of the node that will be overridden
    new_on_punch: The name of the function that will be called in addition to nodename's usual on_punch event
Returns: 
    Nothing
--]]
function clumpfall.override.add_punch_event(nodename, new_on_punch)
    --Store the old on_punch event for later use
    local old_on_punch = minetest.registered_nodes[nodename].on_punch
    --Create a function that calls both the old and new on_punch methods
    local master_on_punch = function(pos, node, player, pointed_thing)
        --Call the old on_punch function if there is one set
        if old_on_punch ~= nil then 
            old_on_punch(pos, node, player, pointed_thing)
        end

        --Then, call the new on_punch method
        new_on_punch(pos, node, player, pointed_thing)
    end

    --Override the given node with the combination of old and new on_punch functions
    minetest.override_item(nodename, {on_punch = master_on_punch})
end

--[[
Description:
    Add a punch event to beds so that if a player punches a half bed, that bed will instantly spawn its other half in the event that said other half doesn't exist, or it will destroy itself if it is unable to spawn its other half
Parameters:
    bed_to_override: The name of the bed half to make fixable via punching
Returns: 
    Nothing
--]]
function clumpfall.override.bed_update_on_punch(bed_to_override)
    clumpfall.override.add_punch_event(bed_to_override, 
    function(pos, node)
        --If this is indeed a bed being affected and it doens't need to clump fall instead, then
        if clumpfall.functions.check_individual_for_fall(pos) == false and minetest.get_item_group(node.name, "bed") ~= 0 then
            --Create local variables to store the bed's name without _top or _bottom at the end, the suffix of its other half, and the position of its other half
            local base_node_name
            local other_suffix
            local other_pos

            --If this half's name ends in "_bottom", then
            if node.name:sub(#node.name - #"bottom", #node.name) == "_bottom" then
                --The other half must be the top half, so update variables accordingly.
                base_node_name = node.name:sub(1, #node.name - #"_bottom")
                other_suffix = "_top"
                other_pos = vector.add(pos, minetest.facedir_to_dir(node.param2))
            else
                --Otherwise, the other half is the bottom half.
                base_node_name = node.name:sub(1, #node.name - #"_top")
                other_suffix = "_bottom"
                other_pos = vector.subtract(pos, minetest.facedir_to_dir(node.param2))
            end

            --If the name of the node at the other half's position is not actually the name of the other half or that other half is turned incorrectly, then...
            if minetest.get_node(other_pos).name ~= base_node_name..other_suffix or minetest.get_node(other_pos).param2 ~= node.param2 then
                --Check if the other half is simply missing by seeing it the node at the other half's position is walkable.
                if minetest.registered_nodes[minetest.get_node(other_pos).name].walkable == false then
                    --If not, spawn the other half with the correct position and direction
                    minetest.set_node(other_pos, {name = base_node_name..other_suffix, param2 = node.param2})
                else
                    --Otherwise, replace this bed half with air and spawn it as an item
                    minetest.set_node(pos, {name = "air"})
                    minetest.spawn_item(pos, base_node_name.."_bottom")
                end
            end
        end
    end)
end

--[[
Description:
    Completely override the on_destruct method of a given bed with a fixed version of the destruct_bed function
Parameters:
    bed_name: The name of the bed half to override
Returns: 
    Nothing
--]]
function clumpfall.override.set_fix_destruct_bed(bed_name)
    --Stores a number reporesenting which half of a bed this is
    local bed_half

    --If this bed half's name ends in _bottom, 
    if bed_name:sub(#bed_name - #"bottom", #bed_name) == "_bottom" then
        --Set bed_half = 1.
        bed_half = 1
    else
        --Otherwise, this is half 2.
        bed_half = 2
    end

    --Override the on_dustruct of the node known by the given name
    minetest.override_item(bed_name, 
    {
        on_destruct = function(pos)
            --Call the fixed destruct_bed at on_destruct's postion and the value of bed_half
	        clumpfall.override.fix_destruct_bed(pos, bed_half)
            --Just in case there was only one bed punched, reset reverse to false afterwards
            reverse = false
        end
    })
end

--[[
Description:
    Destroy a bed in such a way that the other half will also be destroyed, but only if that other half actually exists and this half hasn't already been destroyed
Parameters:
    pos: The position of the bed half to destroy
    n: A number representing which half of the bed is currently being destoryed
Returns: 
    Nothing
--]]
--reverse: global variable that defaults to false, and is used in determining if the other bed half should be destroyed
reverse = false
function clumpfall.override.fix_destruct_bed(pos, n)
    --Store the node at the given position
	local node = minetest.get_node(pos)
    --Will be used to store the position of the other bed half
	local other

    --Based on n and this node's param2 (direction), get the other half's postion
	if n == 2 then
		local dir = minetest.facedir_to_dir(node.param2)
		other = vector.subtract(pos, dir)
	elseif n == 1 then
		local dir = minetest.facedir_to_dir(node.param2)
		other = vector.add(pos, dir)
	end

    --Flip the value inside of reverse. If reverse was false before, it is true now and this bed will destroy the other half. If not, this half will do nothing more.
    reverse = not reverse

    --If the other half is indeed a bed, it is this bed's other half (and not the other half of a completely different bed), and reverse is true, then
	if minetest.get_item_group(minetest.get_node(other).name, "bed") ~= 0 and minetest.get_node(other).param2 == node.param2 and reverse then
        --Delete the other node without spawning an item; this will call the entirety of that bed half's on_destruct before reverse is automatically reset to false
		minetest.remove_node(other)
        --Use the helper function check_for_falling to update nodes near the other half
		minetest.check_for_falling(other)
	end
end


--[[
Description: 
    Overrides falling_node entities with an on_step method that has one key difference compared to usual: when it lands, it calls on_place to prevent glitches
Parameters: 
    None
Returns: 
    Nothing
--]]
function clumpfall.override.fix_falling_nodes()
    entitycontrol.override_entity("__builtin:falling_node", 
    {
        on_step = function(self, dtime)
            -- Set gravity
            local acceleration = self.object:getacceleration()
            if not vector.equals(acceleration, {x = 0, y = -10, z = 0}) then
                self.object:setacceleration({x = 0, y = -10, z = 0})
            end
            -- Turn to actual node when colliding with ground, or continue to move
            local pos = self.object:getpos()
            -- Position of bottom center point
            local bcp = {x = pos.x, y = pos.y - 0.7, z = pos.z}
            -- Avoid bugs caused by an unloaded node below
            local bcn = minetest.get_node_or_nil(bcp)
            local bcd = bcn and minetest.registered_nodes[bcn.name]
            if bcn and
	                (not bcd or bcd.walkable or
	                (minetest.get_item_group(self.node.name, "float") ~= 0 and
	                bcd.liquidtype ~= "none")) then
                if bcd and bcd.leveled and
		                bcn.name == self.node.name then
	                local addlevel = self.node.level
	                if not addlevel or addlevel <= 0 then
		                addlevel = bcd.leveled
	                end
	                if minetest.add_node_level(bcp, addlevel) == 0 then
		                self.object:remove()
		                return
	                end
                elseif bcd and bcd.buildable_to and
		                (minetest.get_item_group(self.node.name, "float") == 0 or
		                bcd.liquidtype == "none") then
	                minetest.remove_node(bcp)
	                return
                end
                local np = {x = bcp.x, y = bcp.y + 1, z = bcp.z}
                -- Check what's here
                local n2 = minetest.get_node(np)
                local nd = minetest.registered_nodes[n2.name]
                -- If it's not air or liquid, remove node and replace it with
                -- it's drops
                if n2.name ~= "air" and (not nd or nd.liquidtype == "none") then
	                minetest.remove_node(np)
	                if nd and nd.buildable_to == false then
		                -- Add dropped items
		                local drops = minetest.get_node_drops(n2.name, "")
		                for _, dropped_item in pairs(drops) do
			                minetest.add_item(np, dropped_item)
		                end
	                end
	                -- Run script hook
	                for _, callback in pairs(minetest.registered_on_dignodes) do
		                callback(np, n2)
	                end
                end
                -- Create node and remove entity
                if minetest.registered_nodes[self.node.name] then
                    --This is what's different from the norm; after setting the node, it punches the node. This updates the node without issues caused by calling on_place without any actual player that placed the node
	                minetest.set_node(np, self.node)
                    minetest.punch_node(np)
	                if self.meta then
		                local meta = minetest.get_meta(np)
		                meta:from_table(self.meta)
	                end
                end
                self.object:remove()
                minetest.check_for_falling(np)
                return
            end
            local vel = self.object:getvelocity()
            if vector.equals(vel, {x = 0, y = 0, z = 0}) then
                local npos = self.object:getpos()
                self.object:setpos(vector.round(npos))
            end
        end
    })
end

--[[
Description:
    This function iterates through every registered node, including those that were registered by other mods, and turns ones that don't already fall by themselves and aren't unbreakable into clump_fall_nodes
Parameters:
    None
Returns:
    Nothing
--]]
function clumpfall.override.make_nodes_fallable()
    --Inspect each registered node, one at a time
    for nodename, nodereal in pairs(minetest.registered_nodes) do
        --create a temporary list of the current node's groups
        local temp_node_group_list = nodereal.groups

        --Ensure that the nodes being modified aren't the placeholder block types that tecnically don't exist
        if nodename ~= "air" and nodename ~= "ignore" and 
                minetest.get_item_group(nodename, "falling_node") == 0 and --Don't need to affect nodes that already fall by themselves
                minetest.get_item_group(nodename, "attached_node") == 0 and --Same thing for nodes in this group, which fall when no longer attached to another node
                minetest.get_item_group(nodename, "liquid") == 0 and --Same thing for nodes in this group, which do technically fall and spread around
                minetest.get_item_group(nodename, "unbreakable") == 0 then --Lastly, if a block is invulnerable to begin with, it shouldn't fall down like a typical node
            --Initialize a new group variable in the temp list known as "clump_fall_node" as 1
            temp_node_group_list.clump_fall_node = 1
            --Override the node's previous group list with the one that includes the new clump_fall_node group
            minetest.override_item(nodename, {groups = temp_node_group_list})
        else
            --For the rest, ensure that clump_fall_node is set to 0 and properly initialized
            temp_node_group_list.clump_fall_node = 0
            --Override the node's previous group list with the one that includes the new clump_fall_node group
            minetest.override_item(nodename, {groups = temp_node_group_list})
        end

        if minetest.get_item_group(nodename, "bed") ~= 0 then
            clumpfall.override.bed_update_on_punch(nodename)
            clumpfall.override.set_fix_destruct_bed(nodename)
        end
    end
end

--[[
Description:
    Overrides the on_dig, after_place_node, and on_punch events of all registered nodes in such a way that it adds the provided function to on_dig, on_place and on_punch, without deleting any old methods
Parameters:
    new_on_event: The name of the function that will be called in addition whenever a node is punched, placed, or dug up
Returns: 
    Nothing
--]]
function clumpfall.override.register_add_on_digplacepunchnode(new_on_event)
    --For every registered node,
    for nodename, nodereal in pairs(minetest.registered_nodes) do
        --Add the given new_on_event to each node's on_dig, after_place_node, and on_punch events
        clumpfall.override.add_dig_event(nodename, new_on_event)
        clumpfall.override.add_after_place_event(nodename, new_on_event)
        clumpfall.override.add_punch_event(nodename, new_on_event)
    end
end

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

clumpfall.functions = {} --global functions variable

--[[
Description: 
    Searches for clump_fall_nodes within a given volume of radius clump_radius and all of the center points between the 3D points given by the parameters. 
Parameters: 
    Two 3D vectors; the first is the smaller, and the second is the larger. These are the two corners of the volume to be searched through. Note that clump_radius is added on to these min and max points, so keep that in mind in relation to the size of the volume that is actually effected by this function.
Returns:
    A table containing the positions of all clump_fall_nodes found
--]]
function clumpfall.functions.check_group_for_fall(min_pos, max_pos)
    --Local created to temporarily store clump_fall_nodes that should fall down
    local nodes_that_can_fall = {}

    --iterates through the entire cubic volume contained between the minimum and maximum positions
    for t = min_pos.z - clumpfall.clump_radius, max_pos.z + clumpfall.clump_radius do
        for n = min_pos.y - clumpfall.clump_radius, max_pos.y + clumpfall.clump_radius do
            for i = min_pos.x - clumpfall.clump_radius, max_pos.x + clumpfall.clump_radius do
                --Creates a 3D vector to store the position that is currently being inspected
                local check_this = {x=i, y=n, z=t}

                --If at least one clump_fall_node was found underneath, nothing else will happen. If none are found, the current position will be placed within the table nodes_that_can_fall. Also won't make a node fall if any walkable node is directly underneath, even if that node is not a clump_fall_node
                if clumpfall.functions.check_individual_for_fall(check_this) then
                    table.insert(nodes_that_can_fall, check_this)
                end
            end
        end
    end
    
    --Once all this looping is complete, the list of nodes that can fall is complete and can be returned.
    return nodes_that_can_fall
end

--[[
Description:
    Checks a 3x3 area under the given pos for clump fall nodes that can be used as supports, and for a non-clump walkable node
Parameters:
    check_pos: The 3D Vector {x=?, y=?, z=?} as the location in which to check
Returns:
    true if none of the described supports are found, false is supports are found, nothing if this isn't a clump fall node being checked
--]]
function clumpfall.functions.check_individual_for_fall(check_pos)
    --If the position currently being checked belongs to the clump_fall_node group, then
    if minetest.get_item_group(minetest.get_node(check_pos).name, "clump_fall_node") ~= 0 then
        --First create a variable that assumes that there are no clump_fall_nodes underneath the current position
        local has_bottom_support = false
        local walkable_node_underneath = false

        --This then checks each node under the current position within a 3x3 area for blocks within the clump_fall_node group
        for b = check_pos.z - 1, check_pos.z + 1 do
            for a = check_pos.x - 1, check_pos.x + 1 do
                local bottom_pos = {x=a, y=check_pos.y-1, z=b}
                --As long as at least a single node belongs to the clump_fall_node group, has_bottom_support will be set to true.
                if minetest.get_item_group(minetest.get_node(bottom_pos).name, "clump_fall_node") ~= 0 then
                    has_bottom_support = true
                end
            end
        end

        --If no registered node underneath the node being checked is walkable, then set walkable_node_underneath to true
        if minetest.registered_nodes[minetest.get_node({x=check_pos.x, y=check_pos.y-1, z=check_pos.z}).name].walkable == true then
            walkable_node_underneath = true
        end
        
        --Return true only if the node checked is 100% able to fall
        return has_bottom_support == false and walkable_node_underneath == false
    end
end

--[[
Description: 
    Initiate a clump fall that starts within the given 3D points, and if needed, will cascade farther until there is nothing left in the area that can fall
Parameters: 
    Any number of 3D vectors of which to draw a cubic volume around. This volume will be the starting point for this clump fall
Returns: 
    Nothing
--]]
function clumpfall.functions.do_clump_fall(...)
    --Used to store an array version of the arguments
    local arg_array = ({...})[1]
    --Used to store an array version of the arguments once they are standardized
    local node_pos_to_check = {}
    
    --This check is needed to properly standardize the arguments. Without it, results of this function would be needlessly inconsistant.
    if type(arg_array[1]) ~= "table" then
        node_pos_to_check = {arg_array}
    else 
        node_pos_to_check = arg_array
    end

    --List of postions of nodes that check_group_for_fall() found to need falling
    local node_pos_to_fall = {}
    --Variable that assumes that no nodes needed to fall
    local found_no_fallable_nodes = true
    --Stores the largest x, y, and z values out of the 3D vertices given by the arguments
    local max_pos = {x, y, z}
    --Stores the smallest x, y, and z values out of the 3D vertices given by the arguments
    local min_pos = {x, y, z}
    --To be used later in this function, this stores the largest x, y, and z values of nodes that were actually found to need falling.
    local new_max_pos = {x, y, z}
    --To be used later in this function, this stores the smallest x, y, and z values of nodes that were actually found to need falling.
    local new_min_pos = {x, y, z}

    --Compares max_pos and min_pos to the list of arguments, and individually sets the x, y, and z values of each to, respectively, the largest/smallest x/y/z values
    for v, pos_find_minmax in pairs(node_pos_to_check) do
        if max_pos.x == nil or max_pos.x < pos_find_minmax.x then
            max_pos.x = pos_find_minmax.x
        end
        if max_pos.y == nil or max_pos.y < pos_find_minmax.y then
            max_pos.y = pos_find_minmax.y
        end
        if max_pos.z == nil or max_pos.z < pos_find_minmax.z then
            max_pos.z = pos_find_minmax.z
        end
        if min_pos.x == nil or min_pos.x > pos_find_minmax.x then
            min_pos.x = pos_find_minmax.x
        end
        if min_pos.y == nil or min_pos.y > pos_find_minmax.y then
            min_pos.y = pos_find_minmax.y
        end
        if min_pos.z == nil or min_pos.z > pos_find_minmax.z then
            min_pos.z = pos_find_minmax.z
        end
    end

    --Now that min_pos and max_pos have been calculated, they can be used to find fallable nodes
    node_pos_to_fall = clumpfall.functions.check_group_for_fall(min_pos, max_pos)

    --Next, iterate through each of the newfound clump_fall_node positions, if any...
    for v,pos_fall in pairs(node_pos_to_fall) do
        --Used to store the node at the current position
        local node_fall = minetest.get_node(pos_fall)

        --Make one more check in case the node at the current postion already fell or has otherwise been replaced
        if minetest.get_item_group(node_fall.name, "clump_fall_node") ~= 0 then 
            --Finally, a falling_node is placed at the current position just as the node that used to be here is removed
            minetest.remove_node(pos_fall)
            clumpfall.functions.spawn_falling_node(pos_fall, node_fall)

            --Update nearby nodes to stop blocks in the falling_node and attached_node groups from floating
            clumpfall.functions.update_nearby_nonclump(pos_fall)
            --Since a node has truly been found that needed to fall, found_no_fallable_nodes can be set to false
            found_no_fallable_nodes = false

            --Compares new_max_pos and new_min_pos to the location of each falling node, and individually sets the x, y, and z values of each to, respectively, the largest/smallest x/y/z values
            if new_max_pos.x == nil or new_max_pos.x < pos_fall.x then
                new_max_pos.x = pos_fall.x
            end
            if new_max_pos.y == nil or new_max_pos.y < pos_fall.y then
                new_max_pos.y = pos_fall.y
            end
            if new_max_pos.z == nil or new_max_pos.z < pos_fall.z then
                new_max_pos.z = pos_fall.z
            end
            if new_min_pos.x == nil or new_min_pos.x > pos_fall.x then
                new_min_pos.x = pos_fall.x
            end
            if new_min_pos.y == nil or new_min_pos.y > pos_fall.y then
                new_min_pos.y = pos_fall.y
            end
            if new_min_pos.z == nil or new_min_pos.z > pos_fall.z then
                new_min_pos.z = pos_fall.z
            end
        end
    end

    --If nodes were found that need to fall in the next round of cascading, loop by calling this very method after 1 second of in-game time passes
    if found_no_fallable_nodes == false then
        --This will be used with the new min and max position that have been found. 
        --These are used instead of the old ones so that the range of cascading can't expand indefinitely and cause crashes
        minetest.after(1, clumpfall.functions.do_clump_fall, {new_min_pos, new_max_pos})
    end
end

--[[
Description:
    Spawn a falling_node version of the given node with the given metadata
Parameters:
    pos: The postion to spawn the falling_node
    node: The node itself to imitate (NOT its name or location)
Returns:
    Nothing
--]]
function clumpfall.functions.spawn_falling_node(pos, node)
    --Gets the metadata of the node at the current position
    local meta = minetest.get_meta(pos)
    --Will be used to store any metadata in a table
    local metatable = {}

    --If there is any metadata, then
    if meta ~= nil then
        --Convert that metadata to a table and store it in metatable
		metatable = meta:to_table()
	end

    --Create a __builtin:falling_node entity and add it to minetest
    local entity_fall = minetest.add_entity(pos, "__builtin:falling_node")
    --If successful, then
    if entity_fall then
        --Set its nodetype and metadata to the given arguments node and meta, respectively
        entity_fall:get_luaentity():set_node(node, metatable)
    end
end

--[[
Description: 
    Checks the position for any falling nodes or attached nodes to call check_for_falling with, so that falling Clump Fall Nodes do not leave behind floating sand/gravel/plants/etc. The size of the volume checked is based on clump_radius.
Parameters: 
    pos as the 3D vector {x=?, y=?, z=?} of the position to check around
Returns: 
    Nothing
--]]
function clumpfall.functions.update_nearby_nonclump(pos)
    --Iterates through the entire cubic volume with radius clump_radius and pos as its center
    for t = pos.z - clumpfall.clump_radius, pos.z + clumpfall.clump_radius do
        for n = pos.y - clumpfall.clump_radius, pos.y + clumpfall.clump_radius do
            for i = pos.x - clumpfall.clump_radius, pos.x + clumpfall.clump_radius do
                --check_pos is used to store the point that is currently being checked.
                local check_pos = {x=i, y=n, z=t}
                --check_name is used to store the name of the node at check_pos
                local check_name = minetest.get_node(check_pos).name

                --If the node being checked doesn't belong to the falling_node or attached_node groups, then
                if minetest.get_item_group(check_name, "falling_node") ~= 0 or minetest.get_item_group(check_name, "attached_node") ~= 0 then
                    --Call the method check_for_falling which will cause those nodes to begin falling if nothing is underneath.
                    minetest.check_for_falling(check_pos)
                end
            end
        end
    end
end

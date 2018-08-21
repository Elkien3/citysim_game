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

entitycontrol = {} --global variable

--[[
Description:
    Alters the properties of the given entity according to the given parameters
Parameters:
    name: The name of the entity to alter.
    redefinition: A list of changes to apply to the given entity. The exact changes can be anything except for its name and type.
Returns:
    Nothing
--]]
function entitycontrol.override_entity(name, redefinition)
    --Stores the current definition of the entity that has the given name
    local entity_to_override = minetest.registered_entities[name]

    --Throw an error if the redefinition tries to rename an entity
    if redefinition.name ~= nil then
		error("Attempt to redefine name of "..name.." to "..dump(redefinition.name), 2)
	end

    --Throw an error if the redefinition tries to turn an entity into something that is not an entity
	if redefinition.type ~= nil then
		error("Attempt to redefine type of "..name.." to "..dump(redefinition.type), 2)
	end

    --Throw an error if there is no entity is known by the given name
	if not entity_to_override then
		error("Attempt to override non-existent item "..name, 2)
	end

    --For each given redefinition,
	for i, v in pairs(redefinition) do
        --Set the index i of the entity to override to value v
		rawset(entity_to_override, i, v)
	end

    --Once the entity has been fully overridden, it can be placed back into minetest's list of registered entities in order to finalize the changes.
	minetest.registered_entities[name] = entity_to_override
end

--[[
Description: 
    Removes a type of entity from minetest so that it will never be spawned again
Parameters: 
    name: The name of the entity to remove
Returns:
    Nothing
--]]
function entitycontrol.unregister_entity(name)
    --Stores the current definition of the entity that has the given name
    local entity_to_unregister = minetest.registered_entities[name]

    --If this definition does not exist, neither does the entity.
	if not entity_to_unregister then
        --Say so in the debug.txt
		minetest.log("warning", "Item " ..name.." already does not exist, so it will not be unregistered.")
        --And leave since there's nothing to do.
		return
	end

	--Otherwise, empty out the registration of the name of the entity to unregister.
	minetest.registered_entities[name] = nil
end


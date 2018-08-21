--[[
Copyright (c) 2015, Robert 'Bobby' Zenz
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]


--- Provides various utility methods for manipulating entities.
entityutil = {
	--- The name of builtin items.
	BUILTIN_ITEM_NAME = "__builtin:item"
}


--- Checks the given entity if it is a builtin item.
--
-- @param entity The entity to test.
-- @return true if the given entity is a builtin item.
function entityutil.is_builtin_item(entity)
	local lua_entity = entity:get_luaentity();
	
	return entity.name == entityutil.BUILTIN_ITEM_NAME
		or (lua_entity ~= nil
			and lua_entity.name == entityutil.BUILTIN_ITEM_NAME)
end

--- Moves the given entity towards the given point by setting its velocity into
-- the correct direction.
--
-- @param entity The entity to move, a LuaEntitySAO.
-- @param position The position to move the entity towards.
-- @param acceleration_x Optional. The acceleration to use in the x direction,
--                       defaults to 1.
-- @param acceleration_y Optional. The acceleration to use in the y direction,
--                       defaults to acceleration_x.
-- @param acceleration_z Optional. The acceleration to use in the x direction,
--                       defaults to acceleration_x.
function entityutil.move_to(entity, position, acceleration_x, acceleration_y, acceleration_z)
	acceleration_x = acceleration_x or 1
	acceleration_y = acceleration_y or acceleration_x
	acceleration_z = acceleration_z or acceleration_x
	
	local direction = vector.direction(entity:getpos(), position)
	local velocity = entity:getvelocity()
	
	velocity.x = velocity.x + (acceleration_x * direction.x)
	velocity.y = velocity.y + (acceleration_y * direction.y)
	velocity.z = velocity.z + (acceleration_z * direction.z)
	
	entity:setvelocity(velocity)
end


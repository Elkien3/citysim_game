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


--- Provides various extensions to the builtin functions.
minetestex = {
	node_drops_handlers = List:new(),
	original_node_drops_function = nil
}


--- The handler that is used for invoking the registered node drop functions.
--
-- @param position The position at which the drop occurred.
-- @param drops The drops that are being dropped, a list of ItemStacks.
-- @param player The player which the event originated at.
function minetestex.handle_node_drops(position, drops, player)
	local dropped_items = List:new()
	
	for index, drop in ipairs(drops) do
		dropped_items:add(ItemStack(drop))
	end
	
	local handled = false
	
	minetestex.node_drops_handlers:foreach(function(handler, index)
		handled = (handler(position, dropped_items, player, handled) == true)
	end)
	
	if not handled then
		minetestex.original_node_drops_function(position, drops, player)
	end
end

--- Initializes the node drops system. This is an internal function and should
-- not be called from clients.
function minetestex.init()
	minetestex.original_node_drops_function = minetest.handle_node_drops
	minetest.handle_node_drops = minetestex.handle_node_drops
end

--- Registers the given handler for node drops.
--
-- @param handler The handler function. The function is assumed to take four
--                parameters, the position at which the drops occurred,
--                the drops which are dropped as list if ItemStacks, the player
--                with which the even originated and if the event has been
--                handled so far or not. Can return a boolean if the event
--                has been handled. The handled flag is used to indicate
--                wether the builtin functionality should be invoked or not.
--                That means that if the last handler returns true, the items
--                will not be added to the players inventory by default. By
--                default the handler should return the given handled parameter
--                to not change the state or return the desired state.
function minetestex.register_on_nodedrops(handler)
	minetestex.node_drops_handlers:add(handler)
end


-- Initialize everything.
minetestex.init()


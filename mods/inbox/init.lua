minetest.register_alias("protector:mailbox", "inbox:empty")

local inbox = {}

-- Boilerplate to support localized strings if intllib mod is installed.
local S
if intllib then
  S = intllib.Getter()
else
  S = function(s) return s end
end

--[[
TODO
* Different node_box and texture for empty mailbox
]]

minetest.register_craft({
  output ="inbox:empty 4",
  recipe = {
    {"","default:steel_ingot",""},
    {"default:steel_ingot","","default:steel_ingot"},
    {"default:steel_ingot","default:steel_ingot","default:steel_ingot"}
  }
})

minetest.register_node("inbox:empty", {
  paramtype = "light",
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-4/12, -6/12, -6/12, 4/12, 0/12, 6/12},
      {-3/12, 0/12, -6/12, 3/12, 2/12, 6/12},
      {3/12, -1/12, -4/12, 4.5/12, 1/12, 3/12},
      {3/12, -2/12, 1/12, 4.5/12, 1/12, 3/12}
    }
  },
  description = S("Mailbox"),
  tiles = {"inbox_top_empty.png", "inbox_bottom_empty.png", "inbox_east_empty.png",
    "inbox_west_empty.png", "inbox_back_empty.png", "inbox_front_empty.png"},
  paramtype2 = "facedir",
  groups = {choppy=2,oddly_breakable_by_hand=2},
  sounds = default.node_sound_wood_defaults(),
  after_place_node = function(pos, placer, itemstack)
    local meta = minetest.get_meta(pos)
    local owner = placer:get_player_name()
    meta:set_string("owner", owner)
    meta:set_string("infotext", S("%s's Mailbox"):format(owner))
    local inv = meta:get_inventory()
    inv:set_size("main", 8*4)
    inv:set_size("drop", 1)
  end,
  on_rightclick = function(pos, node, clicker, itemstack)
    local meta = minetest.get_meta(pos)
    local player = clicker:get_player_name()
    local owner  = meta:get_string("owner")
    if owner == player or owner == "" then
      minetest.show_formspec(
        player,
        "default:chest_locked",
        inbox.get_inbox_formspec(pos))
    else
      minetest.show_formspec(
        player,
        "default:chest_locked",
        inbox.get_inbox_insert_formspec(pos))
    end
  end,
  can_dig = function(pos,player)
    local meta = minetest.get_meta(pos);
    local owner = meta:get_string("owner")
    local inv = meta:get_inventory()
    return (player:get_player_name() == owner or owner == "") and inv:is_empty("main")
  end,
  on_metadata_inventory_put = function(pos, listname, index, stack, player)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if listname == "drop" and inv:room_for_item("main", stack) then
      inv:remove_item("drop", stack)
      inv:add_item("main", stack)
	  local node = minetest.get_node(pos)
	  minetest.swap_node(pos,
						{ name="inbox:full",
						param2 = node.param2 })
    end
  end,
  allow_metadata_inventory_put = function(pos, listname, index, stack, player)
    if listname == "main" then
      return 0
    end
    if listname == "drop" then
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      if inv:room_for_item("main", stack) then
        return -1
      else
        return 0
      end
    end
  end,
  allow_metadata_inventory_take = function(pos, listname, index, stack, player)
    local meta = minetest.get_meta(pos)
    local owner = meta:get_string("owner")
    if player:get_player_name() ~= owner and owner ~= "" then
      return 0
    end
    return stack:get_count()
  end,
  allow_metadata_inventory_move = function(pos)
    return 0
  end,
})

minetest.register_node("inbox:full", {
  paramtype = "light",
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-4/12, -6/12, -6/12, 4/12, 0/12, 6/12},
      {-3/12, 0/12, -6/12, 3/12, 2/12, 6/12},
      {3/12, 0/12, -4/12, 4/12, 5/12, -2/12},
      {3/12, 3/12, -2/12, 4/12, 5/12, 0/12}
    }
  },
  description = S("Mailbox"),
  tiles = {"inbox_top_full.png", "inbox_bottom_full.png", "inbox_east_full.png",
    "inbox_west_full.png", "inbox_back_full.png", "inbox_front_full.png"},
  paramtype2 = "facedir",
  groups = {choppy=2,oddly_breakable_by_hand=2, not_in_creative_inventory = 1},
  sounds = default.node_sound_wood_defaults(),
  drop = {"inbox:empty"},
  after_place_node = function(pos, placer, itemstack)
    local meta = minetest.get_meta(pos)
    local owner = placer:get_player_name()
    meta:set_string("owner", owner)
    meta:set_string("infotext", S("%s's Mailbox"):format(owner))
    local inv = meta:get_inventory()
    inv:set_size("main", 8*4)
    inv:set_size("drop", 1)
  end,
  on_rightclick = function(pos, node, clicker, itemstack)
    local meta = minetest.get_meta(pos)
    local player = clicker:get_player_name()
    local owner  = meta:get_string("owner")
    if owner == player or owner == "" then
      minetest.show_formspec(
        player,
        "default:chest_locked",
        inbox.get_inbox_formspec(pos))
    else
      minetest.show_formspec(
        player,
        "default:chest_locked",
        inbox.get_inbox_insert_formspec(pos))
    end
  end,
  can_dig = function(pos,player)
    local meta = minetest.get_meta(pos);
    local owner = meta:get_string("owner")
    local inv = meta:get_inventory()
    return (player:get_player_name() == owner or owner == "") and inv:is_empty("main")
  end,
  on_metadata_inventory_put = function(pos, listname, index, stack, player)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if listname == "drop" and inv:room_for_item("main", stack) then
      inv:remove_item("drop", stack)
      inv:add_item("main", stack)
    end
  end,
  on_metadata_inventory_take = function(pos, listname, index, stack, player)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if inv:is_empty("main") then
		local node = minetest.get_node(pos)
		minetest.swap_node(pos,
						{ name="inbox:empty",
						param2 = node.param2 })
	end
  end,
  allow_metadata_inventory_put = function(pos, listname, index, stack, player)
    if listname == "main" then
      return 0
    end
    if listname == "drop" then
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      if inv:room_for_item("main", stack) then
        return -1
      else
        return 0
      end
    end
  end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
    local meta = minetest.get_meta(pos)
    local owner = meta:get_string("owner")
    if player:get_player_name() ~= owner and owner ~= "" then
      return 0
    end
    return stack:get_count()
  end,
  allow_metadata_inventory_move = function(pos)
    return 0
  end,
})

function inbox.get_inbox_formspec(pos)
	local spos = pos.x .. "," .. pos.y .. "," ..pos.z
	local formspec =
		"size[8,9]"..
		"list[nodemeta:".. spos .. ";main;0,0;8,4;]"..
		"list[current_player;main;0,5;8,4;]"
	return formspec
end

function inbox.get_inbox_insert_formspec(pos)
	local spos = pos.x .. "," .. pos.y .. "," ..pos.z
	local formspec =
		"size[8,9]"..
		"list[nodemeta:".. spos .. ";drop;3.5,2;1,1;]"..
		"list[current_player;main;0,5;8,4;]"
	return formspec
end

print(S("[Mod]Inbox Loaded!"))

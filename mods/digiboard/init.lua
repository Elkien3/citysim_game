-- Original Digiboard mod by bas080
-- Cracked by jogag
-- Added features: settable channel, no more minetest.env, settable field caption (via digiline)

minetest.register_node("digiboard:keyboard", {
  description = "Digiboard",
  tiles = {"keyboard_top.png", "keyboard_bottom.png", "keyboard_side.png", "keyboard_side.png", "keyboard_side.png", "keyboard_side.png"},
  walkable = true,
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-4/8, -4/8, 0, 4/8, -3/8, 4/8},
    },
  },
  selection_box = {
    type = "fixed",
    fixed = {
      {-4/8, -4/8, 0, 4/8, -3/8, 4/8},
    },
  },
  digiline = { receptor = {},
    effector = {
      action = function(pos, node, channel, msg)
        local meta = minetest.get_meta(pos)
        if channel == meta:get_string("channel") and type(msg) == "string" then
          meta:set_string("formspec", "field[text;"..msg..";]")
        end
      end
    },
  },
  groups =  {choppy = 3, dig_immediate = 2},
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    meta:set_string("formspec", "field[channel;Channel;]")
    meta:set_string("infotext", "Keyboard")
    meta:set_int("lines", 0)
  end,
  on_receive_fields = function(pos, formname, fields, sender)
    local meta = minetest.get_meta(pos)
    local channel = meta:get_string("channel")
    if fields.channel then
      meta:set_string("channel", fields.channel)
      meta:set_string("formspec", "field[text;Enter text;]")
    elseif fields.text then
      digiline:receptor_send(pos, digiline.rules.default, channel, fields.text)
    end
  end,
})

minetest.register_craft({
	output = "digiboard:keyboard 2",
	recipe = {
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{"","digilines:wire_std_00000000",""}
	}
})

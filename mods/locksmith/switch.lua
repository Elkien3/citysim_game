-- mesecons_switch

mesecon.register_node("locksmith:mesecon_switch", {
	paramtype2="facedir",
	description="Locked Switch",
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	after_place_node = function(pos, placer, itemstack)
		local owner = placer:get_player_name()
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Switch (owned by "..owner..")")
		meta:set_string("owner",owner)
	end,
	on_rightclick = function(pos, node, clicker)
		if not default.can_interact_with_node(clicker, pos) then return end
		if(mesecon.flipstate(pos, node) == "on") then
			mesecon.receptor_on(pos)
		else
			mesecon.receptor_off(pos)
		end
		minetest.sound_play("mesecons_switch", {pos=pos})
	end
},{
	groups = {dig_immediate=2},
	tiles = {	"mesecons_switch_side.png", "mesecons_switch_side.png",
				"mesecons_switch_side.png", "mesecons_switch_side.png",
				"mesecons_switch_side.png", "mesecons_switch_off.png"},
	mesecons = {receptor = { state = mesecon.state.off }}
},{
	groups = {dig_immediate=2, not_in_creative_inventory=1},
	tiles = {	"mesecons_switch_side.png", "mesecons_switch_side.png",
				"mesecons_switch_side.png", "mesecons_switch_side.png",
				"mesecons_switch_side.png", "mesecons_switch_on.png"},
	mesecons = {receptor = { state = mesecon.state.on }}
})

minetest.register_craft({
	output = "locksmith:mesecon_switch_off 2",
	recipe = {
		{"mesecons_switch:mesecon_switch_off", "default:steel_ingot", "mesecons_switch:mesecon_switch_off"},
	}
})

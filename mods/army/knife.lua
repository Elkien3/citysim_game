minetest.register_tool("army:knife", {
    description = "Knife",
	inventory_image = "army_knife.png",
    stack_max = 1,
	tool_capabilities = {
		full_punch_interval = 0.05,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.4, [3]=0.40}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=4},
	}
})

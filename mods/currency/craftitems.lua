minetest.register_craftitem("currency:minegeld", {
    description = "1 MineGeld Note",
    inventory_image = "minegeld.png",
        stack_max = 30000,
		groups = {minegeld = 1}
})

minetest.register_craftitem("currency:minegeld_5", {
    description = "5 MineGeld Note",
    inventory_image = "minegeld_5.png",
        stack_max = 30000,
		groups = {minegeld = 1}
})

minetest.register_craftitem("currency:minegeld_10", {
    description = "10 MineGeld Note",
    inventory_image = "minegeld_10.png",
        stack_max = 30000,
		groups = {minegeld = 1}
})

minetest.register_craftitem("currency:minegeld_bundle", {
    description = "Bundle of random Minegeld notes",
    inventory_image = "minegeld_bundle.png",
        stack_max = 30000,
})

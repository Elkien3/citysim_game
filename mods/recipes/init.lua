
minetest.register_craft({
    type = "shapeless",
    output = "default:clay",
    recipe = {"technic:stone_dust", "default:dirt", "bucket:bucket_water", "group:sand"},
    replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}},
})

minetest.register_craft({
    type = "shapeless",
    output = "default:bronze_ingot 9",
    recipe = {
        "default:bronzeblock",
    },
})


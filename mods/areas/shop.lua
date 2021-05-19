local show_shop_formspec = function()

end

minetest.register_node("areas:shop",
{
  description = "Area Shop",
  tiles = {"default_dirt.png"},
  on_rightclick = show_shop_formspec
})
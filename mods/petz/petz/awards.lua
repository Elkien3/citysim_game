awards.register_trigger("milk", {
	type             = "custom",
	progress         = "@1/@2 buckets of milk",
	auto_description = { "Do a foo", "Foo @1 times" },
})

minetest.register_on_milk(function()
	for _, trigger in pairs(awards.on.milk) do


		if condition then
			awards.unlock(trigger)
		end
	end
end)
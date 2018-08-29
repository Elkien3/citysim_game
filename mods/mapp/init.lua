minetest.register_tool("mapp:map", {
	description = "Map",
	inventory_image = "map_block.png",
	on_use = function(itemstack, user, pointed_thing)
	map_handler(itemstack,user,pointed_thing)
	end,
})
function map_handler (itemstack, user, pointed_thing)
		local pos = user:getpos()
		local player_name=user:get_player_name()
		local mapar = {}
		local map
		local p
		local pp
		local po = {x = 0, y = 0, z = 0}
		local tile = ""
		local yaw
		local rotate = 0
		pos.y = pos.y + 1
        yaw = user:get_look_yaw()
        if yaw ~= nil then
           -- Find rotation and texture based on yaw.
           yaw = math.deg(yaw)
           yaw = math.fmod (yaw, 360)
           if yaw<0 then yaw = 360 + yaw end
           if yaw>360 then yaw = yaw - 360 end           
           if yaw < 90 then
              rotate = 90
           elseif yaw < 180 then
              rotate = 180
           elseif yaw < 270 then
              rotate = 270
           else
              rotate = 0
           end
           yaw = math.fmod(yaw, 90)
           yaw = math.floor(yaw / 10) * 10
           
        end

		--Localise some global minetest variables for speed.
		local env = minetest.env
		local registered_nodes = minetest.registered_nodes

		for i = -17,17,1 do
			mapar[i+17] = {}
			for j = -17,17,1 do
				mapar[i+17][j+17] = {}
				po.x, po.y, po.z = pos.x+i, pos.y, pos.z+j
				local no = env:get_node(po)
				local k=po.y
				if no.name == "air" then
					while no.name == "air" do
						k=k-1
						po.x, po.y, po.z = pos.x+i, k, pos.z+j
						no = env:get_node(po)
					end
				elseif no.name ~= "air" and (no.name ~= "ignore")  then
						while (no.name ~= "air") and (no.name ~= "ignore") do
							k=k+1
							po.x, po.y, po.z  = pos.x+i, k, pos.z+j
							no = env:get_node(po)
						end
				  k=k-1
				  po.x, po.y, po.z = pos.x+i, k, pos.z+j
				end

				local node = env:get_node(po)
				local tiles
				local def = registered_nodes[node.name]
				if def then tiles = def["tiles"] end
				if tiles ~=nil then
					tile = tiles[1]
				end

				if type(tile)=="table" then
				  tile=tile["name"]
				end
				mapar[i+17][j+17].y = k
				mapar[i+17][j+17].im = tile
			end
		end

	--Optimisation technique.
	--Lua does not edit string buffers via concatenation, using a table and then invoking table.concat is MUCH faster.
	p = {}
	pp = #p

	pp = pp + 1
	p[pp] = "size[5.2,5]"

	for i=1,32,1 do
		for j=1,32,1 do
			if mapar[i][j].y ~= mapar[i][j+1].y then mapar[i][j].im = mapar[i][j].im .. "^1black_blockt.png" end
			if mapar[i][j].y ~= mapar[i][j-1].y then mapar[i][j].im = mapar[i][j].im .. "^1black_blockb.png" end
			if mapar[i][j].y ~= mapar[i-1][j].y then mapar[i][j].im = mapar[i][j].im .. "^1black_blockl.png" end
			if mapar[i][j].y ~= mapar[i+1][j].y then mapar[i][j].im = mapar[i][j].im .. "^1black_blockr.png" end
			pp = pp + 1
			p[pp] = "image[".. 0.15*(i) ..",".. 0.15*(32-j)+0.1 ..";0.2,0.2;" .. mapar[i][j].im .. "]"
		end
	end

	pp = pp + 1
	if rotate ~= 0 then
		p[pp] = "image[".. 0.15*(16)+0.075 ..",".. 0.15*(16)-0.085 ..";0.4,0.4;d" .. yaw .. ".png^[transformFYR".. rotate .."]"
	else
		p[pp] = "image[".. 0.15*(16)+0.075 ..",".. 0.15*(16)-0.085 ..";0.4,0.4;d" .. yaw .. ".png^[transformFY]"
	end

	map = table.concat(p, "\n")

	minetest.show_formspec(player_name, "mapp:map", map)
end

minetest.register_craft({
	output = 'mapp:map',
	recipe = {
		{'default:paper', 'default:paper', 'default:paper'},
		{'default:paper', 'group:dye', 'default:paper'},
		{'default:paper', 'default:paper','default:paper'},
	}
})
 
local guide = {}

guide.path = minetest.get_worldpath()

function guide.formspec(player,article)
	
	if ( article == "" or article == nil ) then
		article = "guide.txt"
	else
		article = "guide_"..article..".txt"
	end
	
	local guidefile = io.open(guide.path.."/"..article,"r")
	
	local formspec = "size[12,10]"
	
	if guidefile ~= nil then
		local guidecontent = guidefile:read("*a")
		formspec = formspec.."textarea[.25,.25;12,10;guide;;"..guidecontent.."]"
	else		
		formspec = formspec.."label[.25,.25;Article does not exist]"
	end		
	formspec = formspec.."button_exit[.25,9;2,1;exit;Close"
	if ( guidefile ~= nil ) then
		guidefile:close()
	end
	return formspec
end

function guide.show_formspec(player)
	local name = player:get_player_name()
	minetest.show_formspec(name,"guide",guide.formspec(player))
	minetest.log('action','Showing formspec to '..name)
end


minetest.register_chatcommand("guide",{
	params = "<article>",
	description="Shows the server guide",
	func = function (name,params)
		local player = minetest.get_player_by_name(name)
		minetest.show_formspec(name,"guide",guide.formspec(player,params))	
	end,
})
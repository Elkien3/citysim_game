jobs.form = {}

function generate_form()

    local form = "" ..
    "size[8,8]" ..
    "label[0.25,0.25;Job Main]" ..
    "field[0.5,1.25;2,1;filtername;Filter by name;]" ..
    "field_close_on_enter[filtername;false]" ..
    "field[2.5,1.25;2,1;filterpay;Filter by pay;]" ..
    "field_close_on_enter[filterpay;false]" ..
    "checkbox[0.25,1.65;noinvite;no invite needed;false]" ..
    "checkbox[0.25,2.1;featuredonly;featured only;false]" ..
    "dropdown[2.25,2.1;1.85,1;sortby;activity,pay,members,old to new,new to old;1]" ..
    "label[2.25,1.75;Sort By:]" ..
    ""

    return form
end

local form =
	"size[8,8]" ..
	"label[0.25,0.25;Job Main]" ..
	"scrollbar[3.5,2;0.3,6;vertical;alljobs;0]" ..
	"scroll_container[.5,3;4,6;alljobs;vertical;.01]"
	local i = 0
	for jobname, data in pairs(jobs.list) do
		form = form.."button[0,"..i..";3,0;"..jobname..";"..jobname.."]"
		i = i + .65
	end
	form = form.."scroll_container_end[]"..
	"scrollbar[7,2;0.3,6;vertical;yourjobs;0]" ..
	"scroll_container[5,3;4,6;yourjobs;vertical;.01]"
	i = 0
	--[[for jobname, rank in pairs(jobs.players["spark"]) do
		form = form.."button[0,"..i..";3,0;"..jobname..";"..jobname.."]"
		i = i + .65
	end--]]
	form = form.."scroll_container_end[]"..
	"label[5,0.5;Your Jobs]" ..
	"label[1.5,0.5;All Jobs]" ..
	--generate_form()..
	""
jobs.form.main = "size[5,1]label[0,0.25;GUI is not completed, please do /jobs help]"--form
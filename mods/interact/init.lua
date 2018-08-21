rule_table = {}
rule_language = {}
dofile(minetest.get_modpath("interact") .. "/rules-english.lua") --I put the rules in their own file so that they don't get lost/overlooked!
dofile(minetest.get_modpath("interact") .. "/rules-russian.lua")
dofile(minetest.get_modpath("interact") .. "/rules-deutsch.lua")
dofile(minetest.get_modpath("interact") .. "/config.lua")

local rule1 = 0
local rule2 = 0
local rule3 = 0
local rule4 = 0
local multi = 0

local all_languages = interact.default_language
for k in pairs(rule_table) do
	if k ~= interact.default_language then
		all_languages = all_languages..", "..k
		if rule_table[k].secondaryname then
			all_languages = all_languages.." ("..rule_table[k].secondaryname..")"
		end
	end
end

local function make_formspec(player, language)
	if not language then language = interact.default_language end
	local name = player:get_player_name()
	local size = { "size[10,4]" }
	table.insert(size, "label[1,0.5;List of Languages (eg: /rules english)]")
	table.insert(size, "label[1,1;"..all_languages.."]")
	table.insert(size, "label[0.5,0;" ..rule_table[language].s1_header.. "]")
	table.insert(size, "label[0.5,3.25;" ..rule_table[language].s1_l2.. "]")
	table.insert(size, "label[0.5,3.75;" ..rule_table[language].s1_l3.. "]")
	table.insert(size, "button_exit[5.5,3.4;2,0.5;no;" ..rule_table[language].s1_b1.. "]")
	table.insert(size, "button[7.5,3.4;2,0.5;yes;" ..rule_table[language].s1_b2.. "]")
	return table.concat(size)
end

local function make_formspec2(player, language)
	if not language then language = interact.default_language end
	local name = player:get_player_name()
	local size = { "size[10,4]" }
	table.insert(size, "label[0.5,0.5;" ..rule_table[language].s2_l1.. "]")
	table.insert(size, "label[0.5,1;" ..rule_table[language].s2_l2.. "]")
	table.insert(size, "button_exit[2.5,3.4;3.5,0.5;interact;" ..rule_table[language].s2_b1.. "]")
	table.insert(size, "button_exit[6.4,3.4;3.6,0.5;visit;" ..rule_table[language].s2_b2.. "]")
	return table.concat(size)
end

local function make_formspec3(player, language)
	if not language then language = interact.default_language end
	local size = { "size[10,8]" }
	table.insert(size, "textarea[0.5,0.5;9.5,7.5;TOS;" ..rule_table[language].s3_header.. ";" ..rule_table[language].rules.. "]")
	table.insert(size, "button[5.5,7.4;2,0.5;decline;" ..rule_table[language].s3_b2.. "]")
	table.insert(size, "button_exit[7.5,7.4;2,0.5;accept;" ..rule_table[language].s3_b1.. "]")
	return table.concat(size)
end

local function make_formspec4(player, language)
	if not language then language = interact.default_language end
	local name = player:get_player_name()
	local size = { "size[10,9]" }
	if interact.s4_to_rules_button == true then
		table.insert(size, "button_exit[7.75,0.25;2.1,0.1;rules;" ..rule_table[language].s4_to_rules.. "]")
	end
	table.insert(size, "label[0.25,0;" ..rule_table[language].s4_header.."]")
	table.insert(size, "label[0.5,0.5;" ..rule_table[language].question1.."]")
	table.insert(size, "checkbox[0.25,1;rule1_true;" ..rule_table[language].s4_question1_true.."]")
	table.insert(size, "checkbox[4,1;rule1_false;" ..rule_table[language].s4_question1_false.. "]")
	table.insert(size, "label[0.5,2;" ..rule_table[language].question2.. "]")
	table.insert(size, "checkbox[0.25,2.5;rule2_true;" ..rule_table[language].s4_question2_true.. "]")
	table.insert(size, "checkbox[4,2.5;rule2_false;" ..rule_table[language].s4_question2_false.. "]")
	table.insert(size, "label[0.5,3.5;" ..rule_table[language].question3.. "]")
	table.insert(size, "checkbox[0.25,4;rule3_true;" ..rule_table[language].s4_question3_true.. "]")
	table.insert(size, "checkbox[4,4;rule3_false;" ..rule_table[language].s4_question3_false.. "]")
	table.insert(size, "label[0.5,5;" ..rule_table[language].question4.. "]")
	table.insert(size, "checkbox[0.25,5.5;rule4_true;" ..rule_table[language].s4_question4_true.. "]")
	table.insert(size, "checkbox[4,5.5;rule4_false;" ..rule_table[language].s4_question4_false.."]")
	table.insert(size, "label[0.5,6.5;" ..rule_table[language].multiquestion.. "]")
	table.insert(size, "checkbox[4.75,6.25;multi_choice1;" ..rule_table[language].mq_answer1.. "]")
	table.insert(size, "checkbox[0.25,7;multi_choice2;" ..rule_table[language].mq_answer2.. "]")
	table.insert(size, "checkbox[4.75,7;multi_choice3;" ..rule_table[language].mq_answer3.."]")
	table.insert(size, "button_exit[3,8.4;3.5,0.5;submit;" ..rule_table[language].s4_submit.."]")
	return table.concat(size)
end

local server_formspec = "size[10,4]" ..
	"label[0.5,0.5;Hey, you! Yes, you, the admin! What do you think you're doing]" ..
	"label[0.5,0.9;ignoring warnings in the terminal? You should watch it carefully!]" ..
	"label[0.5,1.5;Before you do anything else, open rules.lua in the interact mod]" ..
	"label[0.5,1.9;and put your rules there. Then, open config.lua, and look at the]" ..
	"label[0.5,2.3;settings. Configure them so that they match up with your rules.]" ..
	"label[0.5,2.7;Then, set interact.configured to true, and this message will go away]" ..
	"label[0.5,3.1;once you've restarted the server.]" ..
	"label[0.5,3.6;Thank you!]"

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "interact_welcome" then return end
	local name = player:get_player_name()
	local language = rule_language[name] or interact.default_language
	if fields.no then
		if interact.screen2 == false then
			minetest.after(1, function()
				minetest.show_formspec(name, "interact_rules", make_formspec3(player, language))
			end)
		else
			minetest.after(1, function()
				minetest.show_formspec(name, "interact_visit", make_formspec2(player, language))
			end)
		end
		return
	elseif fields.yes then
		if interact.grief_ban ~= true then
			--minetest.kick_player(name, rule_table[language].msg_grief)
			minetest.chat_send_player(name, rule_table[language].msg_grief)
		else
			minetest.ban_player(name)
		end
	return
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "interact_visit" then return end
	local name = player:get_player_name()
	local language = rule_language[name] or interact.default_language
	if fields.interact then
		minetest.after(1, function()
			minetest.show_formspec(name, "interact_rules", make_formspec3(player, language))
		end)
		return
	elseif fields.visit then
		minetest.chat_send_player(name, rule_table[language].visit_msg)
		minetest.log("action", name.. " is just visiting.")
	return
	end
end)


minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "interact_rules" then return end
	local name = player:get_player_name()
	local language = rule_language[name] or interact.default_language
	if fields.accept then
		if interact.screen4 == false then
			if minetest.check_player_privs(name, interact.priv) then
				minetest.chat_send_player(name, rule_table[language].interact_msg1)
				minetest.chat_send_player(name, rule_table[language].interact_msg2)
				local privs = minetest.get_player_privs(name)
				privs.interact = true
				minetest.set_player_privs(name, privs)
				minetest.log("action", "Granted " ..name.. " interact.")
			end
		else
			minetest.after(1, function()
				minetest.show_formspec(name, "interact_quiz", make_formspec4(player, language))
			end)
		end
		return
	elseif fields.decline then
		if interact.disagree_action == "kick" then
			minetest.kick_player(name, rule_table[language].disagree_msg)
		elseif interact.disagree_action == "ban" then
			minetest.ban_player(name)
		else
			minetest.chat_send_player(name, rule_table[language].disagree_msg)
		end
	return
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "interact_quiz" then return end
	local name = player:get_player_name()
	local language = rule_language[name] or interact.default_language
	if fields.rules then
		minetest.after(1, function()
			minetest.show_formspec(name, "interact_rules", make_formspec3(player, language))
		end)
		return
	end
	if fields.rule1_true then rule1 = true
	elseif fields.rule1_false then rule1 = false
	elseif fields.rule2_true then rule2 = true
	elseif fields.rule2_false then rule2 = false
	elseif fields.rule3_true then rule3 = true
	elseif fields.rule3_false then rule3 = false
	elseif fields.rule4_true then rule4 = true
	elseif fields.rule4_false then rule4 = false
	elseif fields.multi_choice1 then multi = 1
	elseif fields.multi_choice2 then multi = 2
	elseif fields.multi_choice3 then multi = 3 end
	if fields.submit and rule1 == interact.quiz1 and rule2 == interact.quiz2 and
	rule3 == interact.quiz3 and rule4 == interact.quiz4 and multi == interact.quiz_multi then
		rule1 = 0
		rule2 = 0
		rule3 = 0
		rule4 = 0
		multi = 0
		if minetest.check_player_privs(name, interact.priv) then
			minetest.chat_send_player(name, rule_table[language].interact_msg1)
			minetest.chat_send_player(name, rule_table[language].interact_msg2)
			local privs = minetest.get_player_privs(name)
			privs.interact = true
			minetest.set_player_privs(name, privs)
			minetest.log("action", "Granted " ..name.. " interact.")
		end
	elseif fields.submit then
		rule1 = 0
		rule2 = 0
		rule3 = 0
		rule4 = 0
		multi = 0
		if interact.on_wrong_quiz == "kick" then
			minetest.kick_player(name, rule_table[language].wrong_quiz_kick_msg)
		elseif interact.on_wrong_quiz == "ban" then
			minetest.ban_player(name)
		elseif interact.on_wrong_quiz == "reshow" then
			minetest.chat_send_player(name, rule_table[language].quiz_try_again_msg)
			minetest.after(1, function()
				minetest.show_formspec(name, "interact_quiz", make_formspec4(player, language))
			end)
		elseif interact.on_wrong_quiz == "rules" then
			minetest.chat_send_player(name, rule_table[language].quiz_rules_msg)
			minetest.after(1, function()
				minetest.show_formspec(name, "interact_rules", make_formspec3(player, language))
			end)
		else
			minetest.chat_send_player(name, rule_table[language].quiz_fail_msg)
		end
	end
end)

minetest.register_chatcommand("rules",{
	params = "<language>",
	description = "Shows the server rules",
	privs = interact.priv,
	func = function (name,params)
	local player = minetest.get_player_by_name(name)
	local language = rule_language[name] or interact.default_language
	if params ~= "" and rule_table[params:lower()] then
		language = params:lower()
		rule_language[name] = language
	elseif params ~= "" then
		minetest.chat_send_player(name, "There is no translation for '"..params:lower().."', Opening rules in '"..language.."'")
	end
		if interact.screen1 ~= false then
			minetest.after(1, function()
				minetest.show_formspec(name, "interact_welcome", make_formspec(player, language))
			end)
		elseif interact.screen2 ~= false then
			minetest.after(1, function()
				minetest.show_formspec(name, "interact_visit", make_formspec2(player, language))
			end)
		else
			minetest.after(1, function()
				minetest.show_formspec(name, "interact_rules", make_formspec3(player, language))
			end)
		end
	end
})

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local language = rule_language[name] or interact.default_language
	if not minetest.get_player_privs(name).interact then
		if interact.screen1 ~= false then
			minetest.show_formspec(name, "interact_welcome", make_formspec(player, language))
		elseif interact.screen2 ~= false then
			minetest.show_formspec(name, "interact_visit", make_formspec2(player, language))
		else
			minetest.show_formspec(name, "interact_rules", make_formspec3(player, language))
		end
	elseif minetest.get_player_privs(name).server and interact.configured == false then
		minetest.show_formspec(name, "interact_no_changes_made", server_formspec)
	end
end)

if not interact.configured then
	minetest.log("warning", "Mod \"Interact\" has not been configured! Please open config.lua in its folder and configure it. See the readme of the mod for more details.")
end

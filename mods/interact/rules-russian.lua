--The actual rules.
local language = "russian" --must be all lowercase
local yes = "да."
local no = "нет."
rule_table[language] = {
secondaryname = "русский", --secondary name, usually the language name in english, or in the actual language.

rules = [[
Rules:

1. PVP разрешен, RDM не разрешен.
2. Не будь * слишком * жестоким, разрушительным или неуместным
3. ругаться минимально, и не спамить.
4. Нет "знакомств" в глобальном чате.
5. Альтернативные аккаунты (alts) не допускаются. Свяжитесь с администратором, если у вас есть друг, которому нужна учетная запись.
6. Взломанные клиенты или csms, которые дают преимущество в pvp, не допускаются.
7. Не укради. (временно, вы увидите, когда изменятся правила)

Игроки могут также запереть вас за другие преступления. (например, продажа наркотиков или ношение незаконного оружия)
]],

--The questions on the rules, if the quiz is used.
--The checkboxes for the first 4 questions are in config.lua
question1 = "Разрешены ли взломанные клиенты или моды, которые дают вам преимущество в PvP?",
question2 = "Разрешены ли альтернативные аккаунты?",
question3 = "Вы можете встречаться в глобальном чате?",
question4 = "Вас могут забанить за кражу?",
multiquestion = "Разрешен ли PVP?",

--The answers to the multiple choice questions. Only one of these should be true.
mq_answer1 = "нет.",
mq_answer2 = "Только если ты согласен.",
mq_answer3 = "Да, но должна быть веская причина.",

--The first screen--
--The text at the top.
s1_header = "Здравствуйте, добро пожаловать в CitySim!",
--Lines one and two. Make sure each line is less than 70 characters, or they will run off the screen.
s1_l2 = "Не могли бы вы сказать мне, если вы любите 'grief' много?",
s1_l3 = "'griefing' разрушает места и наводит беспорядок.",
--The buttons. Each can have 15 characters, max.
s1_b1 = "Нет не знаю.",
s1_b2 = "Да!",

--The message to send kicked griefers.
msg_grief = "На многие griefing смотрят свысока, хотя некоторые из них разрешены сервером.",

--The second screen--
--Lines one and two. Make sure each line is less than 70 characters, or they will run off the screen.
s2_l1 = "Итак, вы хотите взаимодействовать, или вы просто хотите осмотреть сервер?",
s2_l2 = "",
--The buttons. These ones can have a maximum of 26 characters.
s2_b1 = "Да, я хочу построить!",
s2_b2 = "Я просто хочу осмотреться.",

--The message the player is sent if s/he is just visiting.
visit_msg = "Приятно провести время, оглядываясь вокруг! Если вы хотите взаимодействовать так же, как /rules, вы можете пройти через процесс снова!",

--The third screen--
--The header for the rules box, this can have 60 characters, max.
s3_header = "Вот правила:",

--The buttons. Each can have 15 characters, max.
s3_b1 = "согласен",
s3_b2 = "я не согласен",

--The message to send players who disagree when they are kicked for disagring with the rules.
disagree_msg = "Ну тогда пока! Вы должны согласиться с правилами игры на сервере.",

--The back to rules button. 13 characters, max.
s4_to_rules = "вернуться к правилам",

--The header for screen 4. 60 characters max, although this is a bit of a squash. I recomend 55 as a max.
s4_header = "Время для викторины о правилах!",

--Since the questions are intrinsically connected with the rules, they are to be found in rules.lua
--The trues are limited to 24 characters. The falses can have 36 characters.

s4_question1_true = yes,
s4_question1_false = no,
s4_question2_true = yes,
s4_question2_false = no,
s4_question3_true = yes,
s4_question3_false = no,
s4_question4_true = yes,
s4_question4_false = no,

s4_submit = "утверждать",

--The message to send the player if reshow is the on_wrong_quiz option.
quiz_try_again_msg = "Попробуйте снова.",
--The message sent to the player if rules is the on_wrong_quiz option.
quiz_rules_msg = "Посмотрите еще раз на правила:",
--The kick reason if kick is the on_wrong_quiz option.
wrong_quiz_kick_msg = "Обратите больше внимания в следующий раз!",
--The message sent to the player if nothing is the on_wrong_quiz option.
quiz_fail_msg = "Вы ответили на вопрос неправильно. введите /rules, чтобы повторить попытку. (прочитайте их внимательно)",

--The messages send to the player after interact is granted.
interact_msg1 = "Спасибо за принятие правил, теперь вы можете взаимодействовать с вещами.",
interact_msg2 = "Повеселись! введите /guide, чтобы помочь начать! (это на английском)",
}
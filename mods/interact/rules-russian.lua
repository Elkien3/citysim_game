--The actual rules.
local language = "russian" --must be all lowercase
local yes = "да."
local no = "нет."
rule_table[language] = {
secondaryname = "русский", --secondary name, usually the language name in english, or in the actual language.
rules = [[
Rules:

1. PVP разрешен.
2. Не будьте чрезмерно жестокими, разрушительными или неуместными.
3. не ругайтесь слишком много, и не спам.
4. нет "знакомства".
5. Не уничтожайте целые леса без посадки снова.
6. Если вы совершаете набег на королевство, когда его члены находятся в автономном режиме, вы не можете много разрушать или украсть.
7. Пожалуйста, строите только средневековую эпоху и следуйте законам физики.
8. Взломанные клиенты или csms, которые дают преимущество pvp, запрещены. (Однако допускается «отставание» через стены.)

Помните: некоторые разрушения во время войны разрешены. просто «Не будьте чрезмерно жестокими»
]],

--The questions on the rules, if the quiz is used.
--The checkboxes for the first 4 questions are in config.lua
question1 = "Разрешено ли PVP?",
question2 = "если вы снова сажаете деревья после их резки?",
question3 = "Можете ли вы дать онлайн-девушкам большие, онлайн-поцелуи?",
question4 = "Можете ли вы уничтожить небольшую часть здания ваших врагов?",
multiquestion = "Какой стиль строительства вы должны использовать?",

--The answers to the multiple choice questions. Only one of these should be true.
mq_answer1 = "Современные, высокие высокие небоскребы.",
mq_answer2 = "Космические станции, вверх по небу.",
mq_answer3 = "Средневековые, без летающих частей.",

--The first screen--
--The text at the top.
s1_header = "Привет, добро пожаловать в Persistent Kingdoms!",
--Lines one and two. Make sure each line is less than 70 characters, or they will run off the screen.
s1_l2 = "действительно хотите уничтожить или 'grief'?",
s1_l3 = "'Griefing' уничтожает пространство и создает беспорядок.",
--The buttons. Each can have 15 characters, max.
s1_b1 = "Нет, не знаю.",
s1_b2 = "Да!",

--The message to send kicked griefers.
msg_grief = "Много griefing смотрится сверху вниз, хотя какое-то разрушение войны может быть в порядке.",

--The second screen--
--Lines one and two. Make sure each line is less than 70 characters, or they will run off the screen.
s2_l1 = "Итак, вы хотите взаимодействовать, или просто хотите посмотреть вокруг сервера?",
s2_l2 = "",
--The buttons. These ones can have a maximum of 26 characters.
s2_b1 = "Да, я хочу взаимодействовать!",
s2_b2 = "Я просто хочу, чтобы оглядеться.",

--The message the player is sent if s/he is just visiting.
visit_msg = "Приятного просмотра! Если вы хотите взаимодействовать, просто введите '/rules russian', и вы сможете снова пройти процесс!",

--The third screen--
--The header for the rules box, this can have 60 characters, max.
s3_header = "Вот правила:",

--The buttons. Each can have 15 characters, max.
s3_b1 = "согласен",
s3_b2 = "я не согласен",

--The message to send players who disagree when they are kicked for disagring with the rules.
disagree_msg = "До свидания! Вы должны согласиться с правилами игры на сервере.",

--The back to rules button. 13 characters, max.
s4_to_rules = "Вернуться к правилам",

--The header for screen 4. 60 characters max, although this is a bit of a squash. I recomend 55 as a max.
s4_header = "Время для викторины по правилам!",

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

s4_submit = "регистрировать!",

--The message to send the player if reshow is the on_wrong_quiz option.
quiz_try_again_msg = "попробуй еще раз.",
--The message sent to the player if rules is the on_wrong_quiz option.
quiz_rules_msg = "Попробуйте еще раз взглянуть на правила:",
--The kick reason if kick is the on_wrong_quiz option.
wrong_quiz_kick_msg = "Обратите внимание в следующий раз!",
--The message sent to the player if nothing is the on_wrong_quiz option.
quiz_fail_msg = "Вы ответили на вопрос неправильно. введите '/rules', чтобы повторить попытку. (внимательно прочитайте их)",

--The messages send to the player after interact is granted.
interact_msg1 = "Спасибо, что приняли правила, теперь вы можете взаимодействовать с вещами.",
interact_msg2 = "повеселись! Я предлагаю найти других российских игроков, чтобы объединиться. '/guide'",
}
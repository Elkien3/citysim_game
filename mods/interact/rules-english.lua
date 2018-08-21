--The actual rules.
local language = "english" --must be all lowercase
local yes = "Yes."
local no = "No."
rule_table[language] = {
secondaryname = nil, --secondary name, usually the language name in english, or in the actual language.

rules = [[
Rules:

1. PVP is allowed. Don't Combat log!
2. Don't be *overly* cruel, destructive, or inappropriate.
3. Keep swearing to a minimum, and don't spam.
4. No "Dating" or the like.
5. Don't clear out entire forests without replanting.
6. If you raid a kingdom while it's members are offline, you may not destroy or steal much.
7. Please keep your builds medieval-ish times, and follow the laws of physics.
8. Hacked clients or csms that give a pvp advantage are disallowed. (However, lagging through walls is allowed.)

Remember: A some destruction during war is O.K. just "Don't be *overly* cruel"
]],

--The questions on the rules, if the quiz is used.
--The checkboxes for the first 4 questions are in config.lua
question1 = "Is PVP is allowed?",
question2 = "Should you replant after your tree genocide?",
question3 = "Can you give online girls big, online smooches?",
question4 = "Can you destroy a bit of your enemies's stuff every once in a while?",
multiquestion = "What building style to use?",

--The answers to the multiple choice questions. Only one of these should be true.
mq_answer1 = "Modern, super tall Skyscrapers.",
mq_answer2 = "Space stations, up in the sky.",
mq_answer3 = "Medieval, with no flying parts.",

--The first screen--
--The text at the top.
s1_header = "Hello, welcome to Persistent Kingdoms!",
--Lines one and two. Make sure each line is less than 70 characters, or they will run off the screen.
s1_l2 = "Could you please tell me if you like to grief a lot?",
s1_l3 = "Griefing is destroying places and generally making a mess.",
--The buttons. Each can have 15 characters, max.
s1_b1 = "No, I don't.",
s1_b2 = "Yes, I do!",

--The message to send kicked griefers.
msg_grief = "A *lot* of griefing is looked down upon, though some war destruction might be ok.",

--The second screen--
--Lines one and two. Make sure each line is less than 70 characters, or they will run off the screen.
s2_l1 = "So, do you want interact, or do you just want to look around the server?",
s2_l2 = "",
--The buttons. These ones can have a maximum of 26 characters.
s2_b1 = "Yes, I want interact!",
s2_b2 = "I just want to look round.",

--The message the player is sent if s/he is just visiting.
visit_msg = "Have a nice time looking round! If you want interact just type /rules, and you can go through the process again!",

--The third screen--
--The header for the rules box, this can have 60 characters, max.
s3_header = "Here are the rules:",

--The buttons. Each can have 15 characters, max.
s3_b1 = "I agree",
s3_b2 = "I disagree",

--The message to send players who disagree when they are kicked for disagring with the rules.
disagree_msg = "Bye then! You have to agree to the rules to play on the server.",

--The back to rules button. 13 characters, max.
s4_to_rules = "Back to rules",

--The header for screen 4. 60 characters max, although this is a bit of a squash. I recomend 55 as a max.
s4_header = "Time for a quiz on the rules!",

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

s4_submit = "Submit!",

--The message to send the player if reshow is the on_wrong_quiz option.
quiz_try_again_msg = "Have another go.",
--The message sent to the player if rules is the on_wrong_quiz option.
quiz_rules_msg = "Have another look at the rules:",
--The kick reason if kick is the on_wrong_quiz option.
wrong_quiz_kick_msg = "Pay more attention next time!",
--The message sent to the player if nothing is the on_wrong_quiz option.
quiz_fail_msg = "You answered a question incorrectly. type in '/rules' to try again. (read them carefully)",

--The messages send to the player after interact is granted.
interact_msg1 = "Thanks for accepting the rules, you now are able to interact with things.",
interact_msg2 = "Happy Kingdoming! Do /guide for help getting started!",
}
--The actual rules.
local language = "german" --must be all lowercase
local yes = "Ja."
local no = "Nein."
rule_table[language] = {
secondaryname = "deutsch", --secondary name, usually the language name in english, or in the actual language.

rules = [[
Regeln:

1. Spielerkämpfe sind erlaubt. Loggen sie nicht immer ab und ein!
2. Sei nicht *übermäßig* grausam, destruktiv oder unangemessen.
3. Sie dürfen fluchen, aber machen sie das nicht öfter und spammen Sie nicht.
4. Kein "Dating" oder ähnliches.
5. Räume ganze Wälder nicht ohne Neupflanzung aus.
6. Wenn du ein Königreich überfallen lässt, während seine Mitglieder offline sind, darfst du nicht viel zerstören oder stehlen.
7. Bitte behalte deine Gebäude zu mittelalterlichen Zeiten und befolge die Gesetze der Physik.
8. Gehackte Clients oder csms, die einen pvp-Vorteil bieten, sind nicht erlaubt. (Es ist jedoch erlaubt, ohne WLAN durch Wände zu gehen.)

Denken Sie daran: Eine gewisse Zerstörung während des Krieges ist O.K. "Sei einfach nicht *übermäßig* grausam"
]],

--The questions on the rules, if the quiz is used.
--The checkboxes for the first 4 questions are in config.lua
question1 = "Dürfen sie Spielerkämpfe machen?",
question2 = "Solltest du nach dem Zerstörung des Bäumes, wieder neu bepflanzen?",
question3 = "Dürfen Sie Mädchen, die online sind, küssen, stattdessen Smoothes zu geben?",
question4 = "Darfst du ab und zu etwas von deinen Feinden zerstören?",
multiquestion = "Welchen Baustil müssen sie verwenden?",

--The answers to the multiple choice questions. Only one of these should be true.
mq_answer1 = "Moderne, super große Wolkenkratzer.",
mq_answer2 = "Raumstationen, oben im Himmel.",
mq_answer3 = "Mittelalterlich, ohne fliegende Teile.",

--The first screen--
--The text at the top.
s1_header = "Hallo, willkommen bei Persistent Kingdoms!",
--Lines one and two. Make sure each line is less than 70 characters, or they will run off the screen.
s1_l2 = "Könnten Sie bitte sagen, wenn Sie gerne viele Dinge griefen?",
s1_l3 = "Griefing zerstört Orte und richtet in Allgemein Chaos ein.",
--The buttons. Each can have 15 characters, max.
s1_b1 = "Nein!",
s1_b2 = "Ja!",

--The message to send kicked griefers.
msg_grief = "Eine Menge der *Grief* wird herabgeschraubt. Leichte Kriegszerstörungen lassen wir noch gelten.",

--The second screen--
--Lines one and two. Make sure each line is less than 70 characters, or they will run off the screen.
s2_l1 = "Möchtest du also interact haben oder möchtest du Dinge auf dem Server anschauen?",
s2_l2 = "",
--The buttons. These ones can have a maximum of 26 characters.
s2_b1 = "Ja, ich möchte interact haben!",
s2_b2 = "Ich möchte Dinge anschauen.",

--The message the player is sent if s/he is just visiting.
visit_msg = "Viel Spaß beim Schauen! Wenn Sie interagieren möchten, schreib '/rules' im chat, um den Vorgang der Regeln wiederholen.",

--The third screen--
--The header for the rules box, this can have 60 characters, max.
s3_header = "Hier sind die Regeln:",

--The buttons. Each can have 15 characters, max.
s3_b1 = "Ich stimme zu",
s3_b2 = "Ich stimme nicht zu",

--The message to send players who disagree when they are kicked for disagring with the rules.
disagree_msg = "Dann tschüß! Sie müssen den Regeln zustimmen, um auf dem Server zu spielen.",

--The back to rules button. 13 characters, max.
s4_to_rules = "Zurück zu den Regeln",

--The header for screen 4. 60 characters max, although this is a bit of a squash. I recomend 55 as a max.
s4_header = "Zeit für ein Quiz über die Regeln!",

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

s4_submit = "Einreichen!",

--The message to send the player if reshow is the on_wrong_quiz option.
quiz_try_again_msg = "Versuch es noch einmal.",
--The message sent to the player if rules is the on_wrong_quiz option.
quiz_rules_msg = "Schau dir die Regeln nochmal an:",
--The kick reason if kick is the on_wrong_quiz option.
wrong_quiz_kick_msg = "Achten Sie beim nächsten Mal mehr Aufmerksamkeit!",
--The message sent to the player if nothing is the on_wrong_quiz option.
quiz_fail_msg = "Sie haben eine Frage falsch beantwortet. Schreib '/rules' im Chat, um es erneut zu versuchen. (lies sie sorgfältig)",

--The messages send to the player after interact is granted.
interact_msg1 = "Danke, dass du die Regeln akzeptiert hast, jetzt kannst du mit den Dingen interagieren.",
interact_msg2 = "Viel Glück! Schreib '/guide' im Chat, um loszulegen!",
}
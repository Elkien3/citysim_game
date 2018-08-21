interact = {}

interact.configured = true --Change this to true when you've configured the mod!
interact.default_language = "english"

--Which answer is needed for the quiz questions. interact.quiz1-4 takes true or false.
--True is left, false is right.
--Please, please spell true and false right!!! If you spell it wrong it won't work!
--interact.quiz can be 1, 2 or 3.
--1 is the top one by the question, 2 is the bottom left one, 3 is the bottom right one.
--Make sure these agree with your answers!

interact.quiz1 = true
interact.quiz2 = true
interact.quiz3 = false
interact.quiz4 = true
interact.quiz_multi = 3

--Which screens to show.
interact.screen1 = true --The welcome a first question screen.
interact.screen2 = true --The visit or interact screen.
interact.screen4 = true --The quiz screen.

--Ban or kick griefers? Default is kick, set to true for ban.
interact.grief_ban = false

--Kick, ban or ignore players who disagree with the rules.
--Options are "kick" "ban" "nothing"
interact.disagree_action = "nothing"

--The fouth screen--
--Should there be a back to rules button?
interact.s4_to_rules_button = true


--What to do on a wrong quiz.
--Options are "kick" "ban" "reshow" "rules" and "nothing"
interact.on_wrong_quiz = "reshow"


--The priv required to use the /rules command. If fast is a default priv, I recomend replacing shout with that.
interact.priv = {shout = true}

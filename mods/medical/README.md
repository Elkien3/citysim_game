Note: features are subject to change. This mod is WIP and may not be useable in it's current state. Intructions on use will come further in development.
if you wish to help with this project please let me know.

Planned features:

injury types: cuts, fractures, punctures, burns, bruises

complications (injuries brought on from other injuries): obstructed airway, heart stopped, breathing stopped

Injuries are treated linearly, but can have steps removed in they arent applicable.

vitals: temperature, blood pressure/volume, oxygen, pulse, respiratory rate

signs: color, injuries, level of alertness.

symptoms: cold, dizzy, pain, immobility

tools: blood pressure cuff, stethoscope, pulse oximeter, suction, AED, OPA and NPA, BVM, non-rebreather mask, oxygen tank, dressing, saline, c-collar, gloves, splint, triangle bandage, tourniquet, blanket, trauma shears, stopwatch/clock, blood bag, vital monitor, ventilator, oxygen concentrator

perfusion rate is calculated based off breaths per minute, oxygen content of breaths taken, blood volume, and heart rate. also hunger and thirst, if applicable.
as the perfusion rate lowers, the patient will (in chronological order) get dizzy, pale, cold, confused, unconscious, stop breathing and pumping blood, and shortly after die.
perfusion will rapidly decrease if patient stops breathing due to drowning or suffocation.
perfusion will rapidly decrease if patient looses a lot of blood.
if patient has no nutrients (food) or no water, perfusion cannot take place.
patient can also can be dizzy, confused, or unconscious due to blunt force trauma, especially to the head.

oxygen tanks will be able to be attached to bvms, non-rebreathers, and oxygen concentrator machines.
bags can be filled with saline (sterile water and salt) or blood from a donor. they can then be placed above the patient and given to the patient by gravity.
dressings can be used to clean, apply pressure, and bandage a wound. a tourniquet may be needed to stop major bleeding.
blankets can be placed on a patient to lower heat loss.
blood pressure cuff and stethoscope is used to attain a blood pressure.
areobic activity (running, jumping, swimming) will increase pulse and respiratory rate. but also has increased need for perfusion.
BVMing too quickly or with too much volume can cause the patient to vomit and cause an airway obstruction.

need a very flexible api for injuries. would need to allow for special tools, vital sign changes, conditions that cause them, signs and symptoms they show, and be able to omit certain steps if needed.
would also need an api for vital sign management tools.

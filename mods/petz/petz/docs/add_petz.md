An example to add a petz: mouse

1. Edit the 'petz.conf' file

- Open petz.conf and add your petz to the end of the 'petz_list'.
You have to add a comma and 'mouse'.
Warning: Do not put blank spaces.

- In the 'Spawn Mobs?' section:
Add the following line at the end:
mouse_spawn = true

- In the 'Specific Settings for Mobs' section:
Add at the end the following:

##Mouse Specific
#To follow/tame and breed:
mouse_follow = petz:cheese
mouse_spawn_chance = 0.6
mouse_spawn_nodes = default:dirt_with_grass
mouse_predators = petz:kitty
#change here if you want it to spawn only at a one biome
#or leave 'default' for all the biomes:
mouse_spawn_biome = default

- If you want to spawn a herd of mouses, i.e. 4, add:

mouse_spawn_herd = 4

- As you defined kitty as the mouse predator, now you have to define mouse as prey in its settings.
Add (or edit if existed) the following line to "Kitty Specific":

kitty_preys = petz:mouse

2. Create a petz file where the petz will be defined.

But it is better to take an old already created one as template.
The better for mouse is piggy: no tamagochi, no orders.
Open 'piggy_mobkit.lua' and save as 'mouse_mobkit.lua'

3. Edit the 'mouse_mobkit.lua'.

- Firstly you have to replace all the 'piggy' coincidences to 'mouse'
With the aid of you text editor replace:
piggy -> mouse
Piggy -> Mouse
PIGGY -> MOUSE

- Edit the petz charateristics as you like:

- scale_model, mesh, textures, collisionbox, etc.

4. Save the 'mouse_mobkit.lua'

5. ¡DONE!

###Extra

####If you have to create a bird use 'parrot_mobkit.lua' as template.
####If you want to create a domestic pet use 'kitty_mobkit.lua' as template.
####If you want to create a wild animal use 'lion_mobkit.lua' as template.

###Tamagochi mode

If you can your mouse with this mode add/edit:

init_tamagochi_timer = false,

####Bloody Mode

In petz.conf set:

blood = true

You can set a custom texture in the hardcoded petz definition:

blood_texture = ""

You can disable the blood individually in the hardcoded petz definition:

no_blood = true

####Spawn

There is a set of spawn settings you could kie to add to the 'minetest.register_entity' definition:

spawn_at_night = true, --only spawns at night
die_at_daylight = false, --it dies at dawn
min_height = 0, --min height to spawn (0= sea level)
max_height = 30, --max height to spawn (0= sea level)
min_daylight_level = 0, --min light to spawn (min 0)
max_daylight_level = 8, --max light to spawn (max 15)

####Noxious Nodes

If mob in node, then damage it per second.

In example:

noxious_nodes  = {
	{name = "air", where ="entity", damage = 1},
},

name = name of the node
where = "stand" or "entity" (by default "entity")
damage = damage points (by default 1)
Note: Lava already makes damage so it is not necessary being defined.

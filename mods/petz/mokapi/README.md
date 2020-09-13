#  Drop Functions

## mokapi.drop_item(self, item, num)
Mob drops only one item.

## mokapi.drop_items(self, killed_by_player)

Mob drops a table list of items defined in the entity.

Example of the 'drops' definition:
```
drops = {
	{name = "petz:mini_lamb_chop", chance = 1, min = 1, max = 1,},
	{name = "petz:bone", chance = 5, min = 1, max = 1,},
},
```
## mokapi.node_drop_items(pos)

Node drops the "drops" list saved in the node metadata.

# Sound Functions

## mokapi.make_misc_sound(self, chance, max_hear_distance)
Make a random sound from the "misc" sound definition.
The misc definition can be a single sound or a table of sounds.
Example of the 'misc' definition:
```
sounds = {
	misc = {"petz_kitty_meow", "petz_kitty_meow2", "petz_kitty_meow3"},
},
```
## mokapi.make_sound(dest_type, dest, soundfile, max_hear_distance)
Make a sound on dest accordingly dest_type.

dest_type can be "object, "player" or "pos".

# Replace Function

## mokapi.replace(self, sound_name, max_hear_distance)
Replace a node to another. Useful for eating grass.

'sound_name' & 'max_hear_distance' are optionals.

Example of the 'replace_what' definition:
```
replace_rate = 10,
replace_offset = 0,
replace_what = {
	{"group:grass", "air", -1},
	{"default:dirt_with_grass", "default:dirt", -2}
},
```
3 parameters for 'replace_what': replace_what, replace_with and y_offset

# Feed & Tame Functions

## function mokapi.feed(self, clicker, feed_rate, msg_full_health, sound_type)

It returns true if fed.

It checks against a string, a stringlist separated by commas or a table of 'self.follow' items or groups.
```
self.follow = "farming:wheat"
self.follow = "group:food_meat_raw, mobs:raw_chicken"
self.follow = {"group:food_meat_raw", "mobs:raw_chicken"}
```
'feed_rate' (from 0.0 to 1.0) is the percentage to heal referenced to self.max_hp

msg_full_health is optional

sound_type is the self.sound type

## function mokapi.tame(self, feed_count, owner_name, msg_tamed, limit)
It returns true if tamed.

'feed_count' is the amount of food to get the mob tamed.

'limit' is an optional table with the following data:

1. max = The limit of the tamed mobs by player
2. count = The current number of tamed mobs of the specific player that wants to tame
3. msg = Message when the limit of tamed mobs is reached

if 'max > count + 1' then the taming process is aborted.

## function mokapi.set_owner(self, owner_name)
Put 'self.tamed' to true and the 'self.owner' name.

## function mokapi.remove_owner(self)
Put 'self.tamed' to false and the 'self.owner' to nil.

## function mokapi.set_health(self, rate)
'rate' (from 0.0 to 1.0) is the percentage of self.max_hp

rate can be positive or negative

# Helper Functions

## function mokapi.remove_mob(self)
It clears the mob HQ and LQ behaviours and then remove it from the world.

# Commands

## clear_mobs modname
It clears all the mobkit non-tamed mobs in the closest range of the player.

Modname is the mod of the mobs to clear.

# Server
## function mokapi.cron_clear(cron_time, modname)
It creates a cron task to clearing all the 'modname' non-tamed mobs in the closest range of all the server's players (or game) from time to time.

If cron_time <= 0 then the cron task does not run.

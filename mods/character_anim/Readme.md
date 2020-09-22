# Character Animations (`character_anim`)

Animates the character. Resembles [`playeranim`](https://github.com/minetest-mods/playeranim) and [`headanim`](https://github.com/LoneWolfHT/headanim).

## About

Depends on [`modlib`](https://github.com/appgurueu/modlib) and [`cmdlib`](https://github.com/appgurueu/cmdlib). Code written by Lars Mueller aka LMD or appguru(eu) and licensed under the MIT license. Media (player model) was created by [MTG contributors](https://github.com/minetest/minetest_game/blob/master/mods/player_api/README.txt) (MirceaKitsune, stujones11 and An0n3m0us) and is licensed under the CC BY-SA 3.0 license.

## Screenshot

![Image](screenshot.png)

## Links

* [GitHub](https://github.com/appgurueu/character_anim) - sources, issue tracking, contributing
* [Discord](https://discordapp.com/invite/ysP74by) - discussion, chatting
* [Minetest Forum](https://forum.minetest.net/viewtopic.php?f=9&t=25385) - (more organized) discussion
* [ContentDB](https://content.minetest.net/packages/LMD/character_anim) - releases (cloning from GitHub is recommended)

# Features

* Animates head, right arm & body
* Advantages over `playeranim`:
  * Extracts exact animations and bone positions from glTF models
  * Also animates attached players (with restrictions on angles)
* Advantages over `headanim`:
  * Provides compatibility for Minetest 5.2.0 and lower
  * Head angles are clamped, head can tilt sideways
  * Animates right arm & body as well

# Instructions

0. If you want to use a custom model, install [`binarystream`](https://luarocks.org/modules/Tarik02/binarystream) from LuaRocks:
   1. `sudo luarocks install binarystream` on many UNIX-systems
   2. Add `player_animations` to `secure.trusted_mods` (or disable mod security)
   3. Export the model as `glTF` and save it under `models/modelname.extension.gltf`
   4. Do `/ca import modelname.extension`
1. Install and use `character_anim` like any other mod
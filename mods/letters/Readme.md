## Letters: A mod for Minetest!

The majority of this code was taken (and altered significantly) from Calinou's [Moreblocks mod](https://forum.minetest.net/viewtopic.php?t=509). It is designed to add letters in all different materials. Code is licensed under the zlib license, textures under the CC BY-SA license.

The Letter Cutter textures use parts of the default wood and tree textures made by Blockmen and Cisoun respectively.

#### Allowing letters to be made from nodes:

Use this code to allow blocks to have letters registered from them:
```lua
letters.register_letters(modname, subname, from_node, description, tiles, def)
```
- Modname is the mod that the node belongs to.
- Subname is the actual name of the node.
- From_node is the node that the letters will be crafted from (Usually modname:subname).
- Description is the description of the node.
- Tiles defines the image that will be used with the node.
- Def (optional) may contain additional node definition parameters. Some might be overwritten to make the letters look and work as intended.

For example, if I wanted to register marble, from the mod darkage, this is the code I would use:
```lua
letters.register_letters("darkage", "marble", "darkage:marble", "Marble", "darkage_marble.png")
```
Add letters with unifieddye.
```lua
letters.register_letters("darkage",
	"marble",
	"darkage:marble", 
	"Marble", 
	"darkage_marble.png",
	{
		paramtype2 = "colorwallmounted", 
		palette = "unifieddyes_palette_colorwallmounted.png", 
		groups = {
			not_in_creative_inventory = 1,
			not_in_craft_guide = 1, 
			oddly_breakable_by_hand = 1, 
			attached_node = 1, 
			ud_param2_colorable = 1
		}
	}
)
```
You will need to add letters as a dependency to your mod, or include the registrations is the code:
```lua
if minetest.get_modpath("letters") then
	letters.register_letters("darkage", "marble", "darkage:marble", "Marble", "darkage_marble.png")
	--ect ect...
end
```

Most of the default nodes have already been registered, and I have added/will add mods I like, as an optional dependancy.

*This mod is fairly stable, and shouldn't crash, but be warned that it is in its early stages of development, and so things may change considerably*


**Screenshots!**
![Screenshot](https://imgrush.com/4BvHPHl70F9F.png)
![Another screenshot!](https://imgrush.com/tuOkRXixvFHY.png)


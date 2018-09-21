### Disclaimer
Drug abusing, dealing, smuggling and organized crime damaged and still damage many cities (like mine...). Minetest is just a game and Drug Wars doesn't encourage in any way illegal acts related to narcotics. Do drugs responsibly.

# **Drug Wars**

This mod adds drugs and other relative items to Minetest. It should be set in servers with a modern city environment, with cops and gangs fighting each other.

Most aspects of the mod are configurable by editing config.lua

Dependencies are stored in depends.txt

## **Plants**

Drug seed are rarely dropped by common grass. They can be used to grow plants which produce raw elements to be refined to drugs.

### **Harvesting notes**

**Opium Poppy** : The plant drops more raw opium on not mature stages (6 and 7) while dropping more petals when bloomed.

## **Drugs**

Using drugs leads to immediate buffs and debuffs and aftereffects.

Everytime a player consumes any drug it will, more or less, increase its drugs addiction, which will progressively cause damage over time, reduced drugs buffs and harder aftereffects. A player's addiction will reduce gradually while not using any narcotic.

If a drug is assumable using pipes, It should be placed in the inventory stack staying on the right of pipe's one and consumed right-clicking while wielding the pipe. Otherwise they can be directly assumed and right-clicking while wielding it should do the trick.

Name | Assumption tool | Immediate effects | Aftereffects | Addiction's increase
--- | --- | --- | --- | ---
**Weed** | Wooden pipe | Slighly heals and increases defense while reducing movement speed and increasing hunger | Gives weak damage | Low 
**Hashish** | Wooden pipe | Same as weed, but with increased effects and duration | Same as weed, but with increased effects and duration | Low 
**Cocaine** | Direct | Increases movement speed, damage and reduces hunger | Gives moderate damage | High
**Crack** | Glass pipe | Same as cocaine, but less durable and higher addictive | Same as cocaine, but less durable and higher addictive | High
**Opium** | Wooden pipe | Moderately heals and increases defense while reducing movement speed | Gives moderate damage | Very high

## **Weapons and tools**

### **Machete**

Machete is mainly used to harvest but can be also used a fast melee weapon. There are currently steel and mese machete.

### **Pipe**

Pipes are used to smoke drugs. There are currently two types of pipe, wooden and glass, and are used to assume different drugs.

### **Inventory frisk**

You can ask other players to show their inventory, this can be used by police forces to search for drugs and other illegal goods. To do that, use the command "/inv_search \<playername>" when you're near enough the player you want to frisk. He may accept with "/inv_search_accept" or run away.

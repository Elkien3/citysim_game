This mod provides a set of nodes that allow large quantities of water to be pumped from one place to another, potentially over very long distances.

**Important Note:** The default behaviour of water in Minetest does not actually lend itself well to this kind of activity. In particular, ``default:water_source`` has ``liquid_renewable = true`` set in its node definition, which often causes new water nodes to be created where old ones are removed.

This mod includes an optional setting that disables ``liquid_renewable`` for default water, but for best effect it is highly recommended that this mod be used in conjunction with the [dynamic_liquid](https://github.com/minetest-mods/dynamic_liquid) mod.

The [airtanks](https://github.com/minetest-mods/airtanks) mod can also be helpful for players who are interested in doing large-scale underwater construction projects.

A pipe network is only active when a player is near one of the terminal nodes attached to it. The map blocks containing all terminal nodes for the network will be forceloaded as long as the pipe network is active, allowing water to be added or removed from remote locations, but note that water will be unable to flow into or out from those remote map blocks into adjoining blocks so it may behoove a player to visit these places from time to time to ensure continued flow.

## Pipes

The core node type introduced by this mod is the pipe. When pipes are laid adjacent to each other they connect up to form a pipe network, to which inlets, outlets, and pumps can be connected. All contiguous pipes are part of the same network, and all terminal nodes connected to that network will be able to interact with each other through the pipes.

Pipes automatically connect to other pipes through any of their six faces.

## Terminals

Terminals can only be connected to a pipe network via one face, the side that by default is facing away from the player when they place the node in world. They interact with water only on the opposite face - the one facing toward the player when they place the node in world. Terminals require at least one pipe segment to connect to, they don't interact directly with each other.

A screwdriver can be used to reorient terminals if you want one facing upward or downward.

The types of terminals in this mod are:

* Inlets let water enter the pipe but not leave
* Outlets let water out but not in
* Grates let water flow either way depending on pressure
* Pumps are inlets that force water into the network at a higher pressure than their elevation would normally give it.

## Valves

A valve can be used to connect or disconnect sections of a pipe network with a simple right-click. When a valve is "open" it acts like a pipe section, and when it's "closed" it does not act like a pipe.

## Elevation and pressure

The flow of water through the network is determined by two main factors; the directionality of each type of terminal, and the pressure of the water at that terminal.

Water flows from high pressure terminals to low pressure terminals. The rise and fall of the pipe in between those two terminals doesn't really matter, just the pressure at the terminals themselves.

The following figure illustrates the basics of how this works with a very simple three-terminal pipe network:

![Figure 1](/screenshots/waterworks_figure_1.png)

The two terminals on the left side are "inlets", only permitting water to enter the network, and the terminal on the right is a grate that allows water in or out.

If terminal 1 were to be immersed in water, water nodes would be transferred from terminal 1 to terminal 2 because terminal 1's higher elevation gives it higher pressure than terminal 2. Water would *not* be transferred to terminal 3 as terminal 3 is an inlet only.

If terminal 2 were to be immersed, likewise no water would be transferred because although terminal 2 can allow water to enter the pipe (it's a grate) there are no valid outlet terminals it could go to.

If terminal 3 were immersed in water, no water would be transferred because terminal 2 is higher elevation and therefore there isn't enough pressure at terminal 3 to reach it.

![Figure 2](/screenshots/waterworks_figure_2.png)

In this example terminal 3 is a pump, which acts as if it were an inlet located at an elevation 100 meters higher than it actually is. There are two potential outlets for water entering the system. Water is preferentially emitted from the *lowest* pressure outlet, so if terminal 3 was immersed in water it would be sent to terminal 2. However, if terminal 2 was contained in an enclosed space that had run out of room for additional water, the water would then be sent to the next-lowest outlet and come out of terminal 1.

If terminal 1 was immersed, then water would transfer from it to terminal 2. Terminal 3 is an inlet, so water wouldn't come out of it.
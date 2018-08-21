-------------------------------------------------------------------------------------------------------------
Clump Fall Nodes
[clumpfall]
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
About
-------------------------------------------------------------------------------------------------------------
This mod is designed to allow almost every node in Minetest to fall down, similar to sand or gravel. However, there are two key differences between regular Falling Nodes and Clump Fall Nodes; first that nodes that are part of the new "clump_fall_node" group will fall down slowly in small "clumps", gradually cascading until there is nothing left in the air. The other key difference is that individual nodes don't automatically fall just because nothing is immediately underneath them. Instead, if there's a block below and to the side or corner of the node in question, then the node still won't fall. Because Clump Fall Nodes only start to fall if there are no other Clump Fall Nodes connected to their underside, lower edges, or lower corners, this means that pyramid shapes will often become structurally sound. It also means that cubic houses won't need to be completely filled with supports in order to keep their roofs from collapsing, and that giant holes won't appear on the world's surface every time a cave collapses.

-------------------------------------------------------------------------------------------------------------
Dependencies and Support
-------------------------------------------------------------------------------------------------------------
This mod has only one dependency, for the mod entitycontrol, which is used to fix some glitches with Clump Fall Behavior. Other than that, support that this mod has for others is built-in and automatic, able to effect all added nodes without much issue, and is able to correctly differentiate between nodes that should be Clump Fall Nodes and nodes that are Falling Nodes, Attached Nodes, Liquid, or Unbreakable.

-------------------------------------------------------------------------------------------------------------
License
-------------------------------------------------------------------------------------------------------------
The Apache 2.0 License is used with this mod. See http://www.apache.org/licenses/LICENSE-2.0 or LICENSE.md for more details.

-------------------------------------------------------------------------------------------------------------
Installation
-------------------------------------------------------------------------------------------------------------
Download, unzip, and place within the usual minetest/current/mods folder, and it will behave in relation to the Minetest engine like any other mod.

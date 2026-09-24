Leads Changelog
===============

0.4.0 (2025-06-14)
------------------

### Additions

- Added subtitle descriptions for sound effects.
- Added Russian translation (contributed by randomei).
- Added Spanish translation (contributed by Miguel P.L and otf31).


### Changes

- Using a lookup tool on a lead or knot now shows documentation for the lead item.
- Leads can now be knotted to Pride Flags flag poles.


### Fixes

- Fixed leads jumping to a nearby knot when a knot is removed without Object UUIDs.
- Fixed leads floating above small animals (reported by Nathan Salapat).
- Fixed a crash when a knot is punched by a Lua entity.
- Fixed a crash caused by invalid object references (reported by Bastrabun).
- Fixed leads staying attached to players when they die.


### API Changes

- The `connect_objects` function has been renamed to `add_lead`. The old name is still available as a deprecated alias.


0.3.2 (2024-01-18)
------------------

### Additions

- Added German translation (contributed by Kyoushi).


### Changes

- Increased default pull force.


### Fixes

- Leads can no longer be attached to fence gates (reported by Nathan Salapat).
- Lead knots now break when the post is removed (reported by Nathan Salapat).


0.3.1 (2023-12-27)
------------------

### Fixes

- Fixed a bug causing MineClone to crash whenever an enderman places a block (reported by Kyoushi).


0.3.0 (2023-12-21)
------------------

### Additions

- Added slack models, which can be enabled or disabled in the settings.
- Added a setting to change lead strength.
- Added a ‘Symmetrical physics’ setting.
- You can now hold Sneak to attach a new lead to a fence instead of tying the lead you're holding.


### Changes

- Object mass is now taken into account during physics calculations.
- Right-clicking a leashable entity while holding a knotted lead now attaches the entity to the lead instead of making a new lead (suggested by erlehmann).
- Tweaked lead physics.
- Leads now have an overextension timer instead of breaking immediately.
- Lead entities now preserve the metadata of the lead item, not just the name.
- Changed the scale of lead models.
- Improved performance by eliminating unnecessary property updates for lead entities.
- Improved protection and ownership logic.
- Protection now applies to all objects, not just knots.
- Reduced the impact of lag by limiting dtime in physics calculations.
- Lead length is now limited to avoid generating extremely large textures (suggested by my computer crashing).
- Improved performance when finding leads attached to an object.
- Protection no longer applies to players with the `protection_bypass` privilege.


### Fixes

- Leads can no longer be knotted to fence rails (reported by erlehmann).
- You can now break a lead or knot while holding a lead item (reported by erlehmann).
- Fixed lead items preventing nodes' right-click handlers.
- Breaking a lead in creative mode no longer gives you a lead item if you already have one.
- Aux1+clicking an entity no longer requires the player to be holding a lead item.
- Fixed a bug preventing leads from working on players.


### API Changes

- Custom lead items can now specify the texture of the lead entity with `_leads_texture`.
- Custom lead items can now override the lead's strength with `_leads_strength`.
- Entities can now customise behaviour when punched or right-clicked while holding a lead item with `_leads_on_interact`.


0.2.2 (2023-11-27)
------------------

### Fixes

- Fixed a bug preventing custom placement behaviour when placing nodes against fences (reported by laireia).
- Fixed a crash when another mod registers a node with a forced name after Leads is loaded.


0.2.1 (2023-10-08)
------------------


### Additions

- Added ‘Item drop mode’ setting.


### Fixes

- Fixed missing `settingtypes.txt`.
- Fixed lead items not dropping when broken on MineClone.
- Fixed lead items being consumed when clicking on a non-knottable node.


0.2.0 (2023-07-26)
------------------

### Additions

- Added item documentation.
- Added Asuna to the list of supported games.
- Added a setting to prevent players from leashing mobs owned by other players (suggested by fluxionary).
- Added a setting to prevent players from leashing unowned mobs.
- Added settings to allow or disallow leashing each object type (suggested by fluxionary).


### Changes

- Added Object UUIDs support. Objects are now identified by UUID where possible.|
- The 5.7+ selection box is now enabled by default.
- Cropped the in-game screenshot to 3:2.
- Tweaked the texture mapping on lead objects to improve shading.
- Leads can now be tied to bamboo from Bamboo Forest.
- Adding and removing knots now respects protection (suggested by fluxionary). This can be disabled in the settings.
- The ‘Allow leashing any entity’ setting has been renamed to ‘Allow leashing any object’, as it now includes players.


0.1.0 (2023-03-26)
------------------

### Additions

- Added more chat messages when failing to use a lead.
- Added sound effects (suggested by Wuzzy).
- Added a list of supported games to mod.conf.
- Added Hades Revisited support.
- Added Exile support.


### Changes

- Chat messages are now disabled by default (suggested by Wuzzy).
- Leads no longer break instantly when placed in an overly stretched position.
- Players are now blocked from interacting with the world for a moment after breaking a lead or knot, to prevent accidentally breaking the node behind it.
- Leads can now be tied to mechanical railway signals.


### Fixes

- Fixed smoke puffs when removing a lead or knot in multiplayer (reported by Wuzzy).
- Fixed lead items being consumed even if the lead failed to spawn.
- Fixed leads jumping to another knot when untied.
- Added a workaround for a bug in Lord of the Test preventing fences from being supported.


0.0.0 (2023-03-20)
------------------

- Initial release.

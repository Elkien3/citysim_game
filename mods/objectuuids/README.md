Object UUIDs
============

[ContentDB](https://content.minetest.net/packages/SilverSandstone/objectuuids/)

This mod assigns a persistent UUID to every player and entity in the game.
Other mods can get an object's UUID or find an object by its UUID using the public API.

UUIDs are persistent between game sessions, and player UUIDs are also
persistent between worlds and servers.

If this mod is removed, entities will not lose their data.


API Summary
-----------

- `objectuuids.get_uuid(object)`                                    - Returns the UUID assigned to the specified object.
- `objectuuids.get_object_by_uuid(uuid)`                            - Returns the object with the specified UUID.
- `objectuuids.set_uuid(object, uuid)`                              - Overrides the specified object's UUID.
- `objectuuids.add_entity_with_uuid(pos, name, uuid, [staticdata])` - Spawns a new entity with the specified UUID.

See `doc/index.html` for full API documentation.


License
-------

Object UUIDs by Silver Sandstone is licensed under the MIT license.

See `LICENSE.txt` for more information.

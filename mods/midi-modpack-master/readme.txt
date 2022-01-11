This modpack adds the ability to play midi files with whatever instruments it's provided, and a record stamp and player as an interface for playing.

To play a midi file to yourself, simply do '/midi midifile.mid'
midi files must be placed in midi-modpack-master\midi\midi\, there is a midis_here.txt to know when it's the correct directory.

To use the record stamper, you first convert a binary midi file to minetest formspec friendly base64 with the command /midiconvert.
A window will pop up with the midi file in base64 format, you must select it and copy it to your computer's clipboard. (using ctrl-a is highly recommended)
Then you rightclick the record stamper and paste the data into the correct field, put in a record (new or used), add a description, and press the "stamp" button. the record in the inventory slot will be marked with the song data, and can then be used in a record player.
If there is an issue of any kind with the stamping a self-explanatory error message will appear on the stamper's formspec.
base64 midi files must have fewer than 20000 characters by default or it will not allow you to press. (this is double the size allowed for default books)

You can put a local midi file onto an external/public server by downloading the modpack, putting the midi file to be converted into the appropriate folder, running the modpack on a local world, and copying the results from '/midiconvert midifile.mid', and pasting them into a record stamper on the destination server.

I currently have one default midi file that comes with the mod, called "simpleboogiewoogie.mid"
as with any other midi files you add, you can play to yourself with '/midi simpleboogiewoogie.mid', and convert to base64 for use in a record stamper with '/midiconvert simpleboogiewoogie.mid'
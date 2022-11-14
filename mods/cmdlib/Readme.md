# Chatcommand Library (`cmdlib`)
Making chatcommands a pleasure to use.

## About
Adds a few features to chatcommands useful for devs (parsing, trees, forbidden privs, etc),
and other features useful for players, such as suggestions, command trees, and a better help command.

**Note : Overrides `/help` chatcommand and `builtin` functions (`minetest.register_chatcommand`), replaces chatcommand handler.**

Depends on [`modlib`](https://github.com/appgurueu/modlib). IntelliJ IDEA with EmmyLua plugin project.
Code & media by Lars Mueller aka LMD or appguru(eu). Licensed under GPLv3.

Links : [GitHub](https://github.com/appgurueu/cmdlib), [Minetest Forum](https://forum.minetest.net/viewtopic.php?t=23055), [Content DB](https://content.minetest.net/packages/LMD/cmdlib/)

## Screenshot

![Screenshot](https://github.com/appgurueu/cmdlib/blob/master/screenshot.png)

## API

A few API methods are listed below. Browse the code for more.
Three parts are provided by `cmdlib` : 

* Trie data structure
* Help command
* Chatcommand utils (main part)

### `cmdlib.register(name, def)`

Name (`name`) : Chatcommand name, including whitespaces (such as `mod command`)

Definition (`def`) : Table with entries `params`, `custom_syntax`, `implicit_call`, `description`, `privs`, and `func`

* Params: Argument syntax, string, format of `<required_param> [optional_param]`, or `{param}` for zero or more occurrences.
  Needs required params first, then optional ones, and finally, an optional list
* Custom syntax: Flag, if set to true, `func` will be called with string params (empty string if none given). Automatically true if params string is invalid.
* Implicit call: Metacommands only. If set to true, chatcommand will be called instead of proposing subcommand. Automatically true if `params` are specified.
* Description: Text describing the usage of the chatcommand
* Privileges: Table with privs which are required or should be missing, like `{priv1=true, priv2=false}`
* Function: Function being invoked with `sendername` and a table of parameters (`{param1="..."}`), `{params}` will be supplied as tables

### `trie.new()`

Creates (returns) a new trie (empty table).

### `trie.insert(trie, word, [value], [overwrite])`

Inserts a word into a trie. `value` is optional (defaults to `true`). 
`overwrite` is optional as well and defaults to `false`. Returns previous value.

### `trie.remove(trie, word)`

Removes word from trie. Returns previous value.

### `trie.get(trie, word)`

Check if trie contains word and return corresponding value, or `nil`.

### `trie.search(trie, word)`

Search for word in trie. Return value if found, else (nil, closest word, value) or `nil` if no closest word exists.

## Invocation

Invoke a chatcommand by giving the params separated by whitespaces (like `/cmd subcmd param1 param2`).

## Help

Use `/help [query]` to open the extremely useful formspec shown above.

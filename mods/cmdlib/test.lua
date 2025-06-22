function test_format()
    minetest.after(1, function()
        minetest.chat_send_all(minetest.get_color_escape_sequence("#FF0000")..[[✗ Looks like there's an error ! (!) /!\
]]..minetest.get_color_escape_sequence("#00FF00")..[[✓ All is alright yay ! (i) (x)]])
    end)
end

function test_chatcommands(explicit_supercommand)
    if explicit_supercommand then
        cmdlib.register_chatcommand("cmdlib_test", {
            params = "<param1>",
            privs = {fast = true},
            description = "Test command for cmdlib.",
            func = function(sendername, params)
                return true, "You shouted "..(params.param1)
            end
        })
    end
    cmdlib.register_chatcommand("this", {
        params = "<param1>",
        func = function() end
    })
    cmdlib.unregister_chatcommand("this")
    cmdlib.register_chatcommand("cmdlib_test say", {
        params = "<param1>",
        privs = {fast = true, noclip = false},
        description = "Test command for cmdlib.",
        func = function(sendername, params)
            return true, "You said "..(params.param1)
        end
    })
    cmdlib.register_chatcommand("cmdlib_test repeat", {
        params = "<param1>",
        privs = {fast = true},
        description = "Test command for cmdlib.",
        func = function(sendername, params)
            return true, "Param1: "..(params.param1)
        end
    })
    cmdlib.register_chatcommand("cmdlib_test shout loud", {
        params = "[param1]",
        privs = {fast = true},
        description = "Test command with a different description.",
        func = function(sendername, params)
            return true, "You SHOUTED "..(params.param1 or "IDK")
        end
    })
    cmdlib.unregister_chatcommand("cmdlib_test shout loud")
end

function test_trie()
    local t = trie.new()
    trie.insert(t, "help")
    trie.insert(t, "heap")
    trie.insert(t, "me")
    print(trie.search(t, "hewp"))
    trie.remove(t, "heap")
    print(trie.search(t, "help"))
    print(trie.search(t, "heap"))
end

function test_info()
    minetest.register_on_mods_loaded(function()
        print(dump(cmdlib.chatcommand_info))
        print(dump(cmdlib.chatcommand_info_by_mod))
    end)
end

-- test_chatcommands()
-- test_format()
-- test_trie()
-- test_info()
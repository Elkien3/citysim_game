function show_help_formspec(sendername, query)
    local chatcommand_info = chatcommand_help
    if query then
        local query = query:lower()
        local function search(chatcommands)
            local new_info = {}
            for _, def in ipairs(chatcommands) do
                local def = modlib.table.tablecopy(def)
                if def.name:lower():find(query, 1, true) or def.description:lower():find(query, 1, true) then
                    table.insert(new_info, def)
                elseif def.subcommands then
                    def.subcommands = search(def.subcommands)
                    if next(def.subcommands) then
                        table.insert(new_info, def)
                    end
                end
            end
            return new_info
        end
        chatcommand_info = search(chatcommand_info)
    else
        query = ""
    end
    local tablecontent = {}
    local function traverse_commands(commands, number, scope)
        for _, info in ipairs(commands) do
            local function cell(value)
                table.insert(tablecontent, value)
            end
            local function row(signcolor, level, ...)
                cell(signcolor or "")
                cell(level or number)
                local packed = { ... }
                for i = 1, 4 do
                    cell(minetest.formspec_escape(packed[i] or ""))
                end
            end
            local name = info.name or "No name"
            local sub_scope = info.is_mod and scope or (scope .. name .. " ")
            local missing, to_lose = validate_privs_ipairs(info.privs or {}, info.forbidden_privs or {}, minetest.get_player_privs(sendername))
            local privs = next(missing) or next(to_lose)
            local red_or_green = (privs and "#FF0000") or "#00FF00"
            row(red_or_green, number, red_or_green, name, "#FFFF00", info.descriptions[1] .. ((#info.descriptions > 1 and "...") or ""))
            for i = 2, #info.descriptions do
                row("#FFFF00", number + 1, "#FFFF00", info.descriptions[i])
            end
            if not info.is_mod then
                row("#FFFF00", number + 1, "#FFFF00", "/" .. sub_scope .. (info.params or ""))
            end
            --
            if info.privs or info.forbidden_privs then
                table.insert(tablecontent, "#FF0000")
                table.insert(tablecontent, number + 1)
                if info.privs then
                    table.insert(tablecontent, "#00FF00")
                    table.insert(tablecontent, minetest.formspec_escape("Required: " ..
                            table.concat(info.privs, ", ")))
                end
                if info.forbidden_privs then
                    table.insert(tablecontent, "#FF0000")
                    table.insert(tablecontent, minetest.formspec_escape("Forbidden: " ..
                            table.concat(info.forbidden_privs, ", ")))
                end
                if not info.privs or not info.forbidden_privs then
                    table.insert(tablecontent, "#FFFFFF")
                    table.insert(tablecontent, "")
                end
                --
                if next(missing) or next(to_lose) then
                    table.insert(tablecontent, "#FF0000")
                    table.insert(tablecontent, number + 1)
                    if next(missing) then
                        table.insert(tablecontent, "#00FF00")
                        table.insert(tablecontent, minetest.formspec_escape("Missing: " .. table.concat(missing, ", ")))
                    end
                    if next(to_lose) then
                        table.insert(tablecontent, "#FF0000")
                        table.insert(tablecontent, minetest.formspec_escape("To lose: " .. table.concat(to_lose, ", ")))
                    end
                    if not next(missing) or not next(to_lose) then
                        table.insert(tablecontent, "#FFFFFF")
                        table.insert(tablecontent, "")
                    end
                end
            end
            if info.subcommands then
                traverse_commands(info.subcommands, number + 1, sub_scope)
            end
        end
    end
    traverse_commands(chatcommand_info, 1, "")
    tablecontent = table.concat(tablecontent, ",")
    minetest.show_formspec(sendername, "cmdlib:help",
[[size[12,8]
real_coordinates[true]
image_button[0.25,0.25;0.75,0.75;cmdlib_trash.png;clear;]
tooltip[clear;Clear]
field[1,0.25;7.5,0.75;query;;]] .. minetest.formspec_escape(query) .. [[]
tooltip[query;Search]
field_close_on_enter[query;false]
image_button[7.75,0.25;0.75,0.75;cmdlib_magnifying_glass.png;search;]
tooltip[search;Search]
image_button_exit[11,0.25;0.75,0.75;cmdlib_cross.png;close;]
tooltip[close;Close]
tablecolumns[color,align=inline;tree,align=inline;color,align=inline;text,align=inline;color,align=inline;text,align=inline,padding=2]
table[0.25,1;11.5,6.75;commands;]] .. tablecontent .. [[;]
]])
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "cmdlib:help" and not fields.close then
        if fields.clear then
            cmdlib.show_help_formspec(player:get_player_name())
        elseif fields.search or fields.query then
            cmdlib.show_help_formspec(player:get_player_name(), fields.query)
        end
    end
end)

cmdlib.register_chatcommand("help", {
    params = "[query]",
    description = "List chatcommands or query them.",
    func = function(sendername, params)
        cmdlib.show_help_formspec(sendername, params.query)
        return true
    end
}, true)

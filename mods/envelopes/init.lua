minetest.register_craftitem("envelopes:envelope_blank", {
    description = "Blank Envelope",
    inventory_image = "envelopes_envelope_blank.png",
    on_use = function(itemstack, user, pointed_thing)
        minetest.show_formspec(user:get_player_name(), "envelopes:input", 
            "size[5.5,5.5]" ..
            "field[2,0.5;3.5,1;addressee;Addressee;]" ..
            "label[0,0;Write a letter]" ..
            "textarea[0.5,1.5;5,3;text;Text;]" ..
            "field[3,4.8;2.5,1;attn;Attn. (Optional);]" ..
            "button_exit[0.25,4.5;2,1;exit;Seal]")
        return itemstack
    end
})

minetest.register_craftitem("envelopes:envelope_sealed", {
    description = "Sealed Envelope",
    inventory_image = "envelopes_envelope_sealed.png",
    stack_max = 1,
    groups = {not_in_creative_inventory = 1},
    on_use = function(itemstack, user, pointed_thing)
        meta = itemstack:get_meta()
        if user:get_player_name() == meta:get_string("receiver") then
            open_env = ItemStack("envelopes:envelope_opened")
            open_meta = open_env:get_meta()
            open_meta:set_string("sender", meta:get_string("sender"))
            open_meta:set_string("receiver", meta:get_string("receiver"))
            open_meta:set_string("text", meta:get_string("text"))
            local desc = ("Opened Envelope\nTo: " .. meta:get_string("receiver") .. "\nFrom: " .. meta:get_string("sender"))
            open_meta:set_string("description", desc)
            if meta:get_string("attn") ~= "" then
                open_meta:set_string("attn", meta:get_string("attn"))
                desc = desc .. "\nAttn: " .. meta:get_string("attn")
                open_meta:set_string("description", desc)
            end
            return open_env
        end
        minetest.chat_send_player(user:get_player_name(), "The seal can only be opened by the addressee!")
        return itemstack
    end
})

minetest.register_craftitem("envelopes:envelope_opened", {
    description = "Opened Envelope",
    inventory_image = "envelopes_envelope_opened.png",
    stack_max = 1,
    groups = {not_in_creative_inventory = 1},
    on_use = function(itemstack, user, pointed_thing)
        local meta = itemstack:get_meta()
        local sender = meta:get_string("sender")
        local receiver = meta:get_string("receiver")
        local text = meta:get_string("text")
        local attn = meta:get_string("attn") or ""
        local form = 
            "size[5,5]" ..
            "label[0,0;A letter from " .. sender .. " to " .. receiver
        if attn ~= "" then
            form = form .. "\nAttn: " .. attn
        end
        form = form .. "\n" .. text .. "]" .. "button_exit[0,4;2,1;exit;Close]"
        minetest.show_formspec(user:get_player_name(), "envelope:display", form)
    end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "envelopes:input" or not minetest.is_player(player) then
        return false
    end

    if fields.addressee == "" or fields.addressee == nil or fields.text == "" or fields.text == nil then
        minetest.chat_send_player(player:get_player_name(), "Please fill out all required fields.")
        return true
    end

    local inv = player:get_inventory()
    local letter = ItemStack('envelopes:envelope_sealed')
    local blank = ItemStack('envelopes:envelope_blank')
    local meta = letter:get_meta()

    meta:set_string("sender", player:get_player_name())
    meta:set_string("receiver", fields.addressee)
    meta:set_string("text", fields.text)

    local desc = ("Sealed Envelope\nTo: " .. fields.addressee .. "\nFrom: " .. player:get_player_name())
    meta:set_string("description", desc)

    if fields.attn ~= "" then
        meta:set_string("attn", fields.attn)
        desc = desc .. "\nAttn: " .. fields.attn
        meta:set_string("description", desc)
    end

    if inv:room_for_item("main", letter) and inv:contains_item("main", blank) then
        inv:add_item("main", letter)
        inv:remove_item("main", blank)
    else
        minetest.chat_send_player(player:get_player_name(), "Unable to create letter! Check your inventory space.")
    end

    return true
end)

minetest.register_craft({
    type = "shaped",
    output = "envelopes:envelope_blank 1",
    recipe = {
        {"", "", ""},
        {"default:paper", "default:paper", "default:paper"},
        {"default:paper", "default:paper", "default:paper"}
    }
})
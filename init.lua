onion = {}

local modpath = minetest.get_modpath(minetest.get_current_modname())
dofile(modpath.."/config.lua")
dofile(modpath.."/functions.lua")
--Initialize the oragin as null

local write_file = function()
    local f = io.open(onion.FN, "w")
    local data_string = minetest.serialize(onion.oragin)
    f:write(data_string)
    io.close(f)
end

minetest.register_craftitem("onion:wand",{
    description = "Sets the center of the xp onion",
    inventory_image = "onion_Wand.png",
    -- on right click create a global variable that specifies the oragin of the onion. 
    on_use = function(itemstack, user, pointed_thing)
        onion.oragin = user:get_pos()
        minetest.chat_send_all("Onion Activated")
        write_file()
    end
})

onion.init()
minetest.after(5,onion.scan)
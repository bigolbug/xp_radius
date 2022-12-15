local modpath = minetest.get_modpath(minetest.get_current_modname())
dofile(modpath.."/config.lua")
dofile(modpath.."/functions.lua")

-- Register Wand
minetest.register_craftitem("onion:wand",{
    description = "Sets the center of the xp onion",
    inventory_image = "onion_Wand.png",
    groups = {not_in_creative_inventory = 1},
    -- on right click create a global variable that specifies the oragin of the onion. 
    on_use = function(itemstack, user, pointed_thing)
        onion.oragin = user:get_pos()
        minetest.chat_send_all("Onion Activated")
        onion.write_file()
    end
})

--Register any privs
minetest.register_privilege("onion:admin",{description = "You are not resticted by the onion"})
minetest.register_privilege("onion:CB",{description = "Priv used for temp privs during the christmas season"})

--Initialize critical variables. 
onion.init()

--Wait 5 seconds after loading game to begin. 
minetest.after(5,onion.scan)
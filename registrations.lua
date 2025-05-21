-- Register Wand
minetest.register_craftitem("xp_radius:wand",{
    description = "Sets the center of the xp xp_radius",
    inventory_image = "xp_radius_Wand.png",
    groups = {not_in_creative_inventory = 1},
    -- on right click create a global variable that specifies the oragin of the xp_radius. 
    on_use = function(itemstack, user, pointed_thing)
        xp_radius.oragin = user:get_pos()
        minetest.chat_send_all("Onion Activated")
        xp_radius.write_file()
    end
})

--Register any privs
minetest.register_privilege("xp_radius:admin",{description = "You are not resticted by the xp_radius"})
minetest.register_privilege("xp_radius:CB",{description = "Priv used for temp privs during the christmas season"})

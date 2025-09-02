local modpath = core.get_modpath(core.get_current_modname())

dofile(modpath.."/config.lua")
dofile(modpath.."/API.lua")
dofile(modpath.."/chatcommands.lua")

-- Register Wand - This is the old method for setting up the radius
--[[
core.register_craftitem("xp_radius:wand",{
    description = "Sets the center of the xp xp_radius",
    inventory_image = "xp_radius_Wand.png",
    groups = {not_in_creative_inventory = 1},
    -- on right click create a global variable that specifies the oragin of the xp_radius. 
    on_use = function(itemstack, user, pointed_thing)
        xp_radius.oragin = user:get_pos()
        local name = 
        core.chat_send_all("xp_radius Activated")
        xp_radius.write_file()
    end
})
]]

--Register any privs
core.register_privilege("xp_radius:admin",{description = "You are not resticted by the xp_radius"})
core.register_privilege("xp_radius:CB",{description = "Priv used for temp privs during the christmas season"})

-- Main Function 
core.register_globalstep(function(dtime)
    local current_time = os.time()
    local last_time = xp_radius.metadata:get_float("last_time")
    local time_dif = current_time - last_time
    
    if time_dif > xp_radius.interval then
        --core.chat_send_all(time_dif)
        if xp_radius.metadata:get_string("enabled") then
            --Mod is enabled but should we scan? - Not Used
            --local last_scan = xp_radius.metadata:get_int("last_scan")
            xp_radius.metadata:set_float("last_time",current_time)
            xp_radius.scan()
        end
    end
end)
local modpath = minetest.get_modpath(minetest.get_current_modname())
dofile(modpath.."/config.lua")
dofile(modpath.."/functions.lua")
dofile(modpath.."/chatcommands.lua")
dofile(modpath.."/registrations.lua")

--Initialize critical variables. 
xp_radius.init()

--Wait 5 seconds after loading game to begin. 
minetest.after(5,xp_radius.scan)
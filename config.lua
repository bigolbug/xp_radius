
xp_radius = {}
xp_radius.metadata = core.get_mod_storage()
xp_radius.interval = 1
xp_radius.ranks = {6000,9000,12000, 24000, 48000, 100000}
xp_radius.rads = {400,500,700, 900, 1200, 2400}
xp_radius.floor = {200,250,300, 400, 500, 1000}
--xp_radius.FN = core.get_worldpath().."/xp_radius.txt"
xp_radius.cprivs = {} -- Current Chapters Mod Privs
xp_radius.CB = 200 -- This is the christmas bonus radius
xp_radius.h_xp_divisor = 50
xp_radius.v_xp_divisor = 100
xp_radius.scan_interval = 5
xp_radius.debuglevel = "error" -- options "info" "none", "error", "warning", "action", or "verbose"
xp_radius.chapters_Enable = false


-- This is not needed since the default return from int is 0. 
--[[
if xp_radius.metadata:get_int("enabled") == 0 then
    xp_radius.metadata:set_string("enabled",false)
end
]]

--Get list of install privileges
local privs = core.registered_privileges

--Populate Privs Table
for priv, def in pairs(privs) do
    if string.find(priv,"chapters") ~= nil and string.find(priv,"-c") ~= nil then
        table.insert(xp_radius.cprivs,priv)
    end
end
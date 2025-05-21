xp_radius = {}
xp_radius.interval = 3
xp_radius.oragin = nil
xp_radius.ranks = {6000,9000,12000, 24000, 48000, 100000}
xp_radius.rads = {400,500,700, 900, 1200, 2400}
xp_radius.floor = {200,250,300, 400, 500, 1000}
xp_radius.FN = minetest.get_worldpath().."/xp_radius.txt"
xp_radius.cprivs = {} -- Current Chapters Mod Privs
xp_radius.CB = 200 -- This is the christmas bonus radius
xp_radius.xp_divisor = 50

--Get list of install privileges
local privs = minetest.registered_privileges

--Populate Privs Table
for priv, def in pairs(privs) do
    if string.find(priv,"chapters") ~= nil and string.find(priv,"-c") ~= nil then
        table.insert(xp_radius.cprivs,priv)
    end
end
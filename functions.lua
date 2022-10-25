onion.radius = function (pxp,player) -- Pass in player XP and objectref
    --Bypass if player is Onion Admin
    if minetest.check_player_privs(player,"onion:admin") then
        return 40000
    end

    local radius = 100
    --Return the radius of the player
    local privs = minetest.check_player_privs(player)
    for index, priv in ipairs(onion.cprivs) do
        if not minetest.check_player_privs(player,priv) then
            local pRad = index*400
            --Determine Radius based on XP
            for index, xp in ipairs(onion.ranks) do
                if pxp < xp then
                    local xRad = ((onion.ranks[index]/10) -200)
                    if xRad < pRad then
                        return xRad
                    else
                        return pRad
                    end
                end
            end
        else

        end
    end
end

onion.init = function ()
    
    local f = io.open(onion.FN, "r")
    if f then   -- file exists
        local data_string = f:read("*all")
        onion.oragin = minetest.deserialize(data_string)
        io.close(f)
    end

    --if there isn't a file...
    --do nothing
end

function onion.permit(rad, pos)
    local ceiling = 32000
    local floor = rad/2
    local prad = {x = math.abs(onion.oragin.x - pos.x), z = math.abs(onion.oragin.z - pos.z), y = onion.oragin.y - pos.y}
    if prad.x > rad or prad.z > rad or prad.y > floor then
        --player outside of radius
        return true 
    end

    --player is within radius
    return false
end

onion.scan = function()
    if onion.oragin == nil then
        minetest.after(onion.interval*5,onion.scan)
        return false 
    end

    local activePlayers = minetest.get_connected_players()
    for index, player in ipairs(activePlayers) do
        --initialize variables
        local radius = nil

        --Get the player position 
        local pos = player:get_pos()
        local name = player:get_player_name()
        
        --Get the player XP
        local currentXp = xp_redo.get_xp(name)

        --Determine players distance from oragin. 
        local d = vector.distance(pos, onion.oragin)

        -- Get player Meta Data
        local pmeta = player:get_meta() -- player Meta

        --Check to see if onion exists in meta
        --If it does not then create onion in meta with coordinates at the onion oragin
        if pmeta:get_string("onion") == "" then
            pmeta:set_string("onion",minetest.serialize(onion.oragin))    
        end

        --Determine permitted radius
        radius = onion.radius(currentXp,player)

        if radius == nil then
            minetest.debug("Onion Player Error: "..name.." radius not defined. Defaulting to 100 nodes.")
            radius = 100
        end

        if onion.permit(radius,pos) then
            minetest.chat_send_player(player:get_player_name(), "You are outside your XP radius, returning you to a previous valid location")
            ppos = minetest.deserialize(pmeta:get_string("onion")) -- Previous valid location
            player:move_to(ppos, true)
        else
            --Record Valid Location
            pmeta:set_string("onion",minetest.serialize(pos))
        end

    end
    
    --For testing purposes
    --minetest.chat_send_all(os.clock())
    
    --Run this function again after interval
    minetest.after(onion.interval,onion.scan)
end
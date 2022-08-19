onion.radius = function (pxp) -- Pass in player XP
    --return the radius of the player
    for index, xp in ipairs(onion.ranks) do
        if pxp < xp then
            return ((onion.ranks[index]/10) -200)
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

onion.scan = function()
    if onion.oragin == nil then
        minetest.after(onion.interval*5,onion.scan)
        return false 
    end

    local activePlayers = minetest.get_connected_players()
    for index, player in ipairs(activePlayers) do
        --initialize variables
        local radius = 100

        --Get the player position 
        local pos = player:get_pos()
        
        --Get the player XP
        local currentXp = xp_redo.get_xp(player:get_player_name())

        --Determine if we need to move the player back
        local d = vector.distance(pos, onion.oragin)
        --minetest.chat_send_all(d)

        -- Get player Meta Data
        local pmeta = player:get_meta() -- player Meta
        

        --Check to see if onion exists in meta
        --If it does not then create onion in meta with cordinates at the onion oragin
        if pmeta:get_string("onion") == "" then
            pmeta:set_string("onion",minetest.serialize(onion.oragin))    
        end

        --Determine permitted radius
        radius = onion.radius(currentXp)

        --[[
        minetest.chat_send_all("x: ".. math.abs(onion.oragin.x - pos.x))
        minetest.chat_send_all("z: ".. math.abs(onion.oragin.z - pos.z))
        minetest.chat_send_all("y: ".. math.abs(onion.oragin.y - pos.y))
        ]]--
        if radius < math.abs(onion.oragin.x - pos.x) or radius < math.abs(onion.oragin.z - pos.z) or radius/2 < math.abs(onion.oragin.y - pos.y) then
            minetest.chat_send_all("you are outside")
            --Teleport player to last known valid location
            --minetest.chat_send_all("teleport")
            minetest.chat_send_player(player:get_player_name(), "You are outside your XP radius, returning you to previous valid location")
            ppos = minetest.deserialize(pmeta:get_string("onion")) -- Previous valid location
            player:move_to(ppos, true)
        else
            --Record Valid Location
            pmeta:set_string("onion",minetest.serialize(pos))
        end
        --[[
        if d > radius then
            --Teleport player to last known valid location
            --minetest.chat_send_all("teleport")
            minetest.chat_send_player(player:get_player_name(), "You are outside your XP radius, returning you to previous valid location")
            ppos = minetest.deserialize(pmeta:get_string("onion")) -- Previous valid location
            player:move_to(ppos, true)
        else
            --Record Valid Location
            pmeta:set_string("onion",minetest.serialize(pos))    
        end
        ]]--
    end
    
    --For testing purposes
    --minetest.chat_send_all(os.clock())
    
    --Run this function again after interval
    minetest.after(onion.interval,onion.scan)
end
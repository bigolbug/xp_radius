--Function to initialize the oragin as null
xp_radius.write_file = function()
    local f = io.open(xp_radius.FN, "w")
    local data_string = core.serialize(xp_radius.oragin)
    f:write(data_string)
    io.close(f)
end

xp_radius.bonus = function (player)
    --initialize Variables
    local bonus = 0
    
    -- Get player Meta Data
    local pmeta = player:get_meta() -- player Meta

    --Test to see if the player has the priv
    if core.check_player_privs(player,"xp_radius:CB") then
        --If the Meta Setting is off turn on. 
        if pmeta:get_string("xp_radius-CB") == "off" then
            pmeta:set_string("xp_radius-CB","on")
        end
        bonus = bonus + xp_radius.CB
    else
        --If the player does not have the priv, check for recent deactivation
        if pmeta:get_string("xp_radius-CB") == "on" then
            pmeta:set_string("xp_radius-CB","off")
            return "reset"
        end
        -- Do not contribute anything to bonus
    end

    return bonus
end

xp_radius.radius = function (pxp,player) -- Pass in player XP and objectref\

    --Bypass if player is Onion Admin
    if core.check_player_privs(player,"xp_radius:admin") then
        return 40000, 40000
    end

    local bonus = xp_radius.bonus(player)
    if bonus == "reset" then
        return "reset"
    end

    -- XP Radius bonus
    local xRad = math.floor(pxp/xp_radius.xp_divisor)

    -- Radius is primarily determined based on chapter progression. 
    for index, priv in ipairs(xp_radius.cprivs) do
        -- Check to see if the player has current priv
        if not core.check_player_privs(player,priv) then
            --return player rad and floor
            return (xp_radius.rads[index] + bonus + xRad),(xp_radius.floor[index] + bonus)
        else

        end
    end


    --[[ This is the old way of determining radius where XP had a greater weight. 
    for index, priv in ipairs(xp_radius.cprivs) do
        -- Check to see if the player had current priv
        if not core.check_player_privs(player,priv) then
            --Player had current priv now check XP
            local pRad = index*400
            --Determine Radius based on XP
            for index, xp in ipairs(xp_radius.ranks) do
                if pxp < xp then
                    local xRad = ((xp_radius.ranks[index]/10) -200)
                    if xRad < pRad then
                        return xRad + bonus
                    else
                        return pRad + bonus
                    end
                end
            end
        else

        end
    end
    ]]--

end

xp_radius.init = function ()
    
    local f = io.open(xp_radius.FN, "r")
    if f then   -- file exists
        local data_string = f:read("*all")
        xp_radius.oragin = core.deserialize(data_string)
        io.close(f)
    end

    --if there isn't a file...
    --do nothing
end

function xp_radius.permit(rad, floor, pos)
    local ceiling = 32000
    local prad = {x = math.abs(xp_radius.oragin.x - pos.x), z = math.abs(xp_radius.oragin.z - pos.z), y = xp_radius.oragin.y - pos.y}
    if prad.x > rad or prad.z > rad or prad.y > floor then
        --player outside of radius
        return true
    end

    --player is within radius
    return false
end

--This is the fuction that is used to process the player list every few seconds
xp_radius.scan = function()
    -- If oragin has not been set skip everything
    if xp_radius.oragin == nil then
        --core.chat_send_player("MacLean","Onion oragin has not been set or has expired. Please reset with the wand")
        core.log("Onion oragin has not been set or has expired. Please reset with the item xp_radius:wand")
        core.after(xp_radius.interval*5,xp_radius.scan)
        return false 
    end

    local activePlayers = core.get_connected_players()
    for index, player in ipairs(activePlayers) do
        

        --initialize variables
        local radius = nil
        local floor = nil

        --Get the player position and vectors
        local pos = player:get_pos()
        local name = player:get_player_name()

        --Get the player XP
        local currentXp = xp_redo.get_xp(name)

        --Determine players distance from oragin. 
        local d = vector.distance(pos, xp_radius.oragin)

        -- Get player Meta Data
        local pmeta = player:get_meta() -- player Meta

        --Check to see if xp_radius exists in meta
        --If it does not then create xp_radius in meta with coordinates at the xp_radius oragin
        if pmeta:get_string("xp_radius") == "" then
            pmeta:set_string("xp_radius",core.serialize(xp_radius.oragin))    
        end
        --initialize the christmas bonus Meta settings. Set init Value to off
        if pmeta:get_string("xp_radius-CB") == "" then
            pmeta:set_string("xp_radius-CB","off")
        end

        --Determine permitted radius
        radius,floor = xp_radius.radius(currentXp,player)
        --core.chat_send_all("DEBUG: Radius - "..radius)

        if radius == nil then
            core.debug("Onion Player Error: "..name.." radius not defined. Defaulting to 100 nodes.")
            radius = 100
        end

        if radius == "reset" then
            core.chat_send_player(player:get_player_name(), "XP radius reset activated, returning you to XP oragin. You don-bin down graded")
            player:move_to(xp_radius.oragin, true)
        elseif xp_radius.permit(radius,floor,pos) then
            -- The player is outside their permitted area.
            
            --core.chat_send_player(name, ">: ) You never escape da XP radius, Moo Moo Ha. Go back now")
            --Calculate the return direction from current location. 
            --minetest.chat_send_all(vector.to_string(op_vector))

            --Check look direction

            --Move the player to a valid location
            ppos = core.deserialize(pmeta:get_string("xp_radius")) -- Previous valid location


            local p_vector = vector.floor(vector.new(pos))
            --core.chat_send_all(vector.to_string(p_vector))
            local o_vector = vector.floor(vector.new(xp_radius.oragin))
            --core.chat_send_all(vector.to_string(o_vector))
            local op_vector = vector.floor(vector.subtract(o_vector,p_vector))
            --core.chat_send_all(vector.to_string(op_vector))
            --core.chat_send_all(vector.length(op_vector))
            local direction = vector.direction(pos,xp_radius.oragin)
            --core.chat_send_all(vector.to_string(vector.direction(pos,xp_radius.oragin)))
            local oragin_direction = math.atan2(direction.x,-direction.z)+math.pi
            local look_direction = player:get_look_horizontal()
            local D_Angle = math.abs(oragin_direction - look_direction)
            --core.chat_send_all(D_Angle)
            if .5 < D_Angle and D_Angle < 5.8 then
                player:set_look_horizontal(oragin_direction)
            end

            player:move_to(ppos, true)
        else
            --Record Valid Location
            pmeta:set_string("xp_radius",core.serialize(pos))
        end

    end
    
    --For testing purposes
    --core.chat_send_all(os.clock())
    
    --Run this function again after interval
    core.after(xp_radius.interval,xp_radius.scan)
end


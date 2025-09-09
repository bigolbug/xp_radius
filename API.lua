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

    --Bypass if player is xp_radius Admin
    if core.check_player_privs(player,"xp_radius:admin") then
        return 40000, 40000
    end

    local bonus = xp_radius.bonus(player)
    if bonus == "reset" then
        return "reset"
    end

    -- XP Radius bonus
    local HRad = math.floor(pxp/xp_radius.h_xp_divisor)
    local VRad = math.floor(pxp/xp_radius.v_xp_divisor)
    if HRad < xp_radius.rads[1] then HRad = xp_radius.rads[1] + HRad - xp_radius.rads[1]/2 end
    if VRad < xp_radius.floor[1] then VRad = xp_radius.floor[1] + VRad - xp_radius.floor[1]/2 end

    --Cap the XP radius. 
    if HRad > xp_radius.rads[#xp_radius.rads] then HRad = xp_radius.rads[#xp_radius.rads] end
    if VRad > xp_radius.floor[#xp_radius.floor] then VRad = xp_radius.floor[#xp_radius.floor] end

    -- Radius is primarily determined based on chapter progression. 
    if xp_radius.chapters_Enable then
        for index, priv in ipairs(xp_radius.cprivs) do
            -- Check to see if the player has current priv
            if not core.check_player_privs(player,priv) then
                --return player rad and floor
                --return (xp_radius.rads[index] + bonus + HRad),(xp_radius.floor[index] + bonus)
            else

            end
        end
    end
    



    return HRad,VRad


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

function xp_radius.vector(pos1, pos2)
    -- this function returns the horizontal and vertical components of two positions. 

end


function xp_radius.permit(rad, floor, pos1,pos2)
    local ceiling = 32000
    local prad = {x = math.abs(pos2.x - pos1.x), z = math.abs(pos2.z - pos1.z), y = pos2.y - pos1.y}
    if prad.x > rad or prad.z > rad or prad.y > floor then
        --player outside of radius
        return true 
    end
    --player is within radius
    return false
end

--This is the fuction that is used to process the player list every few seconds
xp_radius.scan = function()
    --Get Origin
    local origin = core.deserialize(xp_radius.metadata:get_string("origin")) 
    if not origin then
        xp_radius.debug("origin is not know at the beginning of the xp_radius.scan() function")
        return false
    end

    local activePlayers = core.get_connected_players()
    for index, player in ipairs(activePlayers) do
        --initialize variables
        local radius = xp_radius.rads[1]
        local floor = xp_radius.floor[1]

        --Get the player position and vectors
        local pos = player:get_pos()
        local name = player:get_player_name()
        local p_vector = vector.floor(vector.new(pos))
        local o_vector = vector.floor(vector.new(origin))
        local op_vector = vector.floor(vector.subtract(o_vector,p_vector))
        local direction = vector.direction(pos,origin)
        local origin_direction = math.atan2(direction.x,-direction.z)+math.pi
        local look_direction = player:get_look_horizontal()
        local D_Angle = math.abs(origin_direction - look_direction)
       

        --Get the player XP
        local currentXp = xp_redo.get_xp(name)

        --Determine players distance from origin. 
        local d = vector.distance(pos, origin)

        -- Get player Meta Data
        local pmeta = player:get_meta() -- player Meta

        --Check to see if xp_radius exists in meta
        --If it does not then create xp_radius in meta with coordinates at the xp_radius origin
        if pmeta:get_string("xp_radius") == "" then
            pmeta:set_string("xp_radius",core.serialize(origin))    
        end
        --initialize the christmas bonus Meta settings. Set init Value to off
        if pmeta:get_string("xp_radius-CB") == "" then
            pmeta:set_string("xp_radius-CB","off")
        end

        --Determine permitted radius
        radius,floor = xp_radius.radius(currentXp,player)
        --core.chat_send_all("DEBUG: "..name.." has a xp_radius of "..radius)


        if radius == nil then
            core.debug("xp_radius Player Error: "..name.." radius not defined. Defaulting to 100 nodes.")
            radius = 100
        end

        if radius == "reset" then
            core.chat_send_player(player:get_player_name(), "XP radius reset activated, returning you to XP origin. You don-bin down graded")
            player:move_to(origin, true)
        elseif xp_radius.permit(radius,floor,pos,origin) then
            core.chat_send_player(name, ">: ) You never escape da XP radius, Moo Moo Ha. Go back now")
            --Calculate the return direction from current location.
            --Set look direction
             if .5 < D_Angle and D_Angle < 5.8 then
                player:set_look_horizontal(origin_direction)
            end
            --Move the player to a valid location
            ppos = core.deserialize(pmeta:get_string("xp_radius")) -- Previous valid location

            --Check to see if saved location is within new radius. 
            if xp_radius.permit(radius,floor,ppos,origin) then
                --It is not, moving player to origin
                player:move_to(origin, true)
            else
                player:move_to(ppos, true)
            end
        else
            --Record Valid Location
            pmeta:set_string("xp_radius",core.serialize(pos))
        end

    end
end

function xp_radius.debug(text)
    core.log(xp_radius.debuglevel,text)
end
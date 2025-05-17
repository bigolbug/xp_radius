--Function to initialize the oragin as null
onion.write_file = function()
    local f = io.open(onion.FN, "w")
    local data_string = core.serialize(onion.oragin)
    f:write(data_string)
    io.close(f)
end

onion.bonus = function (player)
    --initialize Variables
    local bonus = 0
    
    -- Get player Meta Data
    local pmeta = player:get_meta() -- player Meta

    --Test to see if the player has the priv
    if core.check_player_privs(player,"onion:CB") then
        --If the Meta Setting is off turn on. 
        if pmeta:get_string("onion-CB") == "off" then
            pmeta:set_string("onion-CB","on")
        end
        bonus = bonus + onion.CB
    else
        --If the player does not have the priv, check for recent deactivation
        if pmeta:get_string("onion-CB") == "on" then
            pmeta:set_string("onion-CB","off")
            return "reset"
        end
        -- Do not contribute anything to bonus
    end

    return bonus
end

onion.radius = function (pxp,player) -- Pass in player XP and objectref\

    --Bypass if player is Onion Admin
    if core.check_player_privs(player,"onion:admin") then
        return 40000, 40000
    end

    local bonus = onion.bonus(player)
    if bonus == "reset" then
        return "reset"
    end

    -- XP Radius bonus
    local xRad = math.floor(pxp/onion.xp_divisor)

    -- Radius is primarily determined based on chapter progression. 
    for index, priv in ipairs(onion.cprivs) do
        -- Check to see if the player has current priv
        if not core.check_player_privs(player,priv) then
            --return player rad and floor
            return (onion.rads[index] + bonus + xRad),(onion.floor[index] + bonus)
        else

        end
    end


    --[[ This is the old way of determining radius where XP had a greater weight. 
    for index, priv in ipairs(onion.cprivs) do
        -- Check to see if the player had current priv
        if not core.check_player_privs(player,priv) then
            --Player had current priv now check XP
            local pRad = index*400
            --Determine Radius based on XP
            for index, xp in ipairs(onion.ranks) do
                if pxp < xp then
                    local xRad = ((onion.ranks[index]/10) -200)
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

onion.init = function ()
    
    local f = io.open(onion.FN, "r")
    if f then   -- file exists
        local data_string = f:read("*all")
        onion.oragin = core.deserialize(data_string)
        io.close(f)
    end

    --if there isn't a file...
    --do nothing
end

function onion.permit(rad, floor, pos)
    local ceiling = 32000
    local prad = {x = math.abs(onion.oragin.x - pos.x), z = math.abs(onion.oragin.z - pos.z), y = onion.oragin.y - pos.y}
    if prad.x > rad or prad.z > rad or prad.y > floor then
        --player outside of radius
        return true
    end

    --player is within radius
    return false
end

--This is the fuction that is used to process the player list every few seconds
onion.scan = function()
    -- If oragin has not been set skip everything
    if onion.oragin == nil then
        core.chat_send_player("MacLean","Onion oragin has not been set or has expired. Please reset with the wand")
        core.after(onion.interval*5,onion.scan)
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
        local p_vector = vector.floor(vector.new(pos))
        --core.chat_send_all(vector.to_string(p_vector))
        local o_vector = vector.floor(vector.new(onion.oragin))
        --core.chat_send_all(vector.to_string(o_vector))
        local op_vector = vector.floor(vector.subtract(o_vector,p_vector))
        --core.chat_send_all(vector.to_string(op_vector))
        --core.chat_send_all(vector.length(op_vector))
        local direction = vector.direction(pos,onion.oragin)
        --core.chat_send_all(vector.to_string(vector.direction(pos,onion.oragin)))
        local oragin_direction = math.atan2(direction.x,-direction.z)+math.pi
        local look_direction = player:get_look_horizontal()
        local D_Angle = math.abs(oragin_direction - look_direction)
        --core.chat_send_all(D_Angle)
        if .5 < D_Angle and D_Angle < 5.8 then
            player:set_look_horizontal(oragin_direction)
        end


        --Get the player XP
        local currentXp = xp_redo.get_xp(name)

        --Determine players distance from oragin. 
        local d = vector.distance(pos, onion.oragin)

        -- Get player Meta Data
        local pmeta = player:get_meta() -- player Meta

        --Check to see if onion exists in meta
        --If it does not then create onion in meta with coordinates at the onion oragin
        if pmeta:get_string("onion") == "" then
            pmeta:set_string("onion",core.serialize(onion.oragin))    
        end
        --initialize the christmas bonus Meta settings. Set init Value to off
        if pmeta:get_string("onion-CB") == "" then
            pmeta:set_string("onion-CB","off")
        end

        --Determine permitted radius
        radius,floor = onion.radius(currentXp,player)
        --core.chat_send_all("DEBUG: Radius - "..radius)

        if radius == nil then
            core.debug("Onion Player Error: "..name.." radius not defined. Defaulting to 100 nodes.")
            radius = 100
        end

        if radius == "reset" then
            core.chat_send_player(player:get_player_name(), "XP radius reset activated, returning you to XP oragin. You don-bin down graded")
            player:move_to(onion.oragin, true)
        elseif onion.permit(radius,floor,pos) then
            core.chat_send_player(name, ">: ) You never escape da XP radius, Moo Moo Ha. Go back now")
            --Calculate the return direction from current location. 
            minetest.chat_send_all(vector.to_string(op_vector))

            --Check look direction

            --Move the player to a valid location
            ppos = core.deserialize(pmeta:get_string("onion")) -- Previous valid location


            player:move_to(ppos, true)
        else
            --Record Valid Location
            pmeta:set_string("onion",core.serialize(pos))
        end

    end
    
    --For testing purposes
    --core.chat_send_all(os.clock())
    
    --Run this function again after interval
    core.after(onion.interval,onion.scan)
end
core.register_chatcommand("ocmd",{
	params = "[action] [data]",
	privs = "server",
	description = "TBD",
	func = function(name, param)
		local params = param:gmatch("([%a%d_,]+)")
		local action, data = params(1), params(2)
		if action ~= nil then action = string.upper(action) end

		if action == "CLEAR" then
			local meta_data = area_rent.metadata:to_table()

			if data then
				if meta_data.fields[data] then
					meta_data.fields[data] = nil
				else
					return false, "You may have missspelled your data type"	
				end
			else
				for area_name, area_desc in pairs(meta_data["fields"]) do
					local digits = string.gmatch(area_name,"[%d]+")
					if digits then
						core.chat_send_all("removing "..area_name.."           ".. area_desc)	
						meta_data["fields"][area_name] = nil
					end
					
				end
			end
			area_rent.metadata:from_table(meta_data)
		elseif action == "CENTER" then
			local player = core.get_player_by_name(name)
			local center = core.serialize(player:get_pos())
			area_rent.metadata:set_string("center",center)
			area_rent.metadata:set_int("setup",1)
			area_rent.debug("Set the area rent center to "..center)
		elseif action == "XP" then
			if not tonumber(data) then
				return false, "You need to enter a number"
			end
			
			area_rent.updateXP(name,data)
		elseif action == "XP_DEBUG" then
			return true, "Your XP from XP redo: " .. xp_redo.get_xp(name)
		elseif action == "CUED" then
			core.chat_send_player(name,"Accessing CUED Data")
			local cued_areas = core.deserialize(area_rent.metadata:get_string("CUED")) 
			if not cued_areas then
				return false, "Can't access cued data"
			end
			for player, area in pairs(cued_areas) do
				core.chat_send_player(name,player.." has cued data. Their properties are")
				for area_name, area_data in pairs(area) do
					core.chat_send_player(name,area_name .. " with name "..area_data.name)
				end
			end
			return true
		elseif action == "RENTED" then
		elseif action == "RAD" then
			local player = core.get_player_by_name(name)
			if player == nil then
				return false, name .. " is not currently active in the game"
			end
			local player_meta = player:get_meta()
			local pos = player:get_pos()
			local ar_center = core.deserialize(area_rent.metadata:get_string("center"))
			local direction = vector.direction(pos,ar_center)
			local direction_rad = math.atan2(direction.x,-direction.z)+math.pi

			core.chat_send_player(name,"You are currently ".. direction_rad.. " radians around center")
			return true

		elseif action == "INTERSECTING" then
			local ar_center = core.deserialize(area_rent.metadata:get_string("center"))
			if not ar_center then
				return false, "Area rent mod is not setup. Ask your admin to set a center with /rcmd center"
			end
			local area_data = {}
			area_data.pos1, area_data.pos2 = areas:getPos(name)
			-- Check to see if an area needs to be selected. 
			if not (area_data.pos1 and area_data.pos2) then
				return false, "You need to select an area first. Use /area_pos1 \nand /area_pos2 to set the bounding corners"
			else
				-- Make sure that pos2 is the farther then pos1
				if area_data.pos1.x > area_data.pos2.x then
					local temp_pos = area_data.pos1
					area_data.pos1 = area_data.pos2
					area_data.pos2 = temp_pos
				end
			end

			--Calculate area deltas
			area_data.dy = math.abs(area_data.pos1.y - area_data.pos2.y)
			area_data.dx = math.abs(area_data.pos1.x - area_data.pos2.x)
			area_data.dz = math.abs(area_data.pos1.z - area_data.pos2.z)

			area_data.loaner = name
			area_data.owner = "SERVER"
			area_data.center = area_rent.center_pos(area_data.pos1,area_data.pos2)
			area_data.distance_to_center = vector.distance(ar_center, area_data.center)
			local direction = vector.direction(area_data.center,ar_center)
			area_data.direction = math.atan2(direction.x,-direction.z)+math.pi
			area_rent.xz_center(area_data,ar_center)
			local intersecting_areas = area_rent.get_intersecting_areas(area_data)
			if not area_rent.tableLen(intersecting_areas) then
				return false, "There are intersecting areas"
			end
			return true, "There are not intersecting areas"

		elseif action == "CHARGE" then
			if not area_rent.charge() then
				return false, "You can only charge once per day."
			end
			return false, "You have successfully charged rent"
		else
			local meta_data = area_rent.metadata:to_table()
			for area_name, area_desc in pairs(meta_data["fields"]) do
				core.chat_send_all(area_name.."           ".. area_desc)
			end
			core.chat_send_player(name,"Running default RCMD")
		end
		
	end,

})
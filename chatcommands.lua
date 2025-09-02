core.register_chatcommand("xprcmd",{
	params = "[action] [data]",
	privs = "server",
	description = "Parameters: \n"..
	"disable \t\tfor disabling the radius\n"..
	"set_rad \t\tfor setting and enabling the xp_radius",
	func = function(name, param)
		local params = param:gmatch("([%a%d_,]+)")
		local action, data = params(1), params(2)
		if action ~= nil then action = string.upper(action) end
		if action == "SET" then
			local user = core.get_player_by_name(name)
			xp_radius.metadata:set_string("origin",core.serialize(user:get_pos()))
			core.chat_send_all("xp_radius Activated")
			--xp_radius.write_file()
			--Update Meta Data. 
			xp_radius.metadata:set_int("enabled",1)	
		elseif action == "DISABLE" then
			xp_radius.metadata:set_int("enabled",0)	
		end
	end,
})
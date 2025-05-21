core.register_chatcommand("xrcmd",{
	params = "[action] [data]",
	privs = "server",
	description = "TBD",
	func = function(name, param)
		local params = param:gmatch("([%a%d_,]+)")
		local action, data = params(1), params(2)
		if action ~= nil then action = string.upper(action) end
        
		if action == "CLEAR" then
		elseif action == "CENTER" then
			if not area_rent.charge() then
				return false, "You can only charge once per day."
			end
			return false, "You have successfully charged rent"
		else
		end

	end,

})
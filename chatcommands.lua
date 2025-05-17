core.register_chatcommand("xrcmd",{
	params = "[action] [data]",
	privs = "server",
	description = "TBD",
	func = function(name, param)
		local params = param:gmatch("([%a%d_,]+)")
		local action, data = params(1), params(2)
		if action ~= nil and tostring(action) then action = string.upper(action) end

		if action == "CLEAR" then
		else
			--default command
		end

	end,

})
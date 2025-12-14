--!strict

local React = require("../React")

local arePropsDifferent = require("./arePropsDifferent")

--[[
	useCallback.lua
	this saves us from having to precalculate a buncha stuff
	It checks the dependencies for us :3
	
	```luau
	return function(props)
		useCallback(function()
			-- this function changes when props.something
			-- changes
			return props.something * 10
		end, props.something)
		
		-- incomplete implementation
		return ...
	end
	```
]]

return function<T>(callback: () -> T, ...: T)
	local wipFiber, currentFiber, hook = React.getHookState()
	if not currentFiber then
		callback()
		wipFiber.hooks[hook] = { ... }
	else
		local pack = { ... }
		if arePropsDifferent(currentFiber.hooks[hook], pack) then
			callback()
			currentFiber.hooks[hook] = pack
		end
	end
end
--!strict

--[[
	useCleanup.lua
	this is called when the dom elements
	are being removed
	
	```luau
	return function(props)
		useCleanup(function()
			print("i was removed :c")
		end)
		
		-- incomplete implementation
		return ...
	end
	```
]]

local React = require("../React")

type Element = React.Element

return function(callback: (Element) -> ())
	local wipFiber, currentFiber, hookIndex = React.getHookState()
	wipFiber.cleanup = callback
end
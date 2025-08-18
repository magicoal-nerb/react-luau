--!strict

--[[
	useCleanup.lua
	* this is called when the dom elements
	* are being removed
	
	usage:
	```lua
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
return function(callback: () -> ())
	local id = React:getHookIndex()
	local new = React.hookFiber :: Element
	local old = new.previous :: Element
	
	if old then
		-- The event was already created
		return
	end
	
	React.pendingQueue:enqueue(function()
		local dom = assert(new.dom)
		dom.Destroying:Once(callback)
	end)
end
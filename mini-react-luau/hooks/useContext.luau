--!strict

--[[
	useContext.lua
	* Redraws when the context changes
	
	usage:
	```lua
	local myContext = React.createContext(0)
	
	return function()
		local clicks = React.useContext(myContext)
		return React.createElement("TextButton", {
			Text = `clicks: {clicks}`,
			-- some stuff here...
			
			[React.event.Activated] = function()
				-- Other elements hooking onto myContext will also
				-- get updated!!
				myContext:set(myContext:get() + 1)
			end,
		})
	end
	```
]]

local React = require("../React")

type Context<T> = React.Context<T>
type Element = React.Element

return function<T>(context: Context<T>): T
	local fiber = React.hookFiber
	context:subscribe(fiber, function()
		-- Do a redraw on context change
		React:enqueueElement(fiber)
	end)

	return context:get()
end

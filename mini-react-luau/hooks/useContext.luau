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
local Context = require("../util/Context")

type Context<T> = Context.Context<T>
type Element = React.Element

return function<T>(context: Context<T>): T
	local wipFiber, currentFiber = React.getHookState()
	local myHooks = wipFiber.hooks
	context:subscribe(myHooks, function()
		-- Do a redraw on context change
		context:unsubscribe(myHooks)
		React.update(wipFiber)
	end)

	return context:get()
end

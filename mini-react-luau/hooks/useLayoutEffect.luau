--!strict

--[[
	useLayoutEffect.lua
	* Calls the function every time the dependencies change
	* Use this for logic before the DOM loads
	
	usage:
	```lua
	-- the function gets called when the element
	-- gets created
	return function()
		useEffect(function()
			print("Hi guys i got mounted!! :D")
		end)
		
		-- incomplete
		return ...
	end
	```
	
	```lua
	-- the function gets called when the state
	-- changes
	return function()
		local counter, setCounter = useState(0)
		useEffect(function()
			-- This gets called if counter is different
			print(`Counter value is: {counter}`)
		end, counter)
		
		-- incomplete
		return ...
	end
	```
]]

local React = require("../React")

type Element = React.Element

return function(
	callback: () -> (),
	...
)
	if not select(1, ...) then
		-- Basically our equivalent of mount
		local new = React.hookFiber :: Element
		local old = new.previous :: Element
		if not old then
			callback()
		end
	else
		-- Check dependencies
		local id = React:getHookIndex()
		local new = React.hookFiber :: Element
		local old = new.previous :: Element

		assert(new.hooks)
		if not old then
			-- Use the callback
			new.hooks[id] = React:getHookDependencies(...)
			callback()
		elseif bit32.btest(bit32.rshift(new.flags, 8), new.hooks[id]) then
			-- Callback because deps changed
			callback()
		end
	end
end

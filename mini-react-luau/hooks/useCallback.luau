--!strict

--[[
	useCallback.lua
	* this saves us from having to precalculate a buncha stuff
	* It checks the dependencies for us :3
	
	usage:
	```lua
	return function(props)
		local result = useCallback(function()
			-- this function changes when props.something
			-- changes
			return props.something * 10
		end, props.something)
		
		-- incomplete implementation
		return ...
	end
	```
]]

local React = require("../React")

type Element = React.Element
type MemoData<T> = {
	dependencies: any,
	cache: T,
}

return function<T>(
	calculate: T,
	...: any
): T
	local id = React:getHookIndex()
	local new = React.hookFiber :: Element
	local old = new.previous :: Element

	if old then
		-- Compare the previous state
		-- to our current state
		local memo = (old :: any).hooks[id] :: MemoData<T>		
		if React:didDependenciesChange(memo.dependencies, ...) then
			return calculate
		end
		
		return memo.cache
	else
		-- Initialize the value		
		local hooks = assert(new.hooks)
		hooks[id] = {
			cache = calculate,
			dependencies = React:getHookDependencies(...),
		}
		
		return calculate
	end
end

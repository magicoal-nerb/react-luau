--!strict

--[[
	useMemo.lua
	* this saves us from having to precalculate a buncha stuff
	* It checks the dependencies for us !!
	
	usage:
	```lua
	return function(props)
		local state, setState = useState<number>(32)
		
		local data = useMemo(function()
			-- Basically, we just recalculate this if
			-- `state` changes
			return state * 8
		end, { state })
		
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
	calculate: () -> T,
	...
): T
	local id = React:getHookIndex()
	local new = React.hookFiber :: Element
	local old = new.previous :: Element

	local value
	if old then
		-- Compare the previous state
		-- to our current state
		local memo: MemoData<T> = (old.hooks :: {any})[id]
		
		if React:didDependenciesChange(memo.dependencies, ...) then
			value = calculate()	
		else
			value = memo.cache
		end
	else
		-- Initialize the value
		value = calculate()
		
		local hooks = assert(new.hooks)
		hooks[id] = {
			cache = value,
			dependencies = React:getHookDependencies(...),
		}
	end
	
	return value
end

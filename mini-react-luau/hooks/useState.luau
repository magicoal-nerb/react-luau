--!strict

--[[
	useState.lua
	* States invoke redraws!!!!
	* Thats important!!!!
	
	usage:
	```lua
	return function(props)
		local state, setState = useState<number>(32)
		
		task.delay(1, function()
			-- For every second, state increments by 1
			setState(state + 1)
		end)
		
		-- incomplete implementation
		return ...
	end
	```
]]

local React = require("../React")
type Element = React.Element

type Hook<T> = {
	state: T,
	setState: (x: T) -> (),
}

return function<T>(initial: T): (T, (x: T) -> ())
	local id = React:getHookIndex()
	local new = React.hookFiber :: Element
	local old = new.previous :: Element

	-- Get the hooks
	local hooks = assert(new.hooks)
	if old then
		-- This already exists, just reuse it
		local hook: Hook<T> = (old.hooks :: {any})[id]		
		return hook.state, hook.setState
	else
		local hook = { state = initial }
		function hook.setState(x: T)
			-- Set state and invoke redraw
			if x == hook.state then
				-- If it's the same as the previous
				-- state, no need to redraw stuff.
				return
			end
			
			hook.state = x
			new.flags = bit32.bor(
				new.flags,
				bit32.lshift(1, id + 7)
			)
			
			React:enqueueElement(new)
		end
		
		new.hooks[id] = hook :: Hook<T>
		React.hookData[hook.setState] = bit32.lshift(1, id - 1)
		
		return initial, hook.setState
	end
end
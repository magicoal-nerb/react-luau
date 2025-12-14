--!strict

--[[
	useRef.lua
	references are kinda like useState but they dont
	redraw the element
	
	usage:
	```lua
	return function(props)
		local ref = useRef(32)
		
		ref:set(64) -- sets ref to 64
		ref:get() -- will return 64
		
		-- incomplete implementation
		return ...
	end
	```
]]

local React = require("../React")
local Ref = require("../util/Ref")

export type Ref<T> = Ref.Ref<T>

return function<T>(initial: T): Ref<T>
	local wipFiber, currentFiber, hookIndex = React.getHookState()
	
	local value = if currentFiber
		then currentFiber.hooks[hookIndex]
		else Ref.new(initial)
	
	wipFiber.hooks[hookIndex] = value
	return value
end

--!strict

--[[
	useRef.lua
	* references are kinda like useState but they dont
	* redraw the element
	
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
type Element = React.Element
type Ref<T> = React.Ref<T>

return function<T>(initial: T): Ref<T>
	local id = React:getHookIndex()
	local new = React.hookFiber :: Element
	local old = new.previous :: Element
	
	-- See if we can reuse the reference, otherwise
	-- we have to create one >_>
	local value = if old
		then (old.hooks :: {any})[id]
		else setmetatable({ data = initial }, React.Ref) :: Ref<T>
	
	(new.hooks :: {any})[id] = value
	return value
end

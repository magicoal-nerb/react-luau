--!strict

local React = require("../React")

local arePropsDifferent = require("./arePropsDifferent")

--[[
	useEffect.lua
	Calls the function every time the dependencies change
	Use this when depending on UI refs
	
	```luau
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
	
	```luau
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

return function<T>(callback: (React.Element) -> (), ...: T)
	local wipFiber, currentFiber, hook = React.getHookState()
	if not currentFiber then
		React.createCallback(callback)
		wipFiber.hooks[hook] = { ... }
	else
		local pack = { ... }
		if arePropsDifferent(currentFiber.hooks[hook], pack) then
			React.createCallback(callback)
			currentFiber.hooks[hook] = pack
		end
	end
end
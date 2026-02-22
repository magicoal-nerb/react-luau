--!strict

local React = require("../React")

export type Callback<T> = (set: T) -> ()

--[[
	useState redraws when the variable changes

	```luau
	return function(props)
		local count, setCount = useState(1)
		
		return createElement("TextButton", {
			Activated = function()
				setCount(count + 1)
			end
		})
	end
	```
]]

return function<T>(initial: T): (T, Callback<T>)
	local wipFiber, currentFiber, hook = React.getHookState()
	
	if not currentFiber then
		wipFiber.hooks[hook] = initial
	end
	
	local function callback(to: T)		
		wipFiber.hooks[hook] = to
		React.update(wipFiber)
	end
	
	return wipFiber.hooks[hook], callback
end
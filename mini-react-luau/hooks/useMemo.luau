local React = require("../React")

--[[
	useMemo.lua
	this saves us from having to precalculate a buncha stuff
	It checks the dependencies for us !!
	
	```luau
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

export type Memo<T> = {
	list: { T },
	value: T,
}

local function arePropsDifferent<T>(propA: T, propB: T): boolean
	for name, value in propA do
		if propB[name] ~= value then
			return true
		end
	end

	return false
end

return function<T>(callback: () -> T, ...: T): T
	local wipFiber, currentFiber, hook = React.getHookState()
	if not currentFiber then
		local value = callback()
		wipFiber.hooks[hook] = {
			list = {...},
			value = value,
		}
		
		return value
	else
		local pack = { ... }
		
		local data = currentFiber.hooks[hook] :: Memo<T>		
		if arePropsDifferent(data.list, pack) then
			local value = callback()
			wipFiber.hooks[hook] = pack
			
			data.value = value
			return value
		end
		
		return data.value
	end
end
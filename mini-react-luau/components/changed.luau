--!strict

local React = require("../React")

export type Connection<T...> = (T...) -> ()

local function changed<T...>(_, name: string): (React.Element, Connection<T...>) -> ()
	return function(
		element: React.Element,
		conn: (T...) -> ()
	)
		local connection = (element.dom :: any)
			:GetPropertyChangedSignal(name)
			:Connect(function()
				conn((element.dom :: any)[name])
			end)
		
		table.insert(element.connections, connection :: RBXScriptConnection)
	end
end

return setmetatable({}, { __index = changed })
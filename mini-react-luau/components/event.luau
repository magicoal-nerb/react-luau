--!strict

local React = require("../React")

export type Connection<T...> = (T...) -> ()

local function event<T...>(_, name: string): any
	return function(
		element: React.Element,
		conn: (T...) -> ()
	)
		local connection = (element.dom :: any)[name]:Connect(conn)
		
		table.insert(element.connections, connection :: RBXScriptConnection)
	end
end

return setmetatable({}, { __index = event })
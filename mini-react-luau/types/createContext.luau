-- createContext.lua
-- Helper function that creates a context for us
-- magicoal_nerb/poopbarrel :^)

local React = require("../React")

return function<T>(initial: T): React.Context<T>
	-- Basically just our constructor for
	-- the context object
	return setmetatable({
		subscribed = { },
		data = initial,
	}, React.Context)
end
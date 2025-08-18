--!strict

-- Changed.lua
-- Handles property changes
-- magicoal_nerb/poopbarrel :^)

local React = require("../React")
local Changed = {}

export type Dispatcher = (dom: Instance, ...any) -> (RBXScriptConnection)

type ChangedImpl = { [string]: Dispatcher }
type Changed = typeof(setmetatable({} :: ChangedImpl, Changed))

function Changed.__index(self: ChangedImpl, key: string): Dispatcher
	local function dispatcher(dom: Instance, fn: Dispatcher): RBXScriptConnection
		local fiber = React.hookFiber
		local event = dom
			:GetPropertyChangedSignal(key)
			:Connect(function(...: any)
				return fn(
					dom,
					(dom :: any)[key],
					...
				)
			end)

		return event
	end
	
	-- Create new dispatcher and return it
	rawset(self, key, dispatcher)	
	return dispatcher
end

return setmetatable({}, Changed)
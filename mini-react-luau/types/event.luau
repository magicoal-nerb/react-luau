--!strict

-- Event.lua
-- Handles script connections
-- magicoal_nerb/poopbarrel :^)

local React = require("../React")
local Event = {}

export type Dispatcher = (dom: Instance, ...any) -> (RBXScriptConnection)

type EventImpl = { [string]: Dispatcher }
type Event = typeof(setmetatable({} :: EventImpl, Event))

function Event.__index(self: EventImpl, key: string): Dispatcher
	local function dispatcher(dom: Instance, fn: Dispatcher): RBXScriptConnection
		local fiber = React.hookFiber		
		local event = (dom :: any)[key]:Connect(function(...: any)
			return fn(dom, ...)
		end)
				
		return event
	end
	
	-- Create new dispatcher and return it
	rawset(self, key, dispatcher)	
	return dispatcher
end

return setmetatable({}, Event)
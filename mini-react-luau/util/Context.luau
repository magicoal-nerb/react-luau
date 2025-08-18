--!strict

-- Context.lua
-- Handles state through a context object :D
-- magicoal_nerb/poopbarrel

local Context = {}
Context.__index = Context

export type Context<T> = typeof(setmetatable({} :: {
	subscribed: { [any]: () -> () },
	data: T,
}, Context))

function Context.set<T>(self: Context<T>, to: T)
	-- Sets the value and goes through our callbacks!
	-- We know that these elements will resubscribe, so
	-- we can clear the array beforehand
	local subscribed = self.subscribed
	self.subscribed = {} -- :c
	self.data = to

	for i, callback in subscribed do
		callback()
	end
end

function Context.get<T>(self: Context<T>): T
	-- Gets the data
	return self.data
end

function Context.unsubscribe<T>(
	self: Context<T>,
	key: any
)
	-- You can manually unsubscribe if you're not using
	-- this in a react context
	self.subscribed[key] = nil
end

function Context.subscribe<T>(
	self: Context<T>,
	key: any,
	callback: () -> ()
)
	-- Add the callback
	self.subscribed[key] = callback
end

return Context
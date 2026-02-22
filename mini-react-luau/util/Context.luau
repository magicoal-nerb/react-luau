--!strict

-- Context.lua
-- Handles state through a context object :D
-- magicoal_nerb/poopbarrel

local Context = {}
Context.__index = Context

export type Context<T> = typeof(setmetatable({} :: {
	subscribed: { [any]: (T) -> () },
	data: T,
}, Context))

function Context.set<T>(self: Context<T>, to: T)
	-- Sets the value and goes through our callbacks!
	self.data = to
	for i, callback in self.subscribed do
		callback(to)
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
	callback: (T) -> ()
)
	-- Add the callback
	self.subscribed[key] = callback
end

function Context.new<T>(initial: T): Context<T>
	return setmetatable({
		subscribed = {},
		data = initial,
	}, Context)
end

return Context
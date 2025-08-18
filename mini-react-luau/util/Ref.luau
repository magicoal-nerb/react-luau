--!strict

-- Ref.lua
-- Handles references in React
-- magicoal_nerb/poopbarrel :^)

local Ref = {}
Ref.__index = Ref

export type Ref<T> = typeof(setmetatable({} :: {
	data: T,
}, Ref))

function Ref.hook<T>(self: Ref<T>, dom: Instance, prop: string)
	-- pass
end

function Ref.get<T>(self: Ref<T>): T
	-- Get the data!!
	return self.data
end

function Ref.set<T>(self: Ref<T>, what: T)
	-- Sets the data field in the ref
	self.data = what
end

return Ref
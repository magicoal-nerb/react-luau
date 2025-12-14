--!strict

local Ref = {}
Ref.__index = Ref

export type Ref<T> = typeof(setmetatable({} :: {
	value: T
}, Ref))

function Ref.new<T>(value: T)
	return setmetatable({
		value = value,
	}, Ref)
end

function Ref.set<T>(self: Ref<T>, to: T)
	self.value = to
end

function Ref.get<T>(self: Ref<T>): T
	return self.value
end

return Ref
--!strict

-- Anim.lua
-- Handles Anims in React
-- magicoal_nerb/poopbarrel :^)

local Anim = {}
Anim.__index = Anim

export type Anim<T> = typeof(setmetatable({} :: {
	hooks: {{ dom: Instance, prop: string }},
	data: T,
}, Anim))

function Anim.hook<T>(self: Anim<T>, dom: Instance, prop: string)
	-- pass
	table.insert(
		self.hooks,
		{ dom = dom, prop = prop }
	)
end

function Anim.get<T>(self: Anim<T>): T
	-- Get the data!!
	return self.data
end

function Anim.set<T>(self: Anim<T>, what: T)
	-- Sets the data field in the Anim
	self.data = what
end

return Anim
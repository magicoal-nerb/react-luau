--!strict

-- Queue.lua
-- Handles the queue stuff I guess
-- magicoal_nerb/poopbarrel :^)

local Queue = {}
Queue.__index = Queue

export type Queue<T> = typeof(setmetatable({} :: {
	left: number,
	right: number,
	count: number,

	mask: number,
	data: { T },
}, Queue))

function Queue.new<T>(capacityPow: number, initial: T): Queue<T>
	local mask = bit32.lshift(1, capacityPow) - 1
	local data = table.create(mask + 1, initial)

	return setmetatable({
		left = 0,
		right = 0,
		count = 0,

		data = data,
		mask = mask,
	}, Queue)
end

function Queue.clear<T>(self: Queue<T>)
	self.count = 0
	self.right = 0
	self.left = 0
end

function Queue.empty<T>(self: Queue<T>)
	return self.count <= 0
end

function Queue.peek<T>(self: Queue<T>)
	return self.data[self.left + 1]
end

function Queue.dequeue<T>(self: Queue<T>)	
	local id = self.left + 1
	self.left = bit32.band(self.left + 1, self.mask)
	self.count -= 1

	return self.data[id]
end

function Queue.enqueue<T>(self: Queue<T>, data: T): number
	local id = self.right + 1
	self.right = bit32.band(self.right + 1, self.mask)
	self.count += 1

	if self.count > self.mask then
		error("Queue count > mask!?")
	end

	self.data[id] = data
	return id
end

-- Be careful with the set and get functions because this can easily
-- give you garbage data or overwrite unrelated entries. 
-- This is for very specific use cases!!
function Queue.set<T>(self: Queue<T>, id: number, value: T)
	self.data[id] = value
end

function Queue.get<T>(self: Queue<T>, id: number): T
	return self.data[id]
end

return Queue
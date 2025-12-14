--!strict

-- yet another queue implementation :P
-- magicoal_nerb

local Queue = {}
Queue.__index = Queue

export type Queue<T> = typeof(setmetatable({} :: {
	data: { T },
	size: number,
}, Queue))

function Queue.new<T>(): Queue<T>
	return setmetatable({
		data = {},
		size = 0,
	}, Queue)
end

function Queue.empty<T>(self: Queue<T>): boolean
	return self.size == 0
end

function Queue.iterate<T>(self: Queue<T>, callback: (T, ...any) -> (), ...: any)
	for i, object in self.data do
		callback(object, ...)
	end
end

function Queue.enqueue<T>(self: Queue<T>, data: T)
	self.data[self.size + 1] = data
	self.size += 1
end

function Queue.dequeue<T>(self: Queue<T>): T
	assert(self.size > 0, "attempted to dequeue empty queue lol")

	self.size -= 1
	return self.data[self.size + 1]
end

function Queue.clear<T>(self: Queue<T>)
	self.size = 0
	table.clear(self.data)
end

return Queue
--!strict

-- React.lua
-- Main logic of React(ish). It's pretty simple
-- but works pretty fast for what it does.
-- magicoal_nerb/poopbarrel :^)

local REACT_FLAG_LEAF = 0x1
local REACT_FLAG_COMPONENT = 0x2
local REACT_FLAG_DIRTY = 0x4

-- <(0_0<) <(0_0)> (>0_0)> kirb dance
local REACT_DIRTY_MASK = bit32.bnot(REACT_FLAG_DIRTY)
local EMPTY_TABLE = {}

local Context = require("./util/Context")
local Queue = require("./util/Queue")
local Anim = require("./util/Anim")
local Ref = require("./util/Ref")

export type Context<T> = Context.Context<T>
export type Anim<T> = Anim.Anim<T>
export type Ref<T> = Ref.Ref<T>

export type Dependency = { flags: number, deps: { any } }
export type FunctionComponent = (props: any, ref: Instance) -> { Element }
export type Type = string | FunctionComponent

export type Element = {
	-- Element type, could be a string or function
	type: Type,
	
	-- Handles custom information, like if it is
	-- a component(function), or a leaf(has no children, we can handle it a bit faster)
	flags: number,
	
	-- Main properties of our element
	props: { [any]: any },
	
	-- The children of our element
	children: { Element },
	
	-- Hook data from our renderer
	hooks: { any }?,
	
	-- Event data from potential hooks
	events: { RBXScriptConnection }?,
	
	-- The previous DOM element
	previous: Element?,

	-- Used for updating elements
	pending: number?,
	
	-- Current parent
	parent: Element?,
	
	-- Current instance it holds
	dom: Instance?,
}

export type Renderer = {
	-- Called when an element changes
	updateHostNode: (
		reconciler: React,
		old: Element,
		new: Element,
		diff: { string },
		numDiff: number
	) -> (),
	
	-- Called when an element is removed
	unmountHostNode: (reconciler: React, element: Element) -> (),
	
	-- Called when an element is created
	mountHostNode: (reconciler: React, element: Element) -> (),
}

local React = {}
React.__index = React

export type React = typeof(setmetatable({} :: {
	-- For the work queue, we insert two elements instead of one
	-- because it'll cause even more table creations. I don't like that,
	-- but it's the only option we have :c
	workQueue: Queue.Queue<Element>,

	-- This is the pending queue, which gets called if React is done with
	-- its rendering work
	pendingQueue: Queue.Queue<() -> ()>,
	
	-- Renderer :D
	renderer: Renderer,
	
	-- For handling differences between elements,
	-- we reuse this to not create another table
	diff: { string },
		
	-- Used by the hooks to determine state
	-- within an element
	hookData: { [any]: any },
	hookIndex: number,
	hookFiber: Element,
}, React))

local function removeElement(e: Element)
	-- Clears the element's fields and freezes it
	-- in order to mark it for garbage collection quicker..?
	table.clear(e :: any)
	table.freeze(e)
end

local function arePropsDifferent(
	propsA: {[string]: any},
	propsB: {[string]: any},
	output: { string }
): number
	-- This reuses the same table so we don't create
	-- a table every time we do this. Mutating B gives
	-- faster results than doing this inplace.
	local diff = 0
	for name, valueA in propsA do
		local valueB = propsB[name]
		if valueA ~= valueB then
			-- We found a difference!
			diff += 1
			output[diff] = name
		end
		
		propsB[name] = nil
	end
	
	for name in propsB do
		-- We found a difference!
		diff += 1
		output[diff] = name
	end
	
	-- No problem here.
	return diff
end

function React.new(): React
	return setmetatable({
		-- Util
		workQueue = Queue.new(8, {} :: Element),
		pendingQueue = Queue.new(8, function() end),
		renderer = {} :: Renderer,
		
		-- Hooks
		hookIndex = 0,
		hookFiber = {} :: Element,
		hookData = { },
		
		-- Context
		contexts = { },
		
		-- Reconcile
		diff = {},
	}, React)
end

function React.getHookDependencies(self: React, ...: any): Dependency
	-- Helper function for hooks to create a bitmask
	-- from our dependencies
	local deps = { }
	
	local flags = 0
	for i, dep in {...} do
		local t = typeof(dep)
		if t == "function" then
			-- If this was a function, then this
			-- might just be a setState setter.
			local mask: number = assert(
				self.hookData[dep],
				`Dependency is not from a state!`
			)
			
			flags = bit32.bor(flags, mask)
		else
			-- If this was something else, then
			-- this is any other object
			table.insert(deps, dep)
		end
	end
	
	return { flags = flags, deps = deps }
end

function React.didDependenciesChange(self: React, dependencies: Dependency, ...: any): boolean
	-- Helper function for hooks to check if
	-- our dependencies changed
	
	if #dependencies.deps ~= 0 then
		-- We also check this too
		local read = 1
		for i, dependency in {...} do
			if typeof(dependency) == "function" then
				-- no need to check this
				continue
			elseif dependencies.deps[read] ~= dependency then
				-- Dependency changed!
				return true
			else
				-- Need to scan for more data
				read += 1
			end
		end
	end
	
	return bit32.btest(
		bit32.rshift(self.hookFiber.flags, 8),
		dependencies.flags
	)
end

function React.getHookIndex(self: React)
	-- Utility function used by hooks
	-- to generate our given index
	local id = self.hookIndex
	self.hookIndex += 1
	
	return id
end

function React.setRenderer(self: React, to: Renderer)
	-- Sets the current renderer to
	-- the given one
	self.renderer = to
end

function React.reconcileChildren(
	self: React,
	newFiber: Element,
	oldChildren: { Element }
)
	-- Reconcile children
	local newChildren = newFiber.children
	if newChildren == oldChildren then
		-- We can't diff this, because it's the same data!! 
		-- Also, this isn't a bug since sometimes we would 
		-- like to use the DOM directly, opting out of the reconcilation
		-- stuff.
		return
	end

	-- This assumes that newChildren != oldChildren
	local newChildren = newFiber.children
	local workQueue = self.workQueue
	local renderer = self.renderer

	for name, new in newChildren do
		local old: Element? = oldChildren[name]		
		oldChildren[name] = nil
		new.parent = newFiber

		if old and old.type ~= new.type then
			-- Create a new element here
			renderer.unmountHostNode(self, old)
			removeElement(old)
			old = nil
		end

		new.previous = old
		if bit32.btest(new.flags, REACT_FLAG_COMPONENT) then
			-- Just enqueue
			self:enqueueElement(new)
		elseif bit32.btest(new.flags, REACT_FLAG_LEAF) then
			-- Just get this thing over with
			self:reconcileElement(new, old)
		else
			-- Since there's children here, we have
			-- to send it to the work queue
			-- ( wow, that sounds bad outta context )
			self:enqueueElement(new)
		end
	end

	for name, old in oldChildren do
		-- Remove elements that remain
		renderer.unmountHostNode(self, old)
		removeElement(old)
	end
end

function React.reconcileElement(
	self: React,
	newFiber: Element,
	oldFiber: Element?
)
	local renderer = self.renderer
	if not oldFiber then
		-- We are going to create a new element
		renderer.mountHostNode(self, newFiber)
	else
		-- These two already exist, so we will diff it
		-- and check if we need to update it
		local diff = self.diff
		local numDiff = arePropsDifferent(
			newFiber.props,
			oldFiber.props,
			diff
		)
		
		newFiber.events = oldFiber.events
		newFiber.dom = oldFiber.dom
		oldFiber.pending = nil
		
		if numDiff ~= 0 then
			renderer.updateHostNode(
				-- Elements
				self,
				oldFiber,
				newFiber,

				-- Diff
				diff,
				numDiff
			)
		end

		local previous = oldFiber.previous
		if previous then
			-- Free up the old fiber's previous so we don't
			-- leak memory.
			oldFiber.previous = nil
			removeElement(previous)
		end
	end
end

function React.enqueueElement(self: React, fiber: Element)
	-- Use this if you mutated the element directly
	if bit32.btest(fiber.flags, REACT_FLAG_DIRTY) then
		-- Don't update it..?? LOL
		return
	end
	
	fiber.flags = bit32.bor(fiber.flags, REACT_FLAG_DIRTY)
	self.workQueue:enqueue(fiber)
end

function React.performUnitOfWork(
	self: React,
	fiber: Element
)
	fiber.flags = bit32.band(
		fiber.flags,
		REACT_DIRTY_MASK
	)

	local previous = fiber.previous
	if bit32.btest(fiber.flags, REACT_FLAG_COMPONENT) then
		-- It's a function component, so run it
		self.hookIndex = 1
		self.hookFiber = fiber
		
		fiber.flags = bit32.band(fiber.flags, 0xFF)
		if previous then
			fiber.dom = previous.dom
			fiber.hooks = previous.hooks
		else
			fiber.hooks = {}
			self.renderer.mountHostNode(self, fiber)
		end
		
		debug.profilebegin("react-component::update")
		
		local result = (fiber.type :: FunctionComponent)(
			fiber.props,
			fiber.dom :: Instance
		)
		
		fiber.children = result

		debug.profileend()
		
		table.clear(self.hookData :: any)
		fiber.previous = {
			children = fiber.children,
			events = fiber.events,
			flags = fiber.flags,
			hooks = fiber.hooks,
			dom = fiber.dom,
		} :: any

		if previous then
			self:reconcileChildren(
				fiber,
				previous.children
			)
		else
			self:reconcileChildren(
				fiber,
				EMPTY_TABLE
			)
		end
	elseif previous then
		-- Reconcile it
		previous.flags = bit32.band(fiber.flags, REACT_DIRTY_MASK)
		self:reconcileElement(fiber, fiber.previous)
		self:reconcileChildren(fiber, previous.children)
	else
		-- Reconcile it
		self:reconcileElement(fiber, fiber.previous)
		self:reconcileChildren(fiber, EMPTY_TABLE)
	end
end

function React.workLoop(
	self: React,
	budgetTime: number
): number
	local workQueue = self.workQueue
	local t0 = os.clock()
	
	local budget = t0 + budgetTime

	-- Please do work
	while not workQueue:empty() and os.clock() < budget do
		self:performUnitOfWork(workQueue:dequeue())
	end
	
	local isPending = workQueue:empty()
	if not isPending then
		-- We're still rendering, so running the
		-- pending functions would give us incomplete
		-- state.
		return os.clock() - t0
	end
	
	-- Run pending functions
	local pendingQueue = self.pendingQueue
	while not pendingQueue:empty() and os.clock() < budget do
		local dispatch = pendingQueue:dequeue()
		task.defer(dispatch)
	end
	
	return os.clock() - t0
end

function React.reconcile(
	self: React,
	old: Element,
	new: Element
)
	-- Use this when you created an element and you want to reconcile
	-- between the new and old one. Note: this will remove pending
	-- elements and provide the updated one. You were warned
	local workQueue = self.workQueue
	if bit32.btest(old.flags, REACT_FLAG_DIRTY) then
		-- This removes the pending element and replaces it
		-- with our current one. This is so our update provides
		-- the most recent snapshot
		local pending = assert(old.pending) :: number
		local previous = workQueue:get(pending)
		if previous == new then
			-- If it's the same thing, then we don't
			-- need to remove the element
			return
		end
		
		new.previous = old

		workQueue:set(pending, new)
		removeElement(previous)
	else
		-- This marks the element with a new id
		local id = self.workQueue:enqueue(new)
		new.previous = old
		
		old.pending = id
		old.flags = bit32.bor(
			old.flags,
			REACT_FLAG_DIRTY
		)
	end
end

function React.unmount(
	self: React,
	element: Element
)
	assert(element.dom, "Element doesn't have a DOM.")
	element.previous = nil
	self.renderer.unmountHostNode(self, element)
end

function React.mount(
	self: React,
	element: Element,
	parent: Instance | Element
)
	if typeof(parent) == "Instance" then
		-- Mount it to an instance
		element.parent = {
			type = "Instance",
			props = {},
			flags = 0,
			children = {},
			dom = parent,
		}
	else
		-- Mount it to an existing element
		element.parent = parent :: Element
		table.insert(
			(parent :: Element).children,
			element
		)
	end
	
	self:enqueueElement(element)
end

React.Context = Context
React.Anim = Anim
React.Ref = Ref

return React.new() :: React
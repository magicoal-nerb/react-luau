--!strict

local Queue = require("./util/Queue")

-- Basic types
export type Proplist = { [string]: any }
export type FiberPair = { left: Element?, right: Element? }
export type FiberCallback = (wip: Element) -> ()

export type Component = (props: any) -> Element
export type Element = {
	class: string | Component,
	hooks: { any },
	props: { [string]: any },
	
	connections: { RBXScriptConnection },
	children: { [any]: Element },
	cleanup: (Element) -> ()?,

	dom: Instance?,
	parent: Element?,
}

export type Renderer = {
	updateHostNode: (node: Element, diff: {[string]: any}) -> (),
	unmountHostNode: (node: Element) -> (),
	mountHostNode: (node: Element) -> (),
}

-- Datastructures for the fiber system
local FiberCallback = Queue.new() :: Queue.Queue<() -> ()>
local FiberQueue = Queue.new() :: Queue.Queue<FiberPair>
local FiberRenderer: Renderer

local FiberCurrent: Element?
local FiberHooks = 0
local FiberWip: Element?

local React = {}

local function getPropDiff(wip: Proplist, current: Proplist): Proplist
	local diff = {}
	for name, value in wip do
		-- This value differed! Note it
		-- in our output proplist
		if current[name] ~= value then
			diff[name] = value
		end
	end
	
	return diff
end

local function fiberEnqueue(wip: Element?, current: Element?): Element?
	-- Helper function that enqueues the wip
	-- and current elements into the queue
	FiberQueue:enqueue({
		right = current,
		left = wip,
	})
	
	return wip
end

local function fiberDestroy(current: Element)
	if typeof(current.class) ~= "function" then
		-- Create the basic element
		current.dom = FiberRenderer.unmountHostNode(current)
		return
	end

	if current.cleanup then
		current.cleanup(current)
	end
	
	for i, wipChild in current.children do
		fiberEnqueue(nil, wipChild)
	end
end

local function fiberCreate(wip: Element)
	if typeof(wip.class) ~= "function" then
		-- Create the basic element
		FiberRenderer.mountHostNode(wip)
	else
		-- Set the component's fields
		FiberCurrent = nil
		FiberHooks = 0
		FiberWip = wip

		-- Create a basic component
		wip.children[1] = wip.class(wip.props)
		wip.dom = if wip.parent
			then wip.parent.dom
			else nil
	end
	
	-- Set parent
	for i, wipChild in wip.children do
		wipChild.parent = wip
		fiberEnqueue(wipChild, nil)
	end
end

local function fiberUpdate(wip: Element, current: Element)
	local diff = getPropDiff(wip.props, current.props)
	wip.connections = current.connections
	wip.hooks = current.hooks
	wip.dom = current.dom
	
	if typeof(wip.class) == "function" then
		-- Set the component's children
		FiberCurrent = current
		FiberHooks = 0
		FiberWip = wip
		
		wip.children[1] = wip.class(wip.props, current)
		wip.cleanup = current.cleanup
		
		if wip.children[1] == current.children[1] then
			-- Do not update
			return
		end
	else
		FiberRenderer.updateHostNode(wip, diff)
	end
	
	-- Add or update new children
	for name, wipChild in wip.children do
		local currentChild = current.children[name]
		wipChild.parent = wip
		
		fiberEnqueue(wipChild, currentChild)
	end
	
	-- Remove older children
	for name, currentChild in current.children do
		if not wip.children[name] then
			fiberEnqueue(nil, currentChild)
		end
	end
end

local function reconcile(wip: Element?, current: Element?)
	if not wip then
		-- Destroy element
		return fiberDestroy(current :: Element)
	elseif not current then
		-- Create element
		return fiberCreate(wip)
	elseif wip.class == current.class then
		-- Look for updates
		return fiberUpdate(wip, current)
	else
		-- Recreate element again
		fiberDestroy(current)
		fiberCreate(wip)
	end
end

function React.unmount(element: Element)
	fiberEnqueue(nil, element)
end

function React.update(element: Element)
	fiberEnqueue({
		class = element.class,
		props = element.props,
		children = {},
	} :: Element, element)
end

function React.getHookState(): (Element, Element, number)
	-- Gives back the current wip root and the number
	-- of hooks it has
	FiberHooks += 1
	
	return FiberWip :: Element,
		FiberCurrent :: Element,
		FiberHooks
end

function React.createCallback(callback: FiberCallback)
	-- Creates callback on the WIP root
	local element = assert(FiberWip)
	FiberCallback:enqueue(function()
		return callback(element)
	end)
end

function React.setRenderer(renderer: Renderer)
	-- Sets the renderer
	FiberRenderer = renderer
end

function React.mount(element: Element, parent: Instance): Element
	-- Create a psuedo object for our
	-- element
	element.parent = {
		class = parent.ClassName,
		dom = parent,
		
		children = {},
		props = {},
	} :: Element
		
	-- Then, we render!
	reconcile(element, nil)
	return element
end

function React.workLoop(budgetTime: number)
	local budget = os.clock() + (budgetTime * 1e-4)

	-- Please do work
	while not FiberQueue:empty() and os.clock() < budget do
		local workPair = FiberQueue:dequeue()
		reconcile(workPair.left, workPair.right)
	end
	
	if not FiberQueue:empty() then
		-- Cannot do anything
		return
	end
	
	-- Run the callbacks when we are done rendering
	while not FiberCallback:empty() and os.clock() < budget do
		local callback = FiberCallback:dequeue()
		task.defer(callback)
	end
end

React.reconcile = reconcile
React.enqueue = fiberEnqueue

return React
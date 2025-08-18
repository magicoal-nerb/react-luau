--!strict

-- RobloxRenderer.lua
-- Displays our state
-- magicoal_nerb/poopbarrel :^)

local React = require("./React")

type Renderer = React.Renderer
type Element = React.Element
type React = React.React

local RobloxRenderer = {} :: Renderer
type Callback = (dom: Instance, property: any) -> (any)

function RobloxRenderer.updateHostNode(
	reconciler: React,
	old: Element,
	new: Element,
	
	diff: { string | Callback | RBXScriptConnection },
	numDiff: number
)
	-- Apply the difference between new and old
	assert(new.dom, "DOM object doesn't exist!")
	
	local dom: any = new.dom
	local props = new.props
	
	for i, event in assert(old.events) do
		-- Disconnect events
		event:Disconnect()
	end
	
	local events = {}
	local read = 1
	
	for i = 1, numDiff do
		local key = diff[i]
		local value = props[key]
		if typeof(key) ~= "function" then
			-- Standard property
			dom[key] = if typeof(value) ~= "table"
				then value
				else value:get()
		else
			-- Call the function again and add
			-- to the `events` table if possible
			local newValue = key(dom, props[key])
			props[key] = newValue

			if newValue then
				events[read] = newValue
				read += 1
			end
		end
	end
	
	new.events = events
end

function RobloxRenderer.unmountHostNode(
	reconciler: React,
	element: Element
)
	-- Remove the node
	if element.dom then
		element.dom = element.dom:Destroy()
	end
end

function RobloxRenderer.mountHostNode(
	reconciler: React,
	element: Element
)
	assert(element.parent, "Element needs a parent!")	
	
	local t = typeof(element.type)
	if t == "function" then
		-- Just create a folder and move on. This is
		-- our div essentially.
		local instance = Instance.new("Folder")
		instance.Name = "div"
		instance.Parent = assert(element.parent.dom, "Element parent needs a DOM!")
		
		element.dom = instance		
		return
	elseif t ~= "string" then
		error("bro what?")
	end

	-- Adds the host node in here :-)
	local instance = Instance.new(element.type :: string)
	local props = element.props
	local events = {}

	for key, value in props do
		local t = typeof(key)
		if t ~= "function" then
			-- It's a standard property
			if typeof(value) == "table" then
				value:hook(instance, key)
				instance[key] = value:get()
			else
				instance[key] = value
			end
		else
			-- It's an event
			local newValue = key(instance, value)
			props[key] = newValue

			if newValue then
				table.insert(events, newValue)
			end
		end
	end
	
	instance.Parent = assert(element.parent.dom, "Element parent needs a DOM!")
	element.events = events
	element.dom = instance
end

return RobloxRenderer
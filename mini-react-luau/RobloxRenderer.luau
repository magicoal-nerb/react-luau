local React = require("./React")

local RobloxRenderer = {}

function RobloxRenderer.updateHostNode(node: React.Element, diff: {[string]: any})
	-- Set element from the diff table
	local element = node.dom
	for i, connection in node.connections do
		connection:Disconnect()
	end
	
	for prop, value in diff do
		local t = typeof(value)
		if typeof(prop) == "function" then
			prop(node, value)
		elseif t == "function" then
			value(node, prop)
		else
			element[prop] = value
		end
	end
end

function RobloxRenderer.unmountHostNode(node: React.Element)
	-- Remove the dom element from the node
	for i, connection in node.connections do
		connection:Disconnect()
	end
	
	node.dom = node.dom:Destroy()
end

function RobloxRenderer.mountHostNode(node: React.Element)
	-- Just render it for now
	local inst = Instance.new(node.class)
	node.dom = inst
	
	for prop, value in node.props do
		local t = typeof(value)
		if typeof(prop) == "function" then
			prop(node, value)
		elseif t == "function" then
			value(node, prop)
		else
			inst[prop] = value
		end
	end
	
	inst.Parent = node.parent.dom
end

return RobloxRenderer
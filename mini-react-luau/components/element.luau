--!strict

local React = require("../React")

type Component = React.Component
type Element = React.Element

return function<T>(
	class: string | Component,
	props: T?,
	children: { [any]: Element }?
): Element
	local element = {
		connections = {},
		class = class,
		hooks = {},
		
		props = props or {},
		children = children or {},
	} :: Element
	
	if children then
		for name, child in children do
			child.parent = element :: Element
		end
	end
	
	return element
end
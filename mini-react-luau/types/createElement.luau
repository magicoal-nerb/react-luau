-- createElement.lua
-- Helper function that gets passed into React
-- to be processed. Most basic building block of what's
-- being displayed
-- magicoal_nerb/poopbarrel :^)

local REACT_FLAG_COMPONENT = 0x2
local REACT_FLAG_LEAF = 0x1

local React = require("../React")

return function(
	type: React.Type,
	props: { [any]: any },
	children: { React.Element }?
): React.Element
	-- potential bug; adding children does not change
	-- its flag(to be a leaf or not)... so, perhaps try doing that?
	local flags = if typeof(type) == "function"
		then REACT_FLAG_COMPONENT
		else 0
	
	if children then
		-- Has nested elements, just rename
		-- if possible
		for name, value in children do
			value.props.Name = name
		end
		
		return {
			type = type,
			props = props,
			children = children,
			flags = flags,
		}
	else
		-- Leaf
		flags = bit32.bor(flags, REACT_FLAG_LEAF)
		return {
			type = type,
			props = props,
			children = {},
			flags = flags,
		}
	end
end
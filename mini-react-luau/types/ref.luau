--!strict

-- Ref.lua
-- Helper function used to create DOM references
-- magicoal_nerb/poopbarrel :^)

local React = require("../React")

return function(dom: Instance, ref: React.Ref<Instance>)
	-- Sets the reference value( wow! )
	ref:set(dom)
end
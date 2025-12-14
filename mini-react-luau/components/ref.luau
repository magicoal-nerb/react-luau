--!strict

local React = require("../React")
local Ref = require("../util/Ref")

return function(element: React.Element, ref: Ref.Ref<any>)
	ref:set(element.dom :: Instance)
end
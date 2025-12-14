--!strict

local React = require("../React")

--[[

	memo prevents computing a component again if
	its props are the same. this wraps around an existing
	component, and returns a modified component
	
	```luau
	local function component(props, dom)
		-- Something that takes a while to do
		local children = {}
		for i = 1, 1024 do
			children[i] = React.createElement("TextLabel", {
				Position = UDim2.fromScale(0, i/1024),
				Size = UDim2.fromScale(0, 1/1024),
				Text = `name: {props.name}, {i}`,
				TextScaled = true,
				TextColor3 = Color3.fromRGB(255, 255, 255)
			})
		end
		
		return children
	end
	
	local myMemoizedComponent = React.memo(component)
	return function()
		local clicks, setClicks = React.useState(0)
		
		return {
			someExpensiveComponent = myMemoizedComponent({ name = "Something...?" }),
			somethingElse = React.createElement("TextButton", {
				Text = `Clicks: {clicks}`,
				Size = UDim2.fromScale(0.25, 0.25),
				
				Activated = function()
					clicks += 1
					setClicks(clicks)
				end,
			})
		}
	end
	```
]]

local function arePropsDifferent<T>(propA: T, propB: T): boolean
	for name, value in propA do
		if propB[name] ~= value then
			return true
		end
	end
	
	return false
end

return function<T>(component: React.Component): React.Component
	return function<T>(props: T): React.Element
		local wipFiber, currentFiber, hook = React.getHookState()
		
		if not currentFiber or arePropsDifferent(props, currentFiber.props) then
			-- If the props are different, recompute
			-- this component
			return component(props)
		else
			-- If the props are the same, just return
			-- back the current fiber's children,
			-- and it will skip the comparison
			return currentFiber.children[1]
		end
	end
end
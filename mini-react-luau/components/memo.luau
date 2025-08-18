--!strict

local React = require("../React")
local useRef = require("../hooks/useRef")

local EMPTY = { }

--[[
	memo.lua
	* redraws only happen if the props of the memo
	* change. otherwise, no redraw occurs evar
	
	usage:
	```lua
	
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

type Diff<T> = (current: T, previous: T) -> (boolean)

local function arePropsDifferent<T>(
	current: T,
	previous: T
): boolean
	for name, valueA in current :: any do
		local valueB = (previous :: any)[name]
		if valueA ~= valueB then
			return true
		end
	end
	
	return false
end

return function<T>(
	component: (props: T, dom: Instance) -> { React.Element },
	diff: Diff<T>?
): React.Type
	-- Note our props!! :P
	local propDiff: Diff<T> = if diff 
		then diff 
		else arePropsDifferent

	return function(props: T, dom: Instance): { React.Element }
		local currentRef: React.Ref<T?> = useRef(nil)
		local propPrev = currentRef:get()

		if not propPrev or propDiff(props, propPrev) then
			-- Then, we need to create the component again
			currentRef:set(props)
			return component(props, dom) :: { React.Element }
		else
			-- Otherwise, we can just reuse the previous
			-- component
			local fiber = React.hookFiber
			assert(fiber.previous)

			return fiber.previous.children
		end
	end
end
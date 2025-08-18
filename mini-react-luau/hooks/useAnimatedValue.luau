--!strict

--[[
	useAnimatedValue.lua
	* used for tweens and stuff.
	
	usage:
	```lua
	local Animated = React.Animated

	return function(props)
		local opacity = useAnimatedValue(0)
		
		local function activated()
			Animated.timing(opacity, {
				toValue = opacity:get() > 0.5 and 0.0 or 1.0,
				easing = React.easings.exponentialIn,
				duration = 1.0,
			}):start()
		end

		return {
			hi = React.createElement("TextButton", {
				BackgroundTransparency = opacity,

				[React.event.Activated] = activated,
			})
		}
	end
	```
]]

local React = require("../React")
type Element = React.Element
type Anim<T> = React.Anim<T>

return function<T>(initial: T): Anim<T>
	local id = React:getHookIndex()
	local new = React.hookFiber :: Element
	local old = new.previous :: Element
	
	-- See if we can reuse the reference, otherwise
	-- we have to create one >_>
	local value = if old
		then (old.hooks :: {any})[id]
		else setmetatable({ data = initial, hooks = {} }, React.Anim) :: Anim<T>
	
	(new.hooks :: {any})[id] = value
	return value
end

-- https://reactnative.dev/docs/animated#timing

local RunService = game:GetService("RunService")
local Animations = {} :: { [any]: boolean }

local React = require("../React")

export type Anim<T> = React.Anim<T>
export type TimingParams<T> = {
	toValue: T,
	easing: (alpha: number) -> number,
	duration: number,
}

local Animated = {}
Animated.__index = Animated

export type State<T> = {
	object: Instance,
	prop: string,
}

export type Animated<T> = typeof(setmetatable({} :: {
	data: Anim<T>,
	clock: number,
	
	params: any,	
	initial: T,
	step: (self: Animated<T>) -> boolean,
	callback: (() -> ())?,
}, Animated))

function Animated.timing<T>(data: Anim<T>, params: TimingParams<T>): Animated<T>
	local t = typeof(data:get())
	local step = typeof(data:get()) == "number" 
		and Animated.easeNumeric 
		or Animated.easeGeneric

	return setmetatable({
		initial = data:get(),
		data = data,
		clock = 0.0,

		step = step,
		params = params,
	}, Animated)
end

function Animated.easeNumeric<T>(self: Animated<T>): (T, boolean)
	-- Animation that uses the numerical lerp
	-- formula instead of a generic lerp method
	local params = self.params :: TimingParams<T>
	local duration = params.duration
	local goal = params.toValue
	
	local t = math.min((os.clock() - self.clock) / duration, 1.0)
	local alpha = params.easing(t)
	
	return self.initial * (1 - alpha) + goal * alpha, t >= 1.0
end

function Animated.easeGeneric<T>(self: Animated<T>): (T, boolean)
	-- Animation that uses the lerp method instead of
	-- the generic formula
	local params = self.params :: TimingParams<T>
	local duration = params.duration
	local goal = params.toValue

	local t = math.min((os.clock() - self.clock) / duration, 1.0)
	local alpha = params.easing(t)

	return (self.initial :: any):Lerp(goal, alpha), t >= 1.0
end

function Animated.start<T>(self: Animated<T>, callback: () -> ()): Animated<T>
	-- Add this to global Animations table
	self.clock = os.clock()
	self.initial = self.data:get()
	self.callback = callback
	
	Animations[self.data] = self
	return self
end

RunService.Heartbeat:Connect(function(dt)
	debug.profilebegin("react-luau::tween")
	
	for hook, anim in Animations do
		-- Step the animation and update
		-- relevant DOM elements
		local value, didComplete = anim:step(dt)
		hook:set(value)
		
		for i, pair in hook.hooks do
			pair.dom[pair.prop] = value
		end
		
		if didComplete then
			-- Remove it because we completed
			-- the animation
			Animations[hook] = nil
		end
	end
	
	debug.profileend()
end)

return Animated
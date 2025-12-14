--!strict

local React = require("../React")

--[[
	useTween gives a tween object and a builder object

	building
	```luau
	useEffect(function()
		local inPosition = Vector2.new(16 / contentSize.X, 1.0)
		tweenBuilder
			:ease(Vector2.one, React.easings.quadOut, FADE_TIME)
			:delay(LIFETIME - FADE_TIME - 0.05)
			:ease(inPosition, React.easings.quintOut, FADE_TIME)
			:finalize()
		
		task.wait(LIFETIME)
		labelRef:get().Text = ' '
		
		-- Destroy the object afterwards
		task.wait(0.15)
		frameRef:get():Destroy()
	end)
	```
	
	main example
	```luau
	return createElement("Frame", {
		LayoutOrder = bubbleProps.LayoutOrder,
		Size = tween(function(vec: Vector2)
			return UDim2.fromOffset(contentSize.X * vec.X, contentSize.Y * vec.Y)
		end),
		
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = opacity,
		
		BorderSizePixel = 0,
		
		[React.ref] = frameRef,
	}, {
		Caret = createElement("ImageLabel", {
			Image = "rbxasset://textures/ui/InGameChat/Caret.png",
			ImageTransparency = if bubbleProps.HasCaret
				then opacity
				else 1.0,
			
			BackgroundTransparency = 1.0,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromOffset(9, 6),
		}),
		
		Corner = createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
		
		Text = createElement("TextLabel", {
			BackgroundTransparency = 1.0,
			Font = Enum.Font.BuilderSansMedium,
			
			Size = UDim2.fromScale(1, 1),
			Text = bubbleProps.Text,
			TextScaled = false,
			
			TextSize = 20,
			TextColor3 = Color3.fromRGB(57, 59, 61),
			TextTransparency = opacity,
			TextStrokeTransparency = 1,
			
			[React.ref] = labelRef,
		}),
	})
	```
]]

local RunService = game:GetService("RunService")

local Tween = {}
Tween.__index = Tween

export type Keyframe<T> = {
	time: number,	
	value: T,
	easing: (x: number) -> number,
}

export type Tween<T, V> = typeof(setmetatable({} :: {
	elapsed: number,
	hook: any,
	
	keyframes: { Keyframe<T> },
	value: T,
	from: T,
	
	subscribed: {{
		inst: Instance,
		prop: string,
		map: (x: T) -> (V)
	}}
}, Tween))

local Tweens = {} :: {{
	duration: number,
	start: number,
	map: (number) -> (),
}}

local function updateTweens(dt: number)
	local clock = os.clock()
	for hook, tween in Tweens do
		local duration = tween.duration
		local alpha = math.min(clock - tween.start, duration)
		tween.map(alpha)

		if alpha >= duration then
			Tweens[hook] = nil
		end
	end
end

local function enqueueTween(
	hook: any,
	map: (number) -> (),
	duration: number
)
	Tweens[hook] = {
		duration = duration,
		start = os.clock(),
		map = map,
	}
end

local function lerp(a: number, b: number, t: number): number
	-- linear interpolation
	return a + (b - a) * t
end

local function linear(x: number): number
	-- simple easing
	return x
end

function Tween.new<T>(initial: T, hook: any)
	return setmetatable({
		elapsed = 0.0,
		hook = hook,
		
		value = initial,
		from = initial,
		
		keyframes = {{
			time = 0.0,
			value = initial,
			easing = linear,
		}},
	}, Tween)
end

function Tween.ease<T, V>(
	self: Tween<T, V>,
	to: T, ease: (number) -> number,
	duration: number
): Tween<T, V>
	-- compose easing
	self.elapsed += duration
	table.insert(self.keyframes, {
		time = self.elapsed,
		value = to,
		easing = ease,
	})
	
	self.from = to
	return self
end

function Tween.delay<T, V>(
	self: Tween<T, V>,
	duration: number
): Tween<T, V>
	-- delays in seconds
	self.elapsed += duration
	table.insert(self.keyframes, {
		time = self.elapsed,
		value = self.from,
		easing = linear,
	})
	
	return self
end

function Tween.cancel<T, V>(self: Tween<T, V>)
	Tweens[self.hook] = nil
end

function Tween.finalize<T, V>(self: Tween<T, V>)
	local keyframes = self.keyframes	
	local previous = self.value
	local length = #keyframes
	
	enqueueTween(self.hook, function(t: number)	
		-- do a binary search to get the keyframe
		local j = length
		local i = 1

		while i < j do
			local center = (i + j) // 2
			if keyframes[center].time > t then
				j = center - 1
			else
				i = center + 1
			end
		end
		
		while keyframes[i].time > t do
			i -= 1
		end
		
		j = i + 1
		
		-- check the keyframes
		local curr = keyframes[i]
		local after = keyframes[j]
		if not after then
			return
		end
		
		-- do the tween
		local alpha = math.min(after.easing((t - curr.time) / (after.time - curr.time)), 1.0)
		local ease = lerp(curr.value, after.value, alpha)
		for i, tween in self.subscribed do
			(tween.inst :: any)[tween.prop] = tween.map(ease) 
		end
		self.value = ease
	end, self.elapsed)
end

-- Connection
RunService.Heartbeat:Connect(updateTweens)

return function<T, V>(initial: T)
	local wipFiber, currentFiber, hookIndex = React.getHookState()
	local hooks = wipFiber.hooks
	
	if not currentFiber then
		hooks[hookIndex] = Tween.new(initial, hooks)
	end
	
	local subscribed = {} 
	local tween = hooks[hookIndex] :: Tween<T, V>
	tween.subscribed = subscribed
	
	local function map<V>(map: (x: T) -> (V))
		return function(element: React.Element, prop: string)
			local inst = element.dom :: Instance
			table.insert(subscribed, {
				inst = inst,
				prop = prop,
				map = map,
			});
			
			-- Do this to help with initialization
			(inst :: any)[prop] = map(tween.value)
		end
	end
	
	return map, tween
end
local React = require("../React")

local RunService = game:GetService("RunService")

local Tweens = {}
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
	
	subscribed: {{
		inst: Instance,
		prop: string,
		map: (x: T) -> (V)
	}}
}, Tween))

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

local function lerp<T>(a: T, b: T, t: number): T
	return a + (b - a)*t
end

local function linear(x: number): number
	return x
end

function Tween.new<T>(initial: T, hook: any)
	return setmetatable({
		elapsed = 0.0,
		hook = hook,
		
		value = initial,
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
		
		local curr = keyframes[i]
		local after = keyframes[j]
		if not after then
			return
		end
		
		local alpha = math.min(after.easing((t - curr.time) / (after.time - curr.time)), 1.0)
		local ease = lerp(curr.value, after.value, alpha)
		
		for i, tween in self.subscribed do
			tween.inst[tween.prop] = tween.map(ease) 
		end
		
		self.value = ease
	end, self.elapsed)
end

-- Connection
RunService.Heartbeat:connect(updateTweens)

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
			local inst = element.dom
			table.insert(subscribed, {
				inst = inst,
				prop = prop,
				map = map,
			})
			
			-- Do this to help with initialization
			inst[prop] = map(tween.value)
		end
	end
	
	return map, tween
end
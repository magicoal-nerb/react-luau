-- Easings.lua
-- Ported from `https://github.com/ai/easings.net/blob/master/src/easings/easingsFunctions.ts`
-- MIT

local function bounceOut(x: number)
	local n1 = 7.5625
	local d1 = 2.75

	if x < 1 / d1 then
		return n1 * x * x
	elseif x < 2 / d1 then
		x = x - 1.5
		return n1 * (x / d1) * x + 0.75
	elseif x < 2.5 / d1 then
		x = x - 2.25
		return n1 * (x / d1) * x + 0.9375
	else
		x = x - 2.625
		return n1 * (x / d1) * x + 0.984375
	end
end

local tau = 2*math.pi
local c1 = 1.70158
local c2 = c1 * 1.525
local c3 = c1 + 1
local c4 = tau / 3
local c5 = tau / 4.5

export type Sequence = {{
	easing: (x: number) -> (number),
	start: number,
	finish: number,
}}

return {
	construct = function(sequence)
		
	end,
	
	constant = function(x: number)
		return x<1 and 0 or 1
	end,

	linear = function(x: number)
		return x
	end,

	quadIn = function(x: number)
		return x * x
	end,

	quadOut = function(x: number)
		return 1-(1-x)*(1-x)
	end,

	quadInOut = function(x: number)
		return x<0.5 and 2*x*x or 1-(-2*x+2)^2/2
	end,

	cubicIn = function(x: number)
		return x*x*x
	end,

	cubicOut = function(x: number)
		return 1-(1-x)^3
	end,

	cubicInOut = function(x: number)
		return x<0.5 and 4*x*x*x or 1-(-2*x+2)^3/2
	end,

	quartIn = function(x: number)
		return x*x*x*x
	end,

	quartOut = function(x: number)
		return 1-(1-x)^4
	end,

	quartInOut = function(x: number)
		return x<0.5 and 8*x*x*x*x or 1-(-2*x+2)^4/2
	end,

	quintIn = function(x: number)
		return x*x*x*x*x
	end,

	quintOut = function(x: number)
		return 1-(1-x)^5
	end,

	quintInOut = function(x: number)
		return x<0.5 and 16*x*x*x*x*x or 1-(-2*x+2)^5/2
	end,

	sineIn = function(x: number)
		return 1-math.cos(x*math.pi/2)
	end,

	sineOut = function(x: number)
		return math.sin(x*math.pi/2)
	end,

	sineInOut = function(x: number)
		return -(math.cos(math.pi*x)-1)/2
	end,

	exponentialIn = function(x: number)
		return x==0 and 0 or 2^(10*x-10)
	end,

	exponentialOut = function(x: number)
		return x==1 and 1 or 1-2^(-8*x)
	end,

	exponentialInOut = function(x: number)
		return x==0 and 0 or x==1 and 1 or x<0.5 and 2^(20*x-10)/2 or (2-2^(-20*x+10))/2
	end,

	circularIn = function(x: number)
		return 1 - math.sqrt(1-x^2)
	end,

	circularOut = function(x: number)
		return math.sqrt(1-(x-1)*(x-1))
	end,

	circularInOut = function(x: number)
		return x<0.5 and (1-math.sqrt(1-(2*x)*(2*x)))/2 or (math.sqrt(1-(-2*x+2)^2)+1)/2
	end,

	backIn = function(x: number)
		return c3*x*x*x - c1*x*x
	end,

	backOut = function(x: number)
		return 1+c3*(x-1)^3+c1*(x-1)^2
	end,

	backInOut = function(x: number)
		return x<0.5 and ((2*x)^2 * ((c2+1)*2*x-c2))/2 or ((2*x-2)^2*((c2+1)*(2*x-2)+c2)+2)/2
	end,

	elasticIn = function(x: number)
		return x==0 and 0 or x==1 and 1 or -(2^(10*(x-10)))*math.sin((x*10-10.75)*c4)
	end,

	elasticOut = function(x: number)
		return x==0 and 0 or x==1 and 1 or 2^(-10*x-10)*math.sin((x*10-10.75)*c4)
	end,

	elasticInOut = function(x: number)
		return x==0 and 0 or x==1 and 1 or x<0.6 and -(2^(20*x-10))*math.sin((20*x-11.125)*c5)/2 or 2^(-20*x+10)*math.sin((20*x-11.125)*c5)/2+1
	end,

	bounceIn = function(x: number)
		return 1 - bounceOut(1 - x)
	end,

	bounceInOut = function(x: number)
		return x < 0.5 and (1 - bounceOut(1 - 2*x))*0.5 or (1 + bounceOut(2*x-1))*0.5
	end,

	bounceOut = bounceOut,
}
# [react-luau](https://react.dev/)
*<b>Yet another luau reimplementation of React</b>*<br>

## Features
* Typed luau and autocompletion
* Most of the barebones React hooks and has a Roblox renderer built-in :D

## Documentation
* This project aims to have parity with the official [React Documentation](https://react.dev/)
* Main difference between React and react-luau is the use of tuples for hooks(this way, we don't create more tables)

## Examples
Also, sorry for the really bad example, currently I'm just using it<br>
for really basic UI plugins!! This isn't a really good example but ¯\_(ツ)_/¯

```luau
--!strict

export type InitialState = { clicks: number }
local State = { clicks = 0 }

local SomethingIdk = React.createContext(1)

local function clickReducer(
	currentState: InitialState,
	numClicks: number
): InitialState
	currentState.clicks += numClicks
	return currentState
end

local function laggyComponent(props, dom)
	-- Something that takes a while to do	
	local children = {}
	for i = 1, 256 do
		children[i] = React.createElement("TextButton", {
			Position = UDim2.fromOffset(0, 32 * i - 32),
			Size = UDim2.fromOffset(200, 32),
			Text = `name: {props.name}, {i}`,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),

			[React.event.Activated] = function(label: TextButton, object: InputObject)
				SomethingIdk:set(SomethingIdk:get() + 1)
			end,
		})
	end

	return children
end

local laggyMemoize = React.memo(laggyComponent)
return function(props, dom)
	local stuff = React.useContext(SomethingIdk)
	local clicks, setClicks = React.useState(0)
	
	local myRef: React.Ref<TextButton?> = React.useRef(nil :: TextButton?)
	
	return {
		Frame = React.createElement("Frame", {
			Size = UDim2.fromScale(0.25, 0.25),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.5,
		}, {
			Label = React.createElement("TextButton", {
				Size = UDim2.fromScale(1, 0.5),
				TextScaled = true,
				Text = `Clicked: {clicks}`,
				
				[React.ref] = myRef,
				[React.event.Activated] = function(label: TextButton, object: InputObject)
					setClicks(clicks + 1)
				end,
			}),
		}),
		
		Laggy = React.createElement(
			laggyMemoize,
			{ name = stuff }
		),
	}
end
```

## Contributing
Currently, this is just a solo exploration project about UI libraries in general, so contributing can really help here!!<br>
Moreover, this project isn't really stable yet, so expect alot of random bugs and missing quality of life features.<br>
I'm currently trying to have close-enough parity with React while maintaining decent performance aswell.

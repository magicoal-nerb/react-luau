-- react-luau.lua
-- Thanks you for using!! :3
-- This library uses function components only, and tries
-- to minimize the codebase size of React while maintaining
-- React's speed
-- poopbarrel/magicoal_nerb :^)

-- Best practices: just make sure you don't spam stuff like setState, 
-- dispatch, etc... which would invoke redraws. Redraws take up a buncha memory
-- for heavier components because we have to make a temporary table each time
-- we want to create elements inside of it, and reconciliation takes some time!!
-- (and that problem's unavoidable, it's just a design flaw with React's style)

local React = require("@self/React")
local Animated = require("@self/lib/Animated")

-- from React
export type Context<T> = React.Context<T>
export type Anim<T> = React.Anim<T>
export type Ref<T> = React.Ref<T>

export type Renderer = React.Renderer
export type Element = React.Element
export type React = React.React
export type Type = React.Type

-- from Animated
export type TimingParams<T> = Animated.TimingParams<T>
export type Value<T> = T | Animated.Anim<T>

return {
	-- Modules
	RobloxRenderer = require("@self/RobloxRenderer"),
	React = require("@self/React"),
	empty = table.freeze({}) :: { any },
	
	-- Lib
	Animated = require("@self/lib/Animated"),
	
	-- Utility
	createContext = require("@self/types/createContext"),
	createElement = require("@self/types/createElement"),
	easings = require("@self/types/easings"),
	changed = require("@self/types/changed"),
	event = require("@self/types/event"),
	ref = require("@self/types/ref"),
	
	-- Components
	memo = require("@self/components/memo"),
	
	-- Hooks
	useAnimatedValue = require("@self/hooks/useAnimatedValue"),
	useLayoutEffect = require("@self/hooks/useLayoutEffect"),
	useCallback = require("@self/hooks/useCallback"),
	useReducer = require("@self/hooks/useReducer"),
	useContext = require("@self/hooks/useContext"),
	useCleanup = require("@self/hooks/useCleanup"),
	useEffect = require("@self/hooks/useEffect"),
	useState = require("@self/hooks/useState"),
	useMemo = require("@self/hooks/useMemo"),
	useRef = require("@self/hooks/useRef"),

	-- Functions
	enqueueElement = function(element: Element)
		return React:enqueueElement(element)
	end,

	mount = function(element: Element, parent: Instance)
		return React:mount(element, parent)
	end,
	
	unmount = function(element: Element)
		return React:unmount(element)
	end,
}
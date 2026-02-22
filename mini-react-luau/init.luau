--!strict

-- thank you so much for using!! :3
-- this version is refactored for better code efficiency
-- and better error management. this is because i thought
-- the old codebase became too verbose
-- magical_noob

local React = require("@self/React")

local Context = require("@self/util/Context")
local Ref = require("@self/util/Ref")

export type Component = React.Component
export type Renderer = React.Renderer
export type Element = React.Element

export type Context<T> = Context.Context<T>
export type Ref<T> = Ref.Ref<T>

return {
	RobloxRenderer = require("@self/RobloxRenderer"),
	Context = require("@self/util/Context"),
	React = require("@self/React"),
	
	-- components
	ref = require("@self/components/ref"),
	memo = require("@self/components/memo"),
	event = require("@self/components/event"),
	union = require("@self/components/union"),
	changed = require("@self/components/changed"),
	easings = require("@self/components/easings"),
	createElement = require("@self/components/element"),
	
	-- hooks
	useRef = require("@self/hooks/useRef"),
	useMemo = require("@self/hooks/useMemo"),
	useTween = require("@self/hooks/useTween"),
	useState = require("@self/hooks/useState"),
	useEffect = require("@self/hooks/useEffect"),
	useCleanup = require("@self/hooks/useCleanup"),
	useContext = require("@self/hooks/useContext"),
	useReducer = require("@self/hooks/useReducer"),
	useCallback = require("@self/hooks/useCallback"),
	useLayoutEffect = require("@self/hooks/useLayoutEffect"),
}
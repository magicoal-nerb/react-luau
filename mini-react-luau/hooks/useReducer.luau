--!strict

--[[
	useReducer.lua
	* Similar to state, but for functions that change
	* the current state. Assumes that you store state 
	* as a constant beforehand. Please do that :3
	
	usage:
	```lua
	-- Make sure your initial state is an upvalue here!!
	-- We don't you creating even more tables when we redraw
	-- stuff!!
	local initialState = {
		thing = "something",
		idk = "ok",
	}
	
	return function(props)
		local state, dispatch = useReducer(function(state, action)
			if action.something then
				state.thing = "idk man"
				return state
			end
		end, initialState)
		
		return {
			-- somewhere in your code...
			createElement("TextButton", {
				Text = state.thing,
				Activated = function()
					-- also you don't have to use tables, this is
					-- just for demonstrations sake
					dispatch({ something = true })
				end,
			})
		}
	end
	```
]]

local React = require("../React")
type Element = React.Element

local function deepClone(element)
	-- Deep clones the state object
	-- on initialization
	local output = {}
	for name, value in element do
		if typeof(value) == "table" then
			output[name] = deepClone(value)
		else
			output[name] = value
		end
	end
	
	return output
end

type Hook<T, V> = {
	state: T,
	dispatch: (action: V) -> (),
}

return function<T, V>(
	reducer: (state: T, action: V) -> T?,
	initial,
	shouldDeepClone: boolean?
): (T, (x: V) -> ())
	local id = React:getHookIndex()
	local new = React.hookFiber :: Element
	local old = new.previous :: Element

	-- Get the hooks
	assert(new.hooks)

	if old then
		-- Use that state instead
		local hook: Hook<T, V> = (old.hooks :: {any})[id]
		return hook.state, hook.dispatch
	else
		-- Create our new state instead
		local state = if shouldDeepClone
			then deepClone(initial)
			else table.clone(initial)

		local function dispatch(action: V)
			-- Queue up this fiber to be rebuilt
			local newState = reducer(state, action)
			if newState ~= nil then
				-- New state, so enqueue
				new.hooks[id].state = newState
				React:enqueueElement(new)
			end
		end
		
		new.hooks[id] = {
			state = state,
			dispatch = dispatch,
		} :: Hook<T, V>
		
		return state, dispatch
	end
end
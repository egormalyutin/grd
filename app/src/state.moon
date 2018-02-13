callbacks = { 'directorydropped', 'draw', 'filedropped', 'focus', 'keypressed', 'keyreleased', 'lowmemory', 'mousefocus', 'mousemoved', 'mousepressed', 'mousereleased', 'quit', 'resize', 'textedited', 'textinput', 'threaderror', 'touchmoved', 'touchpressed', 'touchreleased', 'update', 'visible', 'wheelmoved', 'gamepadaxis', 'gamepadpressed', 'gamepadreleased', 'joystickadded', 'joystickaxis', 'joystickhat', 'joystickpressed', 'joystickreleased', 'joystickremoved' }	
class State
	new: =>
		-- generate event callbacks
		for cb in *callbacks
			@[cb] = (...) =>
				if @current and @current[cb] ~= nil
					return @current[cb] @current, ...

		@history = {}
		@switch {}

	switch: (to, ...) =>
		if @current ~= nil and @current.leave ~= nil
			@current\leave to

		@current = to
		table.insert @history, @current

		if @current ~= nil and not @current.__gamestate_inited
			if @current ~= nil and @current.init ~= nil
				@current\init ...

			@current.__gamestate_inited = true

		if @current ~= nil and @current.enter ~= nil
			@current\enter ...

	pop: (...) =>
		if @current ~= nil and @current.leave ~= nil
			@current\leave to

		table.remove @history
		@current = @history[#@history]

		if @current ~= nil and @current.resume ~= nil
			@current\resume ...

	register: =>
		sf = @
		for cb in *callbacks
			love.event.push cb, (...) ->
				return sf[cb] sf, ...

return State

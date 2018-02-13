local callbacks = {
  'directorydropped',
  'draw',
  'filedropped',
  'focus',
  'keypressed',
  'keyreleased',
  'lowmemory',
  'mousefocus',
  'mousemoved',
  'mousepressed',
  'mousereleased',
  'quit',
  'resize',
  'textedited',
  'textinput',
  'threaderror',
  'touchmoved',
  'touchpressed',
  'touchreleased',
  'update',
  'visible',
  'wheelmoved',
  'gamepadaxis',
  'gamepadpressed',
  'gamepadreleased',
  'joystickadded',
  'joystickaxis',
  'joystickhat',
  'joystickpressed',
  'joystickreleased',
  'joystickremoved'
}
local State
do
  local _class_0
  local _base_0 = {
    switch = function(self, to, ...)
      if self.current ~= nil and self.current.leave ~= nil then
        self.current:leave(to)
      end
      self.current = to
      table.insert(self.history, self.current)
      if self.current ~= nil and not self.current.__gamestate_inited then
        if self.current ~= nil and self.current.init ~= nil then
          self.current:init(...)
        end
        self.current.__gamestate_inited = true
      end
      if self.current ~= nil and self.current.enter ~= nil then
        return self.current:enter(...)
      end
    end,
    pop = function(self, ...)
      if self.current ~= nil and self.current.leave ~= nil then
        self.current:leave(to)
      end
      table.remove(self.history)
      self.current = self.history[#self.history]
      if self.current ~= nil and self.current.resume ~= nil then
        return self.current:resume(...)
      end
    end,
    register = function(self)
      local sf = self
      for _index_0 = 1, #callbacks do
        local cb = callbacks[_index_0]
        love.event.push(cb, function(...)
          return sf[cb](sf, ...)
        end)
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      for _index_0 = 1, #callbacks do
        local cb = callbacks[_index_0]
        self[cb] = function(self, ...)
          if self.current and self.current[cb] ~= nil then
            return self.current[cb](self.current, ...)
          end
        end
      end
      self.history = { }
      return self:switch({ })
    end,
    __base = _base_0,
    __name = "State"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  State = _class_0
end
return State
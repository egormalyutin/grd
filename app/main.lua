local config = require('config')
local sti = require('libs.sti.sti')
local loc = require('libs.loc')
local asset = require('src.assets')
if config.debug then
  print('DEBUG')
end
local map
love.load = function()
  local ww = love.graphics.getWidth()
  local wh = love.graphics.getHeight()
  map = sti('assets/maps/top.lua', {
    "box2d"
  })
  love.physics.setMeter(32)
  local world = love.physics.newWorld(0, 0)
  return map:box2d_init(world)
end
local assets
love.update = function(dt)
  map:update(dt)
  assets = {
    arch = asset('assets/sprites/archlogo.png')
  }
end
love.draw = function()
  love.graphics.setColor(255, 255, 255, 255)
  map:draw(nil, nil, 2.3, 2.3)
  if assets then
    if assets.arch then
      return love.graphics.draw(assets.arch)
    end
  end
end
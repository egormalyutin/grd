-- modules
config = require 'config'

sti = require 'libs.sti.sti'
loc = require 'libs.loc'
asset = require 'src.assets'

if config.debug
	print 'DEBUG'

local map

love.load = ->
	ww = love.graphics.getWidth!
	wh = love.graphics.getHeight!

	map = sti 'assets/maps/top.lua', { "box2d" }

	love.physics.setMeter 32
	world = love.physics.newWorld 0, 0

	map\box2d_init world

local assets

love.update = (dt) ->
	map\update dt

	assets =
		arch: asset 'assets/sprites/archlogo.png'

love.draw = ->
	love.graphics.setColor 255, 255, 255, 255
	map\draw nil, nil, 2.3, 2.3
	if assets
		if assets.arch
			love.graphics.draw assets.arch

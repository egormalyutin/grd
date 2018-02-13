THREAD_FILE_NAME = (...)\gsub("%.", "/") .. "/thread.lua"

current = (...)

load = (path) ->
	succ, loaded = pcall require, path
	unless succ
		LC_PATH = current .. '.' .. path
		succ, loaded = pcall require, LC_PATH
		unless succ
			LC_PATH = current\gsub("%.[^%..]+$", "") .. '.' .. path
			succ, loaded = pcall require, LC_PATH
			unless succ
				error loaded

	return loaded

loaders = load 'loaders'

getExt = (name) ->
	name\match "[^.]+$"


channelNum = 0

cache = {}

new = (path) ->
	CHANNEL_NAME = "load-channel-" .. channelNum
	channelNum += 1
	thread  = love.thread.newThread  THREAD_FILE_NAME
	channel = love.thread.getChannel CHANNEL_NAME

	ext = getExt path 

	thread\start path, ext, CHANNEL_NAME, current
	loader = loaders[ext]

	assert loader, 'Not found loader for format "' .. ext .. '"!'

	local data

	return ->
		unless data
			err = thread\getError!
			error err if err
			data = channel\pop!
			if data
				data = loader.master data


		return data

get = (path) ->
	if cache[path]
		return cache[path]()
	else
		cache[path] = new path
		return cache[path]()

return get
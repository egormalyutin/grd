gulp = require 'gulp'
# PLUGINS
download   = require 'gulp-downloader'
rename     = require 'gulp-rename'
merge      = require 'merge-stream'
mustache   = require 'mustache'

class BuildFiles
	constructor: (@config) ->
		sf = @
		Object.defineProperty @, 'compiled',
			get: ->
				unless sf._compiled?
					sf.compile()

				return sf._compiled


	links: ->
		# GET LINKS
		version   = @config.version
		dp        = @config.download
		platforms = @config.platforms

		r = {}

		for name, platform of platforms
			r[name] = {}
			for arch in platform.arches
				path = mustache.render platform.filename, { version, arch }
				link = mustache.render dp, { path }
				r[name][arch] = link

		return r

	compile: ->
		links = @links()

		r = 
			platforms: {}
			streams: []
			stream: undefined

		for name, platform of links
			r.platforms[name] = {}
			plt = r.platforms[name]
			for arch, link of platform
				# DOWNLOAD AND PROCESS BUILDFILE
				do (name, arch, link, plt) =>
					dw = download link
					dw = @config.platforms[name].prepare dw
					dw = dw.pipe rename (path) -> 
						path.dirname = "#{name}/#{arch}/" + path.dirname

					sf = @

					plt[arch] =
						stream: dw
						build: -> 
							sf.config.platforms[name].build dw, arguments...

					r.streams.push dw

		r.stream = merge r.streams...
		@_compiled = r
		return r

module.exports = BuildFiles

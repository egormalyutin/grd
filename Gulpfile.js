// Generated by CoffeeScript 2.1.1
// PLUGINS
var BUILDERS, BUILDFILES, BUILDFILES_DIR, BuildFiles, CONFIG_NAME, Vinyl, addGameConfig, ar, beep, bf, cache, concat, debug, decompress, del, error, exists, filter, fs, generateGameConfig, gif, gulp, ico, ignore, ignorify, imagemin, merge, moon, moonify, path, plumber, rcedit, rename, tap, tarxz, through, watch, zip;

gulp = require('gulp');

watch = require('gulp-watch');

plumber = require('gulp-plumber');

debug = require('gulp-debug');

rename = require('gulp-rename');

filter = require('gulp-filter');

gif = require('gulp-if');

concat = require('gulp-concat');

ignore = require('gulp-ignore');

tap = require('gulp-tap');

cache = require('gulp-cache');

ico = require('gulp-to-ico');

imagemin = require('gulp-imagemin');

ar = require('gulp-extract-ar');

zip = require('gulp-zip');

decompress = require('gulp-decompress');

moon = require('gulp-moon');

through = require('through2');

Vinyl = require('vinyl');

tarxz = require('decompress-tarxz');

beep = require('beeper');

merge = require('merge-stream');

rcedit = require('rcedit');

path = require('path');

fs = require('fs');

del = require('del');

BuildFiles = require('./buildfiles.js');

bf = void 0;

//#############
// BUILDFILES #
//#############
BUILDFILES_DIR = "buildfiles";

BUILDFILES = {
  version: '0.10.2',
  download: 'https://bitbucket.org/rude/love/downloads/{{path}}',
  platforms: {
    linux: {
      filename: "love_{{version}}ppa1_{{arch}}.deb",
      prepare: function(file) {
        return file.pipe(ar()).pipe(filter('data.tar.xz')).pipe(decompress({
          plugins: [tarxz()]
        })).pipe(filter('usr/bin/love')).pipe(rename('game'));
      },
      arches: ['i386', 'amd64', 'armhf']
    },
    windows: {
      filename: "love-{{version}}-{{arch}}.zip",
      prepare: function(file) {
        return file.pipe(decompress()).pipe(rename(function(pth) {
          var arr;
          arr = pth.dirname.split(path.sep);
          arr.shift();
          return pth.dirname = arr.join(path.sep);
        })).pipe(filter(['**', '!love-*']));
      },
      arches: ['win32', 'win64']
    }
  }
};

//###########
// BUILDERS #
//###########
BUILDERS = {
  linux: function(buildfiles, love) {
    return buildfiles.pipe(gif('love', tap(function(file) {
      return file.contents = Buffer.concat([file.contents, love]);
    }))).pipe(gif("love", rename("game")));
  },
  windows: function(buildfiles, love) {
    return buildfiles.pipe(ignore(['love.ico', 'lovec.exe', 'changes.txt', 'readme.txt'])).pipe(gif('love.exe', tap(function(file) {
      return file.contents = Buffer.concat([file.contents, love]);
    }))).pipe(gif("love.exe", rename("game.exe")));
  }
};

//#########
// CONSTS #
//#########
CONFIG_NAME = '/config.lua';

//##########
// HELPERS #
//##########
error = function(err) {
  beep();
  return console.error(err);
};

generateGameConfig = function(name) {
  return new Buffer(`return require('configs.${name}')`);
};

addGameConfig = function(name) {
  var cfg, complete;
  cfg = generateGameConfig(name);
  complete = false;
  return through.obj(function(file, enc, cb) {
    if (!complete) {
      this.push(new Vinyl({
        cwd: '/',
        base: '/',
        path: CONFIG_NAME,
        contents: cfg
      }));
      complete = true;
    }
    if (file.path.match(CONFIG_NAME)) {
      return cb(null);
    } else {
      return cb(null, file);
    }
  });
};

exists = function(file) {
  try {
    fs.statSync(file);
    return true;
  } catch (error1) {
    return false;
  }
};

ignorify = function(patterns) {
  var p;
  return (function() {
    var i, len, results;
    results = [];
    for (i = 0, len = patterns.length; i < len; i++) {
      p = patterns[i];
      results.push(`!${p}`);
    }
    return results;
  })();
};

//########
// TASKS #
//########
moonify = function(s) {
  return s.pipe(plumber({
    errorHandler: error
  })).pipe(moon()).pipe(debug({
    title: 'MoonScript: compiled'
  })).pipe(gulp.dest('app'));
};

// WATCH TASKS
gulp.task('watch:moon', function() {
  return moonify(watch('app/**/*.moon', {
    ignoreInitial: false
  }));
});

gulp.task('moon', function() {
  return moonify(gulp.src('app/**/*.moon'));
});


// CLEAN TASKS
gulp.task('clean:buildfiles', function(cb) {
  return del(['buildfiles'], cb);
});

gulp.task('clean:dist', function(cb) {
  return del(['dist'], cb);
});

gulp.task('clean:build', function(cb) {
  return del(['build'], cb);
});

gulp.task('clean:icon', function(cb) {
  return del(['icon.ico'], cb);
});

gulp.task('clean', gulp.parallel('clean:buildfiles', 'clean:dist', 'clean:build', 'clean:icon'));

// START TASKS
gulp.task('start:dist', function() {
  var ignored;
  ignored = ['app/**/docs/**/*', 'app/**/docs', 'app/**/spec/**/*', 'app/**/spec', 'app/**/*.md', 'app/**/*.moon', 'app/**/*.git', 'app/**/*.rockspec', 'app/**/LICENSE', 'app/**/*.sh'];
  return gulp.src(['app/**/*', ...ignorify(ignored)]).pipe(gif('*.+(png|jpg|gif|svg)', cache(imagemin()))).pipe(addGameConfig('production')).pipe(gulp.dest('dist'));
});

gulp.task('start:copy-build', function() {
  return gulp.src(['buildfiles/**/*']).pipe(gulp.dest('build'));
});

// BUILD TASKS
gulp.task('build:love', function() {
  return gulp.src('dist/**/*').pipe(zip('game.love')).pipe(gulp.dest('build'));
});

// 'build:rcedit'
gulp.task("build:main", function() {
  var arch, builder, files, i, len, lv, name, platform, ref, streams;
  lv = fs.readFileSync('build/game.love');
  streams = [];
  for (name in BUILDERS) {
    builder = BUILDERS[name];
    platform = BUILDFILES.platforms[name];
    ref = platform.arches;
    for (i = 0, len = ref.length; i < len; i++) {
      arch = ref[i];
      files = gulp.src(`${BUILDFILES_DIR}/${name}/${arch}/**/*`);
      streams.push(builder(files, lv).pipe(gulp.dest(`build/${name}/${arch}`)));
    }
  }
  return merge(...streams);
});

gulp.task('build:icon', function(cb) {
  if (!exists('icon.ico')) {
    return gulp.src('app/assets/sprites/icon.png').pipe(ico("icon.ico", {
      resize: true
    })).pipe(gulp.dest("./"));
  } else {
    return Promise.resolve();
  }
});

gulp.task('build:copy-icon', function() {
  return gulp.src('icon.ico').pipe(rename('game.ico')).pipe(gulp.dest('build/windows/win32/')).pipe(gulp.dest('build/windows/win64/'));
});

gulp.task('build:rcedit', function() {
  return Promise.all([
    new Promise(function(resolve,
    reject) {
      return rcedit('build/windows/win64/game.exe',
    {
        icon: 'build/windows/win64/game.ico'
      },
    function() {
        return resolve();
      });
    }),
    new Promise(function(resolve,
    reject) {
      return rcedit('build/windows/win32/game.exe',
    {
        icon: 'build/windows/win32/game.ico'
      },
    function() {
        return resolve();
      });
    })
  ]);
});

// GET TASKS
gulp.task('get:buildfiles', function() {
  if (!exists(BUILDFILES_DIR)) {
    bf = new BuildFiles(BUILDFILES);
    return bf.compiled.stream.pipe(debug({
      title: 'Loaded buildfile'
    })).pipe(gulp.dest(BUILDFILES_DIR));
  } else {
    return Promise.resolve();
  }
});

// MIX TASKS
gulp.task('build', gulp.series(gulp.parallel('get:buildfiles', 'clean:dist', 'clean:build'), 'start:dist', gulp.parallel('build:love', 'build:icon'), 'build:main', 'build:copy-icon', 'build:rcedit'));

gulp.task('default', gulp.series('build'));
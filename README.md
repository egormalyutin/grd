[![Windows builds](https://img.shields.io/appveyor/ci/egorcod/grd.svg?style=flat-square)](https://ci.appveyor.com/project/egorcod/grd) [![Linux builds](https://img.shields.io/travis/malyutinegor/grd.svg?style=flat-square)](https://travis-ci.org/malyutinegor/grd) 

# Building

## Run
Simply execute `gulp`.

## On Windows

You need to install [Node.JS] and [git], clone this [repository], install [Gulp] and this module dependencies.
You can easily do it with [Chocolatey]: 
```cmd
choco install nodejs git
# Reopen your terminal for update PATH!
git clone https://github.com/malyutinegor/grd
npm i -g gulp-cli
npm i
```

## On Linux
You need to install [Node.JS], [git] and [Wine] (it\'s needed for edit Windows executable icon and manifest).
Then, clone this [repository], install [Gulp] and this module dependencies.
```bash
# Install this packages via your system package manager: nodejs git wine
git clone https://github.com/malyutinegor/grd
sudo npm i -g gulp-cli
npm i
```

[Wine]: https://winehq.org/
[git]: https://git-scm.com/
[repository]: https://github.com/malyutinegor/grd
[Node.JS]: https://nodejs.org/
[Gulp]: https://gulpjs.com/
[Chocolatey]: https://chocolatey.org/
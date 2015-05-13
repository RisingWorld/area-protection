# Area Protection Script

---
# !! DO NOT USE ON PUBLIC SERVERS !!

This branch is a development branch. It is either not complete or unstable. It may break and not work as intented. This branch is offered strictly for testing purposes. **Backup your script database before using this branch!**

---


## Introduction

This script enable area protection for your server and allow assigning rights to players in any protected areas.


## Installation

This modules has dependencies, therefore you need to make sure that all of them are properly installed before using this script!

### Using Git

Go to the `scripts` folder of your Rising World installation and type

```
git clone --recursive https://github.com/RisingWorld/area-protection.git
git checkout dev
```

### Manually

Download the Zip file for [this](https://github.com/RisingWorld/area-protection/archive/dev.zip) repository and extract it to your Rising World's `scripts/area-protection` folder.

Download the Zip file for the [i18n](https://github.com/RisingWorld/i18n/archive/master.zip) sub-module, and extract it inside the `i18n` folder of this script.

Download the Zip file for the [command parser](https://github.com/RisingWorld/command-parser/archive/master.zip) sub-module, and extract it inside the `command-parser` folder of this script.

Download the Zip file for the [string-ext](https://github.com/RisingWorld/string-ext/archive/master.zip) sub-module, and extract it inside the `string-ext` folder of this script.


## Updating

Whenever Area Protection is updated, you should also update your server. To keep up-to-date with the newest features, but more importantly to stay up-to-date with the most recent patches of Rising World, and correct any security issues. You may also consider automating this process. The updates will take effect only after server restart.

### Using Git

Go to your `area-protection` script folder and type

```
git fetch --recurse-submodules origin dev
```

### Manually

Repeat manual installation process, overwrite any existing files.


## Usage

In-game, in chat, type `/area <command>` where `<command>` is one of the following :

### Commands

* `help [<command>]` : dipslay help. If `<command>` is specified, display help for that command.  
  Ex: `/area help create`

* `show` : show all areas
* `hide` : hide all areas
* `select` : start area selection  
* `cancel` : cancel area selection
* `create <areaname>` : create an area with the specified name from the current selection. If the area name contains many words, enclose it in double quotes.  
  Ex: `/area create "My super fun zone!"`

* `info [areaname]` : show information about an area. If `areaname` is not specified, the current area information is shown. If `areaname` contains spaces, enclose it in double quotes.  
  Ex: `/area info "My super fun zone!"`

* `remove` : remove the current area. For security reasons, the player must stand in the area to remove it.  
  Ex: `/area remove`

* `grant <group> [playername]` : grant permissions to the specified player in the current area. For security reasons, the player must stand in the area to grant permissions. If no player name is given, then the current player is granted permissions.  
  Ex: `/area grant builder xSuperfrienDx`

* `revoke [playername]` : revoke all permissions to the specified player in the current area. For security reasons, the player must stand in the area to revoke permissions. If no player name is given, then the current player gets it's own permissions revoked.  
  Ex: `/area revoke xSuperfrienDx`


## Contributors

* LordFoobar (Yanick Rochon)
* KingGenius *(original author)*

### Translators

* *n/a*


## License

Copyright (c) 2015 Rising World Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
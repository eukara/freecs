# FreeCS
[As seen on phoronix.com](https://phoronix.com/scan.php?page=news_item&px=FreeCS-Open-Counter-Strike)

Clean-room reimplementation of Counter-Strike 1.5 (mod-version).

Aiming for a stable reimagining of the original mod in QuakeC.
Not aiming for accuracy, but for a smooth, exploit and bug-free
experience over the Internet.

Done in my freetime for countless reasons, but most important to me: to learn everything there is to know about one of my favorite games.

This is all 100% new, original code written by good old trial and error.
**Differences exist** and features are slowly being implemented one by one.
This allows the code to be fully free and unencumbered, unlike similar projects.

Featuring proper weapon prediction to enable stress-free netplay.

The engine you want to use to run this is FTEQW (https://www.fteqw.org), which is a project unrelated to this. It just happens to support the file-formats FreeHL needs.

![Preview 1](img/preview1.jpg)
![Preview 2](img/preview2.jpg)
![Preview 3](img/preview3.jpg)
![Preview 4](img/preview4.jpg)

## Features and Improvements

- Native support for Windows/Mac/Linux/BSD and wherever else FTEQW runs on
- Better support for higher display modes and aspect ratios
- Much easier modding by having the entire logic be in modern QuakeC
- Netcode that's always improving and more advanced prediction
- Open-source code for transparent modding
- Very permissive license (ISC/BSD)
- The code doesn't rely on others work, so nobody can shut it down :-)

## Installing 
To run it, all you need is [FTEQW](https://www.fteqw.org), [FreeHL](https://www.frag-net.com/pkgs/package_valve.pk3), and [the latest release .pk3 file](https://www.frag-net.com/pkgs/package_cstrike.pk3), which you save into `Half-Life/valve/` and `Half-Life/cstrike/` respectively. That's about it. You can install updates through the **Configuration > Updates** menu from here on out.

### Disclaimer
Please **do not** file bugs if you see missing/broken content **while not** using the original Half-Life and Counter-Strike 1.5 data.

## Building
Here's the quick and dirty instructions for those unfamilar:

```
$ git clone https://code.idtech.space/vera/nuclide Nuclide-SDK
$ cd Nuclide-SDK
$ ./build_engine.sh # (only required if you don't have an up-to-date FTEQW & FTEQCC in your PATH)
$ git clone https://code.idtech.space/fn/valve valve
$ git clone https://code.idtech.space/fn/cstrike cstrike
$ SKIP_UPDATE=1 SKIP_RADIANT=1 ./build_game.sh valve
$ SKIP_UPDATE=1 SKIP_RADIANT=1 ./build_game.sh cstrike
```

You can also issue `make` inside `valve/src/` and `cstrike/src`, but it won't build an `entities.def` file for use in Radiant (level editor family).

** !! You need to also provide data-files !! **

This should be self explanatory.
Half-Life and Counter-Strike are owned by Valve and protected under copyright.

## Community

### Matrix
If you're a fellow Matrix user, join the Nuclide Space to see live-updates and more!
https://matrix.to/#/#nuclide:matrix.org

### IRC
Join us on #freecs via irc.libera.chat and talk/lurk or discuss bugs, issues
and other such things. It's bridged with the Matrix room of the same name!

### Others
We've had people ask in the oddest of places for help, please don't do that.

## Special Thanks

- Spike for FTEQW and for being the most helpful person all around!
- Xylemon for the hundreds of test maps, verifying entity and game-logic behaviour
- CYBERDEViL for his work on making Bots fascinated with Bomb Defusal
- mikota for his work on refining the bullet spread code
- To my supporters on Patreon, who are always eager to follow what I do.
- Any and all people trying it, tinkering with it etc. :)

## License
ISC License

Copyright (c) 2016-2024 Marco Cawthorne <marco@icculus.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 

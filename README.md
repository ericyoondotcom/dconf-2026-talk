# Eric's DConf 2026 Talk

Supplementary materials for Eric Yoon's DConf 2026 talk.

> ### Deploying Cross-Platform DLang Games on Steam: From Dev to Production
> 
> The greatest test of a new game programming language is whether it can actually be used to ship commercial software. This talk will prove that D can indeed be used to make games that are distributed on Mac, Windows, and Steam marketplaces. We’ll go in depth about the technical challenges associated with building universal binaries, code signing executables, and bundling often-used game programming libraries like SDL, Steamworks, and Discord SDKs. By the end of the talk, you’ll be able to go from dub dev builds to shipping plug-and-play .exe and .app files on Steam.

Relevant folders:
- `sdl-gui-app`: minimal example of an SDL3 app that builds to Mac `.app` and Windows `.exe`
- `discord-sdk`: contains documentation + example code for running the Discord Social SDK in D
- `steam-sdk`: contains documentation + example code for running the Steamworks SDK in D

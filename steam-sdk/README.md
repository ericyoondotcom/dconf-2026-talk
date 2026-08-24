# Steam SDK

This folder contains instructions on how to generate DLang bindings for the Steamworks SDK using SWIG, along with a minimal example.

## Prerequisites
1. **Get the SDK**: [Download the Steamworks C++ SDK](https://partner.steamgames.com/).
2. **Get SWIG**: [Download SWIG](https://www.swig.org/) from their webpage. I'm using v4.4.1.
3. **Build SWIG**: Inside the SWIG directory, follow the instructions in `INSTALL`. TL;DR: run `./configure && make`

## Set Env Vars

For convenience, set these environment variables that we will reference in later commands

```bash
export STEAMWORKS_SDK=/path/to/steamworks_sdk
export SWIG=/path/to/swig # path to the executable you built *inside* the SWIG dir
```

## Generate D Bindings Using SWIG

Copy the `steamworks.i` file from this folder into your `$STEAMWORKS_SDK/public/steam` directory. This is a SWIG interface file that tells SWIG what headers to copy, etc.

Then, run SWIG!

```bash
cd $STEAMWORKS_SDK/public/steam
mkdir -p dlang_out/steamworks

$SWIG -d -d2 -I. -outdir dlang_out -o dlang_out/steamworks_wrap.c -package steamworks steamworks.i
```

Note on what each file does:
- `steamworks.d` is the actual DLang API for the Steamworks SDK and has the methods/types you'll use.
- `steamworks_im.d` is the file that dynamically loads the Steamworks SDK dynamic library at runtime.
- `steamworks_wrap.c` is a thin wrapper that is necessary for the D bindings to talk to the C++ library.
- `libsteam_api.dylib` is the original Steamworks SDK dynamic library (which you still have to include with your executable)

## Build dylibs (macOS)

For macOS, we need to compile `steamworks_wrap.c` into two versions of a wrapper dylib, and then glue them together into a universal binary.

Note that we are specifying `-install_name` so that our executable knows where to find our dylib.

```bash
# Build the x64 slice
c++ -arch x86_64 -shared \
    -o "$STEAMWORKS_SDK/libsteamworks_wrap-x64.dylib" \
    "$STEAMWORKS_SDK/public/steam/dlang_out/steamworks_wrap.c" \
    -I"$STEAMWORKS_SDK/public" -I"$STEAMWORKS_SDK/public/steam" \
    -L"$STEAMWORKS_SDK/redistributable_bin/osx" -lsteam_api \
    -install_name @rpath/libsteamworks_wrap.dylib

# Build the arm64 slice
c++ -arch arm64 -shared \
    -o "$STEAMWORKS_SDK/libsteamworks_wrap-arm64.dylib" \
    "$STEAMWORKS_SDK/public/steam/dlang_out/steamworks_wrap.c" \
    -I"$STEAMWORKS_SDK/public" -I"$STEAMWORKS_SDK/public/steam" \
    -L"$STEAMWORKS_SDK/redistributable_bin/osx" -lsteam_api \
    -install_name @rpath/libsteamworks_wrap.dylib

# Glue into a universal binary
lipo -create \
    "$STEAMWORKS_SDK/libsteamworks_wrap-x64.dylib" \
    "$STEAMWORKS_SDK/libsteamworks_wrap-arm64.dylib" \
    -output "$STEAMWORKS_SDK/libsteamworks_wrap.dylib"
```

## Building dlls (Windows)


First, install [Build Tools for Visual Studio](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2026) with "Desktop Development with C++" workload.

You need to work in **x64 Native Tools Command Prompt** which comes bundled with C++ Build Tools. You cannot use regular Command Prompt because `cl` needs to be defined.

With the Steamworks SDK folder as your cwd, run:
```bat
mkdir obj

cl /nologo /LD /O2 /MT /TP /EHsc ^
   /I public ^
   /I public\steam ^
   /I public\steam\dlang_out ^
   /Foobj\ ^
   /Fepublic\steam\dlang_out\steamworks_wrap.dll ^
   public\steam\dlang_out\steamworks_wrap.c ^
   /link redistributable_bin\win64\steam_api64.lib
```

This will generate the `steamworks_wrap.dll` dynamic library, which you should include in your project, alongside the original `steam_api64.dll`.

## Move Libraries Into Project

After you're done building the dylib, copy them into the example project.

In macOS, the libraries can live in the `lib` folder that's been added to the rpath:

```bash
cp $STEAMWORKS_SDK/libsteamworks_wrap.dylib ./steam-sdk-example/lib
cp $STEAMWORKS_SDK/redistributable_bin/osx/libsteam_api.dylib ./steam-sdk-example/lib
```

> Note that I've added an `lflags` entry in `dub.json` for Mac builds to modify the rpath so `lib/` gets searched when loading dylibs.

In Windows, the DLLs need to be siblings of the executable, since that's where the dynamic loader looks by default.

```bat
copy %STEAMWORKS_SDK%\public\steam\dlang_out\steamworks_wrap.dll .\steam-sdk-example
copy %STEAMWORKS_SDK%\redistributable_bin\win64\steam_api64.dll .\steam-sdk-example
```


## Run The Example

Put your Steam App ID into `steam_appid.txt`. Note that you only need to do this for development; when you ship a build to Steam, it automatically fills in the App ID for you.

```bash
cd steam-sdk-example
dub run --build=windows # for windows
dub run --build=mac # for mac
```

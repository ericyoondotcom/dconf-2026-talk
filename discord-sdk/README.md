# Discord SDK

This folder contains instructions on how to generate DLang bindings for the Discord SDK using SWIG, along with a minimal example.

## Prerequisites
1. **Get the SDK**: Due to the Discord SDK being proprietary, you'll need to sign the Discord Developers T&C and download the C library yourself from [their webpage](https://discord.com/developers/docs/social-layer/overview).
2. **Get SWIG**: [Download SWIG](https://www.swig.org/) from their webpage. I'm using v4.4.1.
3. **Build SWIG**: Inside the SWIG directory, follow the instructions in `INSTALL`. TL;DR: run `./configure && make`

## Set Env Vars

For convenience, set these environment variables that we will reference in later commands

```bash
export DISCORD_SDK=/path/to/discord_social_sdk
export SWIG=/path/to/swig # path to the executable you built *inside* the SWIG dir
```

## Generate D Bindings Using SWIG

Copy the `discord.i` file from this folder into your `$DISCORD_SDK/include` directory. This is a SWIG interface file that tells SWIG what headers to copy, etc.

Then, run SWIG!

```bash
cd $DISCORD_SDK/include
mkdir -p dlang_out/discord

$SWIG -d -d2 -I. -outdir dlang_out -o dlang_out/discord_wrap.c -package discord discord.i
```

Note on what each file does:
- `discord.d` is the actual DLang API for the Discord SDK and has the methods/types you'll use.
- `discord_im.d` is the file that dynamically loads the Discord SDK dynamic library at runtime.
- `discord_wrap.c` is a thin wrapper that is necessary for the D bindings to talk to the C library.
- `libdiscord_partner_sdk.dylib` is the original Discord SDK dynamic library (which you still have to include with your executable)

## Build dylibs (macOS)

For macOS, we need to compile `discord_wrap.c` into two versions of a wrapper dylib, and then glue them together into a universal binary.

Note that we are specifying `-install_name` so that our executable knows where to find our dylib.

```bash
# Build the x64 slice
cc -arch x86_64 -shared \
    -o "$DISCORD_SDK/libdiscord_wrap-x64.dylib" \
    "$DISCORD_SDK/include/dlang_out/discord_wrap.c" \
    -I"$DISCORD_SDK/include" \
    -L"$DISCORD_SDK/lib/release" -ldiscord_partner_sdk \
    -install_name @rpath/libdiscord_wrap.dylib

# Build the arm64 slice
cc -arch arm64 -shared \
    -o "$DISCORD_SDK/libdiscord_wrap-arm64.dylib" \
    "$DISCORD_SDK/include/dlang_out/discord_wrap.c" \
    -I"$DISCORD_SDK/include" \
    -L"$DISCORD_SDK/lib/release" -ldiscord_partner_sdk \
    -install_name @rpath/libdiscord_wrap.dylib

# Glue into a universal binary
lipo -create \
    "$DISCORD_SDK/libdiscord_wrap-x64.dylib" \
    "$DISCORD_SDK/libdiscord_wrap-arm64.dylib" \
    -output "$DISCORD_SDK/libdiscord_wrap.dylib"
```

## Building dlls (Windows)

First, install [Build Tools for Visual Studio](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2026) with "Desktop Development with C++" workload.

You need to work in **x64 Native Tools Command Prompt** which comes bundled with C++ Build Tools. You cannot use regular Command Prompt because `cl` needs to be defined.

With the Discord SDK folder as your cwd, run:
```bat
mkdir obj

cl /nologo /LD /O2 /MT ^
   /I include ^
   /I include\dlang_out ^
   /Foobj\ ^
   /Feinclude\dlang_out\discord_wrap.dll ^
   include\dlang_out\discord_wrap.c ^
   /link lib\release\discord_partner_sdk.lib
```

This will generate the `discord_wrap.dll` dynamic library, which you should include in your project, alongside the original `discord_partner_sdk.dll`.

## Move Libraries Into Project

Again, due to licensing concerns, I can't include the Discord SDK binary in the code example. So after you're done building the dylib, copy them into the example project.

In macOS, the libraries can live in the `lib` folder that's been added to the rpath:

```bash
cp $DISCORD_SDK/libdiscord_wrap.dylib ./discord-sdk-example/lib
cp $DISCORD_SDK/lib/release/libdiscord_partner_sdk.dylib ./discord-sdk-example/lib
```

In Windows, the DLLs need to be siblings of the executable:
```bat
copy %DISCORD_SDK%\discord_wrap.dll .\discord-sdk-example
copy %DISCORD_SDK%\lib\release\discord_partner_sdk.dll .\discord-sdk-example
```

Note that I've added an `lflags` entry in `dub.json` to modify the rpath so `lib/` gets searched when loading dylibs.

## Run The Example

Make an app in the Discord Developer Portal, and paste your app ID into `DISCORD_APP_ID` in `app.d`.

```bash
cd discord-sdk-example
dub run --build=windows # for windows
dub run --build=mac # for mac
```

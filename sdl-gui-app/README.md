# SDL3 Minimal Example

This example shows how to build and run an SDL3 app from DLang.

## Get the libraries

Download the latest SDL3 libraries from the [Github releases page](https://github.com/libsdl-org/SDL/releases/).
- **For macOS**: Download the `.dmg` and mount it. Inside `SDL3.xcframework/macos-arm64_x86_64`, copy `SDL3.framework` into `./lib`.
- **For Windows**: Download the `win32-x64.zip` file. Copy `SDL3.dll` to `./lib`.

## Run a development build

For Mac:
```bash
make mac-dev
```

For Windows:
```bash
make win-dev
```

_Try peeking inside the Makefile and see how the `--build` flag is passed!_

## Build a Mac App Bundle

```bash
make mac-appbundle
```

See the Makefile for details on how the build chain works.
- We create x64 and arm64 binaries, and then glue them together using `lipo`.
- We also have to copy SDL3 into `*.app/Contents/Frameworks` (which is already included in the rpath thanks to `lflags` in `dub.json`)
- Finally, we copy the required `Info.plist` into the app bundle
- The step that nukes `.DS_Store` is VERY IMPORTANT!

## Codesign your Mac App Bundle

First, you'll need two certificates from Apple: one **Developer ID Application**, and one **Developer ID Installer**. (To generate these, a $100/yr subscription is required.)

You also need an _app-specific password_, which you can create [here](https://account.apple.com/account/manage/section/security).

Fill in the following environment variables:
```bash
export DEVELOPER_ID_APPLICATION_CERT_NAME='Developer ID Application: Your Name (XXXXXXXXXX)'
export DEVELOPER_ID_INSTALLER_CERT_NAME='Developer ID Installer: Your Name (XXXXXXXXXX)'
export APPLE_ID='your_apple_id@example.com'
export APP_SPECIFIC_PWD='xxxx-xxxx-xxxx-xxxx'
export APPLE_TEAM_ID='XXXXXXXXXX'
```

Then, run the build script:

```bash
make mac-codesign
```

This may take a while, as you need to upload a `.pkg` file to Apple's servers and wait for it to comb through your binary!

## Build a Windows EXE

Building a Windows EXE is much easier than building a Mac app bundle. We simply copy everything into the `lib` folder that sits as a sibling to the exe.

Note that this portion of the Makefile uses Windows make syntax.

```bash
make win-exe
```

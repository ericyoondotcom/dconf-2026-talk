MAC_SDL3_FRAMEWORK_PATH = ./lib/SDL3.framework
WIN_SDL3_DLL_PATH = .\lib\SDL3.dll

SOURCES = $(wildcard source/**/*.d)

mac-dev: $(SOURCES)
	dub run --build=development-mac --compiler=ldc2

win-dev: $(SOURCES)
	dub run --build=development-win --compiler=ldc2

dlang-release-mac-x64: $(SOURCES)
# We target 10.13 for compat with older systems
	DFLAGS="-mtriple=x86_64-apple-macosx10.13" dub build --build=release-mac --compiler=ldc2 --arch=x86_64
	mv sdl-gui-app sdl-gui-app-x64

dlang-release-mac-arm64: $(SOURCES)
	DFLAGS="-mtriple=arm64-apple-macosx10.13" dub build --build=release-mac --compiler=ldc2 --arch=aarch64
	mv sdl-gui-app sdl-gui-app-arm64

dlang-release-win: $(SOURCES)
	dub build --build=release-win --compiler=ldc2

mac-appbundle: dlang-release-mac-x64 dlang-release-mac-arm64 Info.plist
# Package x64 and arm64 binaries into a universal binary
	lipo -create -output sdl-gui-app-universal sdl-gui-app-x64 sdl-gui-app-arm64

# Make the .app bundle structure
	rm -rf build
	mkdir -p "build/SDL GUI App.app/Contents/MacOS"
	mkdir -p "build/SDL GUI App.app/Contents/Frameworks"
	mkdir -p "build/SDL GUI App.app/Contents/Resources"
	
# Copy the executable
	cp sdl-gui-app-universal "build/SDL GUI App.app/Contents/MacOS/sdl-gui-app"

# Copy SDL frameworks
# -R is used instead of -r to preserve symlinks withour dereferencing them
	cp -R $(MAC_SDL3_FRAMEWORK_PATH) "build/SDL GUI App.app/Contents/Frameworks"

# Copy INFO plist
	cp Info.plist "build/SDL GUI App.app/Contents"

# Delete .DS_Store directories (they make codesign error out)
	find . -name ".DS_Store" -delete

	open build/

mac-codesign: build/SDL\ GUI\ App.app sdl-gui-app.entitlements
	chmod -R a+xr build/SDL\ GUI\ App.app
	xattr -cr "build/SDL GUI App.app"
# if you add more frameworks, add more codesign lines here
# we cannot use --deep because it is recommended against in 2025
	codesign --force --verify --verbose --sign "$(DEVELOPER_ID_APPLICATION_CERT_NAME)" --timestamp --options runtime "build/SDL GUI App.app/Contents/Frameworks/SDL3.framework"
	codesign --force --verify --verbose --sign "$(DEVELOPER_ID_APPLICATION_CERT_NAME)" --timestamp --options runtime --entitlements "sdl-gui-app.entitlements" "build/SDL GUI App.app/Contents/MacOS/sdl-gui-app"
	codesign --force --verify --verbose --strict --timestamp --options runtime --entitlements "sdl-gui-app.entitlements" --sign "$(DEVELOPER_ID_APPLICATION_CERT_NAME)" "build/SDL GUI App.app"
	
	productbuild --component "build/SDL GUI App.app" /Applications --sign "$(DEVELOPER_ID_INSTALLER_CERT_NAME)" "build/SDL GUI App.pkg"
	xcrun notarytool submit --apple-id "$(APPLE_ID)" --password "$(APP_SPECIFIC_PWD)" --team-id "$(APPLE_TEAM_ID)" "build/SDL GUI App.pkg" --wait
	echo "Notarization accepted. Waiting 5 seconds for ticket propagation..."
	sleep 5
	xcrun stapler staple "build/SDL GUI App.pkg"
	spctl -a -v --type install "build/SDL GUI App.pkg"
# In case notarization fails, you can check why by running
# 	xcrun notarytool log <ticket id> --apple-id "$APPLE_ID" --password "$APP_SPECIFIC_PWD" --team-id "$APPLE_TEAM_ID"

win-exe: dlang-release-win
	if exist build rmdir /s /q build
	mkdir build\sdl-gui-example-win64
	mkdir build\sdl-gui-example-win64\lib
	copy sdl-gui-app.exe build\sdl-gui-example-win64\sdl-gui-example.exe
	copy "$(WIN_SDL3_DLL_PATH)" build\sdl-gui-example-win64\lib
	cmd /c start "" build\sdl-gui-example-win64

clean:
	rm -rf build
	rm -f sdl-gui-app-x64
	rm -f sdl-gui-app-arm64
	rm -f sdl-gui-app-universal
	rm -f sdl-gui-app

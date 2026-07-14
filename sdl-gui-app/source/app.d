import std.stdio;
import std.conv;
import std.path;
import core.runtime;
import std.string;
import std.file;
import bindbc.sdl;
import bindbc.loader;

SDL_Window* window;
SDL_Renderer* renderer;

void initSDL()
{
	string execPath = Runtime.args[0];
	bool found = false;
	version(Release) {
		writeln("Looks like you're running a RELEASE build...");
		version(Platform_MacOS) {
			writeln("...on MAC");
			string exePath = thisExePath();
			string frameworksPath = buildNormalizedPath(dirName(exePath), "..", "Frameworks");
			if(loadSDL(buildPath(frameworksPath, "SDL3.framework", "SDL3").toStringz()) != LoadMsg.success)
				throw new Exception("Failed to load SDL");
			found = true;
		}
		version(Platform_Windows) {
			writeln("...on WINDOWS");
			string dllPath = buildPath(dirName(execPath), "lib");

			if(loadSDL(buildPath(dllPath, "SDL3.dll").toStringz()) != LoadMsg.success)
				throw new Exception("Failed to load SDL");
			found = true;
		}
	}
	version(Development) {
		writeln("Looks like you're running a DEVELOPMENT build...");
		version(Platform_MacOS) {
			writeln("...on MAC");
			string frameworksPath = buildPath(dirName(execPath), "lib");

			if(loadSDL(buildPath(frameworksPath, "SDL3.framework", "SDL3").toStringz()) != LoadMsg.success)
				throw new Exception("Failed to load SDL");
			found = true;
		}
		version(Platform_Windows) {
			writeln("...on WINDOWS");
			string dllPath = buildPath(dirName(execPath), "lib");

			if(loadSDL(buildPath(dllPath, "SDL3.dll").toStringz()) != LoadMsg.success)
				throw new Exception("Failed to load SDL");
			found = true;
		}
	}

	if(!found) {
		throw new Exception("Did not load SDL dynamic library! Did you forget to pass --build flag?");
	}

	bool result = SDL_Init(SDL_INIT_VIDEO);
	if(!result) {
		throw new Exception("Failed to initialize SDL: " ~ SDL_GetError().to!string);
	}
}

void createWindow()
{
	window = SDL_CreateWindow("SDL3 in DLang!", 1440, 810, SDL_WINDOW_HIGH_PIXEL_DENSITY);
	if(window is null) {
		throw new Exception("Failed to create window: " ~ SDL_GetError().to!string);
	}

	renderer = SDL_CreateRenderer(window, null);
	if(renderer is null) {
		throw new Exception("Failed to create renderer: " ~ SDL_GetError().to!string);
	}
}

void main()
{
	try {
		initSDL();
		createWindow();
	} catch(Exception e) {
		stderr.writeln("Error: ", e.msg);
		return;
	}

	bool running = true;
	while(running) {
		SDL_Event event;
		while(SDL_PollEvent(&event)) {
			if(event.type == SDL_EVENT_QUIT) {
				running = false;
			}
		}

		SDL_SetRenderDrawColor(renderer, 255, 0, 255, 255);
		SDL_RenderClear(renderer);
		SDL_RenderPresent(renderer);

		SDL_Delay(16);
	}

	SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
	SDL_Quit();
}

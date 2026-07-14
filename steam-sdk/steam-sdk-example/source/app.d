import core.thread;
import std.stdio;
import steamworks.steamworks;
static import steamworks.steamworks_im;

void main()
{
	bool initialized = SteamAPI_Init();
	if(!initialized) {
		stderr.writeln("Failed to initialize Steam API\nThis is expected if Steam is not running, or if the app was not launched through Steam");
		return;
	}
	
	while(true) {
		SteamAPI_RunCallbacks();
		Thread.sleep(1.seconds);
	}
}

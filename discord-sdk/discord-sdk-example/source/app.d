import core.thread;
import std.stdio;
static import discord.discord_im;
import discord.discord;

const ulong DISCORD_APP_ID = 0; // Replace with your app ID from the Discord Dev Console

extern(C) void discordDummyCb(void* result, void* userData) nothrow {}
extern(C) void discordDummyFreeCb(void* userData) nothrow {}

Discord_String toDiscordString(string s) {
	auto ds = new Discord_String();
	ds.ptr = cast(ubyte*)s.ptr;
	ds.size = cast(uint)s.length;
	return ds;
}

Discord_Client client;

void main()
{
	client = new Discord_Client();
	Discord_Client_Init(client);
	Discord_Client_SetApplicationId(client, DISCORD_APP_ID);
	Discord_Client_Connect(client);
	writeln("Discord SDK connected!");

	// Update rich presence (as a test)
	auto activity = new Discord_Activity();
	Discord_Activity_Init(activity);
	Discord_Activity_SetDetails(activity, toDiscordString("Using Discord SDK from D!"));
	auto cb = new SWIGTYPE_p_f_p_struct_Discord_ClientResult_p_void__void(cast(void*)&discordDummyCb, false);
	auto freeCb = cast(discord.discord_im.SwigExternC!(void function(void*))) &discordDummyFreeCb;
	Discord_Client_UpdateRichPresence(client, activity, cb, freeCb, null);
	writeln("Rich presence updated!");
	
	while(true) {
		Discord_RunCallbacks();
		Thread.sleep(1.seconds);
	}
}

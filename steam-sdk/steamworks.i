%module steamworks
%{
#include "steam_api_flat.h"
%}

#define S_API

typedef unsigned long long uint64;
typedef unsigned int uint32;
typedef unsigned short uint16;
typedef unsigned char uint8;
typedef long long int64;
typedef int int32;
typedef short int16;
typedef char int8;

extern "C" {
bool SteamAPI_Init();
void SteamAPI_Shutdown();
void SteamAPI_RunCallbacks();
}

%include "steam_api_flat.h"

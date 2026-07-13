%module discord
%{
/* Strip DISCORD_API for the C wrapper */
#define DISCORD_API
#include "cdiscord.h"
%}

/* Tell SWIG to treat DISCORD_API as empty */
#define DISCORD_API

/* Map standard C types that SWIG needs to know about */
%include "stdint.i"

/* Process the entire C header */
%include "cdiscord.h"

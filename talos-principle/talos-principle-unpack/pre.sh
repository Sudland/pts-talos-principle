#!/bin/bash

chmod +x talos-principle

echo '#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <dlfcn.h>

#define INI getenv("INI")

int access(const char *filename, int x)
{
	static int (*access_orig)(const char *, int );
	access_orig = dlsym(RTLD_NEXT, "access");
	if (strstr(filename, "/Talos.ini") != NULL){    
		return access_orig(INI, x);
		/* Talos checks if there exist a Talos.ini file, if file doesn'\''t exist,  */
		/* it won'\''t open any config file. */
	}
	else
	{
		return access_orig(filename, x);
	}
}

typedef FILE* (*orig_fopen_func_type)(const char *path, const char *mode);
FILE* fopen(const char *path, const char *mode)
{
	orig_fopen_func_type orig_func;
	orig_func = (orig_fopen_func_type)dlsym(RTLD_NEXT, "fopen");
	if (strstr(path, "/Talos.ini") != NULL){
		return orig_func(INI,"rb");
		/* Stops Talos from having RW on config file. */
		/* User ini file always get rewriten on sigterm */
	}
	else if(strstr(path, "/CheckDriver.lua") != NULL){ 
		/* Disables Popup message for outdated drivers. */
		/* because Mesa is missing extension GL_ARB_get_program_binary on some drivers etc... */
		return orig_func("", "");
}
	else
	{
		return orig_func(path, mode);
	}
}
' > hook.c

if [[ $(uname -m) -eq "x86_64" ]]; then
  gcc hook.c -o hook64.so -fPIC -shared -ldl -O2 -march=native
fi

gcc hook.c -o hook.so -fPIC -shared -ldl -m32 -O2 -march=native

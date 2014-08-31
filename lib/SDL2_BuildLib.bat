@echo off
rem set path=C:\D\dm\bin;C:\D\dmd.2.065.0\windows\bin;c:\D\dub\bin;
set path=C:\D\dm\bin;C:\D\dmd.2.066.0\windows\bin;c:\D\dub\bin;

set lib_objs=functions.obj image.obj mixer.obj sdl.obj ttf.obj types.obj exception.obj loader.obj sharedlib.obj system.obj wintypes.obj xtypes.obj
set sdl2_lib_files=../derelict/sdl2/functions.d ../derelict/sdl2/image.d ../derelict/sdl2/mixer.d ../derelict/sdl2/sdl.d ../derelict/sdl2/ttf.d ../derelict/sdl2/types.d
set util_lib_files=../derelict/util/exception.d ../derelict/util/loader.d ../derelict/util/sharedlib.d ../derelict/util/system.d ../derelict/util/wintypes.d ../derelict/util/xtypes.d

@echo on

del /q *.lib
del /q *.obj

@rem ---- debug_lib ----
dmd -c -g -debug -I.. %sdl2_lib_files%
@if errorlevel 1 goto ERR

dmd -c -g -debug -I.. %util_lib_files%
@if errorlevel 1 goto ERR

lib -c -n -p64 sdl2_debug.lib %lib_objs%
@if errorlevel 1 goto ERR


@rem ---- debug_lib ----
dmd -c -O -inline -release -I.. %sdl2_lib_files%
@if errorlevel 1 goto ERR

dmd -c -O -inline -release -I..  %util_lib_files%
@if errorlevel 1 goto ERR

del sdl2.lib
lib -c -n -p64 sdl2.lib %lib_objs%
@if errorlevel 1 goto ERR
del *.obj


goto END

:ERR
echo XXXXXXXXXXXXX
echo XX  ERROR  XX
echo XXXXXXXXXXXXX

:END
pause


##
TARGET  = WeatherInfo
SRCS	= WeatherInfo.d weather_hacks.d debuglog.d sdl2tk.d
#OBJS	= 
#RES     = resource.res

####
## http://dlang.org/dmd-windows.html
DMD     = dmd
DFLAGS  = -O -inline -boundscheck=off -wi
DEBUG_DFLAGS = -g -wi -version=useDebugLog
DMDLIBS  = lib/sdl2.lib
DEBUG_DMDLIBS  = lib/sdl2_debug.lib
DLDFLAGS = -L/exet:nt/su:windows:4.0
#http://msdn.microsoft.com/ja-jp/library/fcc1zstk.aspx
#DLDFLAGS = -L/SUBSYSTEM:CONSOLE:5.01
#DLDFLAGS = -L/SUBSYSTEM:WINDOWS:5.01

####
## http://www.digitalmars.com/ctg/sc.html
DMC      = dmc
DMCFLAGS = -HP99 -g -o+none -D_WIN32_WINNT=0x0400 -I$(SETUPHDIR) $(CPPFLAGS)
DMCLIB   = lib
DMCLIBFLAGS = lib -p64 -c -n
#DMCLIBFLAGS = lib -p512 -c -n

####
## http://gcc.gnu.org/onlinedocs/gcc/Invoking-GCC.html
CC      = gcc
CXX     = g++
CFLAGS  = -Wall -O2
CLDFLAGS =
CINCLUDES = -I/usr/local/include
CLIBS     = -L/usr/local/lib -lm

####---------------
# $@ : Target name
# $^ : depend Target name
# $< : Target Top Name
# $* : Target name with out suffix name
# $(MACRO:STING1=STRING2) : Replace STRING1 to STRING2
#

all : $(TARGET).exe 

debug : $(TARGET)_debug.exe 

$(TARGET).exe : $(SRCS)
	$(DMD) $(DFLAGS) $(SRCS) $(RES) $(DMDLIBS) $(DLDFLAGS) -of$(TARGET).exe 

$(TARGET)_debug.exe : $(SRCS)
	$(DMD) $(DEBUG_DFLAGS) $(SRCS) $(RES) $(DEBUG_DMDLIBS) $(DLDFLAGS) -of$(TARGET)_debug.exe 

test :
	$(TARGET).exe

clean :
	rm -f $(TARGET).exe $(TARGET)_debug.exe *.obj
#	-rm -f $(TARGET) $(OBJS)

.c.obj :
	$(CC) $(CFLAGS) $(INCLUDES) -c $<

#.d.obj :
#	$(DMD) $(DFLAGS) -c $<
#
# Depend of header file
# obj : header
# foo.obj : foo.h 

/++++
debugLog.d

#License
 Copyright (c) 2014- Seiji Fujita
 Distributed under the Boost Software License, Version 1.0.
++++/

//module debuglog;
module derelict.util.debuglog;

import std.stdio;
import core.vararg;
import std.ascii: isPrintable;
import std.string: format, lastIndexOf;
import std.file: append;
import std.datetime;
//

debug {
	version = useDebugLog;
}

static int LogFlag;
static string debugLogFilename;

/++
enum logStatus {
	NON,
	LogOnly,
	WithConsole
}
++/

void outLog(string file = __FILE__, int line = __LINE__, T...)(T t)
{
 version (useDebugLog) {
    // _outLogV(format("%s(%d)-[%s]", file, line, getDateTimeStr()), t);
    // for hidemaru  
    // _outLogV(format("%s(%d)[%s]", file, line, getDateTimeStr()), t);
    // for emacs
    _outLogV(format("%s:%d:[%s]", file, line, getDateTimeStr()), t);
 }
}

/++
get
	MODULE md = GetModuleHandle(null);
	GetModuleFileName(NULL, szPath, sizeof(szPath));
	
string getFileName()
{
	char[512] Path;
	
	GetModuleFileName(null, Path.ptr, Path.sizeof);
	if (Path.length) {
		return 
	}
}
++/


// setDebugLog();
void setDebugLog(int flag = 1)
{
 version (useDebugLog) {
    enum string ext = "debug_log.txt";
    string logfilename;
    
    import core.runtime: Runtime;
    if (Runtime.args.length)
        logfilename = Runtime.args[0];
    
    debugLogFilename = ext;
    if (logfilename.length) {
        int n = lastIndexOf(logfilename, ".");
        if ( n > 0 )
            debugLogFilename = logfilename[0 .. n]  ~ "." ~ ext;
        else
            debugLogFilename =  logfilename ~ "." ~ ext;
    }
    LogFlag = flag;
    outLog(format("==debuglog %s", debugLogFilename));
 } // useDebugLog
}

static void _outLog(lazy string dg)
{
    if (LogFlag) {
        append(debugLogFilename, dg());
    }
}

static void _outLoglf(lazy string dg)
{
    if (LogFlag) {
        append(debugLogFilename, dg() ~ "\n");
    }
}

static void _outLog2(lazy string dg1, lazy string dg2)
{
    if (LogFlag) {
        string  sout = dg1() ~ format("[%s]", getDateTimeStr()) ~ dg2();
        append(debugLogFilename, sout ~ "\n");
        // writeln(debugLogFilename, sout);
        // stdout.writeln(sout);
    }
}

static void _outLogV(...)
{
    string str;
    for (int i = 0; i < _arguments.length; i++) {
        if (_arguments[i] == typeid(string)) {
            string s = va_arg!(string)(_argptr);
            str ~= format("%s", s);
        }
        else if (_arguments[i] == typeid(int)) {
            int n = va_arg!(int)(_argptr);
            str ~= format("%d", n);
        }
        else if (_arguments[i] == typeid(uint)) {
            uint n = va_arg!(uint)(_argptr);
            str ~= format("%d", n);
        }
        else if (_arguments[i] == typeid(short)) {
            short n = va_arg!(short)(_argptr);
            str ~= format("%d", n);
        }
        else if (_arguments[i] == typeid(ushort)) {
            ushort n = va_arg!(ushort)(_argptr);
            str ~= format("%d", n);
        }
        else if (_arguments[i] == typeid(long)) {
            long n = va_arg!(long)(_argptr);
            str ~= format("%d", n);
        }
        else if (_arguments[i] == typeid(ulong)) {
            ulong n = va_arg!(ulong)(_argptr);
            str ~= format("%d", n);
        }
        else if (_arguments[i] == typeid(char)) {
            char c = va_arg!(char)(_argptr);
            str ~= format("%c", c);
        }
        else if (_arguments[i] == typeid(wchar)) {
            wchar c = va_arg!(wchar)(_argptr);
            str ~= format("%c", c);
        }
        else if (_arguments[i] == typeid(dchar)) {
            dchar c = va_arg!(dchar)(_argptr);
            str ~= format("%c", c);
        }
        else if (_arguments[i] == typeid(byte)) {
            byte n = va_arg!(byte)(_argptr);
            str ~= format("%d", n);
        }
        else if (_arguments[i] == typeid(ubyte)) {
            ubyte n = va_arg!(ubyte)(_argptr);
            str ~= format("%d", n);
        }
        else if (_arguments[i] == typeid(float)) {
            float f = va_arg!(float)(_argptr);
            str ~= format("%f", f);
        }
        else if (_arguments[i] == typeid(double)) {
            double d = va_arg!(double)(_argptr);
            str ~= format("%g", d);
        }
        else if (_arguments[i] == typeid(wstring)) {
            wstring s = va_arg!(wstring)(_argptr);
            str ~= format("%s", s);
        }
        else if (_arguments[i] == typeid(dstring)) {
            dstring s = va_arg!(dstring)(_argptr);
            str ~= format("%s", s);
        }
        else if (_arguments[i] == typeid(real)) {
            real r = va_arg!(real)(_argptr);
            str ~= format("%g", r);
        }
        else if (_arguments[i] == typeid(ifloat)) {
            ifloat r = va_arg!(ifloat)(_argptr);
            str ~= format("%g", r);
        }
        else if (_arguments[i] == typeid(idouble)) {
            idouble r = va_arg!(idouble)(_argptr);
            str ~= format("%g", r);
        }
        else if (_arguments[i] == typeid(ireal)) {
            ireal r = va_arg!(ireal)(_argptr);
            str ~= format("%g", r);
        }
        else if (_arguments[i] == typeid(cfloat)) {
            cfloat r = va_arg!(cfloat)(_argptr);
            str ~= format("%g", r);
        }
        else if (_arguments[i] == typeid(cdouble)) {
            cdouble r = va_arg!(cdouble)(_argptr);
            str ~= format("%g", r);
        }
        else if (_arguments[i] == typeid(creal)) {
            creal r = va_arg!(creal)(_argptr);
            str ~= format("%g", r);
        }
/++     else if (_arguments[i] == typeid(cent)) {
            creal r = va_arg!(creal)(_argptr);
            str ~= format("%d", r);
        }
        else if (_arguments[i] == typeid(ucent)) {
            creal r = va_arg!(creal)(_argptr);
            str ~= format("%d", r);
        }
++/
        else {
            assert(0, format("Unknown type: add your type %s:%d", __FILE__, __LINE__));
        }
    }
    _outLoglf(str);
}

static string getDateTimeStr()
{
    SysTime cTime = Clock.currTime();
    string  tms = format(
        "%04d/%02d/%02d-%02d:%02d:%02d", 
        cTime.year, 
        cTime.month, 
        cTime.day, 
        cTime.hour, 
        cTime.minute, 
        cTime.second); 
    return tms;
}

static string getDateStr()
{
    SysTime cTime = Clock.currTime();
    string  tms = format(
        "%04d/%02d/%02d", 
        cTime.year, 
        cTime.month, 
        cTime.day); 
    return tms;
}
/++
 outdumpLog(void *, uint, string);
 outdumpLog(cast(void*)foo, foo.length, "string");
++/
void outdumpLog(string file = __FILE__, int line = __LINE__, T1, T2, T3)
(T1 t1, T2 t2, T3 t3)
if (is(T1 == void*) && is(T2 == uint) && is(T3 == string))
{
 version (useDebugLog) {
    _outLoglf(format("%s:%d:[%s] %s, %d byte", file, line, getDateTimeStr(), t3, t2));
    _dumpLog(t1, t2);
 }
}

/++
 outdumpLog2(anytype, ...);
 outdumpLog(cast(void*)foo, foo.length, "string");

void outdumpLog2(string file = __FILE__, int line = __LINE__, T...) (T t)
{
    format("%s:%d:[%s] ", file, line, getDateTimeStr())._outLoglf();
	foreach (i, v; t) {
		if (i == 1) {
			void* ptr = cast(void*)v;
			uint size;
			if (typeid(x) == "string")
				size = v.length * char.sizeof;
			
		    _dumpLog(ptr, size);
			
		}
		else {
			_outLogV(v);
		}
	}

	
}
++/

//
static void _dumpLog(void *Buff, uint byteSize)
{
    const int PrintLen = 16;
    ubyte[PrintLen] dumpBuff;
    
    void printCount(uint n) {
        _outLog(format("%06d: ", n));
    }
    void printBody() {
        string s;
        foreach (int i, ubyte v; dumpBuff) {
            if (i == PrintLen / 2) {
                s ~= " ";
            }
            s ~= format("%02X ", v);
        }
        _outLog(s);
    }
    void printAscii() {
        string s;
        char c;
        foreach (ubyte v; dumpBuff) {
            c = cast(char)v;
            if (! isPrintable(c))
                c = '.';
            s ~= format("%c", c);
        }
        _outLoglf(s);
    }
    // Main
    uint endPrint;
    for (uint i; i < byteSize + PrintLen; i += PrintLen) {
        endPrint = i + PrintLen;
        if (byteSize < endPrint) {
            uint end = byteSize - i;
            dumpBuff = dumpBuff.init;
            dumpBuff[0 .. end] = cast(ubyte[]) Buff[i .. byteSize];
            printCount(i);
            printBody();
            printAscii();
            break;
        }
        dumpBuff = cast(ubyte[]) Buff[i .. endPrint];
        printCount(i);
        printBody();
        printAscii();
    }
}
//eof

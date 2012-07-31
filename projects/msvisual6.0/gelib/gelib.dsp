# Microsoft Developer Studio Project File - Name="gelib" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Static Library" 0x0104

CFG=gelib - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "gelib.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "gelib.mak" CFG="gelib - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "gelib - Win32 Release" (based on "Win32 (x86) Static Library")
!MESSAGE "gelib - Win32 Debug" (based on "Win32 (x86) Static Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "gelib - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_MBCS" /D "_LIB" /YX /FD /c
# ADD CPP /nologo /Gz /Zp1 /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_MBCS" /D "_LIB" /D "_ASM" /YX /FD /c
# ADD BASE RSC /l 0x419 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo

!ELSEIF  "$(CFG)" == "gelib - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_MBCS" /D "_LIB" /YX /FD /GZ /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_MBCS" /D "_LIB" /YX /FD /GZ /c
# ADD BASE RSC /l 0x419 /d "_DEBUG"
# ADD RSC /l 0x419 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo

!ENDIF 

# Begin Target

# Name "gelib - Win32 Release"
# Name "gelib - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Group "Bytecode"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\..\src\bytecode\cmdlist.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\bytecode\funclist.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\bytecode\geasm.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\bytecode\geload.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\bytecode\geoptimize.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\bytecode\gesave.c
# End Source File
# End Group
# Begin Group "Common"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\..\src\common\arr.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\arrdata.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\buf.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\collection.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\crc.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\file.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\hash.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\memory.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\mix.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\msg.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\msglist.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\number.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\str.c
# End Source File
# End Group
# Begin Group "Compiler"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\..\src\compiler\alias.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\bcodes.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\body.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\compile.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\compinit.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\define.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\desc.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\expr.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\extern.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\for.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\foreach.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\func.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\global.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\goto.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\if.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\ifdef.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\import.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\include.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\jump.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\lexem.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\macro.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\macroexp.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\operlist.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\out.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\subfunc.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\switch.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\type.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\vars.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\while.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\with.c
# End Source File
# End Group
# Begin Group "genteeapi"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\..\src\genteeapi\gentee.c
# End Source File
# End Group
# Begin Group "lex"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\..\src\lex\lex.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\lex\lexgentee.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\lex\lextbl.c
# End Source File
# End Group
# Begin Group "os"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\..\src\os\user\defines.c
# End Source File
# End Group
# Begin Group "vm"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\..\src\vm\vm.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\vm\vmload.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\vm\vmmanage.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\vm\vmres.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\vm\vmrun.c

!IF  "$(CFG)" == "gelib - Win32 Release"

# ADD CPP /Zp1

!ELSEIF  "$(CFG)" == "gelib - Win32 Debug"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\..\..\src\vm\vmtype.c
# End Source File
# End Group
# Begin Group "Algorithm"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\..\src\Algorithm\qsort.c
# End Source File
# Begin Source File

SOURCE=..\..\..\src\Algorithm\search.c
# End Source File
# End Group
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=..\..\..\src\compiler\alias.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\arr.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\arrdata.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\bcodes.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\buf.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\bytecode\bytecode.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\bytecode\cmdlist.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\collection.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\compile.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\compinit.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\crc.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\define.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\os\user\defines.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\file.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\func.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\bytecode\funclist.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\bytecode\ge.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\genteeapi\gentee.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\global.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\hash.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\ifdef.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\import.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\include.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\lex\lex.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\lexem.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\lex\lexgentee.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\lex\lextbl.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\macro.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\macroexp.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\memory.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\mix.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\msg.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\msglist.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\number.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\operlist.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\out.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\Algorithm\qsort.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\Algorithm\search.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\str.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\compiler\type.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\common\types.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\vm\vm.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\vm\vmload.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\vm\vmmanage.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\vm\vmres.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\vm\vmrun.h
# End Source File
# Begin Source File

SOURCE=..\..\..\src\vm\vmtype.h
# End Source File
# End Group
# End Target
# End Project

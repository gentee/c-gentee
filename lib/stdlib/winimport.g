/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

define <export>{
   GENERIC_READ  = 0x80000000
   GENERIC_WRITE = 0x40000000
   
   FILE_SHARE_READ  = 0x00000001  
   FILE_SHARE_WRITE = 0x00000002    
   FILE_SHARE_RW    =  $FILE_SHARE_READ | $FILE_SHARE_WRITE
     
   GENERIC_READ  = 0x80000000
   GENERIC_WRITE = 0x40000000
   GENERIC_RW    = $GENERIC_READ | $GENERIC_WRITE
   
   CREATE_ALWAYS = 2
   OPEN_EXISTING = 3
   OPEN_ALWAYS   = 4
   //FILE_FLAG_WRITE_THROUGH = 0x80000000
   INVALID_HANDLE_VALUE = 0xFFFFFFFF
   
/*-----------------------------------------------------------------------------
* Id: drivetypes D
* 
* Summary: Values of drive types.
*
-----------------------------------------------------------------------------*/
   DRIVE_UNKNOWN     = 0      // Unknown type.
   DRIVE_NO_ROOT_DIR = 1      // Invalid path to root.
   DRIVE_REMOVABLE   = 2      // Removable disk.
   DRIVE_FIXED       = 3      // Fixed disk.
   DRIVE_REMOTE      = 4      // Network disk.
   DRIVE_CDROM       = 5      // CD/DVD-ROM drive.
   DRIVE_RAMDISK     = 6      // RAM disk.
   
/*-----------------------------------------------------------------------------
* Id: fileattribs D
* 
* Summary: File attributes.
*
-----------------------------------------------------------------------------*/
   FILE_ATTRIBUTE_READONLY = 0x00000001   // Read-only.  
   FILE_ATTRIBUTE_HIDDEN   = 0x00000002   // Hidden.
   FILE_ATTRIBUTE_SYSTEM   = 0x00000004   // System.
   FILE_ATTRIBUTE_DIRECTORY = 0x00000010  // Directory.
   FILE_ATTRIBUTE_ARCHIVE  = 0x00000020   // Archive.
   FILE_ATTRIBUTE_NORMAL   = 0x00000080   // Normal.
   FILE_ATTRIBUTE_TEMPORARY = 0x00000100  // Temporary.
   FILE_ATTRIBUTE_COMPRESSED = 0x00000800 // Compressed.

/*-----------------------------------------------------------------------------
* Id: filesetmode D
* 
* Summary: Set mode for file.setpos method.
*
-----------------------------------------------------------------------------*/
   FILE_BEGIN   = 0   // From the beginning of the file.
   FILE_CURRENT = 1   // From the current position.
   FILE_END     = 2   // From the end of the file.

//-----------------------------------------------------------------------------
   
   MAX_PATH = 260
}

define <export> { 

// Флаги для CreateProcess   
   CREATE_DEFAULT_ERROR_MODE = 0x04000000
   CREATE_NO_WINDOW = 0x08000000
   NORMAL_PRIORITY_CLASS = 0x00000020
   
// Значение для WaitForSingleObject    
   INFINITE = 0xFFFFFFFF
   
/* TRUE = 1
   FALSE = 0*/
}

/*-----------------------------------------------------------------------------
* Id: tdatetime T datetime
* 
* Summary: The datetime structure. An object of the datetime type is used to
           work with time. This type can contain information about date 
           and time.
*
-----------------------------------------------------------------------------*/
    
type datetime { 
    ushort year         // Year.
    ushort month        // Month. 
    ushort dayofweek    // Weekday. Counted from 0. 0 is Sunday, 1 is Monday... 
    ushort day          // Day.
    ushort hour         // Hours.
    ushort minute       // Minutes.
    ushort second       // Seconds.
    ushort msec         // Milliseconds.
}

/*-----------------------------------------------------------------------------
* Id: tfiletime T filetime
* 
* Summary: The filetime structure. The filetime type is used to work with time
           of files. 
*
-----------------------------------------------------------------------------*/
    
type filetime { 
    uint lowdtime       // Low uint value.
    uint highdtime      // High uint value.
}

//-----------------------------------------------------------------------------
    
type WIN32_FIND_DATA {
   uint     dwFileAttributes
   filetime ftCreationTime
   filetime ftLastAccessTime
   filetime ftLastWriteTime
   uint     nFileSizeHigh
   uint     nFileSizeLow 
   uint     dwReserved0 
   uint     dwReserved1
   reserved cFileName[ $MAX_PATH ] 
   reserved cAlternateFileName[ 14 ] 
} 

type PROCESS_INFORMATION { 
    uint   hProcess
    uint   hThread 
    uint   dwProcessId
    uint   dwThreadId 
} 

type STARTUPINFO { 
    uint    cb 
    uint    lpReserved
    uint    lpDesktop 
    uint    lpTitle
    uint    dwX
    uint    dwY 
    uint    dwXSize
    uint    dwYSize 
    uint    dwXCountChars
    uint    dwYCountChars 
    uint    dwFillAttribute
    uint    dwFlags
    ushort  wShowWindow
    ushort  cbReserved2 
    uint    lpReserved2 
    uint    hStdInput
    uint    hStdOutput
    uint    hStdError 
} 

import "kernel32.dll" {
   uint CloseHandle( uint )
   int  CompareFileTime( filetime, filetime )
   uint CompareStringW( uint, uint, uint, int, uint, int )
   uint CopyFileA( uint, uint, uint ) -> CopyFile
   uint CreateDirectoryA( uint, uint ) -> CreateDirectory
   uint CreateFileA( uint, uint, uint, uint, uint, uint, uint ) -> CreateFile
   uint CreateProcessA( uint, uint, uint, uint, uint, uint, uint, 
                        uint, STARTUPINFO, PROCESS_INFORMATION ) -> CreateProcess
   uint DeleteFileA( uint ) -> DeleteFile
        ExitProcess( uint )
   uint FileTimeToLocalFileTime( filetime, filetime )
   uint FileTimeToSystemTime( filetime, datetime )
   uint FindClose( uint )
   uint FindFirstFileA( uint, WIN32_FIND_DATA ) -> FindFirstFile
   uint FindNextFileA( uint, WIN32_FIND_DATA ) -> FindNextFile
   uint FreeLibrary( uint )
   uint GetCurrentDirectoryA( uint, uint ) -> GetCurrentDirectory
   uint GetDateFormatA( uint, uint, datetime, uint, uint, int ) -> GetDateFormat
   uint GetDriveTypeA( uint ) -> GetDriveType
   uint GetExitCodeProcess( uint, uint )
   uint GetFileAttributesA( uint ) -> GetFileAttributes
   uint GetFileSize( uint, uint )
   uint GetFileTime( uint, filetime, filetime, filetime )
   uint GetFullPathNameA( uint, uint, uint, uint ) -> GetFullPathName
   uint GetLastError()
   uint GetLogicalDriveStringsA( uint, uint ) -> GetLogicalDriveStrings
   uint GetLocaleInfoA( uint, uint, uint, int ) -> GetLocaleInfo
        GetLocalTime( datetime )
   uint GetModuleHandleA( uint ) -> GetModuleHandle
   uint GetModuleFileNameA( uint, uint, uint ) -> GetModuleFileName
   uint GetPrivateProfileStringA( uint, uint, uint, uint, uint, uint ) ->
                                  GetPrivateProfileString
   uint GetProcAddress( uint, uint )
        GetSystemTime( datetime )
   uint GetTimeFormatA( uint, uint, datetime, uint, uint, int ) -> GetTimeFormat
   uint IsDBCSLeadByte( byte )
   
   uint LoadLibraryA( uint ) -> LoadLibrary
   uint LocalFileTimeToFileTime( filetime, filetime )
   uint MoveFileA( uint, uint ) -> MoveFile
   uint MoveFileExA( uint, uint, uint ) -> MoveFileEx
   int  MulDiv( int, int, int )
   int  MultiByteToWideChar( uint, uint, uint, int, uint, int )
   uint ReadFile( uint, uint, uint, uint, uint )
   uint RemoveDirectoryA( uint ) -> RemoveDirectory
   uint SetCurrentDirectoryA( uint ) -> SetCurrentDirectory
   uint SetFileAttributesA( uint, uint ) -> SetFileAttributes
   uint SetFilePointer( uint, uint, uint, uint )
   uint SetFileTime( uint, filetime, filetime, filetime )   
   uint SystemTimeToFileTime( datetime, filetime )
   uint WaitForSingleObject( uint, uint )
   int  WideCharToMultiByte( uint, uint, uint, int, uint, int, uint, uint ) 
   uint WriteFile( uint, uint, uint, uint, uint )
   uint WritePrivateProfileStringA( uint, uint, uint, uint ) ->
                                    WritePrivateProfileString
}

define <export> {
// Значения при открытии окон
   SW_HIDE = 0
   SW_SHOWNORMAL = 1
   SW_NORMAL = 1
   SW_SHOWMINIMIZED = 2
   SW_SHOWMAXIMIZED = 3
   SW_MAXIMIZE = 3
   SW_SHOWNOACTIVATE = 4
   SW_SHOW = 5
   SW_MINIMIZE = 6
   SW_SHOWMINNOACTIVE = 7
   SW_SHOWNA = 8
   SW_RESTORE = 9
   SW_SHOWDEFAULT = 10
}

define 
{
   LANG_NEUTRAL   = 0x00
   LANG_ENGLISH   = 0x09
   LANG_FRENCH    = 0x0c
   LANG_GERMAN    = 0x07

   SUBLANG_NEUTRAL = 0x00
   SUBLANG_DEFAULT = 0x01
   SUBLANG_SYS_DEFAULT = 0x02
   SUBLANG_ENGLISH_US  = 0x01
   SUBLANG_FRENCH      = 0x01
   SUBLANG_GERMAN      = 0x01
   SORT_DEFAULT        = 0x0

   LOCALE_SMONTHNAME1 = 0x00000038
   LOCALE_SABBREVDAYNAME1 = 0x00000031   // abbreviated name for Monday
   LOCALE_IFIRSTDAYOFWEEK = 0x0000100C   // first day of week
}

type SHELLEXECUTEINFO 
{
    uint cbSize
    uint fMask
    uint hwnd
    uint lpVerb
    uint lpFile
    uint lpParameters
    uint lpDirectory
    int  nShow
    uint hInstApp
    uint lpIDList
    uint lpClass
    uint hkeyClass
    uint dwHotKey
    uint hIcon
    uint hProcess
}

import "shell32.dll" {
	uint ShellExecuteA( uint, uint, uint, uint, uint, uint ) -> ShellExecute
   uint ShellExecuteExA( SHELLEXECUTEINFO ) -> ShellExecuteEx
}

import "user32.dll" {
   uint CharLowerBuffA( uint, uint ) -> CharLowerBuff
   uint CharUpperBuffA( uint, uint ) -> CharUpperBuff      
}

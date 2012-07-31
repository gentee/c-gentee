/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: defines 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
* Summary: This file provides Windows basic types and some constants.
*
******************************************************************************/

#ifndef _DEFINES_
#define _DEFINES_

   #ifdef __cplusplus
      extern "C" {
   #endif // __cplusplus

#include <stdio.h>
#include <stdarg.h>
#ifdef LINUX
   #include <time.h>
   #include <stdlib.h>
   #include "ini.h"
   #include <locale.h>
#else
 #include <windows.h>
 #include <conio.h>
#endif
#include "../../common/str.h"

//--------------------------------------------------------------------------
#ifdef LINUX
 #define SLASH '/'      // Filename divider
#else
 #define SLASH '\\'      // Filename divider
 #define OS_CRL        CRITICAL_SECTION  // type
#endif

#define os_alloc      malloc
#define os_free       free
//#define os_lower      CharLower
#define os_crlsection_delete DeleteCriticalSection
#define os_crlsection_enter  EnterCriticalSection
#define os_crlsection_init   InitializeCriticalSection
#define os_crlsection_leave  LeaveCriticalSection
//#define os_exitthread        pthread_exit
#define os_isleadbyte        IsDBCSLeadByte
#define os_wait              WaitForSingleObject
#define os_exitcode          GetExitCodeThread

//#define os_time              GetTickCount

uint     STDCALL os_dircreate( pstr name );
uint     STDCALL os_getattrib( pstr name );
uint     STDCALL os_dirdelete( pstr name );
pstr     STDCALL os_dirgetcur( pstr name );
uint     STDCALL os_dirsetcur( pstr name );
uint     STDCALL os_dirdeletefull( pstr name );


uint     STDCALL os_fileclose( uint handle );
uint     STDCALL os_filedelete( pstr name );
uint     STDCALL os_fileexist( pstr name );
//pstr     STDCALL os_filefullname( pstr filename, pstr result );
pvoid  STDCALL os_filefullname( pubyte filename, pvoid buf );

uint     STDCALL os_fileopen( pstr name, uint flag );
ulong64  STDCALL os_filepos( uint handle, long64 offset, uint mode );
uint     STDCALL os_fileread( uint handle, pubyte data, uint size );
ulong64  STDCALL os_filesize( uint handle );
uint     STDCALL os_filewrite( uint handle, pubyte data, uint size );

uint     STDCALL os_multibytes( void );
void     STDCALL os_init( uint param );
void     STDCALL os_print( pubyte ptr, uint len );
uint     STDCALL os_getchar( void );
uint     STDCALL os_scan( pubyte input, uint len );
int      STDCALL os_strcmp( pubyte one, pubyte two );
int      STDCALL os_strcmpign( pubyte one, pubyte two );
int      STDCALL os_strcmplen( pubyte one, pubyte two, uint len );
int      STDCALL os_strcmpignlen( pubyte one, pubyte two, uint len );
int      STDCALL os_ustrcmp( pushort one, pushort two );
int      STDCALL os_ustrcmpign( pushort one, pushort two );
int      STDCALL os_ustrcmplen( pushort one, pushort two, uint len );
int      STDCALL os_ustrcmpignlen( pushort one, pushort two, uint len );
pstr     STDCALL os_tempdir( pstr name );
pstr     STDCALL os_gettemp( void );
pvoid STDCALL os_thread(pvoid pfunc,pvoid param);

void STDCALL os_exitthread(long retcode);
pubyte STDCALL os_lower(pubyte pData);
uint STDCALL os_time();
pubyte STDCALL strlower1(pubyte string1);
pubyte   STDCALL os_getexepath( pubyte dir, pubyte name );
pubyte  STDCALL os_getexename( pubyte dir);


//pvoid STDCALL os_alloc( uint size );
//void STDCALL os_free( pvoid ptr );

//--------------------------------------------------------------------------

   #ifdef __cplusplus
      }
   #endif // __cplusplus

#endif // _DEFINES_

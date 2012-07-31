/******************************************************************************
*
* Copyright (C) 2006-09, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov
*
******************************************************************************/

#include "windows.h"
#include "../../common/types.h"
#include "../../genteeapi/gentee.h"
//#elif defined(LAUNCHERD)
//#include "../../genteeapi/gentee.h"
#ifdef MINILAUNCHER 
   #include "../gea/LZGE/lzge.h"
   #include "../gea/memory.h"
#endif

#define GE_STRING  0x00004547   // String GE

typedef struct
{
   uint   sign1;         // 'Gentee Launcher' sign
   uint   sign2;         // 
   uint   sign3;         // 
   uint   sign4;         // 
   uint   exesize;       // Размер exe-файла.
                          // Если не 0, то файл является SFX 
                          // архивом и далее идут прикрепленныe данные
   uint   minsize;       // Если не 0, то выдавать ошибку если размер файла
                          // меньше указанного
   ubyte  console;       // 1 если консольное приложение
   ubyte  exeext;        // Количество дополнительных блоков
   ubyte  pack;          // 1 если байт код и dll упакованы
   ushort flags;         // flags
   uint   dllsize;       // Упакованный размер Dll файла. 
                         // Если 0, то динамическое подключение gentee.dll
   uint   gesize;        // Упакованный размер байт-кода.
   uint   mutex;         // ID для mutex, если не 0, то будет проверка
   uint   param;         // Зашитый параметр
   uint   offset;        // Смещение данной структуры
   uint   extsize[ 16 ]; // Зарезервированно для размеров 8 ext блоков
                         // Каждый размер занимает long
} lahead, * plahead;

#if defined __WATCOMC__
   #ifdef LAUNCHER
      const uint   gentee_offset = 0x17000;  // Смещение gentee секции
   #elif defined(LAUNCHERD)
      const uint   gentee_offset = 0x5000;  // Смещение gentee секции
   #endif
#elif defined __GNUC__
   #ifdef LAUNCHER
      const uint   gentee_offset = 0x12000;  // Смещение gentee секции
   #elif defined(LAUNCHERD)
      const uint   gentee_offset = 0x6000;  // Смещение gentee секции
   #endif
#else
   #ifdef LAUNCHER
      #ifdef _ASM 
         const uint   gentee_offset = 0xF000;  // Смещение gentee секции
      #else
         const uint   gentee_offset = 0xE000;  // Смещение gentee секции
      #endif
   #elif defined(LAUNCHERD)
      const uint   gentee_offset = 0x4000;  // Смещение gentee секции
   #elif defined(MINILAUNCHER)
      const uint   gentee_offset = 0x4000;  // Mini Launcher
   #endif
#endif

const lahead head = {
   0x746E6547,
   0x4C206565,
   0x636E7561,
   0x00726568,
   0x0,              // exesize
   0,                // minsize
   0,                // console
   0,                // exeext
   0, 0,             // pack
   0, 0,             // Размеры dll и байт-кода
   0,                // mutex
   0, 0,             // param offset
};

#ifdef MINILAUNCHER

gea_call  lge_call;

//--------------------------------------------------------------------------

uint STDCALL fgeauser( uint param, uint userfunc, uint pgeaparam )
{
   uint  result;

   if ( userfunc )
   {
      *( puint )pgeaparam = param;
      lge_call( userfunc, &result, 200, pgeaparam );
   }
   return 1;
}

uint  STDCALL  unpackdll( pubyte input, pubyte out, pubyte temp, pubyte dllname )
{
   uint     rw, diskc = 0;
   HANDLE   handle;
   slzge    lzge;

   if ( head.dllsize )
   {
      mem_zero( &lzge, sizeof( slzge ));
      // Looking for the temporary directory
      GetTempPath( 512, temp );
      if ( temp[ lstrlen( temp ) - 1 ] == '\\' )
         temp[ lstrlen( temp ) - 1 ] = 0;

again:
      wsprintf( dllname, "%s\\genteert.dll", temp );
      if ( GetFileAttributes( dllname ) == 0xFFFFFFFF )
      {
         handle = CreateFile( dllname, GENERIC_READ | GENERIC_WRITE, 
                                    0, NULL, CREATE_ALWAYS, 0, NULL ); 
         if ( handle == INVALID_HANDLE_VALUE )
         {
            if ( !diskc )
            {
               lstrcpy( temp, "c:\\temp" );
               CreateDirectory( temp, NULL );
               diskc = 1;
               goto again;
            }
            else
               goto error;
         }
         lzge_decode( input + 4, out, *( puint )input, &lzge );

         if ( !WriteFile( handle, out, *( puint )input, &rw, NULL ) ||
               rw != *( puint )input )
               goto error;

         CloseHandle( handle );
      }
   }
   if ( head.pack )
   {
      // Unpacking the byte-code
      input += head.dllsize;
      mem_zero( &lzge, sizeof( slzge ));
      lzge_decode( input + 4, out, *( puint )input, &lzge );
   }
   else
      mem_copy( out, input, head.gesize );

   return 1;
error:
   lstrcpy( temp, "Cannot create gentee.dll!" );
   return 0;
}

//--------------------------------------------------------------------------
#define  LAGET_HEAD      0
#define  LAGET_ALLOC     1   
#define  LAGET_FREE      2
#define  LAGET_ZERO      3   
#define  LAGET_COPY      4
#define  LAGET_GEAUSER   5   

pvoid STDCALL launcher_get( uint id )
{
   switch ( id )
   {
      case LAGET_HEAD : return ( pvoid )( &head );
      case LAGET_ALLOC : return &mem_alloc;
      case LAGET_FREE : return &mem_free;
      case LAGET_ZERO : return &mem_zero;
      case LAGET_COPY : return &mem_copy;
      case LAGET_GEAUSER : return &fgeauser;
   }
   return 0;
}

//--------------------------------------------------------------------------

PVOID CALLBACK export2gentee( PCHAR str )
{
   if ( !lstrcmp( str, "lzge_decode" ) )
      return &lzge_decode;
   if ( !lstrcmp( str, "launcher_get" ) )
      return &launcher_get;
   return NULL;
}
#endif

//--------------------------------------------------------------------------
#if LAUNCHERD 
   int WINAPI WinMainCRTStartup(void)
#elif LAUNCHER || MINILAUNCHER
   int WINAPI WinMain(  HINSTANCE hInstance, HINSTANCE hPrevInstance,
                        LPSTR lpCmdLine,  int nCmdShow )
#endif
{
#ifdef MINILAUNCHER
   pvoid    hdll;
   FARPROC  gentee_init;
   FARPROC  gentee_deinit;
   FARPROC  gentee_load;
   FARPROC  gentee_set;
   byte     dllname[ 512 ];
#endif

   uint     result = 0;
   HANDLE   hMutex;
   pvoid    handle;
   ubyte    exename[ 512 ];
   ubyte    temp[ 512 ];
   ubyte    tmpname[ 512 ];
   pubyte   gesection, out;

   GetModuleFileName( NULL, exename, 512 );
   
   // Prohibit to run the second application copy if there is 'mutex' field
   if ( head.mutex )
   {
      wsprintf( temp, "%X", head.mutex );
      hMutex = CreateMutex( NULL, TRUE, temp );
      if ( GetLastError() == ERROR_ALREADY_EXISTS )
      {
         lstrcpy( temp, __TEXT("The application has already run."));
         goto error;
      }
   }
   // Checking up the minimum size of EXE file 
   if ( head.minsize )
   {
      handle = CreateFile( exename, GENERIC_READ, FILE_SHARE_READ | 
                           FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 0, NULL ); 
      if ( head.minsize > GetFileSize( handle, NULL ))
      {
         lstrcpy( temp, __TEXT("The file is corrupted. It was downloaded with errors or otherwise \
damaged.\nPlease download it again and make sure that you do not have viruses."));
         goto error;
      }
      CloseHandle( handle );
   }
   gesection = ( pubyte )GetModuleHandle( NULL ) + gentee_offset;

#if MINILAUNCHER
   out = mem_alloc( max( *( puint )gesection, *(puint)( gesection + head.dllsize )
                         ) + 1024 );
   if ( !unpackdll( ( pubyte )gesection, out, temp, dllname ))
      goto error;
   // Loading gentee.dll
   hdll = LoadLibrary( dllname );

   if ( !hdll )
   {
      wsprintf( temp, __TEXT("Cannot load %s."), dllname );
      goto error;
   }
   gentee_init = ( FARPROC )GetProcAddress( hdll, "gentee_init" );
   gentee_deinit = ( FARPROC )GetProcAddress( hdll, "gentee_deinit" );
   gentee_load = ( FARPROC )GetProcAddress( hdll, "gentee_load" );
   gentee_set = ( FARPROC )GetProcAddress( hdll, "gentee_set" );
   lge_call = ( gea_call )GetProcAddress( hdll, "gentee_call" );
#else
   out = ( pubyte )gesection;
#endif

   #ifdef _ASMRT
      gentee_init( G_SILENT | head.console | G_ASM | head.flags );
   #else
      gentee_init( G_SILENT | head.console | head.flags );
   #endif

#if MINILAUNCHER
   gentee_set( GSET_EXPORT, &export2gentee );
#endif

   if ( *( puint )out != GE_STRING )
   {
      lstrcpy( temp, "The executable file does not have a bytecode!" );
      goto error;
   }
   result = gentee_load( out, GLOAD_RUN | GLOAD_ARGS );

#if MINILAUNCHER
   mem_free( out );
#endif
   gentee_deinit();
#if MINILAUNCHER
   // I don't understand why gentee.dll is free just after 
   // the second FreeLibrary
   FreeLibrary( hdll );
   FreeLibrary( hdll );
   DeleteFile( dllname );
#endif

   ExitProcess( result );
error:
   lstrcat( lstrcpy( tmpname, "ERROR: " ), exename );
   MessageBox( NULL, temp, tmpname, MB_OK | MB_ICONHAND );
   ExitProcess( 0 );
   return 0;
}
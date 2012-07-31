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

#include "defines.h"
#include "../../genteeapi/gentee.h"

pvoid  _stdout = INVALID_HANDLE_VALUE;
pvoid  _stdin = INVALID_HANDLE_VALUE;

/*-----------------------------------------------------------------------------
*
* ID: os_dircreate 23.10.06 0.0.A.
* 
* Summary: Create the directory
*
-----------------------------------------------------------------------------*/

uint     STDCALL os_dircreate( pstr name )
{
   return CreateDirectory( str_ptr( name ), NULL );
}

/*-----------------------------------------------------------------------------
*
* ID: os_dirdelete 23.10.06 0.0.A.
* 
* Summary: Delete the empty directory
*
-----------------------------------------------------------------------------*/

uint     STDCALL os_dirdelete( pstr name )
{
   return RemoveDirectory( str_ptr( name ));
}

/*-----------------------------------------------------------------------------
*
* ID: os_dirgetcur 23.10.06 0.0.A.
* 
* Summary: Get the current directory
*
-----------------------------------------------------------------------------*/

pstr   STDCALL os_dirgetcur( pstr name ) 
{
   return str_setlen( name, GetCurrentDirectory( 512, 
                      str_ptr( str_reserve( name, 512 ))));
}

/*-----------------------------------------------------------------------------
*
* ID: os_dirsetcur 23.10.06 0.0.A.
* 
* Summary: Set the current directory
*
-----------------------------------------------------------------------------*/

uint  STDCALL os_dirsetcur( pstr name ) 
{
   return SetCurrentDirectory( str_ptr( name ));
}

/*-----------------------------------------------------------------------------
*
* ID: os_dirdeletefull 23.10.06 0.0.A.
* 
* Summary: Delete the directory with subfolders and files
*
-----------------------------------------------------------------------------*/

uint     STDCALL os_dirdeletefull( pstr name )
{
   str  stemp;
   WIN32_FIND_DATA  data;
   pvoid            find;

   str_init( &stemp );
   str_reserve( &stemp, 512 );
   str_printf( &stemp, "%s%c*.*", str_ptr( name ), SLASH );
   find = FindFirstFile( str_ptr( &stemp ), &data );
   if ( find != INVALID_HANDLE_VALUE )
   {
      do { 
         if ( data.cFileName[0] == '.' && ( !data.cFileName[1] ||
            ( data.cFileName[1] == '.' && !data.cFileName[2] )))
            continue;
         str_clear( &stemp );        
         str_printf( &stemp, "%s%c%s", str_ptr( name ), SLASH, data.cFileName );

         if ( data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY )
            os_dirdeletefull( &stemp );
         else
            os_filedelete( &stemp );
//         print( "%s\n", str_ptr( &stemp ));
      } while ( FindNextFile( find, &data ));

      FindClose( find );
   }
//   _getch();
   str_delete( &stemp );
   return os_dirdelete( name );
}

/*-----------------------------------------------------------------------------
*
* ID: os_fileclose 23.10.06 0.0.A.
* 
* Summary: Close the file
*
-----------------------------------------------------------------------------*/

uint     STDCALL os_fileclose( uint handle )
{
   return CloseHandle(( pvoid )handle );
}

/*-----------------------------------------------------------------------------
*
* ID: os_filefullname 23.10.06 0.0.A.
* 
* Summary: Get the full name of the file
*
-----------------------------------------------------------------------------*/

pstr  STDCALL os_filefullname( pstr filename, pstr result )
{
   uint   len;
   pubyte ptr;

   str_reserve( result, 512 );
   len = GetFullPathName( str_ptr( filename ), 512, str_ptr( result ), &ptr );
   str_setlen( result, len );
   return result;
}

/*-----------------------------------------------------------------------------
*
* ID: os_filedelete 23.10.06 0.0.A.
* 
* Summary: Delete the file
*
-----------------------------------------------------------------------------*/

uint     STDCALL os_filedelete( pstr name )
{
   return DeleteFile( str_ptr( name ));
}

uint  STDCALL os_fileopen( pstr name, uint flag )
{
   uint ret;

   ret = ( uint )CreateFile( str_ptr( name ), ( flag & FOP_READONLY ? GENERIC_READ : 
            GENERIC_READ | GENERIC_WRITE ), ( flag & FOP_EXCLUSIVE ? 0 : 
// ( flag & FOP_READONLY ? FILE_SHARE_READ : FILE_SHARE_READ | FILE_SHARE_WRITE )
            FILE_SHARE_READ | FILE_SHARE_WRITE ), NULL, 
           ( flag & FOP_CREATE ? CREATE_ALWAYS :
              ( flag & FOP_IFCREATE ? OPEN_ALWAYS : OPEN_EXISTING )),
           /*FILE_FLAG_WRITE_THROUGH*/ 0, NULL ); 
//   printf("Name=%s %i\n", str_ptr( name ), ret );
   return ret == ( uint )INVALID_HANDLE_VALUE ? 0 : ret ;
}

ulong64  STDCALL os_filepos( uint handle, long64 offset, uint mode )
{
   LARGE_INTEGER  li;

   li.QuadPart = offset;

   li.LowPart = SetFilePointer( ( pvoid )handle, li.LowPart, &li.HighPart, 
       ( mode == FSET_BEGIN ?
      FILE_BEGIN : ( mode == FSET_CURRENT ? FILE_CURRENT : FILE_END )));
   if ( li.LowPart == MAX_UINT && GetLastError() != NO_ERROR )
      return -1L;
   return li.QuadPart;
}

uint   STDCALL os_fileread( uint handle, pubyte data, uint size )
{
   uint  read;

   if ( !ReadFile( (pvoid)handle, data, size, &read, NULL ) || read != size ) 
      return FALSE;
   return read;
}

ulong64  STDCALL os_filesize( uint handle )
{
   LARGE_INTEGER  li;

   li.LowPart = GetFileSize( ( pvoid )handle, &li.HighPart ); 
 
   if ( li.LowPart == INVALID_FILE_SIZE && GetLastError() != NO_ERROR )
      return -1L;

   return li.QuadPart;
}

//--------------------------------------------------------------------------

uint   STDCALL os_filewrite( uint handle, pubyte data, uint size )
{
   uint  write;

   if ( !WriteFile( ( pvoid )handle, data, size, &write, NULL ) || write != size ) 
      return FALSE;
   return write;
}

/*-----------------------------------------------------------------------------
*
* ID: os_fileexist 23.10.06 0.0.A.
* 
* Summary: If the file or directory exists
*
-----------------------------------------------------------------------------*/

uint STDCALL os_fileexist( pstr name )
{
   return os_getattrib( name ) != 0xFFFFFFFF ? 1 : 0;
}

/*-----------------------------------------------------------------------------
*
* ID: os_getattrib 23.10.06 0.0.A.
* 
* Summary: Get the file or directory attrbutes
*
-----------------------------------------------------------------------------*/

uint  STDCALL os_getattrib( pstr name )
{
   return GetFileAttributes( str_ptr( name ));
}

/*-----------------------------------------------------------------------------
*
* ID: os_tempdir 23.10.06 0.0.A.
* 
* Summary: Get the temp dir
*
-----------------------------------------------------------------------------*/

pstr  STDCALL os_tempdir( pstr name )
{
   str_setlen( name, GetTempPath( 1024, str_reserve( name, 1024 )->data ));
   return str_trim( name, SLASH, TRIM_ONE | TRIM_RIGHT );
}

#ifndef NOGENTEE

pstr  STDCALL os_gettemp( void )
{
   uint  diskc = 0;
   pstr  temp;
   pstr  ret;
//   ubyte temp[ 512 ];
//   ubyte stemp[ 512 ];

//   str_lenset( dir, 0 );
//   str_isfree( dir, 512 );
/*#ifdef LINUX
   if ( !ggentee.tempfile )
   {
      while( 1 )
      {
         wsprintf( stemp, "/temp/gentee%02X.tmp", ggentee.tempid );
         ggentee.tempfile = file_open( stemp, FOP_CREATE | FOP_EXCLUSIVE );
         if ( ggentee.tempfile = -1 )
            ggentee.tempid++;
         else
            break;
      }
      stemp[ mem_len( stemp ) - 4 ] = 0;
//      wsprintf( stemp, "%s\\gentee%02X", temp, ggentee.tempid );
      mkdir( stemp, 700 );
      ggentee.tempdir = str_new( 0, stemp );
   }
//   str_appendp( dir, str_ptr( ggentee.tempdir ));
#else*/
   if ( !_gentee.tempfile )
   {
      temp = str_new( NULL );
      ret = str_new( NULL );
      os_tempdir( temp );

      while ( 1 )
      {
         str_clear( ret );
         str_printf( ret, "%s\\gentee%02X.tmp", str_ptr( temp ), _gentee.tempid );
   
         _gentee.tempfile = os_fileopen( ret, FOP_CREATE | FOP_EXCLUSIVE );
            
         if ( !_gentee.tempfile )
         {
            if ( os_getattrib( ret ) == 0xFFFFFFFF )
               if ( !diskc )
               {
                  str_copyzero( temp, "c:\\temp" );
                  os_dircreate( temp );
                  diskc = 1;
               }
               else
                  msg( MFileopen | MSG_STR, ret );
            _gentee.tempid++;
         }
         else
            break;
      }
      str_setlen( ret, str_len( ret ) - 4 );
      os_dircreate( ret );
      str_copy( &_gentee.tempdir, ret );

      str_destroy( temp );
      str_destroy( ret );
   }
//#endif
   return &_gentee.tempdir;
}

/*-----------------------------------------------------------------------------
*
* ID: os_init 23.10.06 0.0.A.
* 
* Summary: Initializing input and output.
*
-----------------------------------------------------------------------------*/

void   STDCALL os_init( uint param )
{
   if ( param )  // if ( !GetConsoleWindow( ))
      AllocConsole();
   else
   {
      CPINFO cpinfo;

      GetCPInfo( CP_ACP, &cpinfo );
      _gentee.multib = cpinfo.MaxCharSize > 1 ? 1 : 0;
   }
   if ( _gentee.flags & G_CONSOLE || param )
   {
      _stdout = GetStdHandle( STD_OUTPUT_HANDLE );
      _stdin = GetStdHandle( STD_INPUT_HANDLE );
   }
}

/*-----------------------------------------------------------------------------
*
* ID: os_print 23.10.06 0.0.A.
* 
* Summary: Print a text to the console.
*
-----------------------------------------------------------------------------*/

void   STDCALL os_print( pubyte ptr, uint len )
{
   uint    write;
   pubyte  charprn;

   if ( _gentee.flags & G_CHARPRN )
   {
      charprn = ( pubyte )mem_alloc( len + 1 );
      CharToOem( ptr, charprn );
      ptr = charprn;
   }
   if ( _gentee.flags & G_CONSOLE )
      WriteFile( _stdout, ptr, len, &write, 0 );
   else
   {
      if ( _stdout == INVALID_HANDLE_VALUE )
          os_init( 1 );
      WriteConsole( _stdout, ptr, len, &write, NULL );
   }
   
   if ( _gentee.flags & G_CHARPRN )
      mem_free( charprn );
}

/*-----------------------------------------------------------------------------
*
* ID: os_getch 23.10.06 0.0.A.
* 
* Summary: Get a character form the console.
*
-----------------------------------------------------------------------------*/

uint    STDCALL os_getchar( void )
{
   uint  mode, get;
   ubyte input[8];

   if ( _gentee.getch )
      return _gentee.getch( 0, 1 );

   if ( _stdin == INVALID_HANDLE_VALUE )
      os_init( 1 );

   GetConsoleMode( _stdin, &mode );
   SetConsoleMode( _stdin, 0 );
   ReadConsole( _stdin, input, 1, &get, NULL );
   SetConsoleMode( _stdin, mode );
//   return _getch();
   return input[0];
}

/*-----------------------------------------------------------------------------
*
* ID: os_scan 23.10.06 0.0.A.
* 
* Summary: Get characters form the console.
*
-----------------------------------------------------------------------------*/

uint  STDCALL os_scan( pubyte input, uint len ) 
{
   uint   read;

   if ( _gentee.getch )
      return _gentee.getch( input, len );

   if ( _stdin == INVALID_HANDLE_VALUE )
      os_init( 1 );
   ReadConsole( _stdin, input, len, &read, NULL );

   return read;
}

#endif // NOGENTEE

/*-----------------------------------------------------------------------------
*
* ID: os_strcmplen 23.10.06 0.0.A.
* 
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_strcmplen( pubyte one, pubyte two, uint len )
{
   int cmp = CompareString( LOCALE_USER_DEFAULT, 0, one, len, two, len );
   if ( cmp == CSTR_LESS_THAN )
      return -1;
   if ( cmp == CSTR_GREATER_THAN )
      return 1;
   return 0;
}

/*-----------------------------------------------------------------------------
*
* ID: os_strcmpignlen 23.10.06 0.0.A.
* 
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_strcmpignlen( pubyte one, pubyte two, uint len )
{
   int cmp = CompareString( LOCALE_USER_DEFAULT, NORM_IGNORECASE, one, len, two, len );

   if ( cmp == CSTR_LESS_THAN )
      return -1;
   if ( cmp == CSTR_GREATER_THAN )
      return 1;

   return 0;
}

pvoid    STDCALL os_thread( pvoid pfunc, pvoid param )
{
   uint   id;

   return CreateThread( 0, 0, pfunc, param, 0, &id );
}

/*-----------------------------------------------------------------------------
*
* ID: os_ustrcmplen 23.10.06 0.0.A.
* 
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_ustrcmplen( pushort one, pushort two, uint len )
{
   int cmp = CompareStringW( LOCALE_USER_DEFAULT, 0, one, len, two, len );
   if ( cmp == CSTR_LESS_THAN )
      return -1;
   if ( cmp == CSTR_GREATER_THAN )
      return 1;
   return 0;
}

/*-----------------------------------------------------------------------------
*
* ID: os_strcmpignlen 23.10.06 0.0.A.
* 
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_ustrcmpignlen( pushort one, pushort two, uint len )
{
   int cmp = CompareStringW( LOCALE_USER_DEFAULT, NORM_IGNORECASE, one, len, two, len );

   if ( cmp == CSTR_LESS_THAN )
      return -1;
   if ( cmp == CSTR_GREATER_THAN )
      return 1;

   return 0;
}

/*-----------------------------------------------------------------------------
*
* ID: os_strcmp 23.10.06 0.0.A.
* 
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_strcmp( pubyte one, pubyte two )
{
   return os_strcmplen( one, two, -1 );
}

/*-----------------------------------------------------------------------------
*
* ID: os_strcmpign 23.10.06 0.0.A.
* 
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_strcmpign( pubyte one, pubyte two )
{
   return os_strcmpignlen( one, two, -1 );
}

/*-----------------------------------------------------------------------------
*
* ID: os_strcmp 23.10.06 0.0.A.
* 
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_ustrcmp( pushort one, pushort two )
{
   return os_ustrcmplen( one, two, -1 );
}

/*-----------------------------------------------------------------------------
*
* ID: os_strcmpign 23.10.06 0.0.A.
* 
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_ustrcmpign( pushort one, pushort two )
{
   return os_ustrcmpignlen( one, two, -1 );
}

//--------------------------------------------------------------------------

/*
pvoid STDCALL os_alloc( uint size )
{
   return VirtualAlloc( NULL, size, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE );
}

void STDCALL os_free( pvoid ptr )
{
   VirtualFree( ptr, 0, MEM_RELEASE );
}
*/ 
//--------------------------------------------------------------------------

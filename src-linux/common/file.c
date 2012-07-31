/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: file 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
* Summary: This file provides file system functions.
*
******************************************************************************/

#include "../os/user/defines.h"
#include "../genteeapi/gentee.h"
#include "../common/arrdata.h"

/*-----------------------------------------------------------------------------
*
* ID: file2buf 23.10.06 0.0.A.
* 
* Summary: Read file to buf. Result must be destroy later. name is converted 
  into the full name.
*
-----------------------------------------------------------------------------*/

pbuf STDCALL file2buf( pstr name, pbuf ret, uint pos )
{
   str       filename;
   uint      search = 0;
   uint      handle, size;
   parrdata  pad;

   str_init( &filename );
   os_filefullname( name, &filename );

   if ( _compile && str_findch( name, SLASH ) >= str_len( name ))
   {
      search = 1;
      pad = &_compile->libdirs;
   }
again:
   handle = os_fileopen( &filename, FOP_READONLY );
   if ( !handle )
   {
      if ( search && search <= arr_count( pad ))
      {
         str_dirfile( arrdata_get( pad, search++ - 1 ), name, &filename );
         goto again;
      }
      msg( MFileopen | MSG_STR | MSG_EXIT | MSG_POS, &filename, pos );
   }
   size = ( uint )os_filesize( handle );
   buf_reserve( ret, size );

   if ( size && !os_fileread( handle, buf_ptr( ret ), size ))
      msg( MFileread | MSG_STR | MSG_EXIT | MSG_POS, &filename, pos );

   buf_setlen( ret, size );
   os_fileclose( handle );

   str_copy( name, &filename );

   str_delete( &filename );

   return ret;
}

uint  STDCALL buf2file( pstr name, pbuf out )
{
   str       filename;
   uint      handle;

   str_init( &filename );
   os_filefullname( name, &filename );

   handle = os_fileopen( &filename, FOP_CREATE );
   if ( !handle )
      msg( MFileopen | MSG_STR | MSG_EXIT, &filename );

   if ( !os_filewrite( handle, buf_ptr( out ), buf_len( out ) ))
      msg( MFileread | MSG_STR | MSG_EXIT, &filename );

   os_fileclose( handle );

   str_copy( name, &filename );
   str_delete( &filename );

   return 1;
}

/*-----------------------------------------------------------------------------
*
* ID: gettempdir 23.10.06 0.0.A.
* 
* Summary: Get the application's temp dir
*
-----------------------------------------------------------------------------*/

pstr  STDCALL gettempdir( pstr name )
{
   if ( !str_len( &_gentee.tempdir ))
   {
      uint   id = 0;
      str    path;
      pstr   ps;

      ps = &_gentee.tempdir;

      os_tempdir( str_init( &path ));

      while ( 1 )
      {
         str_clear( ps );
         str_printf( ps, (pubyte)("%s%cgentee%02X.tmp"), str_ptr( &path ), SLASH, id );
         _gentee.tempfile = os_fileopen( ps, FOP_CREATE | FOP_EXCLUSIVE );

         if ( !_gentee.tempfile )
         {
            if ( id++ > 0xFFFF )
               msg( MFileopen | MSG_STR | MSG_EXIT, ps );
         }
         else
            break;
      }
      os_dircreate( str_setlen( ps, str_len( ps ) - 4 ));
      str_delete( &path );
   }
   return str_copy( name, &_gentee.tempdir );

   //return str_copy( name, os_gettemp());
}

/*-----------------------------------------------------------------------------
*
* ID: gettempfile 23.10.06 0.0.A.
* 
* Summary: Get the filename in the temp dir
*
-----------------------------------------------------------------------------*/

pstr  STDCALL gettempfile( pstr name, pstr additional )
{
   str     tempdir;

   str_init( &tempdir );
   gettempdir( &tempdir );
   str_dirfile( &tempdir, additional, name );
   str_delete( &tempdir );

   return name;
}

/*-----------------------------------------------------------------------------
*
* ID: getexefile 23.10.06 0.0.A.
* 
* Summary: Get the filename in the exe dir
*
-----------------------------------------------------------------------------*/

pstr  STDCALL getmodulename( pstr name )
{
 #ifdef WINDOWS
   uint  i;

   str_reserve( name, 512 );
   i = GetModuleFileName( 0, str_ptr( name ), 511 );
   str_setlen( name, i );
#endif
   return name;
}

/*-----------------------------------------------------------------------------
*
* ID: getexedir 23.10.06 0.0.A.
* 
* Summary: Get the filename in the exe dir
*
-----------------------------------------------------------------------------*/

pstr  STDCALL getmodulepath( pstr name, pstr additional )
{
   str  temp;

   str_init( &temp );

#ifdef LINUX
   //Only for linux ???
   uint len = readlink( "/proc/self/exe", additional, 512 ) - 1;
   //uint sep1 = str_find(additionaļ,0,'\304',1);
   uint   separ = str_find( additional, 0, SLASH, 1 );
   //pCopyStr=strrchr(additionaļ,SLASH);
   //while ( len && (additional[ len ] != '/') ) len--;
   //if ( str_findch(filename,SLASH) != 0 )
   mem_copyuntilzero((pubyte) (additional + separ + 1), name );
   //strcpy(str_ptr(name),pCopyStr);
   //mem_copyuntilzero( additional + len + 1, name );
#else
   getmodulename( name );
   str_getdirfile( name, &temp, NULL );
   str_dirfile( &temp, additional, name );
#endif
   str_delete( &temp );
   return name;
}

//--------------------------------------------------------------------------

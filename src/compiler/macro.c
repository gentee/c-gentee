/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: define 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: macro functions
*
******************************************************************************/

#include "../genteeapi/gentee.h"
#include "macro.h"

const pubyte defmacro[] = {
   "_FILE","_DATE", "_TIME", "_LINE", "_WINDOWS", "_LINUX", ""
};

/*-----------------------------------------------------------------------------
*
* ID: macro_init 22.11.06 0.0.A.
* 
* Summary: Create default macros
*
-----------------------------------------------------------------------------*/

uint STDCALL macro_init( void )
{
   uint   i = 0;
   pmacro pm;

   // Определяем предопределенные макросы
   while ( *defmacro[ i ] )
   {
      pm = ( pmacro )( hash_create( &_compile->macros, defmacro[ i ] ) + 1 );
      pm->mr.vallexem.type = LEXEM_STRING;
      pm->mr.vallexem.nameid = i++;
      pm->flag = MACROF_PREDEF;
   }
   return i;
}

/*-----------------------------------------------------------------------------
*
* ID: macro_set 22.11.06 0.0.A.
* 
* Summary: Set macro value
*
-----------------------------------------------------------------------------*/

pmacro STDCALL macro_set( plexem plex, uint type, uint group )
{
   ubyte     fullname[256];
   pmacro    pm;
   pubyte    name;
   phash     macrohash;
   uint      namedef = 0;
   
   if ( type & MACRO_NAMEDEF )
   {
      type &= ~MACRO_NAMEDEF;
      macrohash = &_compile->namedef;
      namedef = MACRO_NAMEDEF;
   }
   else
      macrohash = &_compile->macros;

   name = lexem_getname( plex );
   if ( group )
   {
      pmacro  palias = macro_set( plex, namedef, 0 );
      // nameid saves the identifier of the group name
      if ( !palias->mr.vallexem.type )
         palias->mr.vallexem.nameid = group - 1;

      wsprintf( fullname, "%s.%s", hash_name( &_compile->names, group - 1 ),
                name );
      name = ( pubyte )&fullname;
//      printf("GROUP=%i %s %s\n", group, groupname, name );
   }
   pm = ( pmacro )( hash_create( macrohash, name ) + 1 );

//   print("create=%s\n", name );
   if ( pm->flag & MACROF_PREDEF || pm->flag & MACROF_GROUP )
      msg( MWrongname | MSG_LEXNAMEERR, plex );

   if ( !pm->mr.vallexem.type )
   {
      pm->mr.vallexem.type = ( ubyte )type;
//      pm->mr.vallexem.nameid = id;
   }
   return pm;
}

/*-----------------------------------------------------------------------------
*
* ID: macro_get 22.11.06 0.0.A.
* 
* Summary: Get macro value
*
-----------------------------------------------------------------------------*/

plexem STDCALL macro_get( plexem plex )
{
   ubyte     temp[ 256 ];
   uint      pos, off = 1;
   pstr      out;
   pmacro    pm;
   plexem    plexsrc;
   phashitem phi;
   phash     macrohash;     
#ifdef LINUX
   struct timespec ftime;
	//timezone ztime;
   struct tm tmt;
#else   
   SYSTEMTIME st;
#endif
   if ( plex->type == LEXEM_NAME )
   {
      macrohash = &_compile->namedef;
      off = 0;
   }
   else
      macrohash = &_compile->macros;

   phi = hash_find( macrohash, lexem_getname( plex ) + off );
   if ( !phi && plex->type != LEXEM_NAME )
      phi = hash_find( macrohash, "_DEFAULT" );

again:   
//   print("phi=%i name= %s\n", phi, lexem_getname( plex ) + off );
   if ( !phi )
      goto error;

   pm = ( pmacro )( phi + 1 );
   plexsrc = &pm->mr.vallexem;
   if ( !plexsrc->type )  // Alias macro
   {
      wsprintf( temp, "%s.%s", hash_name( &_compile->names, plexsrc->nameid ), 
                lexem_getname( plex ) + off );
      phi = hash_find( macrohash, temp );
      goto again;
   }
   if ( pm->flag & MACROF_GROUP  )   // Must be a dot in the next lexem
   {
      plexem nlex; 

      nlex = lexem_next( plex, 0 );
      if ( !lexem_isys( nlex, LSYS_DOT ))
         goto error;
      nlex->type = LEXEM_SKIP;
      nlex = lexem_next( nlex, LEXNEXT_NAMEDEF );
      if ( nlex->type != LEXEM_NAME )
         goto error;
      nlex->type = LEXEM_SKIP;
      wsprintf( temp, "%s.%s", lexem_getname( plex ) + off, 
                lexem_getname( nlex ));
      phi = hash_find( macrohash, temp );
      goto again;
   }
   if ( pm->flag & MACROF_PREDEF  )
   {
      if ( plexsrc->nameid > MACRO_TIME )
      {
         plex->type = LEXEM_NUMBER;
         plex->num.type = TUint;
      }
      else
      {
         out = str_init( ( pstr )arr_append( &_compile->string ));
         plex->type = LEXEM_STRING;
         plex->strid = arr_count( &_compile->string ) - 1;
#ifdef LINUX    
	      gettimeofday( &ftime, 0 );
         localtime_r( &ftime.tv_sec, &tmt );         
#else 
         GetLocalTime( &st );
#endif
      }
      switch ( plexsrc->nameid  )
      {
         case MACRO_FILE:
            str_copy( out, _compile->cur->filename );
            break;
         case MACRO_DATE:
#ifdef LINUX
            wsprintf( temp, "%02i%02i%i", tmt.tm_mday, tmt.tm_mon, tmt.tm_year );
#else      
            wsprintf( temp, "%02i%02i%i", st.wDay, st.wMonth, st.wYear );
#endif
            str_copyzero( out, temp );
            break;
         case MACRO_TIME:
#ifdef LINUX      
            wsprintf( temp, "%02i%02i%02i", tmt.tm_hour, tmt.tm_min, tmt.tm_sec );
#else
            wsprintf( temp, "%02i%02i%02i", st.wHour, st.wMinute, st.wSecond );
#endif
            str_copyzero( out, temp );
            break;
         case MACRO_LINE:
            plex->num.vint = str_pos2line( _compile->cur->src, plex->pos, &pos );
            break;
         case MACRO_WINDOWS:
#ifdef WINDOWS
            plex->num.vint = 1;
#else
            plex->num.vint = 0;
#endif
            break;
         case MACRO_LINUX:
#ifdef LINUX
            plex->num.vint = 1;
#else
            plex->num.vint = 0;
#endif
            break;
      }
   }
   else
   {
      lexem_copy( plex, plexsrc );
   }
//   printf("Macro=%s\n", lexem_getname( plex ));
   return plex;
error:
   if ( plex->type == LEXEM_NAME )
      return plex;

   msg( MUndefmacro | MSG_LEXNAMEERR, plex );
   return 0;
}

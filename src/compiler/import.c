/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: import 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: import command
*
******************************************************************************/

#include "../genteeapi/gentee.h"
#include "bcodes.h"
#include "compile.h"
#include "../common/file.h"

/*-----------------------------------------------------------------------------
*
* ID: include 22.11.06 0.0.A.
* 
* Summary: import command
*
-----------------------------------------------------------------------------*/

plexem  STDCALL import( plexem plex )
{
   bcflag bcf; 
   uint   funcflags = _compile->cur->priv ? GHRT_PRIVATE : 0;
   pubyte pout;
   plexem lexname, lexalias;
   pstr   filename;
   buf    bdata;
   pvmobj parent;
   uint   ret, parcount, i;
   uint   params[64];

   buf_init( &bdata );
   plex = lexem_next( plex, LEXNEXT_IGNLINE );
   if ( plex->type != LEXEM_STRING )  
      msg( MMuststr | MSG_LEXERR, plex );
   lexname = plex;
   filename = lexem_getstr( lexname );

   plex = bc_flag( lexem_next( plex, LEXNEXT_IGNLINE ), BFLAG_IMPORT, &bcf );
 
   funcflags |= GHEX_IMPORT | ( bcf.value & GHIMP_CDECL ? GHEX_CDECL : 0 );
   out_init( OVM_IMPORT, bcf.value, 0 );

   if ( bcf.value & GHIMP_LINK )
   {
      // Линкуем dll файл
      file2buf( filename, &bdata, lexname->pos );
      // Оставляем только имя dll файла
      str_getdirfile( filename, 0, filename );

      // проверку на дублирование
      if ( !hash_find( &_compile->files, str_ptr( filename )))
         hash_create( &_compile->files, str_ptr( filename ));
      else
         buf_clear( &bdata );
   }
   out_addname( str_ptr( filename ));
   out_adduint( buf_len( &bdata )); 
   out_addbuf( &bdata );

   pout = out_finish();
   parent = load_import( &pout );

//   print("IMPORT name=%s size =%i\n", str_ptr( filename ), buf_len( _compile->pout ));
   buf_delete( &bdata );

   plex = lexem_next( plex, LEXNEXT_IGNLINE | LEXNEXT_LCURLY );

   while ( 1 )
   {
      if ( lexem_isys( plex, LSYS_RCURLY ))
         break;

      if ( ret = bc_type( plex ))
         plex = lexem_next( plex, LEXNEXT_IGNLINE );
      
      if ( plex->type != LEXEM_NAME )
         msg( MExpname | MSG_LEXERR, plex );
      lexname = plex;

      plex = lexem_next( plex, LEXNEXT_IGNLINE );
      if ( !lexem_isys( plex, LSYS_LBRACK ))
         msg( MExpopenbr | MSG_LEXERR, plex );
      parcount = 0;

      while ( 1 )
      {
         plex = lexem_next( plex, LEXNEXT_IGNLINE | LEXNEXT_IGNCOMMA );
         if ( lexem_isys( plex, LSYS_RBRACK ))
            break;
         params[ parcount++ ] = bc_type( plex );
         if ( !params[ parcount - 1 ] )
            msg( MExptype | MSG_LEXERR, plex );
      }
      plex = lexem_next( plex, 0 );
      lexalias = NULL;
      if ( lexem_isys( plex, LSYS_PTR ))
      {
         plex = lexem_next( plex, LEXNEXT_IGNLINE );
         if ( plex->type != LEXEM_NAME )
            msg( MExpname | MSG_LEXERR, plex );
         lexalias = plex;
      }
      out_init( OVM_EXFUNC, funcflags, 
                lexem_getname( lexalias ? lexalias : lexname ));
      out_adduint( ret );
      out_addubyte( 0 );      
      out_adduint( parcount );
      for ( i = 0; i < parcount; i++ )
      {
         out_adduint( params[ i ] );
         out_addubyte( 0 );      
      }
      out_adduint( parent->id );
      out_addname( lexem_getname( lexname ));
      pout = out_finish();
      load_exfunc( &pout, 0 );

      plex = lexem_next( plex, LEXNEXT_IGNLINE );
   }

   return plex;
}


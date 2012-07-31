/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: global 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: global command
*
******************************************************************************/

#include "../genteeapi/gentee.h"
#include "bcodes.h"
#include "compile.h"
#include "../common/file.h"

/*-----------------------------------------------------------------------------
*
* ID: global 22.11.06 0.0.A.
* 
* Summary: global command
*
-----------------------------------------------------------------------------*/

plexem  STDCALL global( plexem plex )
{
   s_descid  field;
   pubyte    pout, pdata;
   uint      isize;
   uint      iflag, flag = GHCOM_NAME | ( _compile->cur->priv ? GHRT_PRIVATE : 0 );

   plex = lexem_next( plex, LEXNEXT_IGNLINE );

   field.flgdesc = DESCID_GLOBAL;
   plex = lexem_next( plex, LEXNEXT_IGNLINE | LEXNEXT_LCURLY );

   field.idtype = 0;
   while ( 1 )
   {
      plex = desc_nextidvar( plex, &field );
      if ( !field.idtype )
         break;

//      if ( bc_getid( field.lex ))
//         msg( MRedefine | MSG_LEXNAMEERR, field.lex );
      _vm.pos = field.lex->pos;

      out_init( OVM_GLOBAL, flag, field.name );
      iflag = 0;
      pdata = 0;
      if ( field.oftype ) 
         iflag |= VAR_OFTYPE;

      if ( field.msr ) 
         iflag |= VAR_DIM;
      if ( field.lexres )
      {
         iflag |= VAR_DATA;
         if ( field.lexres->type == LEXEM_NUMBER )
            pdata = ( pubyte )&field.lexres->num.vint;
         else
            pdata = ( pubyte )lexem_getstr( field.lexres );
      }
      out_addvar( &field, iflag, pdata );
      
      // Reserve space for variable data
      isize = ((povmtype)PCMD(field.idtype))->size;
      buf_expand( _compile->pout, isize );
      _compile->pout->use += isize;

      pout = out_finish();
      load_global( &pout );
   }
   if ( !lexem_isys( plex, LSYS_RCURLY ))
      msg( MRcurly | MSG_LEXERR, plex );

   return plex;
}


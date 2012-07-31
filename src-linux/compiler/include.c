/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: include 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: include command
*
******************************************************************************/

#include "../genteeapi/gentee.h"
#include "bcodes.h"
#include "compile.h"

/*-----------------------------------------------------------------------------
*
* ID: include 22.11.06 0.0.A.
* 
* Summary: include command
*
-----------------------------------------------------------------------------*/

plexem  STDCALL include( plexem plex )
{
   pstr   filename;

   plex = lexem_next( lexem_next( plex, LEXNEXT_IGNLINE ), 
                      LEXNEXT_IGNLINE | LEXNEXT_LCURLY );
   while ( 1 )
   {
      if ( lexem_isys( plex, LSYS_RCURLY ))
         break;

      if ( plex->type == LEXEM_STRING )
         filename = lexem_getstr( plex );
      else
         msg( MMuststr | MSG_LEXERR, plex );
      _compile->cur->pos = plex->pos;
      compile_process( filename );

      plex = lexem_next( plex, LEXNEXT_IGNLINE | LEXNEXT_IGNCOMMA );
   }

   return plex;
}


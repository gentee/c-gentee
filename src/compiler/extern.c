/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: extern 03.11.06 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
******************************************************************************/

#include "func.h"

/*-----------------------------------------------------------------------------
*
* ID: m_extern 03.11.06 0.0.A.
*
* Summary: The extern command processing
*
-----------------------------------------------------------------------------*/

plexem STDCALL m_extern( plexem curlex )
{
   D( "Extern start\n" );
   curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
   curlex = lexem_next( curlex, LEXNEXT_LCURLY | LEXNEXT_IGNLINE );
   while ( 1 )
   {
      if ( curlex->type == LEXEM_KEYWORD )
      {
         switch ( curlex->key )
         {
            case KEY_FUNC:
            case KEY_METHOD:
            case KEY_OPERATOR:
            case KEY_TEXT:
            case KEY_PROPERTY:
               curlex = m_func( curlex, 1 );
               break;
            default: msg( MNokeyword | MSG_LEXERR, curlex );
         }
      }
      if ( curlex->type == LEXEM_OPER )
      {
         if ( curlex->oper.operid == OpRcrbrack )
            break;
         if ( curlex->oper.operid == OpLine )
         {
            curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
            continue;
         }
      }
      msg( MSyntax | MSG_LEXNAMEERR, curlex );
   }
   D( "Extern stop\n" );
   return lexem_next( curlex, LEXNEXT_NULL );
}

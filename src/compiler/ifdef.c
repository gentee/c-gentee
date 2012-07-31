/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: ifdef 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: ifdef command
*
******************************************************************************/

#include "ifdef.h"
#include "macro.h"

/*-----------------------------------------------------------------------------
*
* ID: ifdef 22.11.06 0.0.A.
* 
* Summary: define command
*
-----------------------------------------------------------------------------*/

plexem  STDCALL ifdef( plexem plex )
{
   plexem    start = plex;
   plexem    exp;
   uint      ok;
   uint      found = 0;
   pmacrores lexval;
   uint      bvalue;

lelif:
   exp = plex;
//   plex->type = LEXEM_SKIP;  // delete 'ifdef' or 'elif'

   plex = lexem_next( macroexpr( lexem_next( plex, LEXNEXT_IGNLINE ), 
                      &lexval ), LEXNEXT_SKIPLINE );
   bvalue = lexval->bvalue;
   if ( (int)bvalue == -1 )
      msg( MWrongname | MSG_LEXNAMEERR, lexem_next( exp, LEXNEXT_IGNLINE ));

   if ( !found )
      found = bvalue;
   else
      bvalue = 0;

   while ( exp < plex ) // delete 'ifdef' or 'elif' and все лексемы в выражении
   {
      exp->type = LEXEM_SKIP;
      exp++;
   }
//   print("Lexval=%i %i\n", lexval->bvalue, lexval->vallexem.num.vint  );
lelse:
   ok = 1;

   // SKIP LINE чтобы plex оставался прежним
   // Можн заменить простой проверкой на LCURLY ?
   plex = lexem_next( plex,  LEXNEXT_SKIPLINE | LEXNEXT_LCURLY );
   plex->type = LEXEM_SKIP; // LCURLY
   while ( ok )
   {
      // Why was 'bvalue ? 0 : '?
      plex = lexem_next( plex,  /*bvalue ? 0 : */LEXNEXT_NOMACRO );
      if ( lexem_isys( plex, LSYS_LCURLY ) || lexem_isys( plex, LSYS_COLLECT ))
         ok++;
      if ( lexem_isys( plex, LSYS_RCURLY ))
         ok--;
      if ( !bvalue )
         plex->type = LEXEM_SKIP;
   }
   plex->type = LEXEM_SKIP;   // RCURLY

   plex = lexem_next( plex, LEXNEXT_SKIPLINE );

   if ( plex->type == LEXEM_KEYWORD )
   {
      if ( plex->key == KEY_ELIF )
         goto lelif;

      if ( plex->key == KEY_ELSE )
      {
         bvalue = !found;
         plex->type = LEXEM_SKIP;
         plex = lexem_next( plex, LEXNEXT_SKIPLINE );
         goto lelse;
      }
   }
   return start;
}

 
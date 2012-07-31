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
* Summary: define command
*
******************************************************************************/

#include "../genteeapi/gentee.h"
#include "define.h"
#include "macro.h"
#include "bcodes.h"
#include "out.h"

/*-----------------------------------------------------------------------------
*
* ID: define 22.11.06 0.0.A.
* 
* Summary: define command
*
-----------------------------------------------------------------------------*/

plexem  STDCALL define( plexem plex )
{
   uint    lastval = 0;
   uint    idname = 0;
   bcflag  bcf;
   plexem  next, pgroup = NULL;
   pmacro  pm;
   uint    export, namedef = 0;
   pubyte  pname;
   uint    off_count, count = 0;
   pmacrores  pres;

   plex = lexem_next( plex, LEXNEXT_IGNLINE );
   if ( plex->type == LEXEM_NAME )  // Имеется имя у множества
   {
      idname = plex->nameid + 1;
//      macro_set( plex, LEXEM_NUMBER, 0 )->flag = MACROF_GROUP;
      pgroup = plex;
      plex = lexem_next( plex, LEXNEXT_IGNLINE );
   }
   plex = bc_flag( plex, BFLAG_DEFINE, &bcf );
   export = bcf.value & GHDF_EXPORT;
   namedef = LEXEM_NUMBER | ( bcf.value & GHDF_NAMEDEF ? MACRO_NAMEDEF : 0 );
   if ( pgroup )
      macro_set( pgroup, namedef, 0 )->flag = MACROF_GROUP;

   if ( export )
   {
      out_init( OVM_DEFINE, bcf.value, idname ? 
                hash_name( &_compile->names, idname - 1 ) : 0 );
      off_count = out_adduint( 0 );
   }

   plex = lexem_next( plex, LEXNEXT_IGNLINE | LEXNEXT_LCURLY );
   while ( 1 )
   {
      if ( lexem_isys( plex, LSYS_RCURLY ))
         break;
      if ( plex->type != LEXEM_NAME )
         msg( MExpname | MSG_LEXERR, plex );

      if ( export )
      {
         pname = lexem_getname( plex );
      }
//      print("Lex=%s\n", lexem_getname( plex ));
      pm = macro_set( plex, namedef, idname );

      next = lexem_next( plex, LEXNEXT_IGNLINE );
      if ( lexem_isys( next, LSYS_EQ ))
      {
         lastval = 0;
         plex = lexem_next( next, LEXNEXT_IGNLINE );
         if ( plex->type == LEXEM_NAME )
         {
            pm->mr.vallexem.type = LEXEM_NAME;
            pm->mr.vallexem.nameid = plex->nameid;
            plex = lexem_next( plex, LEXNEXT_IGNLINE | LEXNEXT_IGNCOMMA );
         }
         else
         {
            plex = macroexpr( plex, &pres );
            pm->mr = *pres;

            if ( pm->mr.vallexem.type == LEXEM_NUMBER && 
                ( pm->mr.vallexem.num.type == TUint || 
                  pm->mr.vallexem.num.type == TInt ))
               lastval = pm->mr.vallexem.num.vint + 1;
            plex = lexem_next( plex, LEXNEXT_SKIPLINE );
         }
         goto export;
      }
      else
      {
         pm->mr.vallexem.num.type = TUint;
         pm->mr.vallexem.num.vint = lastval++;
//         printf("lv=%i\n", lastval );
      }
      plex = lexem_next( plex, LEXNEXT_IGNLINE | LEXNEXT_IGNCOMMA );

export:
      if ( export )
      {
         uint      iflag;
         s_descid  field;
         pubyte pdata = ( pubyte )lexem_getstr( &pm->mr.vallexem );

         field.flgdesc = DESCID_GLOBAL;
         field.idtype = TStr;
         iflag = VAR_NAME;
         field.name = pname;

         switch ( pm->mr.vallexem.type )
         {
            case LEXEM_STRING : break;
            case LEXEM_BINARY : 
               field.idtype = TBuf; 
               break;
            case LEXEM_NUMBER : 
               field.idtype = pm->mr.vallexem.num.type; 
               pdata = ( pubyte )&pm->mr.vallexem.num.vint;
               break;
            case LEXEM_NAME : 
               iflag |= VAR_IDNAME;
               pdata = lexem_getname( &pm->mr.vallexem );
               break;
         }
         count++;
         iflag |= VAR_DATA;
         out_addvar( &field, iflag, pdata );
      }
   }
   if ( export )   
   {
      out_setuint( off_count, count );
      pname = out_finish();
      load_define( &pname );
   }
   return plex;
}


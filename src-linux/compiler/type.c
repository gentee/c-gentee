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

/*-----------------------------------------------------------------------------
*
* ID: define 22.11.06 0.0.A.
* 
* Summary: define command
*
-----------------------------------------------------------------------------*/
/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: type 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: type command and fucntions
*
******************************************************************************/

#include "../genteeapi/gentee.h"
#include "type.h"
//#include "bcodes.h"

/*-----------------------------------------------------------------------------
*
* ID: type_fieldname 22.11.06 0.0.A.
* 
* Summary: Find the name of the type
*
-----------------------------------------------------------------------------*/

pvartype STDCALL type_fieldname( uint idtype, pubyte name )
{
   povmtype ptype = ( povmtype )PCMD( idtype );
   uint     i;
   pvartype ret;
   
   if ( ptype->inherit )
   {
      if ( ret = type_fieldname( ptype->inherit, name ))
         return ret; 
   }
//   if ( type->vmobj.flag & GHTY_PROTECTED )
//      return NULL;
//   Обнулять имена полей после окончания файла если есть такой флаг.  

   ret = ptype->children;
   for ( i = 0; i < ptype->count; i++ )
   {
      if ( ret->name && mem_iseqzero( ret->name, name ))
         return ret;
      ret++;
   }
   return NULL;
}

/*-----------------------------------------------------------------------------
*
* ID: type_field 22.11.06 0.0.A.
* 
* Summary: Find the name of the type
*
-----------------------------------------------------------------------------*/

pvartype STDCALL type_field( plexem plex, uint idtype )
{
   pvartype   ret;
   ubyte      name[ 128 ];
   pubyte     tname = lexem_getname( plex );

   ret = type_fieldname( idtype, tname );
   if ( !ret )
   {
      // Ищем property get и set
      sprintf( name, "@%s", tname );
      if ( !hash_find( &_vm.objname, name ))
         msg( MNofield | MSG_LEXNAMEERR, plex );
   }
   return ret;
}

/*-----------------------------------------------------------------------------
*
* ID: type 22.11.06 0.0.A.
* 
* Summary: type command
*
-----------------------------------------------------------------------------*/

plexem  STDCALL type( plexem plex )
{
   bcflag  bcf;
   plexem  namelex;
   pubyte  pout, curname;
   uint    off_count, count = 0, i, inherit = 0;
   s_descid  field;
   uint      iflag;
   buf       fields;

   buf_init( &fields );
   namelex = lexem_next( plex, LEXNEXT_IGNLINE | LEXNEXT_NAME );

//   if ( bc_getid( namelex ))
//      msg( MRedefine | MSG_LEXNAMEERR, namelex );
   _vm.pos = namelex->pos;
   plex = bc_flag( lexem_next( namelex, LEXNEXT_IGNLINE ), BFLAG_TYPE, &bcf );

   out_init( OVM_TYPE, GHCOM_NAME | bcf.value, lexem_getname( namelex ));

   if ( bcf.value & GHTY_INHERIT )
   {
      inherit = bcf.inherit.idtype;

      if ( inherit < TBuf || inherit == TReserved  )
         msg( MInherit | MSG_LEXERR, namelex );
      out_adduint( inherit );
   }
   if ( bcf.value & GHTY_INDEX )
   {
      out_adduint( bcf.index.idtype );
      out_adduint( bcf.index.oftype );
   }
   off_count = out_adduint( 0 );

   plex = lexem_next( plex, LEXNEXT_IGNLINE | LEXNEXT_LCURLY );
   
   if ( inherit )
   {
      // Added as the first field
      count = 1;
      out_adduint( inherit );
      out_addubyte( 0 );
      buf_appendch( &fields, 0 );
   }
   field.flgdesc = DESCID_TYPE;

   field.idtype = 0;
   while ( 1 )
   {
      plex = desc_nextidvar( plex, &field );
      if ( !field.idtype )
         break;

      iflag = VAR_NAME;
      if ( field.oftype ) 
         iflag |= VAR_OFTYPE;

      if ( field.msr ) 
         iflag |= VAR_DIM;
      
      // Проверка на переопределение полей
      curname = buf_ptr( &fields );
      for ( i = 0; i < count; i++ )
      {
         if ( mem_iseqzero( curname, field.name ))
            msg( MRefield | MSG_LEXNAMEERR, field.lex );
         curname += mem_len( curname ) + 1;
      }
      buf_append( &fields, field.name, mem_len( field.name ) + 1 );
//      print("Name=%s flag=%x\n", field.name, iflag );
      count++;
      out_addvar( &field, iflag, NULL );
   }
   if ( !lexem_isys( plex, LSYS_RCURLY ))
      msg( MExptype | MSG_LEXERR, plex );

   out_setuint( off_count, count );

   pout = out_finish();
   load_type( &pout );
   buf_delete( &fields );
   return plex;
}

/*-----------------------------------------------------------------------------
*
* ID: type_protect  22.11.06 0.0.A.
* 
* Summary: Clear names of the type
*
-----------------------------------------------------------------------------*/

void  STDCALL type_protect( povmtype ptype )
{
   uint  i;

   for ( i = 0; i < ptype->count; i++ )
   {
      ptype->children[ i ].name = NULL;
      ptype->children[ i ].flag &= ~VAR_NAME;
   }
}

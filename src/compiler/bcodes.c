/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: lexem 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Working with lexems
*
******************************************************************************/

#include "bcodes.h"
#include "compinit.h"
#include "../vm/vm.h"
#include "../vm/vmres.h"
#include "../vm/vmtype.h"
#include "../common/msg.h"
#include "alias.h"

const  pubyte  nameflags[] ={ 
   // Флаги для функций
   "entry" , "main", "result", "=alias",
   // Флаги для типов
   "=index", "=inherit", "protected", 
   // Флаги для define
   "export", "namedef",
   // Флаги для import
   "link" ,"cdeclare", "exe"
};

const  uint  valflags[] = {
   // Флаги для функций
   GHBC_ENTRY | BFLAG_FUNC, GHBC_MAIN | BFLAG_FUNC, GHBC_RESULT | BFLAG_FUNC, GHRT_ALIAS | BFLAG_FUNC,
   // Флаги для типов
   GHTY_INDEX | BFLAG_TYPE, GHTY_INHERIT | BFLAG_TYPE, GHTY_PROTECTED | BFLAG_TYPE, 
   // Флаги для define
   GHDF_EXPORT | BFLAG_DEFINE, GHDF_NAMEDEF | BFLAG_DEFINE,
   // Флаги для import
   GHIMP_LINK | BFLAG_IMPORT, GHIMP_CDECL | BFLAG_IMPORT, GHIMP_EXE | BFLAG_IMPORT, 0,
};

/*-----------------------------------------------------------------------------
*
* ID: bc_flag 03.11.06 0.0.A.
* 
* Summary: Get flags. Return the next lexem
*
-----------------------------------------------------------------------------*/

plexem  STDCALL bc_flag( plexem plex, uint type, pbcflag bcf )
{
   uint eqflag, i;

   bcf->value = _compile->cur->priv ? GHRT_PRIVATE : 0;

   if ( !lexem_isys( plex, LSYS_LESS ))
      return plex;

   while ( 1 )
   {
      plex = lexem_next( plex, LEXNEXT_IGNLINE );
nonext:
      if ( lexem_isys( plex, LSYS_GREATER ))
         break;
      if ( plex->type != LEXEM_NAME )
         msg( MExpname | MSG_LEXERR, plex );

      i = 0;
      while ( valflags[ i ] )
      {
         if ( valflags[ i ] & type )
         {
            eqflag = ( *nameflags[ i ] == '=' ? 1 : 0 );
            if ( mem_iseqzero( nameflags[ i ] + eqflag, lexem_getname( plex )))
            {
               bcf->value |= valflags[ i ] & 0xFFFFFF00;
               break;
            }
         }
         i++;
      }
      // Нет такого флага
      if ( !valflags[ i ] )
         msg( MNotattrib | MSG_LEXNAMEERR, plex );

      if ( eqflag )
      {
         plexem next;

         next = lexem_next( plex, LEXNEXT_IGNLINE );
         if ( !lexem_isys( next, LSYS_EQ ))
            msg( MAttrval | MSG_LEXNAMEERR, plex );
         next = lexem_next( next, LEXNEXT_IGNLINE | LEXNEXT_NAME );
         if ( valflags[i] & GHTY_INDEX )
         {
            if ( mem_iseqzero( lexem_getname( next ), "this" ))
            {
               bcf->index.idtype = arr_count( &_vm.objtbl );
               bcf->index.msr = 0;
               bcf->index.oftype = 0;
               plex = lexem_next( next, 0 );
            }
            else
               plex = desc_idtype( next, &bcf->index  );
         }
         if ( valflags[i] & GHTY_INHERIT )
            plex = desc_idtype( next, &bcf->inherit );
         if ( valflags[i] & GHRT_ALIAS )
            plex = alias_add( next, &bcf->alias );
         goto nonext;
      }
   }
   return lexem_next( plex, LEXNEXT_IGNLINE );
}

/*-----------------------------------------------------------------------------
*
* ID: bc_method 03.11.06 0.0.A.
* 
* Summary: Find method id
*
-----------------------------------------------------------------------------*/

pvmfunc   STDCALL  bc_method( plexem plex, uint count, puint pars )
{
   pvmfunc      bcode;
   ubyte        name[256];

   // Формируем имя метода или оператора
   sprintf( name, "@%s", lexem_getname( plex ));
   bcode = vm_find( name, count, pars );

   return ( uint )bcode < MSGCOUNT ? 0 : bcode;
}

/*-----------------------------------------------------------------------------
*
* ID: bc_func 03.11.06 0.0.A.
* 
* Summary: Find func id
*
-----------------------------------------------------------------------------*/

pvmfunc   STDCALL  bc_func( plexem plex, uint count, puint pars )
{
   pvmfunc      bcode;
   ubyte        name[256];

   if ( plex->flag & LEXF_NAME )
      mem_copyuntilzero( name, ( pubyte )plex->nameid );
   else
   {
      // Формируем имя метода или оператора
      if ( plex->flag & LEXF_METHOD )
         sprintf( name, "@%s", lexem_getname( plex ));
      else
         if ( plex->flag & LEXF_OPERATOR )
            sprintf( name, "#%s", ( pubyte )&plex->oper.name );
         else
            mem_copyuntilzero( name, lexem_getname( plex ));
   }
   bcode = vm_find( name, count, pars );
   if ( ( uint )bcode < MSGCOUNT )
         msg( ( uint )bcode | MSG_LEXERR | MSG_VALUE, plex, name );
   if (( plex->flag & LEXF_PROPERTY ) && !( bcode->vmo.flag & GHBC_PROPERTY ))
      msg( MUnkprop | MSG_LEXERR, plex );

   return bcode;
}

/*-----------------------------------------------------------------------------
*
* ID: bc_oper 03.11.06 0.0.A.
* 
* Summary: Find operator id
*
-----------------------------------------------------------------------------*/

pvmfunc   STDCALL bc_oper( plexem plex, uint srctype, uint desttype, 
                           uint srcof, uint destof )
{
   uint ptr[12];
//   pslexsys sys;
   
/*   if ( opers[ plex->oper.operid ].flgs & OPF_NOP )
   {
      return NULL;
   }*/
/* ???  if ( plex->sys->oper == OpNone )
   {
      *ret = ( lexitem->sys->type & OPER_RETUINT ? SUInt : desttype );
      return 0;
   }*/
   ptr[0] = srctype ? srctype : desttype;
   ptr[1] = srctype ? srcof : destof;
   ptr[2] = desttype;
   ptr[3] = destof;
   plex->oper.name = oper2name( plex->oper.operid );
//   if ( plex->oper.operid == OpIncright )
//      print("XXX=%x", plex->oper.name );
//   print("OK %i %i %i %i\n", srctype, desttype, plex->oper.operid, plex->oper.name );
   plex->flag |= LEXF_OPERATOR;
   return bc_func( plex, srctype ? 2 : 1, ( puint )&ptr );
}

/*-----------------------------------------------------------------------------
*
* ID: bc_property 03.11.06 0.0.A.
* 
* Summary: Find property id
*
-----------------------------------------------------------------------------*/

pvmfunc   STDCALL bc_property( plexem plex, uint objtype, uint setpar )
{
   uint  pars[12];

   plex->flag |= LEXF_METHOD | LEXF_PROPERTY;
   pars[0] = objtype;
   pars[1] = 0;
   pars[2] = setpar;
   pars[3] = 0;
   return bc_func( plex, 1 + ( setpar ? 1 : 0 ), ( puint )&pars );
}

/*-----------------------------------------------------------------------------
*
* ID: bc_isproperty 03.11.06 0.0.A.
* 
* Summary: Find possible property id
*
-----------------------------------------------------------------------------*/

pvmfunc   STDCALL bc_isproperty( plexem plex, uint objtype )
{
   pvmfunc      bcode;
   uint         id;
   phashitem    phi = NULL;
   ubyte        name[256];

   // Формируем имя метода или оператора
   sprintf( name, "@%s", lexem_getname( plex ));

   phi = hash_find( &_vm.objname, name );

   if ( !phi )
      return ( pvmfunc )0;

   id = *( puint )( phi + 1 );
      
   while ( id )
   {
      bcode =  ( pvmfunc )PCMD( id );
      if ( bcode->vmo.flag & GHBC_PROPERTY )
      {
         if ( type_isinherit( objtype, bcode->params->type ))
            return bcode;
      }
      id = bcode->vmo.nextname;
   }
   return NULL;
}

//--------------------------------------------------------------------------

pvmfunc  STDCALL  bc_funcname( plexem plexerr, pubyte name, uint count, puint pars )
{
   lexem       lexerr;

   mem_zero( &lexerr, sizeof( lexem ));
   lexerr.pos = plexerr->pos;
   lexerr.flag |= LEXF_NAME;
   lexerr.nameid = ( uint )name;

   return bc_func( &lexerr, count, pars );
}

//--------------------------------------------------------------------------

uint  CDECLCALL bc_find( plexem plexerr, pubyte name, uint count, ... )
{
   va_list     argptr;
   uint        i = 0;
   uint        params[ 32 ];
//   pvmfunc     pfunc;

   va_start( argptr, count );
   while ( i < count )
   {
      params[ i << 1 ] = va_arg( argptr, uint );
      params[ ( i << 1 ) + 1 ] = 0; // flags oftype
      i++;
   }
   va_end( argptr );

//   pfunc = vm_find( name, count, ( puint )&params );
   return bc_funcname( plexerr, name, count, ( puint )&params )->vmo.id;
//   return ( uint )pfunc < MSGCOUNT ? 0 : pfunc->vmo.id;
}

/*-----------------------------------------------------------------------------
*
* ID: bc_getid 03.11.06 0.0.A.
* 
* Summary: Get an id of vm 
*
-----------------------------------------------------------------------------*/

uint   STDCALL bc_getid( plexem plex )
{
   phashitem  phi;
//   pscompile    compile = ggentee.compile;

//   print("0 %i %i %i %s=", plex->type, plex->flag, plex->pos, lexem_getname( plex ));
   if ( plex->type != LEXEM_NAME )
      msg( MWrongname | MSG_LEXERR, plex );
 
   phi = hash_find( &_vm.objname, lexem_getname( plex ) );
   
//   result = nametbl_find( &compile->gevm.nametbl, 
//          nametbl_getname( &compile->idname, lexitem->id ), FALSE );

//   if ( result )
//      result = nametbl_valget( &compile->gevm.nametbl, result );
//   result = nametbl_valgetname( &compile->gevm.nametbl, 
//                         nametbl_getname( &compile->idname, lexitem->id ));
   return phi ? *( puint )( phi + 1 ) : 0;
}

/*-----------------------------------------------------------------------------
*
* ID: bc_obj 03.11.06 0.0.A.
* 
* Summary: 
*
-----------------------------------------------------------------------------*/
/*
uint   STDCALL bc_obj( plexem plex )
{
   uint   type = bc_getid( plex );

   if ( type )
      return (( pvmobj )PCMD( type ))->type;
      ret = (( psvmobj )objtbl_getobj( &compile->gevm, type ))->type;
      if ( ret == OVM_BYTECODE || ret == OVM_EXFUNC || ret == OVM_STACKCMD ||
           ret == OVM_GLOBAL )
         lexitem->sys = ( pslexsys ) type;
   return 0;
}
*/
/*-----------------------------------------------------------------------------
*
* ID: bc_type 03.11.06 0.0.A.
* 
* Summary: Get a type of the identifier
*
-----------------------------------------------------------------------------*/

uint   STDCALL bc_type( plexem plex )
{
   uint       type = bc_getid( plex );

//   pscompile  compile = ggentee.compile;

/*   if ( !type || (( psvmobj )objtbl_getobj( &compile->gevm, type ))->type != OVM_TYPE )
      if ( noerror )
         type = 0;
      else
         io_mess( IOC_UNKTYPE, lexitem );
*/
   return (( pvmobj )PCMD( type ))->type == OVM_TYPE ? type : 0;
}

/*-----------------------------------------------------------------------------
*
* ID: bc_resource 03.11.06 0.0.A.
* 
* Summary: Get an identifier of the resource
*
-----------------------------------------------------------------------------*/

uint   STDCALL bc_resource( pubyte ptr )
{
   phashitem   phi;
   puint       pidphi;

   phi = hash_create( &_compile->resource, ptr );
   pidphi = ( puint )( phi + 1 );
   if ( !*pidphi )
      *pidphi = vmres_addstr( ptr ) + 1;

   return *pidphi - 1;
}


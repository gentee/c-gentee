/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: ge 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: 
* 
******************************************************************************/

#ifndef RUNTIME

#include "ge.h"
#include "../vm/vm.h"
#include "../vm/vmload.h"
#include "../bytecode/bytecode.h"
#include "../genteeapi/gentee.h"

puint optiused;

void STDCALL geopti_var( pvartype var )
{
   ge_getused( var->type );

   if ( var->flag & VAR_OFTYPE )
      ge_getused( var->oftype );
}

void STDCALL geopti_varlist( pvartype pvar, uint count )
{
   uint i;

   for ( i = 0; i < count; i++ )
      geopti_var( pvar++ );
}

void STDCALL ge_getused( uint id )
{
   puint     ptr, end;
   povmbcode bcode;
   povmtype  ptype;
   pvmobj    pvmo;
   uint      cmd, i, k, count = 0;

   if ( id < KERNEL_COUNT || optiused[ id ] )
      return;
   optiused[ id ] = 1;
   pvmo = ( pvmobj )PCMD( id );

   if ( pvmo->type == OVM_BYTECODE )
   {  
      bcode = ( povmbcode )pvmo;
      geopti_var( bcode->vmf.ret );
      geopti_varlist( bcode->vmf.params, bcode->vmf.parcount );

      for ( i = 0; i < bcode->setcount; i++ )
         count += bcode->sets[i].count;
      geopti_varlist( bcode->vars, count );

      ptr = ( puint )bcode->vmf.func;
      if ( !ptr )
         return;

      end = ( puint )( ( pubyte )ptr + bcode->bcsize );
      while ( ptr < end )
      {
         cmd = *ptr++;
         if ( cmd < CNop || cmd >= CNop + STACK_COUNT )
         {
            if ( cmd >= KERNEL_COUNT )
               ge_getused( cmd );
            continue;
         }

         switch ( cmd )
         {
            case CQwload:
               ptr += 2;
               break;
            case CDwload:
               ptr++;
               break;
            case CDwsload:
               i = *ptr++;
               for ( k = 0; k < i; k++ )
                  ge_getused( ptr[k] & 0xFFFFFF );
               ptr += i;
               break;
            case CAsm:
               i = *ptr++;
               ptr += i;
               break;
            case CResload:
            case CCmdload:
            case CPtrglobal:
               ge_getused( *ptr++ );
               break;
            case CDatasize:
               i = *ptr++;
               ptr += ( i >> 2 ) + ( i & 3 ? 1 : 0 );
               break;
            default:
               switch ( shifts[ cmd - CNop ] )
               {
                  case SH1_3:
                  case SH2_3:
                     ptr++;
                  case SHN1_2:
                  case SH0_2:
                  case SH1_2:
                     ptr++;
                     break;
               }
         }
      }
   }
   if ( pvmo->type == OVM_EXFUNC )
   {
      geopti_var( (( povmfunc )pvmo)->vmf.ret );
      geopti_varlist( (( povmfunc )pvmo)->vmf.params, 
                      (( povmfunc )pvmo)->vmf.parcount );
   
      if ( pvmo->flag & GHEX_IMPORT )
         ge_getused( (( povmfunc )pvmo)->import );
   }
   if ( pvmo->type == OVM_TYPE )
   {
      ptype = ( povmtype )pvmo;

      if ( pvmo->flag & GHTY_INHERIT )
         ge_getused( ptype->inherit );

      if ( pvmo->flag & GHTY_INDEX )
      {
         ge_getused( ptype->index.type );
         ge_getused( ptype->index.oftype );
      }
      if ( pvmo->flag & GHTY_INITDEL )
      {
         ge_getused( ptype->ftype[ FTYPE_INIT ] );
         ge_getused( ptype->ftype[ FTYPE_DELETE ] );
      }
      if ( pvmo->flag & GHTY_EXTFUNC )
      {
         ge_getused( ptype->ftype[ FTYPE_OFTYPE ] );
         ge_getused( ptype->ftype[ FTYPE_COLLECTION ] );
      }
      if ( pvmo->flag & GHTY_ARRAY )
      {
         i = 0;
         while ( ptype->ftype[ FTYPE_ARRAY + i ] )
            i++;
         ge_getused( i == 1 ? ptype->ftype[ FTYPE_ARRAY ] : i );
         if ( i > 1 )
            for ( k = 0; k < i; k++ )
               ge_getused( ptype->ftype[ FTYPE_ARRAY + k ] );
      }
      geopti_varlist( ptype->children, ptype->count );
   }
   if ( pvmo->type == OVM_GLOBAL )
      geopti_var( (( povmglobal )pvmo)->type );
}

void STDCALL ge_optimize( void )
{
   uint i, count, main = 0;
   pvmobj pvmo;
   pubyte cur;
   
   count = arr_count( &_vm.objtbl );
   // Deletes ALIAS and DEFINE
   for ( i = KERNEL_COUNT; i < count ; i++ )
   {
      pvmo = ( pvmobj )PCMD( i );
      if ( pvmo->flag & GHRT_SKIP )
         continue;
      switch ( pvmo->type )
      {
         case OVM_DEFINE:
            if ( _compile->popti->flag & OPTI_DEFINE )
               pvmo->flag |= GHRT_SKIP;
            break;
         case OVM_ALIAS:
            pvmo->flag |= GHRT_SKIP;
            break;
      }
   }
   if ( !( _compile->popti->flag & OPTI_AVOID ))
      return;
   optiused = mem_allocz( count * sizeof( uint ));
   for ( i = KERNEL_COUNT; i < count; i++ )
   {
      pvmo = ( pvmobj )PCMD( i );

      if ( pvmo->name )
      {
         cur = _compile->popti->avoidon;
         while ( *cur )
         {
            if ( ptr_wildcardignore( pvmo->name, cur ))
            {
               ge_getused( i );
               break;
            }
            cur += mem_len( cur ) + 1;
         }
      }

      if ( pvmo->type == OVM_BYTECODE || pvmo->type == OVM_EXFUNC )
         if ( pvmo->flag & GHBC_ENTRY )
            ge_getused( i );
         else
            if ( pvmo->flag & GHBC_MAIN )
               if ( _compile->popti->flag & OPTI_MAIN )
                  main = i;
               else
                  ge_getused( i );
   }
   if ( main )
      ge_getused( main );

   for ( i = KERNEL_COUNT; i < count ; i++ )
   {
      pvmo = ( pvmobj )PCMD( i );
      if ( !optiused[ i ] )
         pvmo->flag |= GHRT_SKIP;
   }

   mem_free( optiused );
}

#endif
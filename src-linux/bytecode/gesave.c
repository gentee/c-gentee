/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gesave 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: 
* 
******************************************************************************/
#ifndef RUNTIME

#include "ge.h"
#include "../genteeapi/gentee.h"
#include "../vm/vmload.h"
#include "../vm/vmres.h"
#include "../common/crc.h"
#include "../bytecode/bytecode.h"

pbuf  gesave;
uint  gesaveoff;
puint gecodes;

void STDCALL gesave_addubyte( uint val )
{
   buf_appendch( gesave, ( ubyte )val );
}

void STDCALL gesave_adduint( uint val )
{
	buf_appenduint( gesave, val );
}

void STDCALL gesave_addushort( uint val )
{
	buf_appendushort( gesave, ( ushort )val );
}

void STDCALL gesave_add2uint( uint val1, uint val2 )
{
   gesave_adduint( val1 );
   gesave_adduint( val2 );
}

void STDCALL gesave_addptr( pubyte data )
{
   buf_append( gesave, data, mem_len( data ) + 1 );
}

void STDCALL gesave_adddata( pubyte data, uint size )
{
   buf_append( gesave, data, size );
}

//--------------------------------------------------------------------------

uint  STDCALL gesave_bwdi( uint val )
{
   if ( val <= 187 )
      gesave_addubyte( val );
   else
      if ( val < 16830 ) // 0xFF *( 253 - 188 ) + 0xFF
      {
         gesave_addubyte( 188 + val / 0xFF );
         gesave_addubyte( val % 0xFF );
      }
      else
         if ( val > MAX_USHORT )
         {
            gesave_addubyte( MAX_BYTE );
            gesave_adduint( val );
         }
         else
         {
            gesave_addubyte( MAX_BYTE - 1 );
            gesave_addushort( val );
         }
   return val;
}

//--------------------------------------------------------------------------

uint  STDCALL gesave_bwdc( uint val )
{
   if ( val >= KERNEL_COUNT && !gecodes[ val ] )
   {
      print("GESAVE ERROR %i\n", val );
      os_getchar();
   }
   return gesave_bwdi( val >= KERNEL_COUNT ? gecodes[ val ] : val );
}

//--------------------------------------------------------------------------

uint  STDCALL gesave_cmdflag( uint val )
{
   uint flag = val & 0xFF000000;
   val &= 0xFFFFFF;
   if ( val >= KERNEL_COUNT )
   {
      if ( !gecodes[ val ] )
      {
         print("GESAVE ERROR %i\n", val );
         os_getchar();
      }
      else
         val = gecodes[ val ];
   }
   gesave_adduint( val | flag );
   return val | flag;
}

void STDCALL gesave_head( uint type, pubyte name, uint flag )
{
   uint   ok = 0;
   pubyte cur; 
   gesaveoff = buf_len( gesave );

   flag &= 0xFFFFFF;

   if ( name && name[0] )
      flag |= GHCOM_NAME;
   else
      flag &= ~GHCOM_NAME;
   
   if ( flag & GHCOM_NAME && _compile->flag & CMPL_OPTIMIZE &&
              _compile->popti->flag & OPTI_NAME )
   {
      cur = _compile->popti->nameson;
      while ( *cur )
      {
         if ( ptr_wildcardignore( name, cur ))
         {
            ok = 1;
            break;
         }
         cur += mem_len( cur ) + 1;
      }
      if ( !ok )
         flag &= ~GHCOM_NAME;
   }
   flag |= GHCOM_PACK;

   gesave_addubyte( type );
   gesave_adduint( flag );
   // The size will be inserted in gesave_finish
   // Now add just one byte
   gesave_addubyte( 0 );

   if ( flag & GHCOM_NAME )
      gesave_addptr( name );
}

void STDCALL gesave_finish( void )
{
   buf  bt;
   pbuf pb = gesave;
   uint size = buf_len( pb ) - gesaveoff;

   if ( size <= 187 )
      *( pubyte )(( pubyte )buf_ptr( gesave ) + gesaveoff + 5 ) = ( ubyte )size;
   else
   {
      buf_init( &bt );
      gesave = &bt;
      if ( size < 16800 )
      {
         size++;
         gesave_bwdi( size );
      }
      else
         if ( size < 0xFFF0 ) 
         {
            gesave_addubyte( 0xFE );
            size += 2;
            gesave_addushort( size );
         }
         else
         {
            gesave_addubyte( 0xFF );
            size += 4;
            gesave_adduint( size );
         }
      // Write the size
      // We have already had one byte, so -1
      buf_insert( pb, gesaveoff + 5, ( pubyte )&size /*any*/, buf_len( gesave ) - 1 );
      mem_copy( buf_ptr( pb ) + gesaveoff + 5, buf_ptr( gesave ), buf_len( gesave ));

      buf_delete( &bt );
      gesave = pb;
   }
}

void STDCALL gesave_var( pvartype var )
{
   uint      i;
   povmtype  ptype;
   pubyte    ptr;

   gesave_bwdc( var->type );

   if ( _compile->flag & CMPL_OPTIMIZE &&
           _compile->popti->flag & OPTI_NAME )
      var->flag &= ~VAR_NAME;

   gesave_addubyte( var->flag );

   if ( var->flag & VAR_NAME )
      gesave_addptr( var->name );

   if ( var->flag & VAR_OFTYPE )
      gesave_bwdc( var->oftype );

   if ( var->flag & VAR_DIM )
   {
      gesave_addubyte( var->dim );
      for ( i = 0; i < var->dim; i++ )
         gesave_bwdi( var->ptr[i] );
   }
   if ( var->flag & VAR_DATA )
   {
      ptr = ( pubyte )( var->ptr + var->dim );
      ptype = ( povmtype )PCMD( var->type );
      if ( ptype->vmo.flag & GHTY_STACK )
         i = ptype->size;
      else
         if ( var->type == TStr )
            i = mem_len( ptr ) + 1;
         else
         {
            i = *( puint )ptr;
            ptr += sizeof( uint );
//            gesave_adduint( i );
            gesave_bwdi( i );   // save data size as bwd
         }
      gesave_adddata( ptr, i );
   }
}

void STDCALL gesave_varlist( pvartype pvar, uint count )
{
   uint i;

   gesave_bwdi( count );
   for ( i = 0; i < count; i++ )
      gesave_var( pvar++ );
}

void STDCALL gesave_resource( void )
{
   uint     i, count;
   pcollect pres;

   pres = &_vm.resource;

   gesave_head( OVM_RESOURCE,(pubyte) "", 0 );
   
   count = collect_count( pres );
   gesave_bwdi( count );
   for ( i = 0; i < count; i++ )
   {
      gesave_bwdc( collect_gettype( pres, i ));
      gesave_addptr( str_ptr( vmres_getstr( i )) );
//      print("str=%s\n", str_ptr( vmres_getstr( i )) );
   }
   gesave_finish();
}

void STDCALL gesave_bytecode( povmbcode bcode )
{
   pvartype  pvar;
   uint      i, count = 0, cmd, val, k;
   puint     end, ptr;

   gesave_var( bcode->vmf.ret );
   gesave_varlist( bcode->vmf.params, bcode->vmf.parcount );

   gesave_bwdi( bcode->setcount );
   for ( i = 0; i < bcode->setcount; i++ )
   {
      gesave_bwdi( bcode->sets[i].count );
      count += bcode->sets[i].count;
   }
   pvar = bcode->vars;
   for ( i = 0; i < count; i++ )
      gesave_var( pvar++ );

   ptr = ( puint )bcode->vmf.func;
   if ( ptr )
   {
      end = ( puint )( ( pubyte )ptr + bcode->bcsize );
      while ( ptr < end )
      {
         cmd = gesave_bwdc( *ptr++ );
         if ( cmd >= CNop && cmd < CNop + STACK_COUNT )
            switch ( cmd  )
            {
               case CQwload:
                  gesave_adduint( *ptr++ );
                  gesave_adduint( *ptr++ );
                  break;
               case CDwload:
                  val = *ptr++;
                  if ( val <= 0xFF )
                  {
                     buf_ptr( gesave )[ buf_len( gesave ) - 1 ] = CByload;
                     gesave_addubyte( val );
                  }
                  else
                     if ( val <= 0xFFFF )
                     {
                        buf_ptr( gesave )[ buf_len( gesave ) - 1 ] = CShload;
                        gesave_addushort( val );
                     }
                     else
                        gesave_adduint( val );
                  break;
               case CDwsload:
                  i = gesave_bwdi( *ptr++ ); 
                  for ( k = 0; k < i; k++ )
                     gesave_cmdflag( *ptr++ );
                  break;
               case CAsm:
                  i = gesave_bwdi( *ptr++ );
                  gesave_adddata( ( pubyte )ptr, i << 2 );
                  ptr += i;
                  break;
               case CResload:
               case CCmdload:
               case CPtrglobal:
                  gesave_bwdc( *ptr++ );
                  break;
               case CDatasize:
                  i = gesave_bwdi( *ptr++ );
                  gesave_adddata( ( pubyte )ptr, i );
                  ptr += ( i >> 2 ) + ( i & 3 ? 1 : 0 );
                  break;
               default:
                  switch ( shifts[ cmd - CNop ] )
                  {
                     case SH1_3:
                     case SH2_3:
                        cmd = gesave_bwdi( *ptr++ );
                     case SHN1_2:
                     case SH0_2:
                     case SH1_2:
                        cmd = gesave_bwdi( *ptr++ );
                        break;
                  }
            }
      }
   }
}

void STDCALL gesave_exfunc( povmfunc exfunc )
{
   gesave_var( exfunc->vmf.ret );
   gesave_varlist( exfunc->vmf.params, exfunc->vmf.parcount );
   
   if ( exfunc->vmf.vmo.flag & GHEX_IMPORT )
   {
      gesave_bwdc( exfunc->import );
      gesave_addptr( exfunc->original );
   }
}

void STDCALL gesave_import( povmimport import )
{
   gesave_addptr( import->filename );
   if ( import->vmo.flag & GHIMP_LINK )
   {
      gesave_adduint( import->size );
      gesave_adddata( import->data, import->size );
   }
}

void STDCALL gesave_type( povmtype ptype )
{
   uint      i, k;
   uint      flag = ptype->vmo.flag;

   if ( flag & GHTY_INHERIT )
      gesave_bwdc( ptype->inherit );

   if ( flag & GHTY_INDEX )
   {
      gesave_bwdc( ptype->index.type );
      gesave_bwdc( ptype->index.oftype );
   }
   if ( flag & GHTY_INITDEL )
   {
      gesave_bwdc( ptype->ftype[ FTYPE_INIT ] );
      gesave_bwdc( ptype->ftype[ FTYPE_DELETE ] );
   }
   if ( flag & GHTY_EXTFUNC )
   {
      gesave_bwdc( ptype->ftype[ FTYPE_OFTYPE ] );
      gesave_bwdc( ptype->ftype[ FTYPE_COLLECTION ] );
   }
   if ( flag & GHTY_ARRAY )
   {
      i = 0;
      while ( ptype->ftype[ FTYPE_ARRAY + i ] )
         i++;
      gesave_bwdc( i == 1 ? ptype->ftype[ FTYPE_ARRAY ] : i );
      if ( i > 1 )
         for ( k = 0; k < i; k++ )
            gesave_bwdc( ptype->ftype[ FTYPE_ARRAY + k ] );
   }
   gesave_varlist( ptype->children, ptype->count );
}

void STDCALL gesave_define( povmdefine pdefine )
{
   gesave_varlist( pdefine->macros, pdefine->count );
}

uint STDCALL ge_save( pbuf out )
{
   gehead   head;
   pgehead  phead;
   uint     i, count, off = 0;
   pvmobj   pvmo;
   gesave = out;
   buf_reserve( out, 0x1ffff );

   if ( _compile->flag & CMPL_OPTIMIZE )
      ge_optimize();

   *( puint )&head.idname = GE_STRING;//0x00004547;   // строка GE
   head.flags = 0;
   head.crc = 0;
   head.headsize = sizeof( gehead );
   head.size = 0;
   head.vermajor = GEVER_MAJOR; 
   head.verminor = GEVER_MINOR; 
   
   buf_append( out, ( pubyte )&head, sizeof( gehead ));
   // Save resources at the first !
   gesave_resource();

   count = arr_count( &_vm.objtbl );
   // Settings new id depending on GHRT_SKIP
   gecodes = ( puint )mem_alloc( count * sizeof( uint ));
   for ( i = KERNEL_COUNT; i < count ; i++ )
   {
      pvmo = ( pvmobj )PCMD( i );
      if ( pvmo->flag & GHRT_SKIP )
      {
         gecodes[ i ] = 0;   
         off++;
      }
      else
         gecodes[ i ] = i - off;
   }
   for ( i = KERNEL_COUNT; i < count ; i++ )
   {
      pvmo = ( pvmobj )PCMD( i );
      if ( pvmo->flag & GHRT_SKIP )
         continue;
//      print("i=%i name=%s\n", i, ((pvmobj)PCMD( i ))->name );
      gesave_head( pvmo->type, pvmo->flag & GHCOM_NAME ? 
                pvmo->name : NULL, pvmo->flag );

      switch ( pvmo->type )
      {
         case OVM_NONE:
            break;
         case OVM_BYTECODE:
            gesave_bytecode( ( povmbcode )pvmo );
            break;
         case OVM_EXFUNC:
            gesave_exfunc( ( povmfunc )pvmo );
            break;
         case OVM_TYPE:
            gesave_type( ( povmtype )pvmo );
            break;
         case OVM_GLOBAL:
            gesave_var( (( povmglobal )pvmo)->type );
            break;
         case OVM_DEFINE:
            gesave_define( ( povmdefine )pvmo );
            break;
         case OVM_IMPORT:
            gesave_import( ( povmimport )pvmo );
            break;
         case OVM_ALIAS:
            gesave_bwdc( (( povmalias )pvmo)->idlink );
            break;
      }
      gesave_finish();
   }
   mem_free( gecodes );
   // Specify the full size and crc
   phead = ( pgehead )buf_ptr( out );
   phead->size = buf_len( out );
   phead->crc = crc( ( pubyte )phead + 12, phead->size - 12, 0xFFFFFFFF );

   return 1;
}

#endif
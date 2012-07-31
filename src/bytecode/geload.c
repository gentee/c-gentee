/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: geload 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: 
* 
******************************************************************************/

#include "ge.h"
#include "../vm/vmload.h"
#include "../vm/vmres.h"
#include "../vm/vmmanage.h"
#include "../common/crc.h"

void  STDCALL load_none( void )
{
   pvmobj pvmo = ( pvmobj )vmmng_begin( sizeof( vmobj ));

   load_addobj( 0 );
   vmmng_end( ( pubyte )( pvmo + 1 ));
}

void STDCALL load_resource( pubyte* in )
{
   uint count, i, type;

   *in += 5;
   count = load_bwd( in ); // skip size
   count = load_bwd( in );
   _vm.irescnv = collect_count( &_vm.resource );

   for ( i = 0; i < count; i ++ )
   {
      type = load_convert( in );
      if ( type == TStr )
      {
         vmres_addstr( *in );
//         print("OK=%s %i\n", *in, _vm.rescnv[ i ] );
         *in += mem_len( *in ) + 1;
      }
   }
}

uint STDCALL ge_load( pbuf in )
{
   pubyte   cur, end, ptemp;
   uint     size;
   pgehead  phead = ( pgehead )buf_ptr( in );

   // Проверка заголовка и целостности
   // Сравниваем с 'GE' с двумя нулями на конце

   if ( *( puint )phead != GE_STRING )//0x00004547 )
      msg( MNotGE | MSG_EXIT );
   if ( phead->crc != crc( ( pubyte )phead + 12, phead->size - 12, 0xFFFFFFFF ))
      msg( MCrcGE | MSG_EXIT );
   if ( phead->vermajor != GEVER_MAJOR || phead->verminor > GEVER_MINOR )
      msg( MVerGE | MSG_EXIT );

   _vm.loadmode = VMLOAD_GE;
   _vm.icnv = arr_count( &_vm.objtbl ) - KERNEL_COUNT;
//   print("icnv=%i\n", _vm.icnv );
   cur = ( pubyte )phead + phead->headsize;
   end = ( pubyte )phead + phead->size;
   while ( cur < end )
   {
      ptemp = cur + 5; // type + flag
      _vm.ipack = ( *( puint )( cur + 1 )) & GHCOM_PACK ? 1 : 0;

      size = load_bwd( &ptemp );
      ptemp = cur;
//      print("size=%i type=%i flag = %x\n", size, *cur, *( puint )( cur + 1 ) );
      switch ( *cur )
      {
         case OVM_NONE:
            load_none();
            break;
         case OVM_BYTECODE:
            load_bytecode( &cur, VMLOAD_GE );
            break;
         case OVM_EXFUNC:
            load_exfunc( &cur, 0 );
            _vm.loadmode = VMLOAD_GE;
            break;
        case OVM_TYPE:
            load_type( &cur );
            break;
        case OVM_GLOBAL:
            load_global( &cur );
            break;
        case OVM_DEFINE:
            load_define( &cur );
            break;
        case OVM_IMPORT:
            load_import( &cur );
            break;
         case OVM_RESOURCE:
            load_resource( &cur );
            break;
         case OVM_ALIAS:
            load_alias( &cur );
            break;
         default: 
            msg( MUnkGE | MSG_DVAL, cur - ( pubyte )phead );
      }
      cur = ptemp + size;
   }
   _vm.loadmode = VMLOAD_G;
   _vm.icnv  = 0;
   return 1;
}
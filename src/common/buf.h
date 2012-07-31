/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: buf 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
* Summary: This file provides functionality for 'buf' type.
*
******************************************************************************/

#ifndef _BUF_
#define _BUF_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus  

#include "memory.h"

typedef struct
{
   pubyte    data;      // Pointer to the allocated memory
   uint      use;       // Using size
   uint      size;      // All available size
   uint      step;      // The minimum step of the increasing
} buf, * pbuf;

//--------------------------------------------------------------------------

pbuf   STDCALL buf_add( pbuf pb, pbuf src );
pbuf   STDCALL buf_alloc( pbuf pb, uint size );
pbuf   STDCALL buf_array( pbuf pb, uint count );
pbuf   STDCALL buf_clear( pbuf pb );
pbuf   STDCALL buf_free( pbuf pb );
pbuf   STDCALL buf_del( pbuf pb, uint off, uint size );
uint   STDCALL buf_isequal( pbuf left, pbuf right );
pbuf   STDCALL buf_append( pbuf pb, pubyte src, uint size );
pubyte STDCALL buf_appendtype( pbuf pb, uint size );
pbuf   STDCALL buf_appendch( pbuf pb, ubyte val );
pbuf   STDCALL buf_appenduint( pbuf pb, uint val );
pbuf   STDCALL buf_appendulong( pbuf pb, ulong64 val );
pbuf   STDCALL buf_appendushort( pbuf pb, ushort val );
pbuf   STDCALL buf_copy( pbuf pb, pubyte src, uint size );
pbuf   STDCALL buf_copyzero( pbuf pb, pubyte src );
void   STDCALL buf_delete( pbuf pb );
pbuf   STDCALL buf_expand( pbuf pb, uint size );
uint   STDCALL buf_find( pbuf ps, uint offset, ubyte symbol );
uint   STDCALL buf_findsh( pbuf ps, uint offset, ushort val );
pubyte STDCALL buf_index( pbuf pb, uint index );
pbuf   STDCALL buf_init( pbuf pb );
pbuf   STDCALL buf_insert( pbuf pb, uint off, pubyte data, uint size );
uint   STDCALL buf_len( pbuf pb );
pubyte STDCALL buf_ptr( pbuf pb );
pbuf   STDCALL buf_reserve( pbuf pb, uint size );
pbuf   STDCALL buf_setlen( pbuf pb, uint size );
pbuf   STDCALL buf_set( pbuf pb, pbuf src );
//pbuf   STDCALL buf_subbuf( pbuf dest, pbuf src, uint off, uint len );

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _BUF_

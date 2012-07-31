/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gentee 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov
* Contributors: SWR
*
* Summary: 
*
******************************************************************************/

#ifndef _COMMON_H_
#define _COMMON_H_

   #ifdef __cplusplus
      extern "C" {
   #endif // __cplusplus
#include "types.h"

#define MEM_EDGE       0xFFFF     // Alloc from heap if the memory size 
                                  // is less or equal than MEM_EDGE 
#define MEM_HEAPSIZE   0x40000    // The minimum size of the heap


/*--------------------------------------------------------------------------
The each memory block begins two bytes.
1. The number of heap ( from 0 to MAX_BYTE ). 
2. The id of block size. The block doesn't belong to any heap if it equals 
MAX_BYTE. 
If the block is free then it contains the next free block with the same id.
*/
//--------------------------------------------------------------------------

pvoid  STDCALL mem_alloc( pvmEngine pThis, uint size );
pvoid  STDCALL mem_copy( pvmEngine pThis, pvoid dest, pvoid src, uint len );
uint   STDCALL mem_copyuntilzero( pvmEngine pThis, pubyte dest, pubyte src  );
uint   STDCALL mem_deinit( pvmEngine pThis );
uint   STDCALL mem_free( pvmEngine pThis, pvoid ptr );
uint   STDCALL mem_getsize( pvmEngine pThis, pvoid ptr );
uint   STDCALL mem_init( pvmEngine pThis );
uint   STDCALL mem_len( pvmEngine pThis, pvoid data );
void   STDCALL mem_move( pvmEngine pThis, pvoid dest, pvoid src, uint len );
pvoid  STDCALL mem_zero( pvmEngine pThis, pvoid dest, uint len );
void   STDCALL mem_zeroui( pvmEngine pThis, puint dest, uint len );
int    STDCALL mem_cmp( pvmEngine pThis, pvoid dest, pvoid src, uint len );



//--------------------------------------------------------------------------

pbuf   STDCALL buf_alloc( pvmEngine pThis, pbuf pb, uint size );

pbuf   STDCALL buf_append( pvmEngine pThis, pbuf pb, pubyte src, uint size );
pbuf   STDCALL buf_appendch( pvmEngine pThis, pbuf pb, ubyte val );
pbuf   STDCALL buf_appenduint( pvmEngine pThis, pbuf pb, uint val );
pbuf   STDCALL buf_appendushort( pvmEngine pThis, pbuf pb, ushort val );
pbuf   STDCALL buf_copy( pvmEngine pThis, pbuf pb, pubyte src, uint size );
pbuf   STDCALL buf_copyzero( pvmEngine pThis, pbuf pb, pubyte src );
void   STDCALL buf_delete( pvmEngine pThis, pbuf pb );
pbuf   STDCALL buf_expand( pvmEngine pThis, pbuf pb, uint size );
pbuf   STDCALL buf_init( pvmEngine pThis, pbuf pb );
pbuf   STDCALL buf_insert( pvmEngine pThis, pbuf pb, uint off, pubyte data, uint size );
uint   STDCALL buf_len( pvmEngine pThis, pbuf pb );
pubyte STDCALL buf_ptr( pvmEngine pThis, pbuf pb );
pbuf   STDCALL buf_reserve( pvmEngine pThis, pbuf pb, uint size );
pbuf   STDCALL buf_setlen( pvmEngine pThis, pbuf pb, uint size );

//--------------------------------------------------------------------------

pvoid  STDCALL arr_append( pvmEngine pThis, parr pa );
uint   STDCALL arr_appenditems( pvmEngine pThis, parr pa, uint count );
void   STDCALL arr_appendnum( pvmEngine pThis, parr pa, uint val );
uint   STDCALL arr_count( pvmEngine pThis, parr pa );
uint   STDCALL arr_getuint( pvmEngine pThis, parr pa, uint num );
void   STDCALL arr_init( pvmEngine pThis, parr pa, uint size );
void   STDCALL arr_delete( pvmEngine pThis, parr pa );
pvoid  STDCALL arr_ptr( pvmEngine pThis, parr pa, uint num );
void   STDCALL arr_reserve( pvmEngine pThis, parr pa, uint count );
void   STDCALL arr_setuint( pvmEngine pThis, parr pa, uint num, uint value );
void   STDCALL arr_step( pvmEngine pThis, parr pa, uint count );

/*-----------------------------------------------------------------------------
*
* ID: strtrimflags 19.10.06 0.0.A.
* 
* Summary: Flags for str_trim
*
-----------------------------------------------------------------------------*/

#define TRIM_ONE    0x0001   // Delete just one character
#define TRIM_RIGHT  0x0002   // Trim the right characters

//--------------------------------------------------------------------------

#define str_delete   buf_delete
#define str_ptr( x ) ( x )->data
#define str_reserve  buf_reserve

pstr  STDCALL str_copyzero( pvmEngine pThis, pstr ps, pubyte src );
pstr  STDCALL str_copy( pvmEngine pThis, pstr dest, pstr src );
pstr  STDCALL str_init( pvmEngine pThis, pstr ps );
uint  STDCALL str_len( pvmEngine pThis, pstr ps );
pstr  STDCALL str_setlen( pvmEngine pThis, pstr ps, uint len );
pstr  STDCALL str_new( pvmEngine pThis, pubyte ptr );

//--------------------------------------------------------------------------

puint    STDCALL collect_add( pvmEngine pThis, pcollect pclt, puint input, uint type );
pubyte   STDCALL collect_addptr( pvmEngine pThis, pcollect pclt, pubyte ptr );
pubyte   STDCALL collect_index( pvmEngine pThis, pcollect pclt, uint index );
uint     STDCALL collect_gettype( pvmEngine pThis, pcollect pclt, uint index );
uint     STDCALL collect_count( pvmEngine pThis, pcollect pclt );
void     STDCALL collect_delete( pvmEngine pThis, pcollect pclt );

//--------------------------------------------------------------------------

#define HASH_SIZE 4096
phashitem  STDCALL hash_create( pvmEngine pThis, phash ph, pubyte name );
void       STDCALL hash_init( pvmEngine pThis, phash ph, uint size );
void       STDCALL hash_delete( pvmEngine pThis, phash ph );


//--------------------------------------------------------------------------

void  STDCALL crc_init( pvmEngine pThis );
uint  STDCALL crc( pvmEngine pThis, pubyte data, uint size, uint seed );

//--------------------------------------------------------------------------

pbuf  STDCALL file2buf( pvmEngine pThis, pstr name, pbuf ret, uint pos );
uint  STDCALL buf2file( pvmEngine pThis, pstr name, pbuf ret );

#include "windows.h"
#include <stdio.h>
#include <conio.h>


#define os_alloc      malloc
#define os_free       free

#define os_crlsection_delete DeleteCriticalSection
#define os_crlsection_enter  EnterCriticalSection
#define os_crlsection_init   InitializeCriticalSection
#define os_crlsection_leave  LeaveCriticalSection 

uint     STDCALL os_fileclose( uint handle );
pstr     STDCALL os_filefullname( pvmEngine pThis, pstr filename, pstr result );
uint     STDCALL os_fileopen( pstr name, uint flag );
uint     STDCALL os_fileread( uint handle, pubyte data, uint size );
ulong64  STDCALL os_filesize( uint handle );
uint     STDCALL os_filewrite( uint handle, pubyte data, uint size );

   #ifdef __cplusplus
      }
   #endif // __cplusplus

#endif // _COMMON_H_

/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: collection 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

#ifndef _COLLECTION_
#define _COLLECTION_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "buf.h"

//--------------------------------------------------------------------------

typedef struct
{
   buf       data;       
   uint      count;   // The number of items
   uint      flag;    // дыруш
//   uint      ifor;    // The number of the current item foreach
//   uint      pfor;    // The offset of the current item foreach
//   uint      owner;   // The collection is an owner of its items
} collect, * pcollect;

puint    STDCALL collect_add( pcollect pclt, puint input, uint type );
pubyte   STDCALL collect_addptr( pcollect pclt, pubyte ptr );
pubyte   STDCALL collect_index( pcollect pclt, uint index );
uint     STDCALL collect_gettype( pcollect pclt, uint index );
pubyte   STDCALL collect_copy( pcollect pclt, pubyte data );
uint     STDCALL collect_count( pcollect pclt );
void     STDCALL collect_delete( pcollect pclt );

/*
pvoid  STDCALL arr_append( parr pa );
uint   STDCALL arr_appenditems( parr pa, uint count );
void   STDCALL arr_appendnum( parr pa, uint val );
pvoid  STDCALL arr_appendzero( parr pa );
void   STDCALL arr_clear( parr pa );
uint   STDCALL arr_count( parr pa );
uint   STDCALL arr_getlast( parr pa );
uint   STDCALL arr_getuint( parr pa, uint num );
void   STDCALL arr_init( parr pa, uint size );
void   STDCALL arr_delete( parr pa );
uint   STDCALL arr_pop( parr pa );
pvoid  STDCALL arr_ptr( parr pa, uint num );
void   STDCALL arr_reserve( parr pa, uint count );
void   STDCALL arr_setuint( parr pa, uint num, uint value );
void   STDCALL arr_step( parr pa, uint count );
pvoid  STDCALL arr_top( parr pa );

pgarr  STDCALL  garr_init( pgarr pga );
void   STDCALL  garr_del( pgarr pga, uint from, uint number );
void   STDCALL  garr_delete( pgarr pga );
pgarr  STDCALL  garr_expand( pgarr pga, uint count );
pgarr  STDCALL  garr_insert( pgarr pga, uint from, uint number );
uint   STDCALL  garr_count( pgarr pga );
pgarr  STDCALL  garr_oftype( pgarr pga, uint itype );
pgarr  STDCALL  garr_array( pgarr pga, uint first );
pgarr  STDCALL  garr_array2( pgarr pga, uint first, uint second );
pgarr  STDCALL  garr_array3( pgarr pga, uint first, uint second, uint third );
pubyte STDCALL  garr_index( pgarr pga, uint first );
pubyte STDCALL  garr_index2( pgarr pga, uint first, uint second );
pubyte STDCALL  garr_index3( pgarr pga, uint first, uint second, uint third );
*/


//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _COLLECTION_


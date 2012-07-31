/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: arr 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

#ifndef _ARR_
#define _ARR_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "buf.h"

//--------------------------------------------------------------------------

typedef struct
{
   buf     data;   
   uint    isize;  // The size of the item
   ubyte   isobj;  // Each item is a memory block
} arr, * parr;

typedef struct
{
   buf     data;   
   uint    itype;  // The type of items
   uint    isize;  // The size of the item
//   uint    ifor;   // For foreach
   uint    dim[ MAX_MSR ];  // Dimensions
} garr, * pgarr;

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
pgarr  STDCALL  garr_del( pgarr pga, uint from, uint number );
void   STDCALL  garr_delete( pgarr pga );
uint   STDCALL  garr_expand( pgarr pga, uint count );
uint   STDCALL  garr_insert( pgarr pga, uint from, uint number );
uint   STDCALL  garr_count( pgarr pga );
void   STDCALL  garr_oftype( pgarr pga, uint itype );
void   STDCALL  garr_array( pgarr pga, uint first );
void   STDCALL  garr_array2( pgarr pga, uint first, uint second );
void   STDCALL  garr_array3( pgarr pga, uint first, uint second, uint third );
pubyte STDCALL  garr_index( pgarr pga, uint first );
pubyte STDCALL  garr_index2( pgarr pga, uint first, uint second );
pubyte STDCALL  garr_index3( pgarr pga, uint first, uint second, uint third );



//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _ARR_


/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: str 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
* Summary: This file provides functionality for 'str' type.
*
******************************************************************************/

#ifndef _STR_
#define _STR_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus  

#include <stdio.h>
#include <stdarg.h>

#include "buf.h"
#ifndef NOGENTEE
#include "collection.h"
#endif

typedef buf str;
typedef str * pstr;

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
#define str_expand   buf_expand
#define str_reserve  buf_reserve
#define str_isequal  buf_isequal
#define str_index    buf_index

uint  STDCALL ptr_wildcardignore( pubyte src, pubyte mask );

pstr  STDCALL str_add( pstr dest, pstr src );
pstr  STDCALL str_appenduint( pstr pb, uint val );
pstr  STDCALL str_clear( pstr ps );
pstr  STDCALL str_copyzero( pstr ps, pubyte src );
pstr  STDCALL str_copy( pstr dest, pstr src );
pstr  STDCALL str_copylen( pstr ps, pubyte src, uint len );
pstr  STDCALL str_dirfile( pstr dir, pstr name, pstr ret );
//pstr  STDCALL str_expand( pstr ps, uint len );
pstr  STDCALL str_init( pstr ps );
uint  STDCALL str_find( pstr ps, uint offset, ubyte symbol, uint fromend );
uint  STDCALL str_findch( pstr ps, ubyte symbol );
uint  STDCALL str_len( pstr ps );
void  STDCALL str_output( pstr ps );
pstr  DLL_EXPORT CDECLCALL  str_printf( pstr ps, pubyte output, ... );
//pstr  STDCALL str_reserve( pstr ps, uint len );
pstr  STDCALL str_setlen( pstr ps, uint len );
pstr  STDCALL str_substr( pstr dest, pstr src, uint off, uint len );
pstr  STDCALL str_trim( pstr ps, uint symbol, uint flag );
void  STDCALL str_destroy( pstr ps );
pstr  STDCALL str_new( pubyte ptr );
uint  STDCALL str_getdirfile( pstr src, pstr dir, pstr name );
uint  STDCALL str_isequalign( pstr left, pstr right );
uint  DLL_EXPORT STDCALL str_pos2line( pstr ps, uint pos, puint lineoff );
pstr  STDCALL str_out4( pstr ps, pstr format, uint val );
pstr  STDCALL str_out8( pstr ps, pstr format, ulong64 val );
uint  STDCALL str_fwildcard( pstr name, pstr mask );

pstr  STDCALL str_appendpsize( pstr str, pubyte src, uint len );
pstr  STDCALL str_appendp( pstr str, pubyte src );
#ifndef NOGENTEE
pstr  STDCALL str_sprintf( pstr ps, pstr output, pcollect pclt ); 
#endif

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _STR_
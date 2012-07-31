/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project <http://www.gentee.com>. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* funclist_h 16.06.2008 0.0.A.
*
* Author: Generated with 'funclist' program
*
* Summary: This file contains a list of the embedded functions and methods.
*
******************************************************************************/

#ifndef _FUNCLIST_
#define _FUNCLIST_

   #ifdef __cplusplus
      extern "C" {
   #endif // __cplusplus

#include "../common/types.h"

#define  FUNCCOUNT  122

extern const ubyte embfuncs[];
extern const pvoid embfuncaddr[];

/*
uint getid( str name, uint flags, collection colpars )
uint type_hasinit( uint itype )
uint type_hasdelete( uint itype )
uint type_isinherit( uint itype iowner )
uint type_init( uint ptr itype )
uint type_delete( uint ptr itype )
uint sizeof( uint itype )
uint new( uint itype pdata )
destroy( uint object )
uint lex_init( plex pl, puint ptbl )
lex_delete( plex pl )
uint gentee_lex(pbuf input, plex pl, parr output)
uint gentee_compile( pcompileinfo compinit )
uint gentee_set( uint flag, uint value )
uint malloc( uint size )
uint mcopy( uint dest src size )
int mcmp( uint dest src size )
mfree( uint ptr )
uint mmove( uint dest src size )
uint mzero( uint dest size )
uint mlen( uint data )
uint mlensh( uint data )
uint getch()
uint os_scan( pubyte input, uint len )
str res_getstr( uint )
uint crc( uint ptr size sead )
int strcmp( uint left right )
int strcmpign( uint left right )
int strcmplen( uint left right len )
int strcmpignlen( uint left right len)
int ustrcmplen( uint left right len )
int ustrcmpignlen( uint left right len)
uint gentee_ptr( uint par)
uint argc()
uint argv( str ret, uint num )
uint calladdr()
void qs_init( pssearch, pubyte pattern, uint m, uint flag )
uint qs_search( pssearch psearch, pubyte y, uint n )
void fastsort( pvoid base, uint count, uint size, uint mode )
void sort( pvoid base, uint count, uint size, uint idfunc )
str  os_gettemp( )
buf buf.append( uint ptr, uint size )
buf buf.init()
buf buf.del( uint offset, uint size )
buf.delete()
buf buf.clear()
buf buf.copy( uint ptr, uint size )
buf buf.insert( uint off ptr size )
buf buf.free()
uint buf.ptr()
buf buf.load( uint ptr, uint size )
buf.array( uint index )
buf.index( uint index )
buf.reserve( uint size )
buf.expand( uint size )
*buf
buf = buf
buf += buf
buf += ubyte
buf += ushort
buf += uint
buf += ulong
buf == buf
uint buf.findch( uint off symbol )
uint buf.findsh( uint off symbol )
str str.init()
str str.load( uint ptr, uint size )
str str.copy( uint ptr )
str str.findch( uint off symbol fromend )
str str.findch( uint symbol )
uint str.fwildcard( str mask )
str.print()
print( str )
str str.setlen( uint )
str str.substr( str uint off len )
str = str
str += str
str += uint
*str
str.out4( str format, uint value )
str.out8( str format, ulong value )
reserved.index( uint index )
arr arr.init()
arr.delete()
arr.oftype( uint )
arr.array( uint first )
arr.array( uint first second )
arr.array( uint first second third )
uint arr.index( uint first )
uint arr.index( uint first second )
uint arr.index( uint first second third )
uint *( arr )
uint arr.expand( uint )
uint arr.insert( uint from count )
uint arr.del( uint from count )
uint collection.index( uint first )
uint collection.ptr( uint first )
uint collection.gettype( uint first )
uint *( collection )
str str.printf( str, collection )
double sin( double )
double cos( double )
double tan( double )
double asin( double )
double acos( double )
double atan( double )
double exp( double )
double ln( double )
double log( double )
double pow( double, double )
double sqrt( double )
uint abs( int )
double fabs( double )
double modf( double, uint )
double ceil( double )
double floor( double )
int strtol( uint ptr end base )
int strtoul( uint ptr end base )
double atof( uint ptr )
long atoi64( uint ptr )
pubyte getenv( pubyte ptr )
int setenv( pubyte ptr )

*/
   #ifdef __cplusplus
      }
   #endif // __cplusplus

#endif // _FUNCLIST_

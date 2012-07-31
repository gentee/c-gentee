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

#include "arr.h"
#include "../bytecode/cmdlist.h"
#include "../vm/vmtype.h"
//! temporary
#include "../os/user/defines.h"
#include "../genteeapi/gentee.h"

//--------------------------------------------------------------------------
// Возвращается указатель на добавленный элемент

pvoid  STDCALL arr_append( parr pa )
{
   arr_reserve( pa, 1 );

   mem_zero( buf_ptr( &pa->data ) + pa->data.use, pa->isize );
   pa->data.use += pa->isize;

   return buf_ptr( &pa->data ) + pa->data.use - pa->isize;
}

//--------------------------------------------------------------------------

uint  STDCALL arr_appenditems( parr pa, uint count )
{
   uint    size = count * pa->isize;

   arr_reserve( pa, count );

   mem_zero( buf_ptr( &pa->data ) + pa->data.use, size );
   pa->data.use += size;

//   printf("Append %i size=%i\n", pa->data.use, pa->data.size );
   return pa->data.use / pa->isize;
}

//--------------------------------------------------------------------------

void  STDCALL arr_appendnum( parr pa, uint val )
{
   *( puint )arr_append( pa ) = val;
}

//--------------------------------------------------------------------------

pvoid  STDCALL arr_appendzero( parr pa )
{
   return mem_zero( arr_append( pa ), pa->isize );
}

//--------------------------------------------------------------------------

void   STDCALL arr_clear( parr pa )
{
   buf_clear( &pa->data );
}

//--------------------------------------------------------------------------

uint  STDCALL arr_count( parr pa )
{
   return buf_len( &pa->data ) / pa->isize;
}

//--------------------------------------------------------------------------

void  STDCALL arr_delete( parr pa )
{
   puint ptr, end;

   if ( pa->isobj )
   {
      ptr = ( puint )buf_ptr( &pa->data );
      end = ( puint )(( pubyte )ptr + buf_len( &pa->data ));
      while ( ptr < end )
      {
         mem_free( ( pvoid )*ptr );
         ptr++;
      }
   }
   buf_delete( &pa->data );
}

//--------------------------------------------------------------------------

uint  STDCALL arr_getuint( parr pa, uint num )
{
   return *( puint )( buf_ptr( &pa->data ) + num * pa->isize );
}

//--------------------------------------------------------------------------

uint  STDCALL arr_getlast( parr pa )
{
   return arr_getuint( pa, arr_count( pa ) - 1 );
}

//--------------------------------------------------------------------------

void  STDCALL arr_init( parr pa, uint size )
{
   buf_init( &pa->data );
   
   pa->isobj = 0;
   if ( !size )
   {
      size = sizeof( uint );
      pa->isobj = 1;
   }
   pa->isize = size;
}

//--------------------------------------------------------------------------

uint  STDCALL arr_pop( parr pa )
{
   uint ret = arr_getlast( pa );

   pa->data.use -= pa->isize;

   return ret;
}

//--------------------------------------------------------------------------

pvoid  STDCALL arr_ptr( parr pa, uint num )
{
   return buf_ptr( &pa->data ) + num * pa->isize;
}

//--------------------------------------------------------------------------

pvoid  STDCALL arr_top( parr pa )
{
   uint  len = buf_len( &pa->data );
   if ( !len )
      return 0;
   return buf_ptr( &pa->data ) + len - pa->isize;
}

//--------------------------------------------------------------------------
// count - количество резервируемых элементов

void  STDCALL arr_reserve( parr pa, uint count )
{
   buf_expand( &pa->data, count * pa->isize );
}

//--------------------------------------------------------------------------

void   STDCALL arr_setuint( parr pa, uint num, uint value )
{
   *( puint )( buf_ptr( &pa->data ) + num * pa->isize ) = value;
}

//--------------------------------------------------------------------------
// count - количество резервируемых элементов

void  STDCALL arr_step( parr pa, uint count )
{
   pa->data.step = count * pa->isize;
}

//--------------------------------------------------------------------------

pgarr  STDCALL  garr_init( pgarr pga )
{
   pga->itype = TUint;
   pga->isize = sizeof( uint );
   return pga;
} 

/*-----------------------------------------------------------------------------
* Id: arr_del_1 FA
*
* Summary: The method removes items from the array.
*  
* Params: from - The number of the first item being deleted (from 0).
          count - The count of the items to be deleted.
*
* Return: #lng/retobj# 
*
* Define: method arr arr.del( uint from, uint count )
*
-----------------------------------------------------------------------------*/

pgarr  STDCALL  garr_del( pgarr pga, uint from, uint number )
{
   uint    count = garr_count( pga );
   pubyte  data = buf_ptr( &pga->data );
   uint    i;

   if ( from >= count )
      return pga;
   number = min( number, count - from );
   data = buf_ptr( &pga->data ) + from * pga->isize;

   if ( type_hasdelete( pga->itype ))
   {
      i = number;

      while ( i-- )
      {
         type_delete( data, pga->itype );
         data += pga->isize;
      }       
   }
   buf_del( &pga->data, from * pga->isize, number * pga->isize );

   return pga;
} 

//--------------------------------------------------------------------------

void  STDCALL  garr_delete( pgarr pga )
{
   garr_del( pga, 0, garr_count( pga ));
} 

pgarr  STDCALL  garr_clear( pgarr pga )
{
   garr_delete( pga );
   buf_free( &pga->data );

   return pga;
} 

/*-----------------------------------------------------------------------------
* Id: arr_oplen F4
* 
* Summary: Get the count of items.
*  
* Return: Count of array items.
*
* Define: operator uint *( arr left ) 
*
-----------------------------------------------------------------------------*/

uint  STDCALL  garr_count( pgarr pga )
{
   return buf_len( &pga->data ) / pga->isize;
} 

/*-----------------------------------------------------------------------------
* Id: arr_expand F2
*
* Summary: Add items to an array.
*  
* Params: count - The number of items being added.
* 
* Return: The index of the first added item.
*
* Define: method uint arr.expand( uint count )
*
-----------------------------------------------------------------------------*/

uint STDCALL garr_expand( pgarr pga, uint count )
{
   return garr_insert( pga, garr_count( pga ), count );
}

/*-----------------------------------------------------------------------------
* Id: arr_insert_1 FA
*
* Summary: The method inserts elements into the array at the specified index.
*  
* Params: from - The index of the first inserted element starts at zero. 
          count - The amount of elements are required to be inserted. 
* 
* Return: The index of the first inserted item.
*
* Define: method uint arr.insert( uint from, uint count )
*
-----------------------------------------------------------------------------*/

uint STDCALL  garr_insert( pgarr pga, uint from, uint number )
{
   uint   size;
   pubyte data;
   
   if ( !number )
      return from;
   
   size = number * pga->isize;
   from = min( from, garr_count( pga ));

   buf_insert( &pga->data, from * pga->isize, NULL, size );

   data = buf_ptr( &pga->data ) + from * pga->isize;

   if ( type_hasinit( pga->itype ))
   {
      while ( number-- )
      {
//         print("INIT=%i from=%i type=%i\n", number, from, pga->itype );
         type_init( data, pga->itype );
         data += pga->isize;
      }       
   }
   else 
      mem_zero( data, size );

   return from;
}

void  STDCALL  garr_array( pgarr pga, uint first )
{
   uint count = garr_count( pga );

   if ( first < count )
      garr_del( pga, first, count - first );
   else
      if ( first > count )
         garr_expand( pga, first - count );

   mem_zeroui( ( puint )&pga->dim, MAX_MSR );
   pga->dim[0] = first;
}

/*-----------------------------------------------------------------------------
* Id: arr_opof F4
* 
* Summary: Specifying the type of items. You can specify #b(of) type when you 
           describe #b(arr) variable. In default, the type of the items 
           is #b(uint).
*  
* Title: arr of type
*
* Define: method arr.oftype( uint itype )  
*
-----------------------------------------------------------------------------*/

void  STDCALL  garr_oftype( pgarr pga, uint itype )
{
   garr_clear( pga );
   pga->itype = itype;
   pga->isize = (( povmtype )PCMD( itype ))->size;
}

void  STDCALL  garr_array2( pgarr pga, uint first, uint second )
{
   garr_array( pga, first * second );
   pga->dim[0] = first;
   pga->dim[1] = second;
}

void  STDCALL  garr_array3( pgarr pga, uint first, uint second, uint third )
{
   garr_array( pga, first * second * third );
   pga->dim[0] = first;
   pga->dim[1] = second;
   pga->dim[2] = third;
}

/*-----------------------------------------------------------------------------
* Id: arr_opind F4
* 
* Summary: Getting #b('[i]') item of the array.
*  
* Title: arr[i]
*
* Return: The #b('[i]') item of the array.
*
* Define: method uint arr.index( uint i )  
*
-----------------------------------------------------------------------------*/

pubyte  STDCALL  garr_index( pgarr pga, uint first )
{
   if ( first >= garr_count( pga ))
      return 0;
   return buf_ptr( &pga->data ) + first * pga->isize;
}

/*-----------------------------------------------------------------------------
* Id: arr_opind_1 FC
* 
* Summary: Getting #b('[i,j]') item of the array.
*  
* Title: arr[i,j]
*
* Return: The #b('[i,j]') item of the array.
*
* Define: method uint arr.index( uint i, uint j )  
*
-----------------------------------------------------------------------------*/

pubyte  STDCALL  garr_index2( pgarr pga, uint first, uint second )
{
   return garr_index( pga, first * pga->dim[1] + second );
}

/*-----------------------------------------------------------------------------
* Id: arr_opind_2 FC
* 
* Summary: Getting #b('[i,j,k]') item of the array.
*  
* Title: arr[i,j,k]
*
* Return: The #b('[i,j,k]') item of the array.
*
* Define: method uint arr.index( uint i, uint j, uint k )  
*
-----------------------------------------------------------------------------*/

pubyte  STDCALL  garr_index3( pgarr pga, uint first, uint second, uint third )
{
   return garr_index( pga, first * pga->dim[1] * pga->dim[2] + 
                           second * pga->dim[2] + third );
}


//--------------------------------------------------------------------------

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

#include "collection.h"
#include "../bytecode/cmdlist.h"
#include "../vm/vmtype.h"
//! temporary
/*#include "../os/user/defines.h"
#include "../genteeapi/gentee.h"
*/

//--------------------------------------------------------------------------

puint STDCALL collect_add( pcollect pclt, puint input, uint type )
{
//   uint value;

   pclt->count++;
   buf_appenduint( ( pbuf )pclt, type );
   if ( (( povmtype )PCMD( type ))->stsize == 2 )
   {
      pclt->flag |= 0x01;
      buf_append( ( pbuf )pclt, ( pubyte )input, sizeof( long64 ));
      return input + 2;
   }
   else
   {
/*      value = *input;

      switch ( type )
      {
         case TUbyte: value = *( pubyte )input; break;
         case TByte: value = *( pbyte )input; break;
         case TUshort: value = *( pushort )input; break;
         case TShort: value = *( pshort )input; break;
         default: value = *input; break;
      }*/
      buf_appenduint( ( pbuf )pclt, *input );
   }
   return  input + 1;
}

pubyte    STDCALL collect_addptr( pcollect pclt, pubyte ptr )
{
   pstr  ps = str_new( ptr );

   collect_add( pclt, ( puint )&ps, TStr );
   return ptr + mem_len( ptr ) + 1;
}

/*-----------------------------------------------------------------------------
* Id: collection_opind F4
* 
* Summary: Gets a value of a collection element. Don't use if the collection 
           contains double, ulong or long types.
*  
* Title: collection[ i ]
*
* Return: A value of the collection element.
*
* Define: method uint collection.index( uint ind )
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: collection_ptr F2
* 
* Summary: Gets a pointer to a collection element.
*
* Params: ind - Element index starts at zero.
*
* Return: A pointer to a collection element, or zero on error.
*
* Define: method uint collection.ptr( uint ind )
*
-----------------------------------------------------------------------------*/

pubyte  STDCALL collect_index( pcollect pclt, uint index )
{
   uint  i;
   uint  off = 0;

   if ( index >= pclt->count )
      return 0;
   
   if ( pclt->flag & 0x01 )
   {
      for( i = 0; i < index; i++ )
      {
//      print("Type=%i\n", *( puint )( 
//                   buf_ptr( ( pbuf )pclt ) + pclt->pfor ) );
         off += sizeof( uint ) + ((( povmtype )PCMD( *( puint )( 
                   buf_ptr( ( pbuf )pclt ) + off ) ))->stsize << 2 );
      }
   }
   else
      off = ( index << 3 );
//   print("Index = %i t=%i pfor=%i off = %i\n", index, 
//       *( puint )buf_ptr( ( pbuf )pclt ), pclt->pfor, pclt->pfor + sizeof( uint ) );
   return buf_ptr( ( pbuf )pclt ) + off + sizeof( uint );
}

/*-----------------------------------------------------------------------------
* Id: collection_gettype F2
* 
* Summary: Gets an element type of a collection. 
*
* Params: ind - Element index starts at zero.
*
* Return: An element type of a collection or zero on error.
*
* Define: method uint collection.gettype( uint ind )
*
-----------------------------------------------------------------------------*/

uint   STDCALL  collect_gettype( pcollect pclt, uint index )
{
   if ( index < pclt->count ) 
      return *(( puint )collect_index( pclt, index ) - 1 );
   return 0;
}

pubyte STDCALL collect_copy( pcollect pclt, pubyte data )
{
   uint    itype;
   pvoid   object; 
   uint    count = *( puint )data;

   data += sizeof( uint );
//   pclt->owner = 1;
   while ( count-- )
   {
      itype = *data++;

      switch ( itype )
      {
         case TBuf: 
         case TStr:
            object = type_new( itype, data );
//            if ( itype == TStr )
//               print("Str=%s type = %i\n", str_ptr( ( pstr )object ), itype );
            collect_add( pclt, ( puint )&object, itype );
            if ( itype == TStr )
               data += mem_len( data ) + 1;
            else
               data += *( puint )data + sizeof( uint );
            break;
         case TCollection:
            object = type_new( itype, NULL );
            data = collect_copy( ( pcollect )object, data );
            collect_add( pclt, ( puint )&object, itype );
            break;
         default:
            data = ( pubyte )collect_add( pclt, ( puint )data, itype );
            break;
      }
   }
   
   return data;
}

/*-----------------------------------------------------------------------------
* Id: collection_oplen F4
* 
* Summary: Gets the amount of elements in the collection.
*  
* Return: The count of the collection items.
*
* Define: operator uint *( collection left ) 
*
-----------------------------------------------------------------------------*/

uint  STDCALL collect_count( pcollect pclt )
{
   return pclt->count;
}

void  STDCALL collect_delete( pcollect pclt )
{

}

// !!! сделать collect_delete() с учетом поля owner. Добавить поле.

//--------------------------------------------------------------------------
/*
void   STDCALL collection_clear( par pa )
{
//   buf_clear( &pa->data );
}
*/
//--------------------------------------------------------------------------

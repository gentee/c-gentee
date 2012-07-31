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

#include "buf.h"
#include "../genteeapi/gentee.h"
#include "../os/user/defines.h"

//--------------------------------------------------------------------------

pbuf  STDCALL buf_alloc( pbuf pb, uint size )
{
//   if ( !pb->data ) bufnum++;
   mem_free( pb->data );

   pb->data = mem_alloc( size );
   pb->size = mem_getsize( pb->data );
   pb->use = 0;

   return pb;
}

pbuf   STDCALL buf_array( pbuf pb, uint count )
{
   buf_alloc( pb, count );
   mem_zero( pb->data, count );
   pb->use = count;
   return pb;
}

/*-----------------------------------------------------------------------------
* Id: buf_clear F3
* 
* Summary: Clear data in the object. This method sets the size of the binary
           data to zero.
*  
* Return: #lng/retobj#
*
* Define: method buf buf.clear()  
*
-----------------------------------------------------------------------------*/

pbuf  STDCALL buf_clear( pbuf pb )
{
   pb->use = 0;
   return pb;
}

/*-----------------------------------------------------------------------------
* Id: buf_free F3
* 
* Summary: Memory deallocation. The method deallocates memory allocated for  
           the object and destroys all data.
*  
* Return: #lng/retobj#
*
* Define: method buf buf.free()  
*
-----------------------------------------------------------------------------*/

pbuf  STDCALL buf_free( pbuf pb )
{
   //if (pb->data) bufnum--;
   mem_free( pb->data );

   pb->data = NULL;
   pb->size = 0;
   pb->use = 0;
   return pb;
}

/*-----------------------------------------------------------------------------
* Id: buf_opind F4
* 
* Summary: Getting byte #b[#lgt(i)] from the buffer.
*  
* Title: buf[ i ]
*
* Return: The value of byte i of the memory data.
*
* Define: method uint buf.index( uint i )  
*
-----------------------------------------------------------------------------*/

pubyte  STDCALL buf_index( pbuf pb, uint index )
{
   return pb->data + index;
}

/*-----------------------------------------------------------------------------
* Id: buf_append F2
* 
* Summary: Data addition. The method adds data to the object. 
*  
* Params: ptr - The pointer to the data to be added. 
          size - The size of the data being added. 
*
* Return: #lng/retobj#
*
* Define: method buf buf.append( uint ptr, uint size )  
*
-----------------------------------------------------------------------------*/

pbuf STDCALL buf_append( pbuf pb, pubyte src, uint size )
{
   buf_expand( pb, size + 1 );
   mem_copy( pb->data + pb->use, src, size );
   pb->use += size;
   
   return pb;
}

/*-----------------------------------------------------------------------------
*
* ID: buf_appendtype 19.10.06 0.0.A.
* 
* Summary: Append a ubyte to buf
*  
-----------------------------------------------------------------------------*/

pubyte STDCALL buf_appendtype( pbuf pb, uint size )
{
   buf_expand( pb, size + 1 );
   pb->use += size;
   
   return pb->data + pb->use - size;
}

/*-----------------------------------------------------------------------------
* Id: buf_opadd F4
* 
* Summary: Appending types to the buffer. Append #b(buf) to #b(buf) =&gt; 
           #b( buf += buf ).
*  
* Title: buf += type
*
* Return: The result buffer.
*
* Define: operator buf +=( buf left, buf right ) 
*
-----------------------------------------------------------------------------*/

pbuf STDCALL buf_add( pbuf pb, pbuf src )
{
   return buf_append( pb, src->data, src->use );
}

/*-----------------------------------------------------------------------------
* Id: buf_opadd_1 FC
* 
* Summary: Append #b(ubyte) to #b(buf) =&gt; #b( buf += ubyte ).
*  
* Define: operator buf +=( buf left, ubyte right ) 
*
-----------------------------------------------------------------------------*/

pbuf   STDCALL buf_appendch( pbuf pb, ubyte val )
{
   buf_expand( pb, 1 );
   *( pb->data + pb->use ) = val;
   pb->use++;
   return pb;
}

/*-----------------------------------------------------------------------------
* Id: buf_opadd_2 FC
* 
* Summary: Append #b(uint) to #b(buf) =&gt; #b( buf += uint ).
*  
* Define: operator buf +=( buf left, uint right ) 
*
-----------------------------------------------------------------------------*/

pbuf STDCALL buf_appenduint( pbuf pb, uint val )
{
   buf_expand( pb, sizeof( uint ));
   *( pint )( pb->data + pb->use ) = val;
   pb->use += sizeof( uint );
   
   return pb;
}

/*-----------------------------------------------------------------------------
* Id: buf_opadd_4 FC
* 
* Summary: Append #b(ulong) to #b(buf) =&gt; #b( buf += ulong ).
*  
* Define: operator buf +=( buf left, ulong right ) 
*
-----------------------------------------------------------------------------*/

pbuf   STDCALL buf_appendulong( pbuf pb, ulong64 val )
{
   buf_expand( pb, sizeof( ulong64 ));
   *( pulong64 )( pb->data + pb->use ) = val;
   pb->use += sizeof( ulong64 );
   
   return pb;
}

/*-----------------------------------------------------------------------------
* Id: buf_opadd_3 FC
* 
* Summary: Append #b(ushort) to #b(buf) =&gt; #b( buf += ushort ).
*  
* Define: operator buf +=( buf left, ushort right ) 
*
-----------------------------------------------------------------------------*/

pbuf STDCALL buf_appendushort( pbuf pb, ushort val )
{
   buf_expand( pb, sizeof( ushort ));
   *( pushort )( pb->data + pb->use ) = val;
   pb->use += sizeof( ushort );
   
   return pb;
}

/*-----------------------------------------------------------------------------
* Id: buf_copy F2
* 
* Summary: Copying. The method copies a binary data into the object. 
*  
* Params: ptr - The pointer to the data being copied. 
          size - The size of the data being copied. 
* 
* Return: #lng/retobj#
*
* Define: method buf buf.copy( uint ptr, uint size )  
*
-----------------------------------------------------------------------------*/

pbuf  STDCALL buf_copy( pbuf pb, pubyte src, uint size )
{
   pb->use = 0;
   buf_reserve( pb, size + 1 );
   mem_copy( pb->data, src, size );
   pb->use = size;
   
   return pb;
}

/*-----------------------------------------------------------------------------
* Id: buf_opeq F4
* 
* Summary: Copying data from one buffer into another.
*  
* Return: The result buffer.
*
* Define: operator buf =( buf left, buf right ) 
*
-----------------------------------------------------------------------------*/

pbuf  STDCALL buf_set( pbuf pb, pbuf src )
{
   return buf_copy( pb, src->data, src->use );
}

//--------------------------------------------------------------------------

pbuf   STDCALL buf_copyzero( pbuf pb, pubyte src )
{
   return buf_copy( pb, src, mem_len( src ) + 1 );
}

//--------------------------------------------------------------------------

void STDCALL buf_delete( pbuf pb )
{
//   if (pb->data) bufnum--;
   mem_free( pb->data );
   pb->data = NULL;
}

//--------------------------------------------------------------------------

pbuf STDCALL buf_init( pbuf pb )
{
   mem_zero( pb, sizeof( buf ));
   return pb;
}

/*-----------------------------------------------------------------------------
* Id: buf_insert_1 FA
* 
* Summary: The method inserts one memory data into the buffer. 
*  
* Title: buf.insert
*
* Params: offset - The offset where data will be inserted. If the offset is  /
                   greater than the size, data is added to the end to the buffer. 
          ptr - The pointer to the memory data to be inserted. 
          size - The size of the data to be inserted.
* 
* Define: method buf buf.insert( uint offset, uint ptr, uint size )
*
-----------------------------------------------------------------------------*/

pbuf  STDCALL buf_insert( pbuf pb, uint off, pubyte data, uint size )
{
   if ( off > pb->use )
      off = pb->use;

   buf_expand( pb, size );
   mem_move( pb->data + off + size, pb->data + off, pb->use - off );
   if ( data )
      mem_copy( pb->data + off, data, size );
   pb->use += size;

   return pb;
}

/*-----------------------------------------------------------------------------
* Id: buf_oplen F4
* 
* Summary: Get the size of the memory being used.
*  
* Return: The size of the used memory.
*
* Define: operator uint *( buf left ) 
*
-----------------------------------------------------------------------------*/

uint STDCALL buf_len( pbuf pb )
{
   return pb->use;
}

/*-----------------------------------------------------------------------------
* Id: buf_ptr F3
* 
* Summary: Get the pointer to memory.
*  
* Return: The pointer to the allocated memory of the binary data. 
*
* Define: method buf buf.ptr()  
*
-----------------------------------------------------------------------------*/

pubyte STDCALL buf_ptr( pbuf pb )
{
   return pb->data;
}

/*-----------------------------------------------------------------------------
* Id: buf_expand F2
* 
* Summary: Expansion. The method increases the size of memory allocated for
           the object. 
*  
* Params: size - The requested additional size of memory. It is an additional /
                 size to be reserved in the buffer. 
* 
* Return: #lng/retobj#
*
* Define: method buf buf.expand( uint size )  
*
-----------------------------------------------------------------------------*/

pbuf  STDCALL buf_expand( pbuf pb, uint size )
{
   uint   tmp;
   pubyte old = pb->data;
   uint   use = pb->use;

   size += use; // only size is additional size
   if ( size <= pb->size )
      return pb;

   if ( !pb->step )
      pb->step = max( size/2, 32 );
   else
      if ( pb->step < pb->size / 2 ) 
         pb->step = pb->size / 2;
   
   tmp = pb->size + pb->step;
   if ( size < tmp )
      size = tmp;
   pb->data = 0;
   buf_alloc( pb, size );
   if ( old )
   {
//      bufnum--;
      mem_copy( pb->data, old, use );
      pb->use = use;
      mem_free( old );
   }

   return pb;
}

/*-----------------------------------------------------------------------------
* Id: buf_opeqeq F4
* 
* Summary: Comparison operation.
*  
* Return: Returns #b(1) if the buffers are equal. Otherwise, it returns #b(0).
*
* Define: operator uint ==( buf left, buf right ) 
*
-----------------------------------------------------------------------------*/

uint   STDCALL buf_isequal( pbuf left, pbuf right )
{
   return left->use == right->use && 
           !mem_cmp( left->data, right->data, left->use );
}

/*-----------------------------------------------------------------------------
* Id: buf_opeqeq_1 FC
* 
* Summary: Comparison operation.
*  
* Return: Returns #b(0) if the buffers are equal. Otherwise, it returns #b(1).
*
* Define: operator uint !=( buf left, buf right ) 
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: buf_reserve F2
* 
* Summary: Memory reservation. The method increases the size of memory 
           allocated for the object. 
*  
* Params: size - The summary requested size of memory. If it is less than the /
                 current size, nothing happens. If the size is increased, the /
                 current data is saved.
* 
* Return: #lng/retobj#
*
* Define: method buf buf.reserve( uint size )  
*
-----------------------------------------------------------------------------*/

pbuf  STDCALL buf_reserve( pbuf pb, uint size )
{
   if ( size <= pb->size )
      return pb;

   return buf_expand( pb, size - pb->use );
}

/*-----------------------------------------------------------------------------
*
* ID: buf_setlen 19.10.06 0.0.A.
* 
* Summary: Set the length of the buffer
*
-----------------------------------------------------------------------------*/

pbuf   STDCALL buf_setlen( pbuf pb, uint len )
{
   pb->use = len > pb->size ? pb->size : len ;

   return pb;
}

/*-----------------------------------------------------------------------------
*
* ID: buf_subbuf 19.10.06 0.0.A.
* 
* Summary: Get a subbuf
*
-----------------------------------------------------------------------------*/
/*
pbuf STDCALL buf_subbuf( pbuf dest, pbuf src, uint off, uint len )
{
   uint slen = buf_len( src );

   if ( len && off < slen )
   {
      if ( len > slen - off )
         len = slen - off;
      buf_copy( dest, buf_ptr( src ) + off, len );
   }
   else 
      buf_clear( dest );

   return dest;
}
*/
/*-----------------------------------------------------------------------------
* Id: buf_del F2
* 
* Summary: Data deletion. The method deletes part of the buffer. 
*  
* Params: offset - The offset of the data being deleted. 
          size - The size of the data being deleted. 
* 
* Return: #lng/retobj#
*
* Define: method buf buf.del( uint offset, uint size )  
*
-----------------------------------------------------------------------------*/

pbuf   STDCALL buf_del( pbuf pb, uint off, uint size )
{
   uint tmp;

   if ( !size || off > pb->use )
      return pb;
   
   tmp = pb->use - off;

   if ( size > tmp ) 
      size = tmp;

   mem_move( pb->data + off, pb->data + off + size, tmp - size );
   pb->use -= size;

   return pb;
}

/*-----------------------------------------------------------------------------
* Id: buf_findch F2
* 
* Summary: Find a byte in a binary data. 
*  
* Params: offset - The offset to start searching from.
          ch - A unsigned byte to be searched. 
* 
* Return: The offset of the byte if it is found. If the byte is not found, the
          size of the buffer is returned. 
*
* Define: method uint buf.findch( uint offset, uint ch )  
*
-----------------------------------------------------------------------------*/

uint  STDCALL buf_find( pbuf ps, uint offset, ubyte symbol )
{
   pubyte   cur = ps->data + offset;
   pubyte   end = ps->data + buf_len( ps ); 

   while ( cur < end )
   {
      if ( *cur == symbol )
         break;
      cur++;
   }

   return ( cur < end ? cur - ps->data : buf_len( ps ));
}

/*-----------------------------------------------------------------------------
*
* ID: buf_find 19.10.06 0.0.A.
* 
* Summary: Find the ushort in the buf
*
-----------------------------------------------------------------------------*/

uint  STDCALL buf_findsh( pbuf ps, uint offset, ushort val )
{
   pushort  cur = ( pushort )( ps->data + ( offset << 1 ));
   pushort  end = ( pushort )(ps->data + buf_len( ps )); 

   while ( cur < end )
   {
      if ( *cur == val )
         break;
      cur++;
   }

   return ( cur < end ? (( pubyte )cur - ps->data ) >> 1 : 
                        ( buf_len( ps ) >> 1 ) - 1 );
}
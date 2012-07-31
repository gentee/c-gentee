/******************************************************************************
*
* Copyright (C) 2006-09, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov
*
* Contributors: Dmitri Ermakov
*
******************************************************************************/

/*-----------------------------------------------------------------------------
* Id: memory L "Memory"
* 
* Desc:    Functions for memory management.
* Summary: Gentee has own memory manager. This overview describes the memory 
           management provided by Gentee. You can allocate and use memory with 
           these functions.
*
* List: *, malloc, mcmp, mcopy, mfree, mlen, mmove, mzero
* 
-----------------------------------------------------------------------------*/

#include "../os/user/defines.h"
#include "memory.h"

memory _memory;
pubyte _lower;
pubyte _bin;
pubyte _hex;
pubyte _dec;
pubyte _name;
OS_CRL _crlmem;               // Critical section for multi-thread calling

//uint  memnum = 0;
//uint  bufnum = 0;

/*--------------------------------------------------------------------------
* 
* Locale functions
*
*/

uint STDCALL _mem_heapalloc( uint id )
{
   uint   size;
   pheap  p_heap;
      
   size = ( MEM_HEAPSIZE << ( id >> 5 ));
   
   p_heap = _memory.heaps + id;
   
   p_heap->ptr = os_alloc( size + MAX_BYTE * sizeof( uint ));
//   p_heap->ptr = VirtualAlloc( NULL, size + MAX_BYTE * sizeof( uint ),
//                MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE );
   if ( !p_heap->ptr )
      return FALSE;
   p_heap->chain = p_heap->ptr;    
   p_heap->size = size;
   p_heap->remain = size;
   p_heap->free = 0;
//   p_heap->count = 0;
//   p_heap->alloc = 0;
   mem_zeroui( p_heap->chain, MAX_BYTE );
      
 //  printf(".\n");
   return TRUE; 
}

//--------------------------------------------------------------------------

uint STDCALL _mem_heapfree( uint id )
{
   pheap  p_heap;
           
   p_heap = _memory.heaps + id;
   if ( p_heap->ptr )   
//      VirtualFree( p_heap->ptr, 0, MEM_RELEASE );
      os_free( p_heap->ptr );
   p_heap->ptr = 0;
        
   return TRUE;
}

//--------------------------------------------------------------------------

uint STDCALL _mem_size2sid( uint size )
{
   uint middle, right = 255;
   uint left = 0;
   
   while ( right > left )
   {
      middle = ( right + left ) >> 1;
      if ( size > _memory.sid[ middle ] )
         left = middle + 1;    
      else
         right = middle;
   }
   return left;          
}

/*-----------------------------------------------------------------------------
* Id: malloc F
* 
* Summary: Allocate the memory. The function allocates the memory of the 
           specified size. 
*  
* Params: size - The size of memory space to be allocated.
*
* Return: The pointer to the allocated memory space or 0 in case of an error. 
*
* Define: func uint malloc( uint size )
*
-----------------------------------------------------------------------------*/

pvoid STDCALL mem_alloc( uint size )
{
   uint   sid, ih;
   pvoid  result = 0;
   pheap  p_heap;
 
   os_crlsection_enter( &_crlmem );
//   memnum++;
   if ( size > MEM_EDGE )
   {
// ** result = ( pubyte )os_alloc( size + 8 ) + 2;
      result = ( pubyte )os_alloc( size + 6 );
      *(( pubyte )result + 5 ) = MAX_BYTE;
      *( puint )result = size;
      result = ( pubyte )result + 6;   
      goto end;
   }
   sid = _mem_size2sid( size );
   
   ih = _memory.last;
   size = _memory.sid[ sid ] + 2;
    
again:
   p_heap = _memory.heaps + ih;
   if ( !p_heap->ptr && !_mem_heapalloc( ih ))
   {
      result = 0;
      goto end;
   }
   if ( p_heap->chain[ sid ] )
   {
      p_heap->free -= size;
      result = ( pvoid )p_heap->chain[ sid ];
      p_heap->chain[ sid ] = *( puint )result; 
   }
   else
   {
      if ( size <= p_heap->remain )
      {
         result = ( pubyte )p_heap->ptr + MAX_BYTE * sizeof( uint ) + 
                  p_heap->size - p_heap->remain;
         *(( pubyte )result)++ = ( byte )ih;
         *(( pubyte )result)++ = ( byte )sid;
         p_heap->remain -= size;
      }
      else
      {
         if ( _memory.last )
         {
            _memory.last = 0;
            ih = 0;   
         }
         else
            ih++;
         goto again;
      } 
   }
   _memory.last = ih;
//   p_heap->count++;
//   p_heap->alloc += size;

end:
   os_crlsection_leave( &_crlmem );

   return result;
}

//--------------------------------------------------------------------------

pvoid STDCALL mem_allocz( uint size )
{
   pvoid   result = NULL;

   result = mem_alloc( size );
   if ( result )
      mem_zero( result, size );

   return result;
}

/*-----------------------------------------------------------------------------
* Id: mcopy F
* 
* Summary: Copying memory. The function copies data from one memory space 
           into another. 
*  
* Params: dest - The pointer for the data being copied. 
          src - The pointer to the source of the data being copied. 
          len - The size of the data being copied. 
*
* Return: The pointer to the copied data. 
*
* Define: func uint mcopy( uint dest, uint src, uint len )
*
-----------------------------------------------------------------------------*/

pvoid  STDCALL mem_copy( pvoid dest, pvoid src, uint len )
{
   puint psrc = ( puint )src;
   puint pdest = ( puint )dest;
   uint  ilen = len >> 2;

   while ( ilen-- ) 
      *pdest++ = *psrc++;
   
   len &= 0x3;
   while ( len-- )
      *((pubyte)pdest)++ = *((pubyte)psrc)++;

   return dest;
}

//--------------------------------------------------------------------------

uint STDCALL mem_deinit( void )
{
   uint i;

   mem_free( _lower );

   for ( i = 0; i <= MAX_BYTE; i++ )
      _mem_heapfree( i );
      
   os_free( _memory.sid );
   os_free( _memory.heaps );

   os_crlsection_delete( &_crlmem );
 
   return TRUE;
}

/*-----------------------------------------------------------------------------
* Id: mfree F
* 
* Summary: Memory deallocation. The function deallocates memory.
*  
* Params: ptr - The pointer to the memory space to be deallocated.
*
* Return: #lng/retf#
*
* Define: func uint mfree( uint ptr )
*
-----------------------------------------------------------------------------*/

uint  STDCALL mem_free( pvoid ptr )
{
//   pubyte  p_id;
   uint   sid;
   uint   pid;
   pheap  p_heap;

   if ( !ptr ) return TRUE;

//   memnum--;
   os_crlsection_enter( &_crlmem );

   sid = *(( pubyte )ptr - 1 );
//   p_id = ( pubyte )ptr - 2;
   pid = *(( pubyte )ptr - 2 );

   if ( sid == MAX_BYTE )
   {
      os_free( ( pubyte )ptr - 6 ); 
// ** os_free( ( pubyte )ptr - 8 );
      goto end;
   }  
   p_heap = _memory.heaps + pid;//*p_id; 
   *( puint )ptr = p_heap->chain[ sid ];
   p_heap->chain[ sid ] = ( uint )ptr;
   
   p_heap->free += _memory.sid[ sid ] + 2;
//   p_heap->alloc -= _memory.sid[ sid ] + 2;
//   p_heap->count--;
// ??? Почему то при последнем элементе иногда получается  выход за границы  
//   if ( p_heap->free + p_heap->remain == p_heap->size )
//   if ( !p_heap->count )
//      _mem_heapfree( pid );
   
end:
   os_crlsection_leave( &_crlmem );

   return TRUE;        
}

//--------------------------------------------------------------------------

uint  STDCALL mem_getsize( pvoid ptr )
{
   uint  sid;

   if ((  sid = *((pubyte)ptr - 1 )) == MAX_BYTE )
      return *( puint )((pubyte)ptr - 6 );
   return _memory.sid[ sid ];
}

//--------------------------------------------------------------------------

uint STDCALL mem_init( void )
{
   uint  i, size, step = 8;
   
   _memory.sid = os_alloc( ABC_COUNT /*( MAX_BYTE + 1 )*/ * sizeof( uint ));
   _memory.sid[ 0 ] = step;
   for ( i = 1; i < MAX_BYTE; i++ )
   {
      if ( !( i & 0xF )) 
         step <<= 1;
      _memory.sid[ i ] = _memory.sid[ i - 1 ] + step;   
   }
   _memory.sid[ MAX_BYTE ] = MAX_UINT;
   
   _memory.heaps = os_alloc( size = ABC_COUNT * sizeof( heap ));
   mem_zero( _memory.heaps, size );

   os_crlsection_init( &_crlmem );
   _memory.last = 0;

   _lower = mem_alloc( ABC_COUNT * 5 );
   _bin = _lower + ABC_COUNT;
   _dec = _bin + ABC_COUNT;
   _hex = _dec + ABC_COUNT;
   _name = _hex + ABC_COUNT;

   for ( i = 0; i < ABC_COUNT; i++ )
   {
      _lower[i] = ( ubyte )os_lower( ( pubyte )i );
      _bin[i] = 0xFF;
      if ( i >= '0' && i <= '9' )
         _name[i] = 1;
      else 
         if ( i >= 0x80 || ( i >= 'A' && i <= 'Z' ) || ( i >= 'a' && i <= 'z' ) ||
              i == '_' )
            _name[i] = 2;
         else
            _name[i] = 0;
   }
   _bin[ '0' ] = 0;
   _bin[ '1' ] = 1;

   for ( i = 0; i < ABC_COUNT; i++ )
      if ( i > '1' && i <= '9' )
         _dec[i] = (ubyte)( 1 + i - '1' );
      else
         _dec[i] = _bin[i];

   for ( i = 0; i < ABC_COUNT; i++ )
      if ( _lower[i] >= 'a' && _lower[i] <= 'f' )
         _hex[i] = 10 + _lower[i] - 'a';
      else
         _hex[i] = _dec[i];

   return TRUE;   
}

/*-----------------------------------------------------------------------------
* Id: mlen F
* 
* Summary: Size till zero. Determines the number of bytes till zero.
*  
* Params: data - The pointer to a memory space.
*
* Return: The number of bytes till the zero character.
*
* Define: func uint mlen( uint data )
*
-----------------------------------------------------------------------------*/

uint STDCALL mem_len( pvoid data )
{
  pubyte temp = ( pubyte )data;

  while ( *temp++ );

  return ( uint )( temp - ( pubyte )data - 1 );
}

//--------------------------------------------------------------------------

uint STDCALL mem_lensh( pvoid data )
{
  pushort temp = ( pushort )data;

  while ( *temp++ );

  return ( uint )( temp - ( pushort )data - 1 );
}

/*-----------------------------------------------------------------------------
* Id: mmove F
* 
* Summary: Move memory. The function moves the specified space. The initial and 
           final data may overlap.
*  
* Params: dest - The pointer for the data being copied. 
          src - The pointer to the source of the data being copied. 
          len - The size of the data being copied. 
*
* Define: func mmove( uint dest, uint src, uint len )
*
-----------------------------------------------------------------------------*/

void  STDCALL mem_move( pvoid dest, pvoid src, uint len )
{
   puint  psrc;
   puint  pdest;
   uint   ilen;

   if ( ( pubyte )dest <= ( pubyte )src || 
         ( pubyte )dest >= ( pubyte )src + len ) 
      mem_copy( dest, src, len );
   else 
   {
      ilen = len >> 2;
      // области памяти пересекаются и надо копировать с конца
      pdest = ( puint )( ( pubyte )dest + len - sizeof( uint ));
      psrc = ( puint )(( pubyte )src + len - sizeof( uint ));
      while ( ilen-- ) 
         *pdest-- = *psrc--;

      len &= 0x3;
      while ( len-- )
         *( ( pubyte )dest + len ) = *( ( pubyte )src + len );
   }
}

/*-----------------------------------------------------------------------------
* Id: mzero F
* 
* Summary: Filling memory with zeros. The functions zeroes the memory space. 
*  
* Params: dest - The pointer to a memory space. 
          len - The size of the data being zeroed.
*
* Return: The pointer to the zeroed data. 
*
* Define: func uint mzero( uint dest, uint len )
*
-----------------------------------------------------------------------------*/

pvoid  STDCALL mem_zero( pvoid dest, uint len )
{
   puint  p_dest = ( puint )dest;
   uint   ilen = len >> 2;

#ifdef LINUX
   while ( ilen-- ) 
      *p_dest++ = 0;
#else
   __asm
   {
        mov     edi, dest
        mov     ecx, ilen
        mov     eax, 0
        rep     stosd
   }
   p_dest += ilen;
#endif
   
   len &= 0x3;
   while ( len-- )
      *((pubyte)p_dest)++ = 0;

   return dest;
}

/*-----------------------------------------------------------------------------
* Id: mcmp F
* 
* Summary: Comparison memory. The function compares two memory spaces. 
*  
* Params: dest - The pointer to the first memory space.
          src - The pointer to the second memory space.
          len - The size being compared.
*
* Return: #tblparam[0|The spaces are equal.$#
          &lt;0|The first space is smaller.$# 
          &gt;0|The second space is smaller.]
*
* Define: func int mcmp( uint dest, uint src, uint len )
*
-----------------------------------------------------------------------------*/

int  STDCALL mem_cmp( pvoid dest, pvoid src, uint len )
{
   puint dsrc = ( puint )src;
   puint ddest = ( puint )dest;
   uint  ilen = len >> 2;
   int   i;

   while ( ilen-- )
      if ( *ddest++ != *dsrc++ )
      {
         ddest--;
         dsrc--;
         for ( i = 0; i < 4; i++ )
         {
            if ( *((pubyte)ddest) > *((pubyte)dsrc) )
               return 1;
            if ( *((pubyte)ddest)++ < *((pubyte)dsrc)++ )
               return -1;
         }
      }

   len &= 0x3;
   while ( len-- )
   {
      if ( *((pubyte)ddest) > *((pubyte)dsrc) )
         return 1;
      if ( *((pubyte)ddest)++ < *((pubyte)dsrc)++ )
         return -1;
   }

   return 0;
}

//--------------------------------------------------------------------------

int  STDCALL mem_cmpign( pvoid dest, pvoid src, uint len )
{
   pubyte psrc = ( pubyte )src;
   pubyte pdest = ( pubyte )dest;

   while ( len-- )
   {
      if ( _lower[ *pdest++ ] != _lower[ *psrc++ ] )
      {
         return *--pdest > *--psrc ? 1 : -1;
      }
   }
   return 0;
}

//--------------------------------------------------------------------------

uint  STDCALL mem_iseqzero( pvoid dest, pvoid src )
{
   uint   len = mem_len( dest );

   return !mem_cmp( dest, src, len ) && 
          (( pubyte )dest)[ len ] == (( pubyte )src)[ len ];
}

//--------------------------------------------------------------------------

void  STDCALL mem_zeroui( puint dest, uint len )
{
#ifdef LINUX
   while ( len-- ) 
      *dest++ = 0;
#else
    __asm
    {
        mov     edi, dest
        mov     ecx, len
        mov     eax, 0
        rep stosd
    }
#endif
}

//--------------------------------------------------------------------------

void  STDCALL mem_copyui( puint dest, puint src, uint len )
{
   while ( len-- ) 
      *dest++ = *src++;
}

//--------------------------------------------------------------------------

uint STDCALL mem_index( pubyte dest, uint number )
{
   return ( uint )( dest + number );
}

//--------------------------------------------------------------------------

uint  STDCALL mem_copyuntilzero( pubyte dest, pubyte src  )
{
  pubyte temp = dest;

  while ( *src )
     *temp++ = *src++;
  *temp = 0;
  return ( uint )( temp - dest + 1 );
}

//--------------------------------------------------------------------------

void  STDCALL mem_swap( pubyte left, pubyte right, uint len )
{
/*   register byte temp;
   
   if ( left != right )
   {    
      while ( len-- ) 
      {
         temp = *left;
         *left++ = *right;
         *right++ = temp;
      }
   }*/

   register uint temp;
   register uint dwlen = len >> 2;

   if ( left != right )
   {    
      while ( dwlen-- ) 
      {
         temp = *( puint )left;
         *(( puint )left)++ = *( puint )right;
         *(( puint )right)++ = temp;
      }
      len &= 0x3;
      while ( len-- )
      {
         temp = *left;
         *left++  = *right;
         *right++ = ( ubyte )temp;
      }
   }
}
/*
uint memtest()
{
   uint i;
   pheap p_heap;

   for ( i = 0; i <= MAX_BYTE; i++ )
   {
      p_heap = _memory.heaps + i;
      if ( p_heap->ptr )
      {
         if ( p_heap->free + p_heap->remain + p_heap->alloc != p_heap->size )   
            return i+1;
      }
   }
   return 0;
}*/
/*
#include "msg.h"

uint STDCALL memstat()
{
   print("Memnum=%i buf=%i\n", memnum, bufnum );
   return 0;
}*/
#include "common.h"
#include "bytecode.h"
#include "vm.h"


/******************************************************************************
* Summary: This file provides functionality for memory management.
******************************************************************************/



/*** Locale functions ***/

uint STDCALL _mem_heapalloc( pvmEngine pThis, uint id )
{
   uint   size;
   pheap  p_heap;
      
   size = ( MEM_HEAPSIZE << ( id >> 5 ));
   
   p_heap = pThis->_memory.heaps + id;
   
   p_heap->ptr = os_alloc( size + MAX_BYTE * sizeof( uint ));
   if ( !p_heap->ptr )
      return FALSE;
   p_heap->chain = p_heap->ptr;    
   p_heap->size = size;
   p_heap->remain = size;
   p_heap->free = 0;
   mem_zeroui( pThis, p_heap->chain, MAX_BYTE );

   return TRUE; 
}

//--------------------------------------------------------------------------

uint STDCALL _mem_heapfree( pvmEngine pThis, uint id )
{
   pheap  p_heap;
           
   p_heap = pThis->_memory.heaps + id;
   if ( p_heap->ptr )   
//      VirtualFree( p_heap->ptr, 0, MEM_RELEASE );
      os_free( p_heap->ptr );
   p_heap->ptr = 0;
        
   return TRUE;
}

//--------------------------------------------------------------------------

uint STDCALL _mem_size2sid( pvmEngine pThis, uint size )
{
   uint middle, right = 255;
   uint left = 0;
   
   while ( right > left )
   {
      middle = ( right + left ) >> 1;
      if ( size > pThis->_memory.sid[ middle ] )
         left = middle + 1;    
      else
         right = middle;
   }
   return left;          
}

/*--------------------------------------------------------------------------
* 
* Public functions
*
*/

/*--------------------------------------------------------------------------
* Description
* Allocate the memory.
*
* Parameters 
* uint size, The required size.
*
* Result 
* uint, The pointer to the memory or 0.
*
*/

pvoid STDCALL mem_alloc( pvmEngine pThis, uint size )
{
   uint   sid, ih;
   pvoid  result = 0;
   pheap  p_heap;
   
   os_crlsection_enter( &pThis->_crlmem );
   if ( size > MEM_EDGE )
   {
      result = ( pubyte )os_alloc( size + 8 ) + 2;
      *(( pubyte )result + 5 ) = MAX_BYTE;
      *( puint )result = size;
      result = ( pubyte )result + 6;   
      goto end;
   }
   sid = _mem_size2sid( pThis, size );
   
   ih = pThis->_memory.last;
   size = pThis->_memory.sid[ sid ] + 2;
    
again:
   p_heap = pThis->_memory.heaps + ih;
   if ( !p_heap->ptr && !_mem_heapalloc( pThis, ih ))
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
         if ( pThis->_memory.last )
         {
            pThis->_memory.last = 0;
            ih = 0;   
         }
         else
            ih++;
         goto again;
      } 
   }
   pThis->_memory.last = ih;

end:
   os_crlsection_leave( &pThis->_crlmem );
   mem_zero( pThis, result, size );
   return result;
}

//--------------------------------------------------------------------------

pvoid  STDCALL mem_copy( pvmEngine pThis, pvoid dest, pvoid src, uint len )
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

uint STDCALL mem_deinit( pvmEngine pThis )
{
   uint i;

   for ( i = 0; i <= MAX_BYTE; i++ )
      _mem_heapfree( pThis, i );
      
   os_free( pThis->_memory.sid );
   os_free( pThis->_memory.heaps );

   os_crlsection_delete( &pThis->_crlmem );
 
   return TRUE;
}

//--------------------------------------------------------------------------

uint  STDCALL mem_free( pvmEngine pThis, pvoid ptr )
{
   pubyte  p_id;
   uint   sid;
   pheap  p_heap;

   if ( !ptr ) return TRUE;

   os_crlsection_enter( &pThis->_crlmem );

   sid = *(( pubyte )ptr - 1 );
   p_id = ( pubyte )ptr - 2;
   
   if ( sid == MAX_BYTE )
   {
      os_free( ( pubyte )ptr - 8 );
      goto end;
   }  
   p_heap = pThis->_memory.heaps + *p_id; 
   *( puint )ptr = p_heap->chain[ sid ];
   p_heap->chain[ sid ] = ( uint )ptr;
   
   p_heap->free += pThis->_memory.sid[ sid ] + 2;
   
   if ( p_heap->free + p_heap->remain == p_heap->size )
      _mem_heapfree( pThis, *p_id );
   
end:
   os_crlsection_leave( &pThis->_crlmem );

   return TRUE;        
}

//--------------------------------------------------------------------------

uint  STDCALL mem_getsize( pvmEngine pThis, pvoid ptr )
{
   uint  sid;

   if ((  sid = *((pubyte)ptr - 1 )) == MAX_BYTE )
      return *( puint )((pubyte)ptr - 8 );
   return pThis->_memory.sid[ sid ];
}

//--------------------------------------------------------------------------

uint STDCALL mem_init( pvmEngine pThis )
{
   uint  i, size, step = 8;

   pThis->_memory.sid = os_alloc(( MAX_BYTE + 1 ) * sizeof( uint ));
   pThis->_memory.sid[ 0 ] = step;

   for ( i = 1; i < MAX_BYTE - 1; i++ )
   {
      if ( !( i & 0xF )) 
         step <<= 1;
      pThis->_memory.sid[ i ] = pThis->_memory.sid[ i - 1 ] + step;   
   }
   pThis->_memory.sid[ MAX_BYTE ] = MAX_UINT;
 
   pThis->_memory.heaps = os_alloc( size = (MAX_BYTE + 1) * sizeof( heap ));
   mem_zero( pThis, pThis->_memory.heaps, size );

   os_crlsection_init( &pThis->_crlmem );
   pThis->_memory.last = 0;

   return TRUE;   
}

//--------------------------------------------------------------------------

uint STDCALL mem_len( pvmEngine pThis, pvoid data )
{
  pubyte temp = ( pubyte )data;

  while ( *temp++ );

  return ( uint )( temp - ( pubyte )data - 1 );
}

//--------------------------------------------------------------------------

//--------------------------------------------------------------------------

void  STDCALL mem_move( pvmEngine pThis, pvoid dest, pvoid src, uint len )
{
   puint  psrc;
   puint  pdest;
   uint   ilen;

   if ( ( pubyte )dest <= ( pubyte )src || 
         ( pubyte )dest >= ( pubyte )src + len ) 
      mem_copy( pThis, dest, src, len );
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

//--------------------------------------------------------------------------

pvoid STDCALL mem_zero( pvmEngine pThis, pvoid dest, uint len )
{
   puint  p_dest = ( puint )dest;
   uint   ilen = len >> 2;

   while ( ilen-- ) 
      *p_dest++ = 0;
   
   len &= 0x3;
   while ( len-- )
      *((pubyte)p_dest)++ = 0;

   return dest;
}

//--------------------------------------------------------------------------

int  STDCALL mem_cmp( pvmEngine pThis, pvoid dest, pvoid src, uint len )
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

void  STDCALL mem_zeroui( pvmEngine pThis, puint dest, uint len )
{
   while ( len-- ) 
      *dest++ = 0;
}



//--------------------------------------------------------------------------

uint  STDCALL mem_copyuntilzero( pvmEngine pThis, pubyte dest, pubyte src  )
{
  pubyte temp = dest;

  while ( *src )
     *temp++ = *src++;
  *temp = 0;
  return ( uint )( temp - dest + 1 );
}


/******************************************************************************
*
* Summary: This file provides functionality for 'buf' type.
*
******************************************************************************/


pbuf  STDCALL buf_alloc( pvmEngine pThis, pbuf pb, uint size )
{
   mem_free( pThis, pb->data );

   pb->data = mem_alloc( pThis, size );
   pb->size = mem_getsize( pThis, pb->data );
   pb->use = 0;

   return pb;
}


/*-----------------------------------------------------------------------------
*
* ID: buf_appendch 19.10.06 0.0.A.
* 
* Summary: Append a ubyte to buf
*  
-----------------------------------------------------------------------------*/

pbuf STDCALL buf_append( pvmEngine pThis, pbuf pb, pubyte src, uint size )
{
    buf_expand( pThis, pb, size + 1 );
    mem_copy( pThis, pb->data + pb->use, src, size );
    pb->use += size;
    
    return pb;
}

pbuf   STDCALL buf_appendch( pvmEngine pThis, pbuf pb, ubyte val )
{
   buf_expand( pThis, pb, 1 );
   *( pb->data + pb->use ) = val;
   pb->use++;
   return pb;
}

pbuf STDCALL buf_appenduint( pvmEngine pThis, pbuf pb, uint val )
{
   buf_expand( pThis, pb, sizeof( uint ));
   *( pint )( pb->data + pb->use ) = val;
   pb->use += sizeof( uint );
   
   return pb;
}


pbuf STDCALL buf_appendushort( pvmEngine pThis, pbuf pb, ushort val )
{
   buf_expand( pThis, pb, sizeof( ushort ));
   *( pushort )( pb->data + pb->use ) = val;
   pb->use += sizeof( ushort );
   
   return pb;
}

pbuf  STDCALL buf_copy( pvmEngine pThis, pbuf pb, pubyte src, uint size )
{
   pb->use = 0;
   buf_reserve( pThis, pb, size + 1 );
   mem_copy( pThis, pb->data, src, size );
   pb->use = size;
   
   return pb;
}


//--------------------------------------------------------------------------

pbuf   STDCALL buf_copyzero( pvmEngine pThis, pbuf pb, pubyte src )
{
   return buf_copy( pThis, pb, src, mem_len( pThis, src ) + 1 );
}

//--------------------------------------------------------------------------

void STDCALL buf_delete( pvmEngine pThis, pbuf pb )
{
   mem_free( pThis, pb->data );
   pb->data = NULL;
}

//--------------------------------------------------------------------------

pbuf STDCALL buf_init( pvmEngine pThis, pbuf pb )
{
   mem_zero( pThis, pb, sizeof( buf ));
   return pb;
}

//--------------------------------------------------------------------------

pbuf  STDCALL buf_insert( pvmEngine pThis, pbuf pb, uint off, pubyte data, uint size )
{
   if ( off > pb->use )
      off = pb->use;

   buf_expand( pThis, pb, size );
   mem_move( pThis, pb->data + off + size, pb->data + off, pb->use - off );
   if ( data )
      mem_copy( pThis, pb->data + off, data, size );
   pb->use += size;

   return pb;
}

uint STDCALL buf_len( pvmEngine pThis, pbuf pb )
{
   return pb->use;
}

pubyte STDCALL buf_ptr( pvmEngine pThis, pbuf pb )
{
   return pb->data;
}

//--------------------------------------------------------------------------
// size - the additional size

pbuf  STDCALL buf_expand( pvmEngine pThis, pbuf pb, uint size )
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
   buf_alloc( pThis, pb, size );
   if ( old )
   {
      mem_copy( pThis, pb->data, old, use );
      pb->use = use;
      mem_free( pThis, old );
   }

   return pb;
}


//--------------------------------------------------------------------------
// size - the full required size

pbuf  STDCALL buf_reserve( pvmEngine pThis, pbuf pb, uint size )
{
   if ( size <= pb->size )
      return pb;

   return buf_expand( pThis, pb, size - pb->use );
}

/*-----------------------------------------------------------------------------
*
* ID: buf_setlen 19.10.06 0.0.A.
* 
* Summary: Set the length of the buffer
*
-----------------------------------------------------------------------------*/

pbuf   STDCALL buf_setlen( pvmEngine pThis, pbuf pb, uint len )
{
   pb->use = len > pb->size ? pb->size : len ;

   return pb;
}



/******************************************************************************
*
*
******************************************************************************/


//--------------------------------------------------------------------------
// Возвращается указатель на добавленный элемент

pvoid  STDCALL arr_append( pvmEngine pThis, parr pa )
{
   arr_reserve( pThis, pa, 1 );

   mem_zero( pThis, buf_ptr( pThis, &pa->data ) + pa->data.use, pa->isize );
   pa->data.use += pa->isize;

   return buf_ptr( pThis, &pa->data ) + pa->data.use - pa->isize;
}

//--------------------------------------------------------------------------

uint  STDCALL arr_appenditems( pvmEngine pThis, parr pa, uint count )
{
   uint    size = count * pa->isize;

   arr_reserve( pThis, pa, count );

   mem_zero( pThis, buf_ptr( pThis, &pa->data ) + pa->data.use, size );
   pa->data.use += size;

//   printf("Append %i size=%i\n", pa->data.use, pa->data.size );
   return pa->data.use / pa->isize;
}

//--------------------------------------------------------------------------

void  STDCALL arr_appendnum( pvmEngine pThis, parr pa, uint val )
{
   *( puint )arr_append( pThis, pa ) = val;
}

//--------------------------------------------------------------------------


//--------------------------------------------------------------------------

uint  STDCALL arr_count( pvmEngine pThis, parr pa )
{
   return buf_len( pThis, &pa->data ) / pa->isize;
}

//--------------------------------------------------------------------------

void  STDCALL arr_delete( pvmEngine pThis, parr pa )
{
   puint ptr, end;

   if ( pa->isobj )
   {
      ptr = ( puint )buf_ptr( pThis, &pa->data );
      end = ( puint )(( pubyte )ptr + buf_len( pThis, &pa->data ));
      while ( ptr < end )
      {
         mem_free( pThis, ( pvoid )*ptr );
         ptr++;
      }
   }
   buf_delete( pThis, &pa->data );
}

//--------------------------------------------------------------------------

uint  STDCALL arr_getuint( pvmEngine pThis, parr pa, uint num )
{
   return *( puint )( buf_ptr( pThis, &pa->data ) + num * pa->isize );
}

//--------------------------------------------------------------------------

void  STDCALL arr_init( pvmEngine pThis, parr pa, uint size )
{
   buf_init( pThis, &pa->data );
   
   pa->isobj = 0;
   if ( !size )
   {
      size = sizeof( uint );
      pa->isobj = 1;
   }
   pa->isize = size;
}

//--------------------------------------------------------------------------

pvoid  STDCALL arr_ptr( pvmEngine pThis, parr pa, uint num )
{
   return buf_ptr( pThis, &pa->data ) + num * pa->isize;
}


//--------------------------------------------------------------------------
// count - количество резервируемых элементов

void  STDCALL arr_reserve( pvmEngine pThis, parr pa, uint count )
{
   buf_expand( pThis, &pa->data, count * pa->isize );
}

//--------------------------------------------------------------------------

void   STDCALL arr_setuint( pvmEngine pThis, parr pa, uint num, uint value )
{
   *( puint )( buf_ptr( pThis, &pa->data ) + num * pa->isize ) = value;
}

//--------------------------------------------------------------------------
// count - количество резервируемых элементов

void  STDCALL arr_step( pvmEngine pThis, parr pa, uint count )
{
   pa->data.step = count * pa->isize;
}


/******************************************************************************
* Summary: This file provides functionality for 'str' type.
*
******************************************************************************/


/*-----------------------------------------------------------------------------
*
* ID: str_copy 19.10.06 0.0.A.
* 
* Summary: Copy the string
*  
-----------------------------------------------------------------------------*/

pstr  STDCALL str_copy( pvmEngine pThis, pstr dest, pstr src )
{
   return buf_copy( pThis, ( pbuf )dest, str_ptr( src ), src->use );
}

//--------------------------------------------------------------------------

pstr   STDCALL str_copyzero( pvmEngine pThis, pstr ps, pubyte src )
{
   ps->use--;
   buf_copyzero( pThis, ps, src );
   return ps;
}


pstr STDCALL str_init( pvmEngine pThis, pstr ps )
{
   mem_zero( pThis, ps, sizeof( str ));
   
   buf_alloc( pThis, ps, 32 );
   ps->data[0] = 0;
   ps->use = 1;
//   print("String Init %x\n", ps );
   return ps;
}


uint  STDCALL str_len( pvmEngine pThis, pstr ps )
{
   return ps->use - 1;
}



/*-----------------------------------------------------------------------------
*
* ID: str_setlen 19.10.06 0.0.A.
* 
* Summary: Reserve string space
*  
* Params: len - additional required size
*
-----------------------------------------------------------------------------*/

pstr   STDCALL str_setlen( pvmEngine pThis, pstr ps, uint len )
{
   if ( len >= ps->size )
      len = 0;

   ps->use = len + 1;
   ps->data[ len ] = 0;

   return ps;
}

/*-----------------------------------------------------------------------------
*
* ID: str_new 19.10.06 0.0.A.
* 
* Summary: Create str object.
*  
-----------------------------------------------------------------------------*/

pstr  STDCALL str_new( pvmEngine pThis, pubyte ptr )
{
   pstr  ret = mem_alloc( pThis, sizeof( str ));

   str_init( pThis, ret );
   if ( ptr )
      str_copyzero( pThis, ret, ptr );

   return ret;
}



/******************************************************************************
*
******************************************************************************/


//--------------------------------------------------------------------------

puint STDCALL collect_add( pvmEngine pThis, pcollect pclt, puint input, uint type )
{
//   uint value;

   pclt->count++;
   buf_appenduint( pThis, ( pbuf )pclt, type );
   if ( (( povmtype )PCMD( type ))->stsize == 2 )
   {
      pclt->flag |= 0x01;
      buf_append( pThis, ( pbuf )pclt, ( pubyte )input, sizeof( long64 ));
      return input + 2;
   }
   else
   {
      buf_appenduint( pThis, ( pbuf )pclt, *input );
   }
   return  input + 1;
}

pubyte    STDCALL collect_addptr( pvmEngine pThis, pcollect pclt, pubyte ptr )
{
   pstr  ps = str_new( pThis, ptr );

   collect_add( pThis, pclt, ( puint )&ps, TStr );
   return ptr + mem_len( pThis, ptr ) + 1;
}

pubyte  STDCALL collect_index( pvmEngine pThis, pcollect pclt, uint index )
{
   uint  i;
   uint  off = 0;

   if ( index >= pclt->count )
      return 0;
   
   if ( pclt->flag & 0x01 )
   {
      for( i = 0; i < index; i++ )
      {
         off += sizeof( uint ) + ((( povmtype )PCMD( *( puint )( 
                   buf_ptr( pThis, ( pbuf )pclt ) + off ) ))->stsize << 2 );
      }
   }
   else
      off = ( index << 3 );
   return buf_ptr( pThis, ( pbuf )pclt ) + off + sizeof( uint );
}

uint   STDCALL  collect_gettype( pvmEngine pThis, pcollect pclt, uint index )
{
   if ( index < pclt->count ) 
      return *(( puint )collect_index( pThis, pclt, index ) - 1 );
   return 0;
}


uint  STDCALL collect_count( pvmEngine pThis, pcollect pclt )
{
   return pclt->count;
}

void  STDCALL collect_delete( pvmEngine pThis, pcollect pclt )
{
// !!! сделать collect_delete() с учетом поля owner. Добавить поле.
}


/******************************************************************************
*
*
******************************************************************************/


void  STDCALL hash_delete( pvmEngine pThis, phash ph )
{
   arr_delete( pThis, &ph->values );
   arr_delete( pThis, &ph->names );
}

//--------------------------------------------------------------------------

phashitem  STDCALL _hash_find( pvmEngine pThis, phash ph, pubyte name, uint create )
{
   pubyte  ptr = name;
   ushort  val = 0;
   uint    len = 0;   
   ubyte   shift = 0;
   ushort  nameoff;
   phashitem  phi = 0, prev = 0;

   // Вычисляем хэш-значение строки
   while ( *ptr )
   {
         val += (( ushort )*ptr++ ) << shift;
      if ( ++shift > 7 )
         shift = 0;
      len++;
   }
// получаем номер в хэш-таблице
   val &= HASH_SIZE - 1;
   phi = prev = ( phashitem )arr_getuint( pThis, &ph->values, val );
   nameoff = sizeof( hashitem ) + ph->isize;
   while ( phi )
   {
      if ( len == phi->len && !(/* ph->ignore ? 
                  mem_cmpign( pThis, name, ( pubyte )phi + nameoff, len ) : */
                mem_cmp( pThis, name, ( pubyte )phi + nameoff, len )))
         // нашли совпадение
         return phi;
      phi = ( phashitem )phi->next;
   }
   if ( create )
   {
      // Будем добавлять элемент в таблицу имен
      phi = ( phashitem )mem_alloc( pThis, nameoff + len + 1 );
      phi->len = ( ushort )len;
      phi->next = ( pvoid )prev;
      phi->id = arr_count( pThis, &ph->names );
      mem_zero( pThis, ( pubyte )phi + sizeof( hashitem ), ph->isize );
      mem_copy( pThis, ( pubyte )phi + nameoff, name, len + 1 );
      arr_appendnum( pThis, &ph->names, ( uint )phi );
      arr_setuint( pThis, &ph->values, val, ( uint )phi );
   }
   return phi;
}

//--------------------------------------------------------------------------

phashitem  STDCALL hash_find( pvmEngine pThis, phash ph, pubyte name )
{
   return _hash_find( pThis, ph, name, 0 );
}

//--------------------------------------------------------------------------

void  STDCALL hash_init( pvmEngine pThis, phash ph, uint isize )
{
   arr_init( pThis, &ph->values, sizeof( uint ));
   arr_appenditems( pThis, &ph->values, HASH_SIZE );

   arr_init( pThis, &ph->names, 0 );
   arr_step( pThis, &ph->names, 512 );
   ph->isize = isize;
   ph->ignore = 0;
}

//--------------------------------------------------------------------------

phashitem  STDCALL hash_create( pvmEngine pThis, phash ph, pubyte name )
{
   return _hash_find( pThis, ph, name, 1 );
}

//--------------------------------------------------------------------------



/******************************************************************************
*
* Summary: This file provides calculating CRC32.
*
******************************************************************************/


//--------------------------------------------------------------------------

void STDCALL crc_init( pvmEngine pThis )
{
   uint  reg, polinom, i, ib;

   polinom = 0xEDB88320;
   pThis->_crctbl[ 0 ] = 0;

   for ( i = 1; i < 256; i++ )
   {
      reg = 0;
      for ( ib = i | 256; ib != 1; ib >>= 1 )
      {
         reg = ( reg & 1 ? (reg >> 1) ^ polinom : reg >> 1 );
         if ( ib & 1 )
            reg ^= polinom;
      }
      pThis->_crctbl[ i ] = reg;
   }
}

//--------------------------------------------------------------------------
// seed must be 0xFFFFFFFF in the first calling

uint STDCALL crc( pvmEngine pThis, pubyte data, uint size, uint seed )
{
   while ( size-- )
      seed = pThis->_crctbl[((ushort)seed ^ ( *data++ )) & 0xFF ] ^ ( seed >> 8 );

   return seed;
}

//--------------------------------------------------------------------------


/*-----------------------------------------------------------------------------
*
* ID: file2buf 23.10.06 0.0.A.
* 
* Summary: Read file to buf. Result must be destroy later. name is converted 
  into the full name.
*
-----------------------------------------------------------------------------*/

pbuf STDCALL file2buf( pvmEngine pThis, pstr name, pbuf ret, uint pos )
{
   str       filename;
   uint      search = 0;
   uint      handle, size;
//   parrdata  pad;

   str_init( pThis, &filename );
   os_filefullname( pThis, name, &filename );

   handle = os_fileopen( &filename, FOP_READONLY );
   if ( !handle )
   {
      longjmp( pThis->stack_state, -1 );//msg( pThis, MFileopen | MSG_STR | MSG_EXIT | MSG_POS, &filename, pos );
   }
   size = ( uint )os_filesize( handle );
   buf_reserve( pThis, ret, size );

   if ( size && !os_fileread( handle, buf_ptr( pThis, ret ), size ))
      longjmp( pThis->stack_state, -1 );//msg( pThis, MFileread | MSG_STR | MSG_EXIT | MSG_POS, &filename, pos );

   buf_setlen( pThis, ret, size );
   os_fileclose( handle );

   str_copy( pThis, name, &filename );

   str_delete( pThis, &filename );

   return ret;
}

uint  STDCALL buf2file( pvmEngine pThis, pstr name, pbuf out )
{
   str       filename;
   uint      handle;

   str_init( pThis, &filename );
   str_reserve( pThis, &filename, 512 );
   str_reserve( pThis, &filename, 512 );
   os_filefullname( pThis, name, &filename );

   handle = os_fileopen( &filename, FOP_CREATE );
   if ( !handle )
     longjmp( pThis->stack_state, -1 );//msg( pThis, MFileopen | MSG_STR | MSG_EXIT, &filename );

   if ( !os_filewrite( handle, buf_ptr( pThis, out ), buf_len( pThis, out ) ))
      longjmp( pThis->stack_state, -1 );//msg( pThis, MFileread | MSG_STR | MSG_EXIT, &filename );

   os_fileclose( handle );

   str_copy( pThis, name, &filename );
   str_delete( pThis, &filename );

   return 1;
}


/*-----------------------------------------------------------------------------
* Summary: Close the file
-----------------------------------------------------------------------------*/

uint     STDCALL os_fileclose( uint handle )
{
   return CloseHandle(( pvoid )handle );
}

/*-----------------------------------------------------------------------------
* Summary: Get the full name of the file
-----------------------------------------------------------------------------*/

pstr  STDCALL os_filefullname( pvmEngine pThis, pstr filename, pstr result )
{
   uint   len;
   pubyte ptr;

   str_reserve( pThis, result, 512 );
   len = GetFullPathName( str_ptr( filename ), 512, str_ptr( result ), &ptr );
   str_setlen( pThis, result, len );
   return result;
}


uint  STDCALL os_fileopen( pstr name, uint flag )
{
   uint ret;

   ret = ( uint )CreateFile( str_ptr( name ), ( flag & FOP_READONLY ? GENERIC_READ : 
            GENERIC_READ | GENERIC_WRITE ), ( flag & FOP_EXCLUSIVE ? 0 : 
            FILE_SHARE_READ | FILE_SHARE_WRITE ), NULL, 
           ( flag & FOP_CREATE ? CREATE_ALWAYS :
              ( flag & FOP_IFCREATE ? OPEN_ALWAYS : OPEN_EXISTING )),
           0, NULL ); 
   return ret == ( uint )INVALID_HANDLE_VALUE ? 0 : ret ;
}


uint   STDCALL os_fileread( uint handle, pubyte data, uint size )
{
   uint  read;

   if ( !ReadFile( (pvoid)handle, data, size, &read, NULL ) || read != size ) 
      return FALSE;
   return read;
}

ulong64  STDCALL os_filesize( uint handle )
{
   LARGE_INTEGER  li;

   li.LowPart = GetFileSize( ( pvoid )handle, &li.HighPart ); 
 
   if ( li.LowPart == INVALID_FILE_SIZE && GetLastError() != NO_ERROR )
      return -1L;

   return li.QuadPart;
}

//--------------------------------------------------------------------------

uint   STDCALL os_filewrite( uint handle, pubyte data, uint size )
{
   uint  write;

   if ( !WriteFile( ( pvoid )handle, data, size, &write, NULL ) || write != size ) 
      return FALSE;
   return write;
}



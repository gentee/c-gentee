/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: hash 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

#include "hash.h"
//! temporary
#include "../os/user/defines.h"

//--------------------------------------------------------------------------

void  STDCALL hash_delete( phash ph )
{

   arr_delete( &ph->values );
   arr_delete( &ph->names );
}

//--------------------------------------------------------------------------

phashitem  STDCALL _hash_find( phash ph, pubyte name, uint create )
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
      if ( ph->ignore )
         val += (( ushort )_lower[ *ptr++ ] ) << shift;
      else
         val += (( ushort )*ptr++ ) << shift;
      if ( ++shift > 7 )
         shift = 0;
      len++;
   }
// получаем номер в хэш-таблице
   val &= HASH_SIZE - 1;
   phi = prev = ( phashitem )arr_getuint( &ph->values, val );
   nameoff = sizeof( hashitem ) + ph->isize;
   while ( phi )
   {
//         printf("CMp <%s><%s> %i %i\n", name, ( pubyte )phi + nameoff, len, phi->len );
      if ( len == phi->len && !( ph->ignore ? 
                  mem_cmpign( name, ( pubyte )phi + nameoff, len ) : 
                  mem_cmp( name, ( pubyte )phi + nameoff, len )))
         // нашли совпадение
         return phi;
      phi = ( phashitem )phi->next;
   }
   if ( create )
   {
      // Будем добавлять элемент в таблицу имен
      phi = ( phashitem )mem_alloc( nameoff + len + 1 );
      phi->len = ( ushort )len;
      phi->next = ( pvoid )prev;
      phi->id = arr_count( &ph->names );
      mem_zero( ( pubyte )phi + sizeof( hashitem ), ph->isize );
      mem_copy( ( pubyte )phi + nameoff, name, len + 1 );
//      printf("Append %x %s\n", phi, name );
      arr_appendnum( &ph->names, ( uint )phi );
      arr_setuint( &ph->values, val, ( uint )phi );
   }
   return phi;
}

//--------------------------------------------------------------------------

phashitem  STDCALL hash_find( phash ph, pubyte name )
{
   return _hash_find( ph, name, 0 );
}

//--------------------------------------------------------------------------

void  STDCALL hash_init( phash ph, uint isize )
{
   arr_init( &ph->values, sizeof( uint ));
   arr_appenditems( &ph->values, HASH_SIZE );

   arr_init( &ph->names, 0 );
   arr_step( &ph->names, 512 );
   ph->isize = isize;
   ph->ignore = 0;
}

//--------------------------------------------------------------------------

phashitem  STDCALL hash_create( phash ph, pubyte name )
{
   return _hash_find( ph, name, 1 );
}

//--------------------------------------------------------------------------

uint  STDCALL hash_getuint( phash ph, pubyte name )
{
   phashitem phi = _hash_find( ph, name, 0 );
   if ( phi )
      return *( puint )( phi + 1 );
   return 0;
}

//--------------------------------------------------------------------------

uint  STDCALL hash_setuint( phash ph, pubyte name, uint val )
{
   phashitem phi = _hash_find( ph, name, 1 );
   *( puint )( phi + 1 ) = val;

   return 1;
}

/*-----------------------------------------------------------------------------
*
* ID: hash_name 30.10.06 0.0.A.
* 
* Summary: Get the object name from its id.
*
-----------------------------------------------------------------------------*/

pubyte  STDCALL hash_name( phash ph, uint id )
{
   if ( id >= arr_count( &ph->names ))
      return NULL;
   return ( pubyte )*(puint)arr_ptr( &ph->names, id ) + sizeof( hashitem ) + 
          ph->isize;
}

//--------------------------------------------------------------------------

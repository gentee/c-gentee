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

#ifndef _HASH_
#define _HASH_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "arr.h"

//--------------------------------------------------------------------------

#define HASH_SIZE 4096

// Описание имени
typedef struct 
{
   ushort len;       // длина имени
   uint   id;        // Identifier. The number in the array
   pvoid  next;      // The next hashitem 
} hashitem, * phashitem; 
// Additional size hash.isize
// name with zero at the end

// После этого идет строка имени
typedef struct
{
   arr     values;   // Hash-values hash table pointer to the first hashitem
   arr     names;    // Array of hash names = pointers to hashitem objects
   uint    isize;    // Additional size
   ubyte   ignore;   // If 1 then ignore case
} hash, * phash;

//--------------------------------------------------------------------------

phashitem  STDCALL hash_create( phash ph, pubyte name );
phashitem  STDCALL hash_find( phash ph, pubyte name );
void       STDCALL hash_init( phash ph, uint size );
void       STDCALL hash_delete( phash ph );
uint       STDCALL hash_getuint( phash ph, pubyte name );
uint       STDCALL hash_setuint( phash ph, pubyte name, uint val );
pubyte     STDCALL hash_name( phash ph, uint id );

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _HASH_


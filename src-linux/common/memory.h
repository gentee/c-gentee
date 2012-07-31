/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: memory 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
* Summary: This file provides functionality for memory management.
*
******************************************************************************/

#ifndef _MEMORY_
#define _MEMORY_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "types.h"

/*--------------------------------------------------------------------------
* Defines
*/
#define MEM_EDGE       0xFFFF     // Alloc from heap if the memory size 
                                  // is less or equal than MEM_EDGE 
#define MEM_HEAPSIZE   0x40000    // The minimum size of the heap

typedef struct _heap
{
   pvoid   ptr;          // Pointer to the heap memory
   puint   chain;        // Array of ABC_COUNT free chains
   uint    size;         // The summary memory size
   uint    remain;       // The remain size of the heap
   uint    free;         // The size of free blocks
//   uint    count;        // The count of allocated blocks
//   uint    alloc;        // The allocated size
} heap, * pheap;

typedef struct memory
{
   pheap   heaps;        // Array of ABC_COUNT heaps
   uint    last;         // The number of the latest active heap
   puint   sid;          // Array of ABC_COUNT limits of block sizes
} memory;
 
extern pubyte _lower;
extern pubyte _bin;
extern pubyte _hex;
extern pubyte _dec;
extern pubyte _name;

/*--------------------------------------------------------------------------
The each memory block begins two bytes.
1. The number of heap ( from 0 to MAX_BYTE ). 
2. The id of block size. The block doesn't belong to any heap if it equals 
MAX_BYTE. 
If the block is free then it contains the next free block with the same id.
*/
//--------------------------------------------------------------------------

pvoid  DLL_EXPORT STDCALL mem_alloc( uint size );
pvoid  STDCALL mem_allocz( uint size );
pvoid  DLL_EXPORT STDCALL mem_copy( pvoid dest, pvoid src, uint len );
void   STDCALL mem_copyui( puint dest, puint src, uint len );
uint   DLL_EXPORT STDCALL mem_copyuntilzero( pubyte dest, pubyte src  );
uint   STDCALL mem_deinit( void );
uint   DLL_EXPORT STDCALL mem_free( pvoid ptr );
uint   STDCALL mem_getsize( pvoid ptr );
uint   STDCALL mem_init( void );
uint   STDCALL mem_index( pubyte dest, uint number );
uint   STDCALL mem_iseqzero( pvoid dest, pvoid src );
uint   DLL_EXPORT STDCALL mem_len( pvoid data );
uint   STDCALL mem_lensh( pvoid data );
void   STDCALL mem_move( pvoid dest, pvoid src, uint len );
pvoid  DLL_EXPORT STDCALL mem_zero( pvoid dest, uint len );
void   STDCALL mem_zeroui( puint dest, uint len );
int    STDCALL mem_cmp( pvoid dest, pvoid src, uint len );
int    DLL_EXPORT STDCALL mem_cmpign( pvoid dest, pvoid src, uint len );
void   STDCALL mem_swap( pubyte left, pubyte right, uint len );
//uint   memtest();
//uint STDCALL memstat();
//extern uint  bufnum;

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _MEMORY_
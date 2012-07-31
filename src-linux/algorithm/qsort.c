/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project <http://www.gentee.com>. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* qsort 20.04.2007 0.0.A.
*
* Author:  
*
******************************************************************************/

#include "../common/memory.h"
#include "../vm/vmrun.h"
#include "qsort.h"

//typedef  void ( STDCALL* swapfunc)( pvoid, pvoid, uint );

//--------------------------------------------------------------------------

void  STDCALL quicksort( pvoid base, uint count,
                               uint width, cmpfunc func, uint param )
{
   pubyte low;
   pubyte high;
   pubyte middle;
   pubyte lowguy;
   pubyte highguy;
   int   size;
   pubyte lowstk[30];
   pubyte highstk[30];
   int       stkptr;
//   swapfunc  swap = ( swapfunc )( width & 3 ? mem_swap : mem_swapdw );

   if ( count < 2 || width == 0 )
      return;

   stkptr = 0;

   low = base;
   high = ( pubyte )base + width * ( count-1 );

recurse:

   size = ( high - low ) / width + 1; 

   middle = low + ( size / 2 ) * width;
   mem_swap( middle, low, width);

   lowguy = low;
   highguy = high + width;

   for (;;) 
   {
      do  {
         lowguy += width;
      } while (lowguy <= high && func(lowguy, low, param) < 0);

      do  {
         highguy -= width;
      } while (highguy > low && func(highguy, low, param) > 0);

      if ( highguy < lowguy )
         break;

      mem_swap( lowguy, highguy, width );
   }

   mem_swap( low, highguy, width );

   if ( highguy - 1 - low >= high - lowguy ) 
   {
      if (low + width < highguy) 
      {
         lowstk[stkptr] = low;
         highstk[stkptr] = highguy - width;
         ++stkptr;
      }

      if (lowguy < high) 
      {
         low = lowguy;
         goto recurse;
      }
   }
   else 
   {
      if (lowguy < high) {
         lowstk[stkptr] = lowguy;
         highstk[stkptr] = high;
         ++stkptr;
      }

      if (low + width < highguy) {
         high = highguy - width;
         goto recurse;
      }
   }

   --stkptr;
   if ( stkptr >= 0 )
   {
      low = lowstk[stkptr];
      high = highstk[stkptr];
      goto recurse;
   }
   else
      return;
}
#ifndef NOGENTEE
//--------------------------------------------------------------------------

int   STDCALL  cmpvm( pvoid left, pvoid right, uint idfunc )
{
   return vm_runtwo( idfunc, ( uint )left, ( uint )right );
}

//--------------------------------------------------------------------------

void  STDCALL sort( pvoid base, uint count, uint size, uint idfunc )
{
   quicksort( base, count, size, cmpvm, idfunc );
//   quicksort( base, count, size, cmpstr, 0 );
//   qsort( base, count, 16, cmpstrc );

}

//--------------------------------------------------------------------------

int   CALLBACK  cmpsortstr( pvoid left, pvoid right, uint idfunc )
{
   return os_strcmp( ( pvoid )*( puint )left, ( pvoid )*( puint )right );
}

//--------------------------------------------------------------------------

int   CALLBACK  cmpsortstri( pvoid left, pvoid right, uint idfunc )
{
   return os_strcmpign( ( pvoid )*( puint )left, ( pvoid )*( puint )right );
}

//--------------------------------------------------------------------------

int   CALLBACK  cmpsortustr( pvoid left, pvoid right, uint idfunc )
{
   return os_ustrcmp( ( pvoid )*( puint )left, ( pvoid )*( puint )right );
}

//--------------------------------------------------------------------------

int   CALLBACK  cmpsortustri( pvoid left, pvoid right, uint idfunc )
{
   return os_ustrcmpign( ( pvoid )*( puint )left, ( pvoid )*( puint )right );
}
//--------------------------------------------------------------------------

int   CALLBACK  cmpsortuint( pvoid left, pvoid right, uint idfunc )
{
   uint  lval = *( puint )left;
   uint  rval = *( puint )right;

   return lval < rval ? -1 : ( lval > rval ? 1 : 0 );
}

//--------------------------------------------------------------------------

void  STDCALL  fastsort( pvoid base, uint count, uint size, uint mode )
{
   cmpfunc  func;

   switch ( mode ) {
      case FS_STR: 
         func = cmpsortstr;
         break;
      case FS_STRIGNORE: 
         func = cmpsortstri;
         break;
      case FS_UINT: 
         func = cmpsortuint;
         break;
      case FS_USTR: 
         func = cmpsortustr;
         break;
      case FS_USTRIGNORE: 
         func = cmpsortustri;
         break;
   }
   quicksort( base, count, size, func, 0 );
}
#endif
//--------------------------------------------------------------------------

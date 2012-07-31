/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project <http://www.gentee.com>. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* search 20.04.2007 0.0.A.
*
* Author:  
*
******************************************************************************/

#include "../common/memory.h"
#include "search.h"

//Quick search Sunday's algorithm

void STDCALL qs_init( pssearch psearch, pubyte pattern, uint m, uint flag ) 
{
   uint i;

   psearch->pattern = pattern;
   psearch->size = m;
   psearch->flag = flag;

   for ( i = 0; i < ABC_COUNT; ++i )
      psearch->shift[ i ] = m + 1;
   
   if ( flag & QS_IGNCASE )
      for ( i = 0; i < m; ++i )
         psearch->shift[ _lower[ pattern[ i ]]] = m - i;
   else
      for ( i = 0; i < m; ++i )
         psearch->shift[ pattern[ i ]] = m - i;
}

uint STDCALL qs_search( pssearch psearch, pubyte y, uint n ) 
{
   uint j, i, m;
   pubyte x;

   j = 0;
   m = psearch->size;
   x = psearch->pattern;
   if ( n < m ) return n;

   if ( psearch->flag & QS_IGNCASE )
   {
      while ( j <= n - m ) 
      {
         for ( i = 0; i < m; i++ )
         {
            if ( _lower[ x[ i ]] != _lower[ y[ j + i ]] ) goto nextign;
         }
         if ( psearch->flag & QS_WORD )
         {
            if (( !j || !_name[ y[ j - 1 ]]) && ( j + m == n || 
                  !_name[ y[ j + m ]])) return j;
         }
         else
            if ( psearch->flag & QS_BEGINWORD )
            {
               if ( !j || !_name[ y[ j - 1 ]] ) return j;
            }
            else return j;
nextign:
         j += psearch->shift[ _lower[ y[ j + m ]]];
      }
   }
   else
      while ( j <= n - m ) 
      {
         for ( i = 0; i < m; i++ )
         {
            if ( x[ i ] != y[ j + i ] ) goto next;
         }
         if ( psearch->flag & QS_WORD )
         {
            if (( !j || !_name[ y[ j - 1 ]]) && ( j + m == n || 
                  !_name[ y[ j + m ]])) return j;
         }
         else
            if ( psearch->flag & QS_BEGINWORD )
            {
               if ( !j || !_name[ y[ j - 1 ]] ) return j;
            }
            else return j;
next:
         j += psearch->shift[ y[ j + m ]];
      }

   return n;
}

//--------------------------------------------------------------------------

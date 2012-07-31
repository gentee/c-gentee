/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: number 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
* Summary: This file provides functionality for numbers.
*
******************************************************************************/

#include "number.h"
#include "../bytecode/cmdlist.h"
#include "../os/user/defines.h"

/*-----------------------------------------------------------------------------
*
* ID: num_gethex 19.10.06 0.0.A.
* 
* Summary: Convert hex input string to value
*  
-----------------------------------------------------------------------------*/

pubyte STDCALL num_gethex( pubyte in, pnumber pnum, uint mode )
{
   pubyte  cur = in;
   int     len = mode << 1;

   pnum->vlong = 0L;
   pnum->type = mode == 8 ? TUlong : TUint;

   while ( _hex[ *cur ] != 0xFF && ( cur - in ) < len )
   {
      pnum->vlong = ( pnum->vlong << 4 ) + _hex[ *cur ];
      cur++;
   }
   return cur;
}

/*-----------------------------------------------------------------------------
*
* ID: num_getval 19.10.06 0.0.A.
* 
* Summary: Convert input string to value
*  
-----------------------------------------------------------------------------*/

pubyte STDCALL num_getval( pubyte in, pnumber pnum )
{
   uint    sign = 0;
   uint    base = 10;
   pubyte  val = _dec;
   ubyte   stop;
   pubyte  eval;
   pubyte  cur = in;

   while ( *cur == '+' || *cur == '-' || *cur == ' ' )
   {
      if ( *cur == '-' )
         sign = !sign;
      cur++;
   }
   if ( _lower[ *( cur + 1 ) ] == 'x' )
   {
      cur += 2;
      base = 16;
      val = _hex;
   }
   else
      if ( _lower[ *( cur + 1 ) ] == 'b' )
      {
         cur += 2;
         base = 2;
         val = _bin;
      }
   pnum->vlong = 0L;
   pnum->type = sign ? TInt : TUint;
   while ( val[ *cur ] != 0xFF )
   {
      pnum->vlong = pnum->vlong * base + val[ *cur ];
      cur++;
   }
//   printf("val=%i %c %i\n", pnum->vint, *cur,  val[ *cur ] );
   stop = _lower[ *cur ];
   if ( stop == 'l' )
   {
      cur++;
      if ( sign )
      {
         pnum->type = TLong;
         pnum->vlong = -(long64)pnum->vlong;
      }
      else
         pnum->type = TUlong;
   }
   else
      if ( stop == '.' || stop == 'e' || stop == 'd' || stop == 'f' )
      {
         pnum->type = TDouble;
         pnum->vdouble = strtod( in, &eval );
         stop = _lower[ *eval ];
         if ( stop == 'f' )
         {
            pnum->type = TFloat;
            pnum->vfloat = (float)pnum->vdouble;
         }
         if ( stop == 'd' || stop == 'f' )
            eval++;
         return eval;
      }
      else
      {
         if ( sign )
            pnum->vint = -(int)pnum->vint;
      }

   return cur;
}

//--------------------------------------------------------------------------

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

#ifndef _NUMBER_
#define _NUMBER_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "types.h"

/*-----------------------------------------------------------------------------
*
* ID: number 23.10.06 0.0.A.
*
* Summary: The type of number
*  
-----------------------------------------------------------------------------*/

typedef struct
{
   uint    type;     // The type of the number  T****
   union {
      uint     vint;
      ulong64  vlong;
      float    vfloat;
      double   vdouble;
   };
} number, * pnumber;

pubyte  STDCALL num_gethex( pubyte in, pnumber pnum, uint mode );
pubyte  STDCALL num_getval( pubyte in, pnumber pnum );

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _NUMBER_

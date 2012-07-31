/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: mix 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Different functions
*
******************************************************************************/

#ifndef _MIX_
#define _MIX_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "str.h"

//--------------------------------------------------------------------------

uint      STDCALL argc( void );
pstr      STDCALL argv( pstr ret, uint num );

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _MIX_


/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: arrdata 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Array of buf or str
*
******************************************************************************/

#ifndef _ARRDATA_
#define _ARRDATA_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "arr.h"
#include "str.h"

//--------------------------------------------------------------------------

typedef arr arrdata;
typedef arrdata * parrdata;

uint      STDCALL arrdata_appendstr( parrdata pa, pubyte input );
void      STDCALL arrdata_delete( parrdata pa );
pstr      STDCALL arrdata_get( parrdata pa, uint index );
parrdata  STDCALL arrdata_init( parrdata pa );
uint      STDCALL arrdata_strload( parrdata pa, pubyte input );


//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _ARRDATA_


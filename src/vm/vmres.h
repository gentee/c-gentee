/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vmres 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Resources
* 
******************************************************************************/

#ifndef _VMRES_
#define _VMRES_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "vm.h"

/*-----------------------------------------------------------------------------
*
* ID: vmres 19.10.06 0.0.A.
* 
* Summary: 
*  
-----------------------------------------------------------------------------*/
/*typedef struct 
{
   uint    type;   // The type of resource
   union
   {
      buf  vbuf;   // buf
      str  vstr;   // str
   };
} vmres, * pvmres;*/

uint  STDCALL  vmres_addstr( pubyte ptr );
pstr  STDCALL  vmres_getstr( uint index );

//--------------------------------------------------------------------------


   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _VMRES_


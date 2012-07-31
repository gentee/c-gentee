/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vmmanage 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Functions, structures and defines of the Gentee virtual machine.
* 
******************************************************************************/

#ifndef _VMMANAGE_
#define _VMMANAGE_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "vm.h"

pvmmanager STDCALL vmmng_new( void );
void       STDCALL vmmng_destroy( void );
pubyte     STDCALL vmmng_begin( uint size );
uint       STDCALL vmmng_end( pubyte end  );

//--------------------------------------------------------------------------


   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _VMMANAGE_


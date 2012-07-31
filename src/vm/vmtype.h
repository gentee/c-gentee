/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vmtype 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Functions, structures and defines of the Gentee virtual machine.
* 
******************************************************************************/

#ifndef _VMTYPE_
#define _VMTYPE_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "vmrun.h"

void   STDCALL type_vardelete( pubyte start, pvartype psub, uint count, 
                               uint align );
void   STDCALL type_varinit( pubyte start, pvartype psub, uint count, 
                               uint align );
void   STDCALL type_setdelete( pstackpos curpos, uint item );
void   STDCALL type_setinit( pstackpos curpos, uint item );
void   STDCALL type_initialize( uint idtype );
uint   STDCALL type_isinherit( uint idtype, uint idowner );
uint   STDCALL type_hasinit( uint idtype );
uint   STDCALL type_hasdelete( uint idtype );
pubyte STDCALL type_init( pubyte ptr, uint idtype );
void   STDCALL type_delete( pubyte ptr, uint idtype );
uint   STDCALL type_sizeof( uint idtype );
uint   STDCALL type_compfull( uint idtype );
pvoid  STDCALL type_new( uint idtype, pubyte data );
void   STDCALL type_destroy( pvoid obj );
uint   STDCALL type_compat( uint idleft, uint idright, uint oftype );



//--------------------------------------------------------------------------


   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _VMTYPE_


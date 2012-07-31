/******************************************************************************
*
* Copyright (C) 2006-08, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
* 
******************************************************************************/

#ifndef _COMPINIT_
#define _COMPINIT_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "../bytecode/cmdlist.h"
#include "operlist.h"

//--------------------------------------------------------------------------

extern  uint  _lexlist[ OPERCOUNT ];

#define   oper2name( x )  _lexlist[ x ]

void  STDCALL initcompile( void );

//--------------------------------------------------------------------------


   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _COMPINIT_


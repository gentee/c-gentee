/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: alias 06.07.07 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: alias
*
******************************************************************************/

#ifndef _ALIAS_
#define _ALIAS_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus   

#include "lexem.h"

#define alias_getid( x )   ((povmalias)PCMD( x ))->idlink
#define alias_setid( x, y )   ((povmalias)PCMD( x ))->idlink = (y)

//--------------------------------------------------------------------------

plexem STDCALL alias_add( plexem plex, puint pid );

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _ALIAS_

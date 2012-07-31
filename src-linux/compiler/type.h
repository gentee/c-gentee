/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: type 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: type command
*
******************************************************************************/

#ifndef _TYPE_
#define _TYPE_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus   

#include "lexem.h"

//--------------------------------------------------------------------------

pvartype STDCALL type_fieldname( uint idtype, pubyte name );
pvartype STDCALL type_field( plexem plex, uint idtype );
plexem   STDCALL type( plexem plex );
void     STDCALL type_protect( povmtype ptype );


//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _TYPE_

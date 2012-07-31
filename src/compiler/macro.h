/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: define 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: macro functions
*
******************************************************************************/

#ifndef _MACRO_
#define _MACRO_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus   

#include "lexem.h"
#include "macroexp.h"

//--------------------------------------------------------------------------

#define  MACROF_PREDEF     0x01  // Predefined macro
#define  MACROF_GROUP      0x02  // The name of define command
// If !mr.type then it is alias (shortname) and nameid - link to full macro
//#define  MACROF_ALIAS      0x04  // Macro is define command with name
#define  MACRO_NAMEDEF     0x80000000  // for macro_set

/*-----------------------------------------------------------------------------
*
* ID: macro 19.10.06 0.0.A.
* 
* Summary: Macro structure
*  
-----------------------------------------------------------------------------*/

typedef struct
{
   macrores  mr;
   uint      flag; 
} macro, * pmacro;

/*-----------------------------------------------------------------------------
*
* ID: defmacro 19.10.06 0.0.A.
* 
* Summary: Predefined macros
*  
-----------------------------------------------------------------------------*/

#define MACRO_FILE    0
#define MACRO_DATE    1
#define MACRO_TIME    2
#define MACRO_LINE    3
#define MACRO_WINDOWS 4
#define MACRO_LINUX   5

//--------------------------------------------------------------------------

uint   STDCALL macro_init( void );
pmacro STDCALL macro_set( plexem plex, uint type, uint group );
plexem STDCALL macro_get( plexem plex );

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _MACRO_

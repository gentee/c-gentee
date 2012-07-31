/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: msg 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
* Summary: Message functions.
*
******************************************************************************/

#ifndef _MSG_
#define _MSG_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      


#include "../os/user/defines.h"
#include "msglist.h"

/*-----------------------------------------------------------------------------
*
* ID: msgflags 19.10.06 0.0.A.
* 
* Summary: Flags for msg function
*
-----------------------------------------------------------------------------*/

#define MSG_STR     0x00010000   // The parameter is a string
#define MSG_EXIT    0x00020000   // Exit the thread
//#define MSG_WAIT    0x00040000   // Wait for pressing key. Set up if MSG_EXIT
//#define MSG_START   0x00080000   // Start compilation
//#define MSG_FINISH  0x00100000   // Finish compilation
#define MSG_POS     0x00200000   // The parameter is a position
#define MSG_LEXEM   0x00400000   // The parameter is a lexem
#define MSG_LEXNAME 0x00800000   // Output the name of the lexem
#define MSG_VALUE   0x01000000   // The parameter is a value
#define MSG_VALSTR  0x02000000   // double value + name
#define MSG_VALVAL  0x04000000   // double value

#define MSG_LEXNAMEERR  ( MSG_EXIT | MSG_LEXEM | MSG_LEXNAME )
#define MSG_LEXERR  ( MSG_EXIT | MSG_LEXEM )
#define MSG_VALSTRERR ( MSG_VALUE | MSG_VALSTR | MSG_EXIT )
#define MSG_DVAL ( MSG_VALUE | MSG_VALVAL | MSG_EXIT )

/*-----------------------------------------------------------------------------
*
* ID: msginfo 19.10.06 0.0.A.
* 
* Summary: Type messageinfo.
*
-----------------------------------------------------------------------------*/

typedef struct
{
   uint   code;        // Message code
   uint   flag;        // Message flags
   pubyte filename;
   uint   line;        
   uint   pos;
   pubyte namepar;
   uint   uintpar;
   pubyte pattern;
} msginfo, * pmsginfo;

extern uint _time;  

uint  CDECLCALL msg( uint code, ... );
void  CDECLCALL print( pubyte output, ... );
uint  STDCALL message( pmsginfo minfo );

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _MSG_
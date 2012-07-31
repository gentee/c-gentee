/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: ge 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: The format of the compiled byte-code. Also, this is a format of 
  .ge files.
* 
******************************************************************************/

#ifndef _GE_
#define _GE_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "../common/buf.h"

/*-----------------------------------------------------------------------------
*
* ID: gedefines 19.10.06 0.0.A.
* 
* Summary: The GE defines
*  
-----------------------------------------------------------------------------*/

#define GE_STRING  0x00004547   // 'GE' string
#define GEVER_MAJOR  4
#define GEVER_MINOR  0

/*-----------------------------------------------------------------------------
*
* ID: gehead 19.10.06 0.0.A.
* 
* Summary: The header of GE data
*  
-----------------------------------------------------------------------------*/

typedef struct
{
   uint    idname;    // 'GE' string. It must equal GE_STRING
   uint    flags;     // The GE flags.
   uint    crc;       // CRC from the next byte to the end
   uint    headsize;  // The size of the header data
   uint    size;      // The summary size of this GE. It includes this header
   ubyte   vermajor;  // The major version of .ge format. The virtual machine
                      // can load the byte code only with the same major version
   ubyte   verminor;  // The minor version of .ge format. 
} gehead, * pgehead;

uint STDCALL ge_load( pbuf in );
uint STDCALL ge_save( pbuf out );
void STDCALL ge_optimize( void );
void STDCALL ge_getused( uint id );

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _GE_


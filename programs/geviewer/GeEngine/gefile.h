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



/*-----------------------------------------------------------------------------
* Summary: The GE defines
-----------------------------------------------------------------------------*/

#define GE_STRING  0x00004547   // 'GE' string
#define GEVER_MAJOR  4
#define GEVER_MINOR  0

/*-----------------------------------------------------------------------------
* Summary: The header of GE data
-----------------------------------------------------------------------------*/
#pragma pack(push, 1)
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
#pragma pack(pop)


// Флаги для VAR DWORD MODE

#define  VAR_NAME   0x01   // Есть имя 
#define  VAR_OFTYPE 0x02   // Есть of type
#define  VAR_DIM    0x04   // Есть размерность [,,,]
#define  VAR_IDNAME 0x08   // For define if macro has IDNAME type
// В этом случае, тип строка, но она содержит имя идентификатора
#define  VAR_PARAM  0x10   // Параметр функции или подфункции
#define  VAR_DATA   0x20   // Имеются данные

// Parameters for 'mode' of load_bytecode
#define  VMLOAD_GE      0   // Loading from GE 
#define  VMLOAD_G       1   // Loading from G
#define  VMLOAD_EXTERN  1   // Extern description

pvmobj  STDCALL load_exfunc( pvmEngine pThis, pubyte* input, uint over );
pvmobj  STDCALL load_type( pvmEngine pThis, pubyte* input );
pvmobj  STDCALL load_stack( pvmEngine pThis, int top, int cmd, void* pseudo );
uint STDCALL ge_load( pvmEngine pThis, char* fileName);
uint STDCALL ge_save( pvmEngine pThis, char* fileName, char* isSave);

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _GE_


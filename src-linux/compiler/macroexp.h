/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: macroexp.h 03.11.06 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: Macro expression
*
******************************************************************************/

#ifndef _MACROEXP_
#define _MACROEXP_

   #ifdef __cplusplus
      extern "C" {
   #endif // __cplusplus

#include "../os/user/defines.h"
#include "../lex/lex.h"
#include "../lex/lexgentee.h"
#include "../common/arrdata.h"
#include "../common/msglist.h"
#include "lexem.h"
#include "operlist.h"
#include "bcodes.h"
#include "../genteeapi/gentee.h"

/*-----------------------------------------------------------------------------
*
* ID: macro 03.11.06 0.0.A.
*
* Summary: Macroexpression result structure
*
-----------------------------------------------------------------------------*/
typedef struct
{
   lexem   vallexem; //Копия лексемы с результатом
   uint    bvalue;   //Значение истинности для ifdef
   uint    colpars;  //Количество параметров коллекции
} macrores, * pmacrores;

/*-----------------------------------------------------------------------------
*
* ID: macro 03.11.06 0.0.A.
*
* Summary: Macroexpression operation stack structure
*
-----------------------------------------------------------------------------*/
typedef struct
{
   plexem    operlexem;
   uint      operid;
   pmacrores left;
   uint      flg;
} macrooper, * pmacrooper;

//----------------------------------------------------------------------------
//macroexp.c
plexem STDCALL macroexpr( plexem curlexem, pmacrores * mr );

//--------------------------------------------------------------------------

   #ifdef __cplusplus
      }
   #endif // __cplusplus

#endif // _MACROEXP_

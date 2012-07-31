/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project <http://www.gentee.com>. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* search 20.04.2007 0.0.A.
*
* Author:  
*
******************************************************************************/

#ifndef _QSORT_
#define _QSORT_

#include "../common/types.h"

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

//--------------------------------------------------------------------------

// Флаги для функции fastsort
#define FS_STR         0   // Сортировка строк первый элемент указатель на 
                           // строки
#define FS_STRIGNORE   1   // Сортирвка строк без учета регистра
#define FS_UINT        2   // Сортировка uint
#define FS_USTR        3   // Сортировка строк первый элемент указатель на 
                           // строки
#define FS_USTRIGNORE  4   // Сортирвка строк без учета регистра

//--------------------------------------------------------------------------
void  STDCALL  fastsort( pvoid base, uint count, uint size, uint mode );
void  STDCALL  sort( pvoid base, uint count, uint size, uint idfunc );
void  STDCALL  quicksort( pvoid base, uint count,
                               uint width, cmpfunc func, uint param );

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _QSORT_

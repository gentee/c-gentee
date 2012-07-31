/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: lextbl 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Развертывание таблицы переходов из краткой формы записи
*
******************************************************************************/

#ifndef _LEXTBL_
#define _LEXTBL_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "lex.h"

/*
   Описание краткой формы записи
   0 uint - количество состояний
   Каждая строка начинается с количества описаний.
   0 uint количество описаний помимо default. 

   1 uint default value
   
   По умолчанию 0 является признаком остановки LEX_STOP

   Значение элементов описывается следующим образом. Оно состоит из пар uint 
   1 uint - указываем диапазон или отдельные символы
         1 byte - номер начального 
         2 byte - номер конечного
         3 byte - the first additional character
         4 byte - the second additional character
   2 uint - значение таблицы переходов

   Предопределенные диапазоны
   0x3000 - Цифры и 0x4100
   0x4100 - '_', 'A'-'Z', 'a'-'z' и больше или равно 128
   0x5800 - Цифры и 'A'-'F' и 'a'-'f'

   0 byte - количество блоков ключевых слов
   0 byte - флаги 
            0x0001 ignore case.
   каждый блок состоит из 
     1 uint - начальное значение первого ключевого слова
     Строки с ключевыми словами
     Заканчивается двойным нулем
*/

//--------------------------------------------------------------------------
// output - результирующая таблица переходов
uint  STDCALL lex_tbl( plex pl, puint input );

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _LEXTBL_


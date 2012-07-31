/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: lex 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

#ifndef _LEX_
#define _LEX_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "../common/hash.h"

// Результирующий элемент лексического анализа
typedef struct
{
   uint    type;    // Тип лексемы
   uint    pos;     // Смещение начала лексемы
   uint    len;     // Размер лексемы
   uint    value;   // Дополнительное значение
} lexitem, * plexitem;

typedef struct
{
   uint    chars;   // Последоватлеьность символов.
   uint    value;   // результирующая команда
   ubyte   len;     // количество символов    
} lexmulti, * plexmulti;

typedef struct
{
   ubyte   left;    // Open character ({
   ubyte   right;   // Close caharacter )}
   int     count;   // Counter - stop when -1
   uint    state;   // Return state
} lexexp, * plexexp;

// Структура с таблицей переходов и прочей информацией 
// лексического анализатора
typedef struct
{
   buf     tbl;     // Таблица переходов. Каждая строка должна иметь 
                    // 256 элементов
   arr     state;   // Стэк состояний в котором хранится история состояний.
   arr     litems;  // Хранятся номера lexitem при занесение в стэк state. 
   arr     mitems;  // Массив multi определений
                    // Резервируется 64 блока на всю таблицу по 8 элементов в 
                    // каждом блоке. Каждый элемент lexmulti.
   uint    imulti;  // Текущий свободный номер в массиве multi
   hash    keywords;  // Keywords
   arr     expr;      // Стэк из lexexp 
   ubyte   alloced;   // Под lex отведена память
} lex, *plex;

typedef struct
{
   uint  pos;       // Первая позиция LEX_TRY
//   uint  state;     // Состояние возврата 
   uint  ret;       // Состояние при LEX_RET 
} lextry, *plextry;

// Дополнительные команды
// с 128 идут зарезервированные команды для LEXF_MULTI
#define  LEX_MULTI  0x80000000     // Начало блоков multi всего 64
#define  LEX_EXPR    0xFA000000     // Выражение в \( )
#define  LEX_STRNAME 0xFB000000     // Проверка на имя в строке \[]
#define  LEX_GTNAME  0xFC000000     // Проверка на GT/XML имя 
#define  LEX_SKIP    0xFD000000     // Пропускаем символ
#define  LEX_OK      0xFE000000     // Накапливаем символы
#define  LEX_STOP    0xFF000000     // Команда остановки разбора

// Флаги для элементов таблицы переходов
#define  LEXF_ITSTATE 0x0001  // Формируем элемент от последней запомненной позиции
#define  LEXF_ITCMD   0x0002  // Формируем элемент от последней запомненной позиции
#define  LEXF_POS     0x0004  // Запоминаем позицию
#define  LEXF_STAY    0x0008  // Оставаться на месте
#define  LEXF_TRY     0x0010  // Проба возможного варианта
#define  LEXF_RET     0x0020  // Возврат на последнее состояние при LEXF_TRY
#define  LEXF_VALUE   0x0040  // value = строковое значение лексемы
#define  LEXF_PUSH    0x0080  // Запомнить текущее состояние
#define  LEXF_POP     0x0100  // Возвратиться в последнее запомненное состояние
#define  LEXF_PUSHLI  0x0200  // Занести данные lexitem в стэк.
#define  LEXF_POPLI   0x0400  // Убрать данные lexitem из стэка.
#define  LEXF_MULTI   0x0800  // Смотреть на комбинацию символов (до 4).
#define  LEXF_KEYWORD 0x1000  // Может быть ключевым словом
#define  LEXF_NEW     0x2000  // Создать новый элемент 
#define  LEXF_PAIR    0x4000  // Учитывать парные скобки

/*
   Описание таблицы переходов

   Таблица переходов состоит из строк по 256 элементов uint.
   
   Элемент таблицы переходов (uint с 0-255)
   1 - 2 bytes
     Flags
   3 byte       Если флаг LEXF_MULTI то указывает количество - 1
     New state
   4 byte       Если флаг LEXF_MULTI то номер строки в mitems 
     Command    Если флаг LEXF_TRY то номер состояния в случае LEX_RET
*/

#ifndef RUNTIME

//--------------------------------------------------------------------------
// output - результирующий массив элементов lexitem
uint  STDCALL gentee_lexptr( pubyte input, plex pl, parr output );
uint  STDCALL gentee_lex( pbuf input, plex pl, parr output );
plex  STDCALL lex_init( plex pl, puint ptbl );
void  STDCALL lex_delete( plex pl );

//--------------------------------------------------------------------------

#endif

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _COMPILE_


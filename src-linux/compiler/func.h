/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: func 02.11.06 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: Описания функций, структур, констант необходимых для компиляции
*
******************************************************************************/

#ifndef _FUNC_
#define _FUNC_

   #ifdef __cplusplus
      extern "C" {
   #endif // __cplusplus

#include "../os/user/defines.h"
#include "../lex/lex.h"
#include "../lex/lexgentee.h"
#include "../common/arrdata.h"
#include "../common/msglist.h"
#include "../genteeapi/gentee.h"
#include "../vm/vmload.h"
#include "../bytecode/cmdlist.h"
#include "lexem.h"
#include "operlist.h"
#include "type.h"
#include "out.h"

/*-----------------------------------------------------------------------------
*
* ID: funcdata 02.11.06 0.0.A.
*
* Summary: funcdata structure.
*
-----------------------------------------------------------------------------*/

typedef struct
{
   //Не менять порядок расположения buf, в случае необходимости добавлять в конец
   buf  bhead;    //Заголовок функции
   buf  bvardef;  //Блок для описания локальных переменных
   buf  bfuncout; //Байт-код
   buf  bsubout;  //Байт-код для подфункций
   buf  bblinit;  //Текущий стэк для команд инициализации блоков
   buf  bvars;    //Стэк локальных переменных, заполнен fvar
   buf  blabels;  //Стэк меток, заполнен flabel
   buf  bwith;    //Стэк сокращений with, заполнен fwith
   buf  bvarsas;  //Стэк переменных, заполнен fvaras

   pbuf bout;     //Текущий буфер вывода байткода

   hash nvars;    //Хэш таблица локальных переменных
   hash nlabels;  //Хэш таблица меток

   uint blcount;      //Общее количество блоков
   uint varcount;     //Общее количество локальных переменных
   uint curcount;     //Текущее количество локальных переменных
   uint lastcurcount; //Количество локальных переменных в верхнем блоке

   uint oldoffbvar;   //Размер таблицы локальных переменных на начало текущего блока
   uint functype;     //Тип функции
   uint funcoftype;   //Подтип функции
   uint bllevel;      //Уровень вложенности текущего блока
   uint offlcbreak;   //Смещение в таблице меток указывающие на break для цикла
   uint offlccontinue;//Смещение в таблице меток указывающие на continue для цикла
   uint blcycle;      //Вложенность циклов
   uint flgfunc;      //Флаг функции
   uint idresult;     //Идентификатор параметра result
   uint offsubgoto;   //Смещение перехода через подфунции
} s_funcdata, * ps_funcdata;

//Структура для хранения исходных типов переменных as
typedef struct
{
   uint offbvar;  //Значение смещения в таблице bvars
   uint type;     //Исходный тип
   uint oftype;   //Тип элемента
   uint flg;
} fvaras, *pfvaras;

//Структура для хранения with
typedef struct
{
   uint num;      //Номер локальной переменной
   uint type;     //Тип объекта
   uint oftype;   //Тип элемента объекта   
} fwith, *pfwith;

//Структура для хранения значения в хэше
typedef struct
{
   hashitem item;
   uint     val;
} hashiuint, *phashiuint;


#define FVAR_SUBFUNC 0x01
#define FVAR_UINTAS  0x02
//Структура локальной переменной
typedef struct
{
   phashiuint hidn; //Идентификатор в таблице имён
   uint flg;        //Если 1 значит идентификатор тип
   uint type;       //Тип переменной
   uint num;        //Номер переменной в таблице локальных переменных
   uint msr;        //Размерность для массива
   uint oftype;     //Тип элемента массива
   uint oldoffbvar; //Значение старого смещение переменной в bvars + 1, для переопределения переменных

   uint addr;       //Адрес для подфункции
   uint pars;       //Количество параметров у подфункции
   uint offbvardef; //Смещение в буфере описания переменных функции

} fvar, *pfvar;

// Структура для таблицы меток
typedef struct
{
   uint type; //Тип LABT_*
union {
   uint link; //Связь, идентификатор в хэш таблице меток, идентификатор в таблице
   phashiuint hitem;
};
   uint offbout;//Смещение в байткоде
   plexem lex;  //Указатель на лексему с меткой для LABT_LABEL
} flabel, *pflabel;


//Структура описания типа
typedef struct
{
   uint idtype;//Идентификатор типа
   uint oftype;//Тип элемента
   byte msr;   //Размерность
} s_desctype, *ps_desctype;


//--------------------------------------------------------------------------
//body.c
plexem STDCALL f_body( plexem plex );

//----------------------------------------------------------------------------
//desc.c
plexem STDCALL desc_nextidvar( plexem curlex, ps_descid pdescid );
plexem STDCALL desc_idtype( plexem curlex, ps_desctype pdesctype );

//----------------------------------------------------------------------------
//expr.c
extern uint artypes[];
#define EXPR_ORD    0x01   //Значение flg, при обработке обычного выражения
#define EXPR_MACROS 0x02   //Выражение для макросов
#define EXPR_VAR    0x04   //Обработка в определении локальных переменных
#define EXPR_COMMA  0x08   //Выражение обрабатывать до запятой
#define EXPR_BOOL   0x10   //Выражение истины
#define EXPR_NONULL 0x20   //Тип выражения должен быть не ноль
#define EXPR_ARR    0x40   //Размерность массива
//Флаги состояния функции для проверки ошибок синтаксиса в выражении
#define L_OPERAND    0x01  //Операнд
#define L_POST_CLOSE 0x02  //Унарный пост оператор, закрывающая скобка
#define L_BINARY     0x04  //Бинарный оператор
#define L_UNARY_OPEN 0x08  //Унарный пре оператор, открывающая скобка
#define L_FUNC       0x10  //Последнее было имя функции ожидается (

plexem STDCALL f_expr( plexem curlex, uint flg, puint rettype, puint retoftype );

//----------------------------------------------------------------------------
//extern.c
plexem STDCALL m_extern( plexem curlex );

//----------------------------------------------------------------------------
//for.c
plexem STDCALL c_for( plexem curlex );
plexem STDCALL c_fornum( plexem curlex );

//----------------------------------------------------------------------------
//foreach.c
plexem STDCALL c_foreach( plexem curlex );

//----------------------------------------------------------------------------
//func.c
extern s_funcdata fd;

plexem STDCALL m_func( plexem curlex, uint flgextern );

//----------------------------------------------------------------------------
//if.c
plexem STDCALL c_if( plexem curlex );

//----------------------------------------------------------------------------
//goto.c
plexem STDCALL c_goto( plexem curlex );
plexem STDCALL c_label( plexem curlex );

//----------------------------------------------------------------------------
//jump.c
#define LABT_VIRT       0x0100
#define LABT_GT         0x0200
#define LABT_GTUNDEF    ( LABT_GT | 0x0001 )  //Неразрешенный переход, в link идентификатор в хэш таблице
#define LABT_GTDEF      ( LABT_GT | 0x0002 )  //Разрешенная переход или переход на виртуальную метку, в link идентификатор в таблице меток
#define LABT_LABEL      0x0004  //Метка, в link идентификатор в хэш таблице
#define LABT_LABELUNDEF 0x0008  //Отработавшая метка
#define LABT_GTVIRT     ( LABT_VIRT | LABT_GT )
#define LABT_LABELVIRT  ( LABT_VIRT ) //Виртуальная метка
#define LABT_SUBFUNC    0x1000   //Метка находится внутри подфункции
#define LABT_RETURN     0x2000 //На данную метку был переход
#define LABT_LABELWORK  0x4000

void STDCALL j_correct( uint curoff, uint link );
uint STDCALL j_jump( uint cmd, uint flag, uint link );
uint STDCALL j_label( uint flag, uint link );

//----------------------------------------------------------------------------
//subfunc.c
plexem STDCALL f_subfunc( plexem curlex );

//----------------------------------------------------------------------------
//switch.c
plexem STDCALL c_switch( plexem curlex );

//----------------------------------------------------------------------------
//vars.c
#define DESCID_GLOBTYPE   0x010 //Описание глобальная переменная, описание структуры - arr a[10,20] of str
#define DESCID_GLOBAL     0x010
#define DESCID_TYPE	     0x011
#define DESCID_SUBFUNC    0x021//Описание подфункции
#define DESCID_PAR        0x040 //Описание параметра функции - arr a of str
#define DESCID_PARFUNC    0x040
#define DESCID_PARSUBFUNC 0x041
#define DESCID_VAR        0x080 //Описание локальной переменной - arr a[x+10,y+20] of str

plexem STDCALL var_def( plexem curlex, uint flgdesc );
uint STDCALL var_checkadd( ps_descid descvar );
STDCALL create_varmode( pbuf out, ps_desctype desctype, ps_descid descid );
plexem STDCALL var_def( plexem curlex, uint flgdesc );
uint STDCALL var_add( phashiuint hidn, ps_descid descvar );
uint STDCALL var_addtmp( uint type, uint oftype );

//----------------------------------------------------------------------------
//while.c
plexem STDCALL c_while( plexem curlex );
plexem STDCALL c_dowhile( plexem curlex );

//----------------------------------------------------------------------------
//with.c
plexem STDCALL c_with( plexem curlex );

#ifdef DOUT
#define D printf
#else
#define D /**////##/
#endif
   #ifdef __cplusplus
      }
   #endif // __cplusplus

#endif // _FUNC_

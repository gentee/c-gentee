/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vmload 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Load objects into VM
* 
******************************************************************************/

#ifndef _VMLOAD_
#define _VMLOAD_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "vmrun.h"

// Флаги для VAR DWORD MODE

#define  VAR_NAME   0x01   // Есть имя 
#define  VAR_OFTYPE 0x02   // Есть of type
#define  VAR_DIM    0x04   // Есть размерность [,,,]
#define  VAR_IDNAME 0x08   // For define if macro has IDNAME type
// В этом случае, тип строка, но она содержит имя идентификатора
#define  VAR_PARAM  0x10   // Параметр функции или подфункции
#define  VAR_DATA   0x20   // Имеются данные

//--------------------------------------------------------------------------
/*    FULL MODE

Все FULL MODE должны начинаться с 
1 - byte - тип объекта OVM_*****
2 - uint - флаги flags
3 - BWD  - размер загружаемых данных - весь включая общие данные
4 - pbyte - последовательность байт до 0 - имя объекта если есть флаг GHCOM_NAME 

//--------------------------------------------------------------------------

Формат описания переменной определенного типа VAR DWORD MODE 

BWD - тип
ubyte - [VARFLAG] флаги VAR_

if [VARFLAG] & VAR_NAME
   pbyte - имя подтипа - последовательность байт до 0

if [VARFLAG] & VAR_OFTYPE
   BWD - Тип - oftype 

if [VARFLAG] & VAR_DIM
   ubyte - [DIM] - размерность
   for [DIM]
      BWD - величины размерностей

if [VARFLAG] & VAR_DATA
   Последовательность данных. Для чисел - числа
   Для прочих 
      BWD - размер 
      Далее идет данные 

//--------------------------------------------------------------------------

 Формат DWORD MODE для OVM_TYPE 

if  GHTY_INHERIT
   BWD - Тип - родитель inherit если есть флаг GHTY_INHERIT

if GHTY_INDEX
   BWD - Тип - index 
   BWD - Тип - index oftype 

if GHTY_INITDEL
   BWD - ID - method init
   BWD - ID - method delete

if GHTY_EXTFUNC
   BWD - ID - method oftype
   BWD - ID - method  = %{}

if GHTY_ARRAY 
   if BWD > MAX_MSR - один метод ID array 
   else array[ MAX_MSR ] - методы array 

BWD - [COUNT] - Количество подтипов. Если GHTY_STACK, то размер

for [COUNT]
   Описание [VAR DWORD MODE]

//--------------------------------------------------------------------------

 Формат DWORD MODE для OVM_BYTECODE

[VAR DWORD MODE] - тип возвращаемого значения
BWD - [PAR COUNT] - Количество параметров

for [ PAR COUNT ]  
   Описания [VAR DWORD MODE] параметров

BWD - [SET COUNT] - Количество блоков параметров

for [ SET COUNT ]  
   BWD - [VAR COUNT] - Количество переменных

for [SUMMARY VAR COUNT]
   Описания [VAR DWORD MODE] параметров

dwords - последовательность dword - команды байт кода

//--------------------------------------------------------------------------

 Формат DWORD MODE для OVM_EXFUNC

[VAR DWORD MODE] - тип возвращаемого значения
BWD - [PAR COUNT] - Количество параметров

for [ PAR COUNT ]  
   Описания [VAR DWORD MODE] параметров

if [GHEX_IMPORT]
   BWD - library id
   pubyte - the original name

//--------------------------------------------------------------------------

 Формат DWORD MODE для OVM_DEFINE

dword [COUNT] - Количество элементов
for [COUNT]
   Описание [VAR DWORD MODE]

//--------------------------------------------------------------------------

 Формат DWORD MODE для OVM_IMPORT

pubyte - the name of the file
if GHIMP_LINK
   dword [SIZE] - the size of DLL
   ubyte SIZE - the body of the dll

//--------------------------------------------------------------------------

 Формат DWORD MODE для OVM_GLOBAL

[VAR DWORD MODE] - тип переменной

//--------------------------------------------------------------------------

 Формат DWORD MODE для OVM_ALIAS

BWD - the id of linked object

//--------------------------------------------------------------------------

 Формат DWORD MODE для OVM_RESOURCE

BWD - [COUNT] - Количество строк
for [COUNT]
   BWD - the id of type
   TStr pubyte - строка 
*/

// Parameters for 'mode' of load_bytecode
#define  VMLOAD_GE      0   // Loading from GE 
#define  VMLOAD_G       1   // Loading from G
#define  VMLOAD_EXTERN  1   // Extern description
#define  VMLOAD_FIRST   2   // Pre-loading function
#define  VMLOAD_OK      3   // Loading byte-code

uint    STDCALL load_bwd( pubyte * ptr );
uint    STDCALL load_convert( pubyte * ptr );
pvmobj  STDCALL load_addobj( uint over );
pvmobj  STDCALL load_stack( int top, int cmd, stackfunc pseudo );
pvmobj  STDCALL load_type( pubyte* input );
pvmobj  STDCALL load_bytecode( pubyte* input, uint mode );
pvmobj  STDCALL load_exfunc( pubyte* input, uint over );
pvmobj  STDCALL load_define( pubyte* input );
pvmobj  STDCALL load_import( pubyte* input );
pvmobj  STDCALL load_global( pubyte* input );
pvmobj  STDCALL load_alias( pubyte* input );

#ifdef _ASM
   void STDCALL ge_toasm( uint id, pbuf bout );
#endif

/*

  По окончанию загрузки предворительная инициализация

  Заполняем поля GHRT_INIT GHRT_DEINIT у типов
  Инициализируем global variables
  выполняем entry
  выполняем main если это необходимо
*/

//--------------------------------------------------------------------------


   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _VMLOAD_


/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: lexem 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Working with lexems
*
******************************************************************************/

#ifndef _LEXEM_
#define _LEXEM_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "../common/str.h"
#include "../common/arr.h"
#include "../common/number.h"

/*-----------------------------------------------------------------------------
*
* ID: lexemtype 23.10.06 0.0.A.
* 
* Summary: The type of lexems
*  
-----------------------------------------------------------------------------*/

#define LEXEM_SKIP     0x0000    //  Skip this lexem
#define LEXEM_BINARY   0x0001    //  Binary data 
#define LEXEM_STRING   0x0002    //  Text string 
#define LEXEM_NUMBER   0x0003    //  Number decimal, hexadecimal, float or double 
#define LEXEM_MACRO    0x0004    //  Macro identifier $name 
#define LEXEM_OPER     0x0005    //  Operations 
#define LEXEM_NAME     0x0006    //  Name identifier 
#define LEXEM_KEYWORD  0x0007    //  Keyword
#define LEXEM_FILENAME 0x0008    //  Data from filename
#define LEXEM_COLLECT  0x0009    //  Collection for macro expressions
//#define LEXEM_LINE    0x0003    //  New line 0x0D0A or 0x0A 

/*-----------------------------------------------------------------------------
*
* ID: lexemsys 23.10.06 0.0.A.
* 
* Summary: Some characters
*  
-----------------------------------------------------------------------------*/

#define LSYS_LBRACK     0x00000028    // (
#define LSYS_RBRACK     0x00000029    // )
#define LSYS_COMMA      0x0000002C    // ,
#define LSYS_DOT        0x0000002E    // .
#define LSYS_LESS       0x0000003C    // <
#define LSYS_EQ         0x0000003D    // =
#define LSYS_GREATER    0x0000003E    // >
#define LSYS_LCURLY     0x0000007B    // {
#define LSYS_VLINE      0x0000007C    // |
#define LSYS_RCURLY     0x0000007D    // }
#define LSYS_COLLECT    0x00007B25    // %{
#define LSYS_PLUSEQ     0x00003D2B    // +=
#define LSYS_PTR        0x00003E2D    // ->

/*-----------------------------------------------------------------------------
*
* ID: lexoper 23.10.06 0.0.A.
* 
* Summary: The type of operation lexem
*  
-----------------------------------------------------------------------------*/

typedef struct
{
   uint    name;     // LEXSYS_****
   uint    operid;   // the identifier of the operation
} lexoper, * plexoper;

// Флаги для lexitem
#define  LEXF_CALL      0x01    // Возможный вызов функции или метода так как следом идет 
                                // круглая скобка
#define  LEXF_METHOD    0x02    // Вызов или описание метода
#define  LEXF_OPERATOR  0x04    // Вызов или описание оператора
#define  LEXF_ARR       0x08    // Возможное обращение к массивы так как следом идет 
                                // квадратная скобка
#define  LEXF_PROPERTY  0x10    // Метод должен быть свойством
#define  LEXF_NAME      0x20    // Передача указателя на имя

/*-----------------------------------------------------------------------------
*
* ID: lexem 23.10.06 0.0.A.
* 
* Summary: The lexem type
*  
-----------------------------------------------------------------------------*/

typedef struct
{
   uint    flag;    // Lexem flags
   ubyte   type;    // Lexem type
   uint    pos;     // The offset of the lexem
   union {
      uint    binid;  // BINARY
      uint    strid;  // STRING
      uint    macroid; // MACRO
      uint    nameid;  // NAME
      uint    key;     // KEYWORD
      number  num;     // NUMBER
      lexoper oper;    // OPERATION
   };
} lexem, * plexem;

typedef struct
{	
	uint flgdesc;
	uint idtype;//Идентификатор типа
	
   uint oftype;//Тип элемента
   uint msr;   //Размерность
	uint msrs[MAX_MSR];  //Меры
	pubyte name; //Имя параметра-переменной
	plexem lex;  //Текущая лексема для вывода ошибки
   plexem lexres;   // Лексема для реультата макровыражения
} s_descid, *ps_descid;

/*-----------------------------------------------------------------------------
*
* ID: lexnextflag 23.10.06 0.0.A.
* 
* Summary: Flag for lexem_next
*  
-----------------------------------------------------------------------------*/

#define LEXNEXT_IGNLINE  0x0001  // Skip LEXEM_OPER ->OpLine
#define LEXNEXT_NULL     0x0002  // Return NULL if there is not the next lexem
                                 // otherwise error
#define LEXNEXT_LCURLY   0x0004  // Wait for left curly {
#define LEXNEXT_IGNCOMMA 0x0008  // Ignore ,
#define LEXNEXT_SKIPLINE 0x0010  // Skip new line move only if lex is New line
#define LEXNEXT_NAME     0x0020  // Must be a name of the indentifier
#define LEXNEXT_NAMEDEF  0x0040  // Check mygroup.myname for 'namedef' macros
#define LEXNEXT_NOMACRO  0x0080  // Ignore $Macros

//--------------------------------------------------------------------------

uint    STDCALL  lexem_load( parr lexems, parr input );
plexem  STDCALL  lexem_copy( plexem dest, plexem src );
void    STDCALL  lexem_delete( parr lexems );
pstr    STDCALL  lexem_getstr( plexem plex );
uint    STDCALL  lexem_isys( plexem plex, uint ch );
plexem  STDCALL  lexem_next( plexem plex, uint flag );
pubyte  STDCALL  lexem_getname( plexem plex );

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _LEXEM_


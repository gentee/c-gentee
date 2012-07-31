/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project <http://www.gentee.com>.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* operlist_h 31.03.2008 0.0.A.
*
* Author: Generated with 'operlist' program
*
* Summary: This file contains a list of the compiler's or VM's messages.
*
******************************************************************************/

#ifndef _OPERLIST_
#define _OPERLIST_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "../common/types.h"

//Флаги операций для таблицы операций
#define OPF_NOP		0x1		//Не имеет кода операции
#define OPF_BINARY		0x2		//Бинарная операция
#define OPF_UNARY		0x4		//Унарная операция стоящая перед операндом
#define OPF_POST		0x8		//Унарная операция стоящая после операнда
#define OPF_UNDEF		0x10		//Операция не определена, следующая операция, для данного типа всегда должен стоять unary
#define OPF_RETUINT		0x20		//Операция будет возвращать uint
#define OPF_ADDNOT		0x40		//Данная операция разбивается на две - предыдущая операция и логическое НЕТ
#define OPF_OPEN		0x80		//Открывающая скобка
#define OPF_CLOSE		0x100		//Закрывающая скобка
#define OPF_LVALUE		0x200		//LValue операция


#define  OPERCOUNT  65 //Количество операций

//Идентификаторы операций
enum {
   OpAs,		  // 0x0 ""
   OpFunc,		  // 0x1 ""
   OpLine,		  // 0x2 ""
   OpStrappend,		  // 0x3 "+="
   OpStrtext,		  // 0x4 "@"
   OpPlus,		  // 0x5 "+"
   OpAdd,		  // 0x6 "+"
   OpMinus,		  // 0x7 "-"
   OpSub,		  // 0x8 "-"
   OpLen,		  // 0x9 "*"
   OpMul,		  // 0xA "*"
   OpDiv,		  // 0xB "/"
   OpMod,		  // 0xC "%"
   OpBinnot,		  // 0xD "~"
   OpLate,		  // 0xE "~"
   OpAddr,		  // 0xF "&"
   OpBinand,		  // 0x10 "&"
   OpBinxor,		  // 0x11 "^"
   OpBinor,		  // 0x12 "|"
   OpLognot,		  // 0x13 "!"
   OpLogand,		  // 0x14 "&&"
   OpLogor,		  // 0x15 "||"
   OpLeft,		  // 0x16 "<<"
   OpRight,		  // 0x17 ">>"
   OpIncleft,		  // 0x18 "++"
   OpIncright,		  // 0x19 "_++"
   OpDecleft,		  // 0x1A "--"
   OpDecright,		  // 0x1B "_--"
   OpSet,		  // 0x1C "="
   OpAddset,		  // 0x1D "+="
   OpSubset,		  // 0x1E "-="
   OpMulset,		  // 0x1F "*="
   OpDivset,		  // 0x20 "/="
   OpModset,		  // 0x21 "%="
   OpAndset,		  // 0x22 "&="
   OpOrset,		  // 0x23 "|="
   OpXorset,		  // 0x24 "^="
   OpLeftset,		  // 0x25 "<<="
   OpRightset,		  // 0x26 ">>="
   OpComma,		  // 0x27 ","
   OpWith,		  // 0x28 "."
   OpPoint,		  // 0x29 "."
   OpPtr,		  // 0x2A "->"
   OpQuest,		  // 0x2B "?"
   OpStrout,		  // 0x2C "@"
   OpStradd,		  // 0x2D "@"
   OpLbrack,		  // 0x2E "("
   OpRbrack,		  // 0x2F ")"
   OpLsqbrack,		  // 0x30 "["
   OpRsqbrack,		  // 0x31 "]"
   OpLcrbrack,		  // 0x32 "{"
   OpRcrbrack,		  // 0x33 "}"
   OpCollect,		  // 0x34 "%{"
   OpEq,		  // 0x35 "=="
   OpNoteq,		  // 0x36 "!="
   OpGreater,		  // 0x37 ">"
   OpLesseq,		  // 0x38 "<="
   OpLess,		  // 0x39 "<"
   OpGreateq,		  // 0x3A ">="
   OpIgneq,		  // 0x3B "%=="
   OpIgnnoteq,		  // 0x3C "%!="
   OpIgngreater,		  // 0x3D "%>"
   OpIgnlesseq,		  // 0x3E "%<="
   OpIgnless,		  // 0x3F "%<"
   OpIgngreateq,		  // 0x40 "%>="

};

//Структура для описания операций
typedef struct {
   ubyte     before; // Приоритет на входе в стэк операций
   ubyte     after;  // Приоритет после вставки в стэк операций
   ushort    flgs;   // Тип операции OPER_   
} soper, * psoper;

extern const soper opers[];
extern const ubyte operlexlist[];
   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _OPERLIST_

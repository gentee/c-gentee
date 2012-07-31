/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project <http://www.gentee.com>.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* operlist_c 31.03.2008 0.0.A.
*
* Author: Generated with 'operlist' program
*
* Summary: 
*
******************************************************************************/


#include "operlist.h"

//Таблица приоритетов и типов операций
const soper opers[] = {
   { 14, 3, OPF_NOP | OPF_BINARY | OPF_LVALUE },// ''  OpAs 
   { 18, 18, OPF_NOP | OPF_UNARY },// ''  OpFunc 
   { 0, 0, OPF_NOP },// ''  OpLine 
   { 18, 18, OPF_BINARY | OPF_LVALUE },// '+='  OpStrappend 
   { 18, 18, OPF_UNARY },// '@'  OpStrtext 
   { 16, 15, OPF_NOP | OPF_UNARY | OPF_UNDEF },// '+'  OpPlus 
   { 12, 12, OPF_BINARY },// '+'  OpAdd 
   { 16, 15, OPF_UNARY | OPF_UNDEF },// '-'  OpMinus 
   { 12, 12, OPF_BINARY },// '-'  OpSub 
   { 16, 15, OPF_UNARY | OPF_UNDEF },// '*'  OpLen 
   { 13, 13, OPF_BINARY },// '*'  OpMul 
   { 13, 13, OPF_BINARY },// '/'  OpDiv 
   { 13, 13, OPF_BINARY },// '%'  OpMod 
   { 16, 15, OPF_UNARY | OPF_UNDEF },// '~'  OpBinnot 
   { 17, 17, OPF_NOP | OPF_BINARY },// '~'  OpLate 
   { 16, 15, OPF_NOP | OPF_UNARY | OPF_UNDEF | OPF_RETUINT | OPF_LVALUE },// '&'  OpAddr 
   { 8, 8, OPF_BINARY },// '&'  OpBinand 
   { 7, 7, OPF_BINARY },// '^'  OpBinxor 
   { 6, 6, OPF_BINARY },// '|'  OpBinor 
   { 16, 15, OPF_UNARY },// '!'  OpLognot 
   { 5, 5, OPF_NOP | OPF_BINARY | OPF_RETUINT },// '&&'  OpLogand 
   { 4, 4, OPF_NOP | OPF_BINARY | OPF_RETUINT },// '||'  OpLogor 
   { 11, 11, OPF_BINARY },// '<<'  OpLeft 
   { 11, 11, OPF_BINARY },// '>>'  OpRight 
   { 16, 15, OPF_UNARY | OPF_UNDEF | OPF_LVALUE },// '++'  OpIncleft 
   { 16, 15, OPF_POST | OPF_LVALUE },// '_++'  OpIncright 
   { 16, 15, OPF_UNARY | OPF_UNDEF | OPF_LVALUE },// '--'  OpDecleft 
   { 16, 15, OPF_POST | OPF_LVALUE },// '_--'  OpDecright 
   { 14, 3, OPF_BINARY | OPF_LVALUE },// '='  OpSet 
   { 14, 3, OPF_BINARY | OPF_LVALUE },// '+='  OpAddset 
   { 14, 3, OPF_BINARY | OPF_LVALUE },// '-='  OpSubset 
   { 14, 3, OPF_BINARY | OPF_LVALUE },// '*='  OpMulset 
   { 14, 3, OPF_BINARY | OPF_LVALUE },// '/='  OpDivset 
   { 14, 3, OPF_BINARY | OPF_LVALUE },// '%='  OpModset 
   { 14, 3, OPF_BINARY | OPF_LVALUE },// '&='  OpAndset 
   { 14, 3, OPF_BINARY | OPF_LVALUE },// '|='  OpOrset 
   { 14, 3, OPF_BINARY | OPF_LVALUE },// '^='  OpXorset 
   { 14, 3, OPF_BINARY | OPF_LVALUE },// '<<='  OpLeftset 
   { 14, 3, OPF_BINARY | OPF_LVALUE },// '>>='  OpRightset 
   { 2, 2, OPF_NOP | OPF_BINARY },// ','  OpComma 
   { 16, 15, OPF_UNARY | OPF_UNDEF },// '.'  OpWith 
   { 17, 17, OPF_BINARY },// '.'  OpPoint 
   { 17, 17, OPF_NOP | OPF_BINARY },// '->'  OpPtr 
   { 18, 18, OPF_NOP | OPF_UNARY },// '?'  OpQuest 
   { 16, 15, OPF_NOP | OPF_UNARY | OPF_UNDEF },// '@'  OpStrout 
   { 12, 12, OPF_BINARY },// '@'  OpStradd 
   { 19, 1, OPF_NOP | OPF_OPEN },// '('  OpLbrack 
   { 1, 20, OPF_NOP | OPF_CLOSE },// ')'  OpRbrack 
   { 18, 1, OPF_NOP | OPF_OPEN },// '['  OpLsqbrack 
   { 1, 20, OPF_NOP | OPF_CLOSE },// ']'  OpRsqbrack 
   { 19, 1, OPF_NOP | OPF_OPEN },// '{'  OpLcrbrack 
   { 1, 20, OPF_NOP | OPF_CLOSE },// '}'  OpRcrbrack 
   { 19, 1, OPF_NOP | OPF_OPEN },// '%{'  OpCollect 
   { 9, 9, OPF_BINARY },// '=='  OpEq 
   { 9, 9, OPF_BINARY | OPF_ADDNOT },// '!='  OpNoteq 
   { 10, 10, OPF_BINARY },// '>'  OpGreater 
   { 10, 10, OPF_BINARY | OPF_ADDNOT },// '<='  OpLesseq 
   { 10, 10, OPF_BINARY },// '<'  OpLess 
   { 10, 10, OPF_BINARY | OPF_ADDNOT },// '>='  OpGreateq 
   { 9, 9, OPF_BINARY },// '%=='  OpIgneq 
   { 9, 9, OPF_BINARY | OPF_ADDNOT },// '%!='  OpIgnnoteq 
   { 10, 10, OPF_BINARY },// '%>'  OpIgngreater 
   { 10, 10, OPF_BINARY | OPF_ADDNOT },// '%<='  OpIgnlesseq 
   { 10, 10, OPF_BINARY },// '%<'  OpIgnless 
   { 10, 10, OPF_BINARY | OPF_ADDNOT },// '%>='  OpIgngreateq 

};

//Список строк операций
const ubyte operlexlist[] = { 0, 0, 0, '+', '=', 0, '@', 0, '+', 0, 0, '-', 
0, 0, '*', 0, 0, '/', 0, '%', 0, '~', 0, 0, '&', 0, 0, '^', 0, '|', 0, '!', 
0, '&', '&', 0, '|', '|', 0, '<', '<', 0, '>', '>', 0, '+', '+', 0, '_', '+', 
'+', 0, '-', '-', 0, '_', '-', '-', 0, '=', 0, '+', '=', 0, '-', '=', 0, '*', 
'=', 0, '/', '=', 0, '%', '=', 0, '&', '=', 0, '|', '=', 0, '^', '=', 0, '<', 
'<', '=', 0, '>', '>', '=', 0, ',', 0, '.', 0, 0, '-', '>', 0, '?', 0, '@', 
0, 0, '(', 0, ')', 0, '[', 0, ']', 0, '{', 0, '}', 0, '%', '{', 0, '=', '=', 
0, '!', '=', 0, '>', 0, '<', '=', 0, '<', 0, '>', '=', 0, '%', '=', '=', 0, 
'%', '!', '=', 0, '%', '>', 0, '%', '<', '=', 0, '%', '<', 0, '%', '>', '=', 
0, };



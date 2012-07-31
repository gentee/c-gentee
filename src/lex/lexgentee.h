/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project <http://www.gentee.com>. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* lexgentee 26.07.2007
*
* Author: Generated with 'lextbl' program 
*
* Description: This file contains a lexical table for the lexical analizer.
*
******************************************************************************/

#ifndef _LEXGENTEE_
#define _LEXGENTEE_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

// States
#define G_BINARY 0x210000 //  Binary data 
#define G_TEXTSTR 0x200000 //  Text string 
#define G_LINE 0x2000000 //  New line 0x0D0A or 0x0A 
#define G_NUMBER 0x3000000 //  Number decimal, hexadecimal, float or double 
#define G_SYSCHAR 0x4000000 //  Punctuation marks 
#define G_STRING 0x1C0000 //  String 
#define G_FILENAME 0x1D0000 //  File data \<filename> 
#define G_MACRO 0x5000000 //  Macro identifier $name or $name$ 
#define G_OPERCHAR 0x1000000 //  Operations 
#define G_NAME 0x80000 //  Name identifier 
#define G_MACROSTR 0x1B0000 //  Macro string $"String" 

// Keywords
#define KEY_AS 0x1 // 1
#define KEY_BREAK 0x2 // 2
#define KEY_CASE 0x3 // 3
#define KEY_CDECL 0x4 // 4
#define KEY_CONTINUE 0x5 // 5
#define KEY_DEFAULT 0x6 // 6
#define KEY_DEFINE 0x7 // 7
#define KEY_DO 0x8 // 8
#define KEY_ELIF 0x9 // 9
#define KEY_ELSE 0xA // 10
#define KEY_EXTERN 0xB // 11
#define KEY_FOR 0xC // 12
#define KEY_FOREACH 0xD // 13
#define KEY_FORNUM 0xE // 14
#define KEY_FUNC 0xF // 15
#define KEY_GLOBAL 0x10 // 16
#define KEY_GOTO 0x11 // 17
#define KEY_IF 0x12 // 18
#define KEY_IFDEF 0x13 // 19
#define KEY_IMPORT 0x14 // 20
#define KEY_INCLUDE 0x15 // 21
#define KEY_LABEL 0x16 // 22
#define KEY_METHOD 0x17 // 23
#define KEY_OF 0x18 // 24
#define KEY_OPERATOR 0x19 // 25
#define KEY_PRIVATE 0x1A // 26
#define KEY_PROPERTY 0x1B // 27
#define KEY_PUBLIC 0x1C // 28
#define KEY_RETURN 0x1D // 29
#define KEY_SIZEOF 0x1E // 30
#define KEY_STDCALL 0x1F // 31
#define KEY_SWITCH 0x20 // 32
#define KEY_SUBFUNC 0x21 // 33
#define KEY_TYPE 0x22 // 34
#define KEY_WHILE 0x23 // 35
#define KEY_WITH 0x24 // 36
#define KEY_TEXT 0xFF // 255


   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _LEXGENTEE_

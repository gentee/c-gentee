/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project <http://www.gentee.com>. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* lexfgentee 24.11.2006
*
* Author: Generated with 'lextbl' program 
*
* Description: This file contains a lexical table for the lexical analizer.
*
******************************************************************************/


define
{
   // States
   FG_BINARY = 0x240000   //  Binary data 
   FG_TEXTSTR = 0x230000   //  Text string 
   FG_COMMENT = 0x90000   //  Comment /* ... */ 
   FG_UNKNOWN = 0x40000   //  Unknown characters 
   FG_LINE = 0x2000000   //  New line 0x0D0A or 0x0A 
   FG_NUMBER = 0x3000000   //  Number decimal, hexadecimal, float or double 
   FG_IGNLINE = 0x30000   //  Ignore line character \ 
   FG_SYSCHAR = 0x4000000   //  Punctuation marks 
   FG_STRING = 0x1F0000   //  String 
   FG_MACRO = 0x5000000   //  Macro identifier $name 
   FG_OPERCHAR = 0x1000000   //  Operations 
   FG_NAME = 0xB0000   //  Name identifier 
   FG_SPACE = 0x50000   //  Space characters 
   FG_MACROSTR = 0x1E0000   //  Macro string $"String" 
   FG_LINECOMMENT = 0xA0000   //  Comment //...  
   FG_TAB = 0x60000   //  Tab characters 

   // Keywords
   KEY_AS = 0x1
   KEY_BREAK = 0x2
   KEY_CASE = 0x3
   KEY_CONTINUE = 0x4
   KEY_DEFAULT = 0x5
   KEY_DEFINE = 0x6
   KEY_DO = 0x7
   KEY_ELIF = 0x8
   KEY_ELSE = 0x9
   KEY_EXTERN = 0xA
   KEY_FOR = 0xB
   KEY_FOREACH = 0xC
   KEY_FORNUM = 0xD
   KEY_FUNC = 0xE
   KEY_GLOBAL = 0xF
   KEY_GOTO = 0x10
   KEY_IF = 0x11
   KEY_IFDEF = 0x12
   KEY_IMPORT = 0x13
   KEY_INCLUDE = 0x14
   KEY_LABEL = 0x15
   KEY_METHOD = 0x16
   KEY_OF = 0x17
   KEY_OPERATOR = 0x18
   KEY_PRIVATE = 0x19
   KEY_PROPERTY = 0x1A
   KEY_PUBLIC = 0x1B
   KEY_RETURN = 0x1C
   KEY_SWITCH = 0x1D
   KEY_SUBFUNC = 0x1E
   KEY_TYPE = 0x1F
   KEY_WHILE = 0x20
   KEY_TEXT = 0xFF
   KEY_ARR = 0x100
   KEY_BUF = 0x101
   KEY_BYTE = 0x102
   KEY_DOUBLE = 0x103
   KEY_FLOAT = 0x104
   KEY_HASH = 0x105
   KEY_INT = 0x106
   KEY_LONG = 0x107
   KEY_SHORT = 0x108
   KEY_STR = 0x109
   KEY_UBYTE = 0x10A
   KEY_UINT = 0x10B
   KEY_ULONG = 0x10C
   KEY_USHORT = 0x10D

} 

global
{
   buf lexfgentee =
} 

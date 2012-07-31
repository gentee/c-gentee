/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project <http://www.gentee.com>.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* msglist_h 19.03.2008 0.0.A.
*
* Author: Generated with 'msglist' program
*
* Summary: This file contains a list of the compiler's or VM's messages.
*
******************************************************************************/

#ifndef _MSGLIST_
#define _MSGLIST_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "../common/types.h"

extern char* msgtext[];

#define  MSGCOUNT  77

enum {
   MLoad,  // 0x0 0 Loading a file for compiling
   MStart,  // 0x1 1 Start compiling process
   MEnd,  // 0x2 2 End compiling process
   MNotGE,  // 0x3 3 This is not GE execute code!
   MCrcGE,  // 0x4 4 Wrong CRC of GE execute code!
   MVerGE,  // 0x5 5 This GE version is not supported.
   MUnkGE,  // 0x6 6 Unknown GE command!
   MFileopen,  // 0x7 7 Cannot create/open a file
   MFileread,  // 0x8 8 Cannot read a file
   MFilewrite,  // 0x9 9 Cannot write a file
   MFullstack,  // 0xA 10 The stack is full
   MNameexist,  // 0xB 11 Object with the same name has already existed
   MUndefcmd,  // 0xC 12 Empty bytecode command
   MUnkbcode,  // 0xD 13 Unknown bytecode command
   MAsleft,  // 0xE 14 Unacceptable variable.
   MAsright,  // 0xF 15 Unacceptable type.
   MAttrval,  // 0x10 16 The attribute requires a value
   MCountpars,  // 0x11 17 The count of parameters is wrong
   MDblname,  // 0x12 18 Variable with the such name '%s' has already been defined
   MDiftypes,  // 0x13 19 The type of the variable is different from the type of the object's item.
   MExpcomma,  // 0x14 20 A comma must be here
   MExpline,  // 0x15 21 Must be a new line here
   MExplogic,  // 0x16 22 A logic expression must be here
   MExplvalue,  // 0x17 23 The operand must be l-value
   MExpmuch,  // 0x18 24 The expression is too much
   MExpname,  // 0x19 25 Must be the name of the identifier here
   MExpnonull,  // 0x1A 26 The expression must return value.
   MExpoper,  // 0x1B 27 The name of the operator is wrong
   MExppoint,  // 0x1C 28 Must be the dot '.' here
   MExptype,  // 0x1D 29 Must be the name of the type here
   MExpopenbr,  // 0x1E 30 Syntax error. There is not left parenthesis or bracket
   MExpclosebr,  // 0x1F 31 Syntax error. There is not right parenthesis or bracket
   MRcurly,  // 0x20 32 Must be the right curly here
   MExpuint,  // 0x21 33 The expression must return 'uint' value
   MExpwhile,  // 0x22 34 Keyword 'while' must be here
   MInherit,  // 0x23 35 Cannot inherit from the specified type
   MLcurly,  // 0x24 36 Must be the left curly here
   MLongname,  // 0x25 37 The name of the identifier is too long
   MLoopcmd,  // 0x26 38 This command can be used in 'for', 'while' operators
   MMainpar,  // 0x27 39 Main or Entry function must not have parameters
   MMustoper,  // 0x28 40 Must be an operand here
   MMustret,  // 0x29 41 'return' must be in the function
   MMuststr,  // 0x2A 42 Must be a string value here
   MNoaddrfunc,  // 0x2B 43 There are some functions with such name
   MNofield,  // 0x2C 44 There is not the such field in the structure
   MNokeyword,  // 0x2D 45 It is impossible to use keyword here
   MNotattrib,  // 0x2E 46 There is not such attribute
   MNotopenbr,  // 0x2F 47 There is not a left parenthesis or bracket
   MOftype,  // 0x30 48 This type cannot be specified with 'of' operator
   MParquest,  // 0x31 49 The types of parameters in '?' operator must be same
   MPropfield,  // 0x32 50 The property cannot have the same name as the field
   MProppar,  // 0x33 51 The count of parameters is wrong in the 'property'
   MPropoper,  // 0x34 52 Unacceptable operator for 'property'
   MQuest,  // 0x35 53 The count of parameters in '?' operator is wrong
   MRedeflabel,  // 0x36 54 Label has already been defined
   MRefield,  // 0x37 55 This field name has already been defined
   MResulttype,  // 0x38 56 Result function (method) cannot return a numeric type
   MRettype,  // 0x39 57 The type of the return value is different from the definition
   MSyntax,  // 0x3A 58 Syntax error
   MSublevel,  // 0x3B 59 
   MTypepars,  // 0x3C 60 The value has the different type from the definition of the function
   MUndefmacro,  // 0x3D 61 Undefined macroname
   MUneof,  // 0x3E 62 Unexpected end of file found in expression or operator
   MUneofsb,  // 0x3F 63 Unexpected end of the string or binary data
   MUnexpoper,  // 0x40 64 Unexpected operand in the expression
   MUnkbinch,  // 0x41 65 Unknown character in binary data
   MUnkcmd,  // 0x42 66 Unknown Gentee command
   MUnklabel,  // 0x43 67 Label was not defined
   MUnklex,  // 0x44 68 Unknown lexem.
   MUnkname,  // 0x45 69 Unknown name of the identifier
   MUnkoper,  // 0x46 70 Function for this operation or method was not defined!
   MUnkprop,  // 0x47 71 There is not the such 'property'
   MUnksbcmd,  // 0x48 72 Unknown string or binary command
   MUnsmoper,  // 0x49 73 Unsupported macro operation or inadmissible macro types
   MVarstr,  // 0x4A 74 The variable must have 'str' type
   MVaruint,  // 0x4B 75 The variable must have 'uint' type
   MWrongname,  // 0x4C 76 Unacceptable name of the identifier or the macro

};

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _MSGLIST_

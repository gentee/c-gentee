/******************************************************************************
*
* Copyright (C) 2006-08, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

#ifndef _COMPILE_
#define _COMPILE_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "../os/user/defines.h"
#include "../lex/lex.h"
#include "../common/arrdata.h"

#define  STACK_OPERS 0xFFFF 
#define  STACK_OPS   0xFFFF
#define  STACK_PARS  0xFFFF

/*-----------------------------------------------------------------------------
* Id: compileflags D
* 
* Summary: Flags for gentee_compile function.
*
-----------------------------------------------------------------------------*/

#define CMPL_SRC    0x0001   // Specify if compileinfo.input is Gentee source
#define CMPL_NORUN  0x0002   // Don't run anything after the compilation.
#define CMPL_GE     0x0004   // Create GE file
#define CMPL_LINE   0x0010   // Proceed #! at the first string
#define CMPL_DEBUG  0x0020   // Compilation with the debug information
#define CMPL_THREAD 0x0040   // Compilation in the thread
#define CMPL_NOWAIT 0x0080   // Do not wait for the end of the compilation. /
                             // Use with CMPL_THREAD only.
#define CMPL_OPTIMIZE 0x0100 // Optimize the output GE file.
#define CMPL_NOCLEAR  0x0200 // Do not clear existing objects in the virtual /
                             // machine.
#define CMPL_ASM      0x0400 // Convert the bytecode to assembler code.

//#define CMPL_DEFARG 0x0008   // Define arguments

/*-----------------------------------------------------------------------------
* Id: optiflags D
* 
* Summary: Flags for optimize structure.
*
-----------------------------------------------------------------------------*/

#define  OPTI_DEFINE  0x0001   // Delete 'define' objects.
#define  OPTI_NAME    0x0002   // Delete names of objects.
#define  OPTI_AVOID   0x0004   // Delete not used objects.
#define  OPTI_MAIN    0x0008   // Leave only one main function with OPTI_AVOID.

/*-----------------------------------------------------------------------------
* Id: toptimize T optimize
* 
* Summary: The structure for the using in $[compileinfo] structure.
*
-----------------------------------------------------------------------------*/

typedef struct
{
   uint     flag;    // Flags of the optimization. $$[optiflags]
   pubyte   nameson; // Don't delete names with the following wildcards /
                     // divided by 0 if OPTI_NAME specified
   pubyte   avoidon; // Don't delete objects with the following wildcards /
                     // divided by 0 if OPTI_AVOID specified
} optimize, * poptimize;

/*-----------------------------------------------------------------------------
* Id: compileinfo T
* 
* Summary: The structure for the using in $[gentee_compile] function.
*
-----------------------------------------------------------------------------*/

typedef struct
{
   pubyte  input;     // The Gentee filename. You can specify the Gentee      /
                      // source if the flag CMPL_SRC is defined.
   uint    flag;      // Compile flags. $$[compileflags]
   pubyte  libdirs;   // Folders for searching files: name1 0 name2 0 ... 00. /
                      // It may be NULL.
   pubyte  include;   // Include files: name1 0 name2 0 ... 00. These files   /
                      // will be compiled at the beginning of the compilation /
                      // process. It may be NULL.
   pubyte  defargs;   // Define arguments: name1 0 name2 0 ... 00. You can    /
                      // specify additional macro definitions. For example,   /
                      // #b( MYMODE = 10 ). In this case, you can use         /
                      // #b( $MYMODE ) in the Gentee program. It may be NULL.
   pubyte  output;    // Ouput filename for GE. In default, .ge file is created /
                      // in the same folder as .g main file. You can specify    /
                      // any path and name for the output bytecode file. You    /
                      // must specify CMPL_GE flag to create the bytecode file.
   pvoid   hthread;   // The result handle of the thread if you specified    /
                      // CMPL_THREAD | CMPL_NOWAIT. 
   uint    result;    // Result of the program if it was executed.
   optimize  opti;    // Optimize structure. It is used if flag CMPL_OPTIMIZE /
                      // is defined.
} compileinfo, * pcompileinfo;

/*-----------------------------------------------------------------------------
*
* ID: compilefile 19.10.06 0.0.A.
* 
* Summary: compilefile structure.
*
-----------------------------------------------------------------------------*/

typedef struct
{
   pstr      filename; // The current compiling filename
   pstr      src;      // The current source text
   uint      off;      // Parsing offset from the beginning
   parr      lexems;   // Array of lexem
   uint      pos;      // The current position ( for include )
   uint      idfirst;  // The first id ( == count of VM identifier )
   uint      priv;     // The private or public mode
} compilefile, * pcompilefile;

/*-----------------------------------------------------------------------------
*
* ID: compile 26.10.06 0.0.A.
* 
* Summary: compile structure.
*
-----------------------------------------------------------------------------*/

typedef struct
{
   uint          flag;   // Compile flags
   lex           ilex;   // Lexical processing structure
   arrdata       libdirs;  // Array of folders for searching
   hash          files;    // Hash of the compiled filenames
   hash          names;    // Hash of the identifier names
   hash          opers;    // Hash of operators
   hash          macros;   // Hash of macros
   hash          namedef;  // Hash of macros without '$'
   hash          resource; // Hash of resource strings
   arrdata       string;   // Array of strings
   arrdata       binary;   // Array of binary data
   pcompilefile  cur;      // The current compiling settings
   pvoid         stkopers; // Stack operations
   pvoid         stkops;   // Stack operands
   pvoid         stkpars;  // Stack parameters
   pvoid         stkmopers; // Stack operations
   pvoid         stkmops;   // Stack operands
   buf           out;      // output for bytecode
   pbuf          pout;     // The current output buffer
   poptimize     popti;    // Pointer to the $[toptimize] structure.
   pstr          curdir;   // The current directory before compiling
} compile, * pcompile;

//--------------------------------------------------------------------------

uint  DLL_EXPORT STDCALL gentee_compile( pcompileinfo compinit );
uint  STDCALL compile_process( pstr filename );


//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _COMPILE_

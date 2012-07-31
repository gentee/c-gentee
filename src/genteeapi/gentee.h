/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov (gentee)
*
******************************************************************************/

#ifndef _GENTEE_
#define _GENTEE_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

//--------------------------------------------------------------------------

#include "../common/str.h"
#include "../vm/vm.h"
#include "../compiler/compile.h"

/*-----------------------------------------------------------------------------
* Id: setpars D
* 
* Summary: States for gentee_set function.
*
-----------------------------------------------------------------------------*/

#define GSET_TEMPDIR  0x0001  // Specify the custom temporary directory
#define GSET_PRINT    0x0002  // Specify the custom print function
#define GSET_MESSAGE  0x0003  // Specify the custom message function
#define GSET_EXPORT   0x0004  // Specify the custom export function
#define GSET_ARGS     0x0005  // Specify the command-line arguments
#define GSET_FLAG     0x0006  // Specify flags 
#define GSET_DEBUG    0x0007  // Specify the custom debug function
#define GSET_GETCH    0x0008  // Specify the custom getch function

/*-----------------------------------------------------------------------------
* Id: ptrpars D
* 
* Summary: States for gentee_ptr function.
*
-----------------------------------------------------------------------------*/

#define GPTR_GENTEE   0x0001  // Pointer to gentee structure. See $[tgentee].
#define GPTR_VM       0x0002  // Pointer to vm structure
#define GPTR_COMPILE  0x0003  // Pointer to compile structure
#define GPTR_CALL     0x0004  // Pointer to gentee_call function

/*-----------------------------------------------------------------------------
* Id: geloadflag D
* 
* Summary: Flags for gentee_load function.
*
-----------------------------------------------------------------------------*/

#define GLOAD_ARGS    0x0001  // Get command line arguments
#define GLOAD_FILE    0x0002  // Read file to load the bytecode. The bytecode /
                              // is name of the loading file
#define GLOAD_RUN     0x0004  // Load #lgt(entry) functions and run #lgt(main) /
                              // function.

/*-----------------------------------------------------------------------------
* Id: initflags D
* 
* Summary: Flags for gentee_init and gentee.flags structure.
*
-----------------------------------------------------------------------------*/

#define G_CONSOLE  0x0001   // Console application.
#define G_SILENT   0x0002   // Don't display any service messages.
#define G_CHARPRN  0x0004   // Print Windows characters.
#define G_ASM      0x0008   // Run-time converting a bytecode to assembler.
#define G_TMPRAND  0x0010   // Random name of t temporary directory.

/*-----------------------------------------------------------------------------
* Id: getidflag D
* 
* Summary: Flags for gentee_getid
*  
-----------------------------------------------------------------------------*/

#define GID_ANYOBJ  0x01000000   // Find any object

/*-----------------------------------------------------------------------------
*
* ID: functype 25.10.06 0.0.A.
* 
* Summary: The function types
*  
-----------------------------------------------------------------------------*/

typedef uint  (STDCALL* messagefunc)( pmsginfo );
typedef void  (STDCALL* printfunc)( pubyte, uint );
typedef uint  (STDCALL* getchfunc)( pubyte, uint );
typedef void* (STDCALL* exportfunc)( pubyte );
typedef void  (STDCALL* debugfunc)( pstackpos );

/*-----------------------------------------------------------------------------
* Id: tgentee T gentee
* 
* Summary: The main structure of gentee engine.
*
-----------------------------------------------------------------------------*/

typedef struct {
   uint         flags;      // Flags. $$[initflags]
   uint         multib;     // 1 if the current page is two-bytes code page
   uint         tempid;     // The indetifier of the temporary directory.
   str          tempdir;    // The temporary directory
   uint         tempfile;   // The handle of the file for locking tempdir
   printfunc    print;      // The custom print function
   getchfunc    getch;      // The custom getch and scan function
   messagefunc  message;    // The custom message function
   exportfunc   export;     // The custom export function 
   debugfunc    debug;      // The custom debug function
   pubyte       args;       // Command -line arguments. arg1 0 arg2 00
} gentee, *pgentee;

//--------------------------------------------------------------------------

extern gentee    _gentee;
extern pcompile  _compile;    // The pointer to compile structure

//--------------------------------------------------------------------------
#ifdef BUILD_DLLRT
  #undef DLL_EXPORT
  #define DLL_EXPORT __declspec(dllexport)
#endif

uint  DLL_EXPORT STDCALL gentee_deinit( void );
uint  DLL_EXPORT STDCALL gentee_init( uint flags );
uint  DLL_EXPORT STDCALL gentee_set( uint state, pvoid val );
pvoid DLL_EXPORT STDCALL gentee_ptr( uint par );
uint  DLL_EXPORT STDCALL gentee_load( pubyte bytecode, uint flag );
uint  DLL_EXPORT CDECLCALL gentee_call( uint id, puint result, ... );
uint  DLL_EXPORT CDECLCALL gentee_getid( pubyte name, uint count, ... );

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _GENTEE_
/******************************************************************************
*
* Copyright (C) 2004-2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

define
{
   GSET_TEMPDIR  = 0x0001  // Specify the custom temporary directory
   GSET_PRINT    = 0x0002  // Specify the custom print function
   GSET_MESSAGE  = 0x0003  // Specify the custom message function
   GSET_EXPORT   = 0x0004  // Specify the custom export function
   GSET_ARGS     = 0x0005  // Specify the command-line arguments
   GSET_FLAG     = 0x0006  // Specify flags 
   GSET_DEBUG    = 0x0007  // Specify the custom debug function
   GSET_GETCH    = 0x0008  // Specify the custom getch function

   CMPL_SRC    = 0x0001   // If compileinfo.input is Gentee source
   CMPL_NORUN  = 0x0002   // Don't run after compiling
   CMPL_GE     = 0x0004   // Create GE file
   CMPL_DEFARG = 0x0008   // Define arguments
   CMPL_LINE   = 0x0010   // Proceed #! at the first string
   CMPL_DEBUG  = 0x0020   // Compilation with the debug information
   CMPL_THREAD = 0x0040   // Compilation in the thread
   CMPL_NOWAIT = 0x0080   // Do not wait for the end of the compilation. /
                          // Use with CMPL_THREAD only.
   CMPL_OPTIMIZE = 0x0100 // Optimize the output GE file
   CMPL_NOCLEAR  = 0x0200 // Do not clear existing objects in the virtual /
                          // machine.
   CMPL_ASM      = 0x0400 // Convert bytecode to assembler

   OPTI_DEFINE   = 0x0001   // Delete 'define' objects.
   OPTI_NAME     = 0x0002   // Delete names of objects.
   OPTI_AVOID    = 0x0004   // Delete no used objects.
   OPTI_MAIN     = 0x0008   // Leave only one main function with OPTI_AVOID.

   G_CONSOLE = 0x0001   // Console application.
   G_SILENT  = 0x0002   // Don't display any service messages.
   G_CHARPRN = 0x0004   // Print Windows characters.
   G_ASM     = 0x0008   // Run-time converting a bytecode to assembler.
   G_TMPRAND = 0x0010   // Random name of t temporary directory.
}

type optimize
{
   uint     flag     // Flags of the optimization. $$[optiflags]
   uint     nameson  // Don't delete names with the following wildcards /
                     // divided by 0 if OPTI_NAME specified
   uint     avoidon  // Don't delete objects with the following wildcards /
                     // divided by 0 if OPTI_AVOID specified
}

type compileinfo
{
   uint    input      // Gentee source or filename 
   uint    flag       // Compile flags
   uint    includes   // folders for searching files  name 0 name 00
   uint    libs       // include files  name 0 name 00
   uint    defargs    // define arguments  name 0 name 00
   uint    output     // Ouput filename for GE
   uint    hthread    // The result handle of the thread if you specified    /
                      // CMPL_THREAD | CMPL_NOWAIT. 
   uint    result     // Result of the program if it was executed.
   optimize opti      // Optimize structure. It is used if flag CMPL_OPTIMIZE /
                      // is defined.
}

type gcompileinfo
{
   str     input      // Gentee source or filename 
   uint    flag       // Compile flags
   arrstr  includes   // folders for searching files  name 0 name 00
   arrstr  libs       // include files  name 0 name 00
   arrstr  defargs    // define arguments  name 0 name 00
   arrstr  args       // Command line arguments
   str     output     // Ouput filename for GE or EXE
   uint    hthread    // The result handle of the thread if you specified    /
                      // CMPL_THREAD | CMPL_NOWAIT. 
   uint    result     // Result of the program if it was executed.
   uint    optiflag   // Flags of the optimization. $$[optiflags]
   arrstr  nameson    // Don't delete names with the following wildcards /
                      // if OPTI_NAME specified
   arrstr  avoidon    // Don't delete objects with the following wildcards /
                      // divided by 0 if OPTI_AVOID specified
}

func uint compile_arrs( arrstr input, buf output )
{
   uint i
   
   output.clear()
   if *input
   {
      fornum i, *input
      { 
         output.append( input[ i ].ptr(), *input[ i ] + 1 )
      }
   }
   output += ubyte( 0 )
   return 1
}

func  compile_file( gcompileinfo gcinfo )
{
   compileinfo  cmpl
   buf          includes libs defargs nameson args avoidon
   
   cmpl.input = gcinfo.input.ptr()
   cmpl.flag = gcinfo.flag//$CMPL_NORUN | $CMPL_GE
   
   compile_arrs( gcinfo.includes, includes ) 
   cmpl.includes = includes.ptr()
   
   compile_arrs( gcinfo.libs, libs ) 
   cmpl.libs = libs.ptr()
   
   compile_arrs( gcinfo.defargs, defargs ) 
   cmpl.defargs = defargs.ptr()

   compile_arrs( gcinfo.args, args ) 
   gentee_set( $GSET_ARGS, args.ptr())
   
   cmpl.output = gcinfo.output.ptr()
   
   cmpl.opti.flag = gcinfo.optiflag
   compile_arrs( gcinfo.nameson, nameson ) 
   cmpl.opti.nameson = nameson.ptr()

   compile_arrs( gcinfo.avoidon, avoidon ) 
   cmpl.opti.avoidon = avoidon.ptr()
   
   gentee_compile( &cmpl )      
}


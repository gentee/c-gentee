/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

/*-----------------------------------------------------------------------------
* Id: process L "Process"
* 
* Summary: Process, shell, arguments and environment functions.
*
* List: *,argc,argv,exit,getenv,processf,setenv,shell  
* 
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: processf F process
*
* Summary: Starting a process.  
*  
* Params: cmdline - The command line. 
          workdir - The working directory. It can be 0-&gt;str. 
          result - The pointer to uint for getting the result. If #b(0), the /
          function will not wait until the process finishes its work. 
* 
* Return: #b(1) if the calling process was successful; otherwise #b(0). 
*
-----------------------------------------------------------------------------*/

func uint process( str cmdline, str workdir, uint result, uint state )
{
   PROCESS_INFORMATION  stpi
   STARTUPINFO          start
   uint                 handle

   start.cb = sizeof( STARTUPINFO )
   if state != $SW_SHOWNORMAL
   {
      start.wShowWindow = state
      start.dwFlags = 1 //$STARTF_USESHOWWINDOW
   }
   handle = CreateProcess( 0, cmdline.ptr( ), 0, 0, 1,
                     $CREATE_DEFAULT_ERROR_MODE | $NORMAL_PRIORITY_CLASS, 
                     0, ?( workdir && *workdir, workdir.ptr(), 0 ), 
                     start, stpi )
   if !handle && GetLastError( ) == 740 //ERROR_ELEVATION_REQUIRED
   {
/*      if ( ShellExecute( 0, "runas".ptr(), cmdline.ptr(), 0, 
               ?( workdir && *workdir, workdir.ptr(), 0 ), $SW_SHOWNORMAL ))
      {
         return 1
      }*/ 
      SHELLEXECUTEINFO shex
      str              filename params
      uint             off
      
      if cmdline[0] == '"'
      { 
         off = cmdline.findchfrom( '"', 1 )
         filename.substr( cmdline, 1, off - 1 )
         params.substr( cmdline, off + 1, *cmdline - off - 1 )
      }
      else
      {
         off = cmdline.findchfrom( ' ', 0 )
         filename.substr( cmdline, 0, off )
         params.substr( cmdline, off + 1, *cmdline - off - 1 )
      }
      shex.cbSize = sizeof( SHELLEXECUTEINFO )
//      shex.fMask = 0
//         shex.hwnd = NULL;
      shex.lpVerb = "runas".ptr()
      shex.lpFile = filename.ptr()
      shex.lpParameters = ?( *params, params.ptr(), 0 )
      shex.lpDirectory = ?( workdir && *workdir, workdir.ptr(), 0 )
      shex.nShow = state;
      return ShellExecuteEx( shex )
   }
   if handle                     
   {
      if result 
      {
         WaitForSingleObject( stpi.hThread, $INFINITE )
         GetExitCodeProcess( stpi.hProcess, result )
      }
      CloseHandle( stpi.hThread )
      CloseHandle( stpi.hProcess )
      return 1
   }
   return 0
}

func uint process( str cmdline, str workdir, uint result )
{
   return process( cmdline, workdir, result, $SW_SHOWNORMAL )
}

/*-----------------------------------------------------------------------------
* Id: shell F
*
* Summary: Launch or open a file in the associated application.  
*  
* Params: name - Filename. 
* 
-----------------------------------------------------------------------------*/

func shell( str name )
{
   ShellExecute( 0, "open".ptr(), name.ptr(), 0, 0, $SW_SHOWNORMAL )
}

/*-----------------------------------------------------------------------------
* Id: exit F
*
* Summary: Exit the current program.  
*  
* Params: code - A return code or the results of the work of the program. 
* 
-----------------------------------------------------------------------------*/

func exit( uint code )
{
   ExitProcess( code )
}

/*-----------------------------------------------------------------------------
* Id: getenv F 
*
* Summary: Get an environment variable.
*  
* Params: varname - Environment variable name. 
          ret - String for getting the value. 
* 
* Return: #lng/retpar( ret ) 
*
-----------------------------------------------------------------------------*/

func str getenv( str varname, str ret )
{
   uint ptr
   
   ret.clear()
   if ptr = _getenv( varname.ptr())
   {
      ret.copy( ptr )
   }
   return ret   
}

/*-----------------------------------------------------------------------------
* Id: setenv F 
*
* Summary: Set a value of an environment variable. The function adds new
           environment variable or modifies the value of the existing
           environment variable. New values will be valid only in the 
           current process. 
*  
* Params: varname - Environment variable name. 
          varvalue - A new value of the environment variable. 
* 
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

func uint setenv( str varname, str varvalue )
{
   return ?( _setenv( "\(varname)=\(varvalue)".ptr()), 0, 1 )   
}


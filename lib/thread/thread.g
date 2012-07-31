/******************************************************************************
*
* Copyright (C) 2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS  FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

/*-----------------------------------------------------------------------------
* Id: thread L "Thread"
* 
* Summary: This library allows you to create threads and work with them. 
           The methods described above are applied to variables of the 
           #b(thread) type. For using this library, it is required to specify
           the file thread.g (from lib\thread
           subfolder) with include command. #srcg[
|include : $"...\gentee\lib\thread\thread.g"]    
*
* List: *#lng/methods#,thread_create,thread_getexitcode,thread_isactive,
        thread_resume,thread_suspend,thread_terminate,thread_wait, 
        *#lng/funcs#,exitthread,sleep
* 
-----------------------------------------------------------------------------*/

define <export>
{
   STILL_ACTIVE = 0x00000103
   INFINITE     = 0xFFFFFFFF
   WAIT_FAILED  = 0xFFFFFFFF
}

type thread 
{
   uint handle
   uint pmem
}

import "kernel32.dll"
{
   uint CreateThread( uint, uint, uint, uint, uint, uint )
        ExitThread( uint )
   uint GetExitCodeThread( uint, uint )
   uint GetTickCount()
   uint ResumeThread( uint )
        Sleep( uint )
   uint SuspendThread( uint )
   uint TerminateThread( uint, uint )
   uint WaitForSingleObject( uint, uint )
}

extern 
{
   method uint thread.isactive()
   method uint thread.terminate()
   method uint thread.delete()
}

/*-----------------------------------------------------------------------------
* Id: exitthread F
* 
* Summary: Exiting the current thread.
*  
* Params: code - Thread exit code.
*
-----------------------------------------------------------------------------*/

func exitthread( uint code )
{
   ExitThread( code )
}

/*-----------------------------------------------------------------------------
* Id: thread_create F2
* 
* Summary: Create a thread.
*  
* Params: idfunc - The pointer to the function that will be called as a new /
                   thread. The function must have one parameter. You can get /
                   the pointer using the operator &. 
          param - Additional parameter. 
*
* Return: The handle of the created thread is returned. It returns 0 in case 
          of an error.
*
-----------------------------------------------------------------------------*/

method uint thread.create( uint idfunc, uint param )
{
   uint  id
   
   if .isactive()
   {  
      return 0
   }
   .delete()
   
   .pmem = callback( idfunc, 1 )
   
//   return this.handle = createthread( .pmem, idfunc, param )
   return .handle = CreateThread( 0, 0, .pmem, param, 0, &id )
}

method thread.delete
{
   if .pmem
   { 
      freecallback( .pmem )
      .pmem = 0
   }
}

/*-----------------------------------------------------------------------------
* Id: thread_isactive F3
* 
* Summary: Checking if a thread is active.
*  
* Return: Returns 1 if the thread is active and 0 otherwise.
*
-----------------------------------------------------------------------------*/

method uint thread.isactive()
{
   uint result

   if GetExitCodeThread( this.handle, &result )
   {
      return result == $STILL_ACTIVE 
   }
   return 0
}

/*-----------------------------------------------------------------------------
* Id: thread_getexitcode F2
* 
* Summary: Get the thread exit code.
*  
* Params: result - The pointer to a variable of the uint type the thread exit /
                   code will be written to. If the thread is still active, /
                   the value $STILL_ACTIVE will be written. 
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint thread.getexitcode( uint result )
{
   return GetExitCodeThread( this.handle, result )
}

/*-----------------------------------------------------------------------------
* Id: thread_resume F3
* 
* Summary: Resuming a thread. Resume a thread paused with the 
           #a(thread_suspend ) method.
*  
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint thread.resume()
{
   return ResumeThread( this.handle ) != 0xFFFFFFFF
}

/*-----------------------------------------------------------------------------
* Id: thread_suspend F3
* 
* Summary: Stop a thread.
*  
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint thread.suspend()
{
   return SuspendThread( this.handle ) != 0xFFFFFFFF
}

/*-----------------------------------------------------------------------------
* Id: thread_terminate F2
* 
* Summary: Terminating a thread.
*  
* Params: code - Thread termination code. 
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint thread.terminate( uint code )
{
   this.delete()
   return TerminateThread( this.handle, code )
}

/*-----------------------------------------------------------------------------
* Id: sleep F
* 
* Summary: Pause the current thread for the specified time. 
*  
* Params: msec - The time for pausing the thread in milliseconds.  
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

func sleep( uint msec )
{
   Sleep( msec )
}

/*-----------------------------------------------------------------------------
* Id: thread_wait F3
* 
* Summary: Waiting till a thread is exited.
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint thread.wait()
{
   return WaitForSingleObject( this.handle, $INFINITE ) != $WAIT_FAILED
}

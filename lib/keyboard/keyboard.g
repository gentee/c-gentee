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

/*-----------------------------------------------------------------------------
* Id: keyboard L "Keyboard"
* 
* Summary: These functions are used to emulate the work of the keyboard. 
           For using this library, it is
           required to specify the file keyboard.g (from lib\keyboard
           subfolder) with include command. #srcg[
|include : $"...\gentee\lib\keyboard\keyboard.g"]   
*
* List: *,sendstr,sendvkey
* 
-----------------------------------------------------------------------------*/

define <export>
{
   INPUT_MOUSE     = 0
   INPUT_KEYBOARD  = 1 
   INPUT_HARDWARE  = 2
/*-----------------------------------------------------------------------------
* Id: keycontrols D
* 
* Summary: Key controls.
*
-----------------------------------------------------------------------------*/
   SVK_SHIFT       = 0x0001      // #b(Shift) is pressed.
   SVK_ALT         = 0x0002      // #b(Alt) is pressed.
   SVK_CONTROL     = 0x0004      // #b(Ctrl) is pressed.
   
//-----------------------------------------------------------------------------
   
   KEYEVENTF_EXTENDEDKEY = 0x0001
   KEYEVENTF_KEYUP       = 0x0002
   KEYEVENTF_UNICODE     = 0x0004
   KEYEVENTF_SCANCODE    = 0x0008
   
   VK_BACK          = 0x08
   VK_TAB           = 0x09

   VK_CLEAR         = 0x0C
   VK_RETURN        = 0x0D

   VK_SHIFT         = 0x10
   VK_CONTROL       = 0x11
   VK_MENU          = 0x12
   VK_PAUSE         = 0x13
   VK_CAPITAL       = 0x14
   VK_ESCAPE        = 0x1B
   
   VK_SPACE          = 0x20
   VK_PRIOR          = 0x21
   VK_NEXT           = 0x22
   VK_END            = 0x23
   VK_HOME           = 0x24
   VK_LEFT           = 0x25
   VK_UP             = 0x26
   VK_RIGHT          = 0x27
   VK_DOWN           = 0x28
   VK_SELECT         = 0x29
   VK_PRINT          = 0x2A
   VK_EXECUTE        = 0x2B
   VK_SNAPSHOT       = 0x2C
   VK_INSERT         = 0x2D
   VK_DELETE         = 0x2E

   VK_F1             = 0x70
   VK_F2             = 0x71
   VK_F3             = 0x72
   VK_F4             = 0x73
   VK_F5             = 0x74
   VK_F6             = 0x75
   VK_F7             = 0x76
   VK_F8             = 0x77
   VK_F9             = 0x78
   VK_F10            = 0x79
   VK_F11            = 0x7A
   VK_F12            = 0x7B
}

type MOUSEINPUT 
{
   int    dx
   int    dy
   uint   mouseData
   uint   dwFlags
   uint   time
   uint   dwExtraInfo
}

type KEYBDINPUT 
{
   ushort    wVk
   ushort    wScan
   uint      dwFlags
   uint      time
   uint      dwExtraInfo
}

type HARDWAREINPUT 
{
   uint     uMsg
   ushort   wParamL
   ushort   wParamH
}

type INPUT {
   uint        typei
   MOUSEINPUT  mi
} 

import "user32.dll" {
   uint   GetKeyState( uint )
   uint   OemKeyScan( ushort )
   uint   SendInput( uint, uint, uint )
   ushort VkKeyScanA( uint ) -> VkKeyScan
}

func newkey( arr ain of INPUT, ushort vk, uint flag )
{
   uint i
   
   i = ain.expand( 1 )
   
   ain[ i ].typei = $INPUT_KEYBOARD
   ain[ i ].mi->KEYBDINPUT.wVk = vk
   ain[ i ].mi->KEYBDINPUT.dwFlags = flag
   ain[ i ].mi->KEYBDINPUT.time = 200
}

/*-----------------------------------------------------------------------------
* Id: sendvkey F
*
* Summary: Pressing a key. Press a key alone or together with 
           #b('Shift, Ctrl, Alt').
*
* Params: vkey - Virtual key code. 
          flag - Flags for pressing additional keys.$$[keycontrols]
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

func uint sendvkey( ushort vkey, uint flag )
{
   arr   ain of INPUT

   if flag & $SVK_SHIFT : newkey( ain, $VK_SHIFT, 0 )
   if flag & $SVK_ALT : newkey( ain, $VK_MENU, 0 )
   if flag & $SVK_CONTROL : newkey( ain, $VK_CONTROL, 0 )

   newkey( ain, vkey, 0 )
   newkey( ain, vkey, $KEYEVENTF_KEYUP )

   if flag & $SVK_SHIFT : newkey( ain, $VK_SHIFT, $KEYEVENTF_KEYUP )
   if flag & $SVK_ALT : newkey( ain, $VK_MENU, $KEYEVENTF_KEYUP )
   if flag & $SVK_CONTROL : newkey( ain, $VK_CONTROL, $KEYEVENTF_KEYUP )
   
   return SendInput( *ain, ain.ptr(), sizeof( INPUT ))
}

/*-----------------------------------------------------------------------------
* Id: sendstr F
*
* Summary: Types a string on the keyboard.
*
* Params: data - The string to be typed on the keyboard.     
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

func uint sendstr( str input )
{
   uint  i cur shift code capslock
   arr   ain of INPUT
   
   capslock = GetKeyState( $VK_CAPITAL ) & 0x01
   fornum i, *input
   {
//      if input[i] == 0x0D : continue
     
      cur = VkKeyScan( input[i] )
      shift = ( cur >> 8 ) & 0x01
      code = cur & 0xFF
      if capslock && code >= 'A' && code <= 'Z' : shift = !shift
                  
      if shift : newkey( ain, $VK_SHIFT, 0 )

      newkey( ain, code, 0 )
      newkey( ain, code, $KEYEVENTF_KEYUP )

      if shift : newkey( ain, $VK_SHIFT, $KEYEVENTF_KEYUP )
   }
   return SendInput( *ain, ain.ptr(), sizeof( INPUT ))    
}
